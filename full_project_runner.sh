#!/bin/bash
set -e
set -x  

echo "🚀 Starting full production-ready project automation..."

# ----------------- CONFIG --------------------
PROJECT_DIR=$(pwd)
VENV_DIR="$PROJECT_DIR/.venv"
AIRFLOW_HOME="$PROJECT_DIR/airflow"
DAGS_FOLDER="$AIRFLOW_HOME/dags"
LOG_DIR="$PROJECT_DIR/logs"
ENV_FILE="$PROJECT_DIR/.env"
OUTPUT_CSV="$PROJECT_DIR/data/processed/processed_output.csv"
NOTEBOOK_IN="$PROJECT_DIR/notebooks/dev_etl_demo.ipynb"
NOTEBOOK_OUT="$PROJECT_DIR/notebooks/dev_etl_demo.ipynb"

# OPTIONALS (ENABLE/DISABLE AS NEEDED)
ENABLE_AWS_UPLOAD=true
ENABLE_GITHUB_ACTIONS=true
ENABLE_ENV_ENCRYPTION=true
ENABLE_DEB_PACKAGE=true

# AWS CONFIG
AWS_S3_BUCKET="batch-etl-pyspark"
AWS_REGION="ap-south-1"


# Encryption
ENCRYPTION_TOOL="sops"  # or "git-crypt"

# ---------------------------------------------

mkdir -p "$LOG_DIR"
echo "📁 Logs saved to: $LOG_DIR"

# 1. Activate virtualenv
echo "✅ Activating virtual environment..."
if [ ! -d "$VENV_DIR" ]; then
  echo "📦 Creating virtual environment..."
  python3 -m venv "$VENV_DIR"
fi
source "$VENV_DIR/bin/activate"


# 1. Install requirements
echo "📦 Installing packages..."
pip install --upgrade pip >> "$LOG_DIR/pip_install.log" 2>&1
pip install -r requirements.txt >> "$LOG_DIR/pip_install.log" 2>&1
pip install apache-airflow-providers-papermill graphviz >> "$LOG_DIR/pip_install.log" 2>&1


# 3. .env validation
if [ ! -f "$ENV_FILE" ]; then
  echo "❌ .env file missing!"
  exit 1
fi
echo "✅ .env found. Validating..."
pip install dotenv-linter >> "$LOG_DIR/env_check.log" 2>&1
dotenv-linter "$ENV_FILE" >> "$LOG_DIR/env_check.log" 2>&1 || echo "⚠️ Check $LOG_DIR/env_check.log"

# 4. Kill existing Airflow
pkill -f "airflow scheduler" || true
pkill -f "airflow webserver" || true

# 5. Set Airflow vars
export AIRFLOW_HOME="$AIRFLOW_HOME"
export AIRFLOW__CORE__DAGS_FOLDER="$DAGS_FOLDER"
export AIRFLOW__CORE__LOAD_EXAMPLES=False

if [ ! -f "$AIRFLOW_HOME/airflow.db" ]; then
    echo "🧠 Initializing Airflow DB..."
    airflow db init >> "$LOG_DIR/airflow_db_init.log" 2>&1
fi

# 6. Start Airflow
airflow scheduler >> "$LOG_DIR/scheduler.log" 2>&1 &
sleep 5
airflow webserver -p 8086 >> "$LOG_DIR/webserver.log" 2>&1 &
echo "🌍 Airflow UI → http://localhost:8086"

# 7. Trigger DAG
echo "📤 Triggering DAG: ecommerce_etl..."
airflow dags trigger ecommerce_etl >> "$LOG_DIR/dag_trigger.log" 2>&1

# 8. Monitor DAG
RUN_DATE=$(date +%Y-%m-%dT%H:%M:%S)
UNIQUE_ID=$(uuidgen | cut -d'-' -f1)  # short unique string
RUN_ID="auto__${RUN_DATE}_${UNIQUE_ID}"

echo "📤 Triggering DAG: ecommerce_etl..."
airflow dags trigger ecommerce_etl --run-id "$RUN_ID" --exec-date "$RUN_DATE"

MAX_ATTEMPTS=30
COUNT=0

while true; do
  STATUS=$(airflow tasks state ecommerce_etl run_etl "$RUN_DATE")
  echo "$(date +%T) ➤ DAG Task Status: $STATUS" | tee -a "$LOG_DIR/dag_monitor.log"

  if [[ "$STATUS" == *success* ]]; then
    echo "✅ DAG completed successfully!" | tee -a "$LOG_DIR/dag_monitor.log"
    break
  elif [[ "$STATUS" == *failed* ]]; then
    echo "❌ DAG failed!" | tee -a "$LOG_DIR/dag_monitor.log"
    exit 1
  fi

  COUNT=$((COUNT+1))
  if [ "$COUNT" -ge "$MAX_ATTEMPTS" ]; then
    echo "⚠️ Timeout reached. Check Airflow manually."
    break
  fi
  sleep 10
done

# 9. Run notebook
# ------------------ PAPERMILL EXECUTION ------------------
# 👇 Kernel Fix
echo "🛠️  Ensuring correct kernel (python3) in notebook..."
sed -i 's/"name": *"powershell"/"name": "python3"/g' "$NOTEBOOK_IN"
sed -i 's/"display_name": *"PowerShell"/"display_name": "Python 3"/g' "$NOTEBOOK_IN"
echo "✅ Kernel fixed to python3 in: $NOTEBOOK_IN"

