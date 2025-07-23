# 🛠️ PySpark E-Commerce ETL Project

![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)
![CI](https://github.com/<your-username>/<repo-name>/actions/workflows/ci.yml/badge.svg)
[![codecov](https://codecov.io/gh/<your-username>/<repo-name>/branch/main/graph/badge.svg)](https://codecov.io/gh/<your-username>/<repo-name>)
![Python](https://img.shields.io/badge/python-3.8+-blue.svg)
![PySpark](https://img.shields.io/badge/PySpark-3.5+-orange.svg)
![Security](https://img.shields.io/badge/security-disclosures-important.svg)

> A production-grade, **portfolio-ready PySpark batch ETL pipeline** for e-commerce analytics  
> Featuring modular ETL layers, CI/CD with GitHub Actions, Apache Airflow orchestration, testing, logging, notebook output, and Power BI visualization.

---

## 📦 Project Structure

```text
batch-etl-pyspark/
│
├── .github/workflows/ci.yml        # ✅ GitHub Actions (CI/CD)
├── airflow/                        # Airflow configs + DB
│   └── dags/
│       └── ecommerce_etl_dag.py    # Airflow DAG
├── data/
│   ├── input/                      # 📥 Raw CSVs (products, customers, orders)
│   └── processed/                  # 📤 Output after ETL
├── logs/                           # 🪵 Logs from scheduler, webserver, dag, etc.
├── notebooks/
│   └── dev_etl_demo.ipynb          # 📓 Papermill-executed analysis notebook
├── src/
│   ├── etl/
│   │   ├── extract.py              # extract_*() logic
│   │   ├── transform.py            # clean + join + derive metrics
│   │   └── load.py                 # write to CSV/parquet
│   └── utils/
│       └── spark_session.py        # SparkSession builder
├── tests/
│   ├── test_extract.py             # ✅ Unit test: extract
│   ├── test_transform.py           # ✅ Unit test: transform
│   ├── test_load.py                # ✅ Unit test: load
│   └── test_sales_metrics.py       # Optional metrics tests
├── .env                            # Configurable paths/secrets
├── .gitignore
├── LICENSE                         # MIT License
├── README.md                       # 🙌 You're reading it
├── requirements.txt                # All packages for local dev
├── full_project_runner.sh          # ⚙️ One-click launch script (Airflow + Notebook + Power BI)
└── pyproject.toml (optional)

⚙️ Features

    ✅ Modular PySpark-based ETL pipeline

    ✅ Airflow DAG orchestration + scheduling

    ✅ Papermill notebook execution (automated)

    ✅ Power BI integration (CSV → Desktop auto-launch)

    ✅ Environment management via .env

    ✅ Unit testing with pytest (extraction, transformation, loading)

    ✅ Logging: airflow, scheduler, notebook logs all tracked

    ✅ GitHub Actions-based CI (via ci.yml)

    ✅ One-command launcher (full_project_runner.sh) for demo/presentation

    ✅ Production-style repo structure — ready for interviews or GitHub Pages

🚀 Getting Started
1️⃣ Clone this Repository

git clone https://github.com/<your-username>/<repo-name>.git
cd <repo-name>

2️⃣ Set up Virtual Environment

python -m venv .venv
source .venv/bin/activate  # On Windows: .venv\Scripts\activate
pip install -r requirements.txt

3️⃣ Create .env File

OUTPUT_PATH=./data/processed/

4️⃣ Run Locally via PySpark

python src/main.py

5️⃣ Or Run Full Pipeline via Airflow

chmod +x full_project_runner.sh
./full_project_runner.sh

This will:

    Start Airflow scheduler + webserver

    Trigger the DAG

    Execute the Jupyter notebook

    Export CSV

    Auto-open Power BI with the result ✅

📈 Sample Output
Metric	Value
Total Orders	xxx
Revenue	₹xxx.xx
Top Customers	✅ ranked
Category Trend	📈 chart

📍 Output is saved to data/processed/processed_output.csv
📍 Notebook output: notebooks/dev_etl_demo_<date>.ipynb
🧪 Testing

pytest tests/

Includes:

    test_extract.py → Validates loading raw CSVs

    test_transform.py → Ensures derived metrics work

    test_load.py → Validates CSV write

    test_sales_metrics.py → Optional: business logic

🔁 CI/CD Integration

✅ GitHub Actions included via:

.github/workflows/ci.yml

Every push to main:

    Installs Python + dependencies

    Runs full test suite via pytest

    Fails build if any test fails

🔐 Security & Secrets

    .env manages all paths

    Add .env.example for team usage

    Optional encryption via git-crypt or sops

🧳 Project Resume Summary (Use for Portfolio)

    ✅ A complete, reproducible ETL + Analytics pipeline using PySpark
    🛠️ Designed for real-world batch processing
    📊 Integrated with Airflow, CI/CD, Power BI, and unit testing
    🎯 Ready to showcase in interviews and GitHub profile

🧠 Advanced Tips (Optional)

    Add docs/ folder + mkdocs.yml → for GitHub Pages site

    Add .deb or .whl packaging only if publishing to PyPI (skip otherwise)

    Use GitHub Secrets + dotenv-linter for secure .env handling

📌 GitHub First-Time Setup (manual once)

git init
git remote add origin https://github.com/<your-username>/<repo-name>.git
git add .
git commit -m "🚀 Final production-ready ETL project"
git push -u origin main

# Optional: tag version
git tag v1.0.0
git push origin v1.0.0

📝 License

This project is licensed under the MIT License — see LICENSE for details.
💬 Questions?

Feel free to open an issue, star the repo, or reach out on LinkedIn!

    Built with 💙 using PySpark + Airflow + VSCode + GitHub Actions
    #DataEngineering #PortfolioProject #ETL #CI/CD #Papermill #Airflow"# BatchEtlPyspark-20250723" 