echo "📓 Running notebook with Papermill..."
papermill "$NOTEBOOK_IN" "$NOTEBOOK_OUT" >> "$LOG_DIR/papermill.log" 2>&1

if [ $? -ne 0 ]; then
    echo "❌ Notebook execution failed. Check $LOG_DIR/papermill.log"
    exit 1
fi

if [ -f "$OUTPUT_CSV" ]; then
    echo "✅ Notebook executed successfully!"
    echo "📘 Output saved to: $OUTPUT_CSV"
else
    echo "⚠️ Notebook ran, but no output file found at $OUTPUT_CSV"
    echo "⚠️ Skipping S3 upload and Power BI launch."
    exit 1
fi


# 10. Launch Power BI (Windows only)
if grep -qi microsoft /proc/version; then
    echo "📊 Opening Power BI..."
    powershell.exe -Command "Start-Process 'C:\\Program Files\\Microsoft Power BI Desktop\\bin\\PBIDesktop.exe' -ArgumentList '${OUTPUT_CSV//\//\\}'" >> "$LOG_DIR/powerbi.log" 2>&1
fi

# ✅ OPTIONAL SECTION
# -----------------------------------------

# ☁️ Deploy DAG to AWS S3
if [ "$ENABLE_AWS_UPLOAD" = true ]; then
    echo "☁️ Uploading DAGs to S3..."
    aws s3 cp "$DAGS_FOLDER" "s3://$AWS_S3_BUCKET/dags/" --recursive --region "$AWS_REGION" >> "$LOG_DIR/aws_upload.log" 2>&1
fi

# 🔁 Setup GitHub Actions (workflow file)
if [ "$ENABLE_GITHUB_ACTIONS" = true ]; then
    echo "🔁 Setting up GitHub Actions..."
    mkdir -p .github/workflows
    cat <<EOF > .github/workflows/ci.yml
name: ETL CI

on: [push]

jobs:
  build:
    runs-on: ubuntu-latest
    steps:
    - uses: actions/checkout@v3
    - name: Set up Python
      uses: actions/setup-python@v5
      with:
        python-version: '3.12'
    - name: Install dependencies
      run: |
        python -m venv .venv
        source .venv/bin/activate
        pip install -r requirements.txt
    - name: Run pytest
      run: |
        source .venv/bin/activate
        pytest
EOF
    echo "✅ GitHub Actions CI created at .github/workflows/ci.yml"
fi

# 🔒 Encrypt .env
if [ "$ENABLE_ENV_ENCRYPTION" = true ]; then
    echo "🔐 Encrypting .env with $ENCRYPTION_TOOL..."
    if [ "$ENCRYPTION_TOOL" = "sops" ]; then
        sops -e "$ENV_FILE" > "$ENV_FILE.enc"
    elif [ "$ENCRYPTION_TOOL" = "git-crypt" ]; then
        git-crypt init && git-crypt lock
    fi
fi

# 📦 Build .deb installer (Linux only)
if [ "$ENABLE_DEB_PACKAGE" = true ] && [[ "$OSTYPE" == "linux-gnu"* ]]; then
    echo "📦 Building .deb package..."
    mkdir -p pkg/DEBIAN
    cat <<EOF > pkg/DEBIAN/control
Package: batch-etl-pyspark
Version: 1.0
Architecture: all
Maintainer: Shivam Gupta
Description: Full PySpark ETL pipeline with Airflow and Power BI integration
EOF
    mkdir -p pkg/usr/local/bin
    cp full_project_runner.sh pkg/usr/local/bin/
    dpkg-deb --build pkg batch-etl-pyspark.deb >> "$LOG_DIR/deb_build.log" 2>&1
    echo "✅ .deb created: batch-etl-pyspark.deb"
fi

# ---------- Run Tests ----------
echo "🧪 Running unit tests with .env loaded..."
export $(grep -v '^#' .env | xargs)  # load env vars
pytest tests/ | tee "$LOG_DIR/pytest.log"


#---------- MkDocs Setup ----------
# 📘 MkDocs Site
if [ "$ENABLE_MKDOCS" = true ]; then
    echo "📘 Setting up MkDocs site..."
    mkdir -p docs
    cp "$README_FILE" docs/index.md
    cat <<EOF > mkdocs.yml
site_name: PySpark E-commerce ETL
repo_url: https://github.com/Github-SG03/batch-etl-pyspark
theme:
  name: material
nav:
  - Home: index.md
EOF
    mkdocs gh-deploy >> "$LOG_DIR/mkdocs_deploy.log" 2>&1
    echo "✅ MkDocs deployed at: https://Github-SG03.github.io/batch-etl-pyspark"
fi


✅ Final Summary

echo "✅ DONE!"
echo "📊 Airflow: http://localhost:8086"
echo "📁 CSV: $OUTPUT_CSV"
echo "📓 Notebook: $NOTEBOOK_OUT"
echo "🧪 Tests: $LOG_DIR/pytest.log"
echo "📘 Docs ready: 'https://Github-SG03.github.io/batch-etl-pyspark'"


---

##✅ Final Steps for You
##✅ Save this as `full_project_runner.sh`
##✅ Make executable:
##✅ Run it:
##chmod +x full_project_runner.sh
##./full_project_runner.sh