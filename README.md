
# Batch ETL PySpark Pipeline

![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)
![CI](https://github.com/<your-username>/<repo-name>/actions/workflows/ci.yml/badge.svg)
![codecov](https://codecov.io/gh/<your-username>/<repo-name>/branch/main/graph/badge.svg)
![Python](https://img.shields.io/badge/python-3.8+-blue.svg)
![PySpark](https://img.shields.io/badge/PySpark-3.5+-orange.svg)
![Docker](https://img.shields.io/badge/docker-ready-blue.svg)
![Airflow](https://img.shields.io/badge/airflow-2.9+-lightblue.svg)
![Security](https://img.shields.io/badge/security-disclosures-important.svg)

## 🚀 Project Overview

This is a complete PySpark Batch ETL pipeline project, containerized with Docker and orchestrated using Apache Airflow. It includes:
- Raw to processed data movement
- Notebook execution
- Power BI reporting
- CI/CD with GitHub Actions
- Secrets encryption with SOPS

## 🧑‍💻 Local Setup

### 1️⃣ Clone the Repo
```cmd
git clone https://github.com/<your-username>/batch-etl-pyspark.git
cd batch-etl-pyspark
```

### 2️⃣ Create Virtual Environment (Windows CMD)
```cmd
python -m venv .venv
call .venv\Scripts\activate.bat
pip install -r requirements.txt
```

### 3️⃣ Docker + Airflow
```cmd
docker-compose up --build -d
```

### 4️⃣ Run Pipeline from CMD (Windows)
```cmd
full_project_runner.cmd
```

## 🔐 Secure Your Secrets with SOPS (Optional)

1. Download SOPS `.exe` from:
   https://github.com/mozilla/sops/releases
2. Move to a folder like `C:\Tools\SOPS\`
3. Add folder to system PATH:
   - Win + S → Search `Environment Variables`
   - Edit system PATH → Add: `C:\Tools\SOPS\`
4. Restart CMD, test with:
```cmd
sops --version
```

### Encrypt .env
```cmd
sops -e .env > .env.enc
```

### Decrypt .env
```cmd
sops -d .env.enc > .env
```

## 🔄 CI/CD with GitHub Actions

GitHub Actions auto-triggers:
- Python lint & test checks
- DAG validation
- .env decryption (if needed)

File: `.github/workflows/ci.yml`

## 📦 Packaging

Build a `.whl` package:
```cmd
python setup.py bdist_wheel
```

Build a `.deb` (requires `fpm`):
```bash
fpm -s python -t deb dist/*.whl --name batch-etl-pyspark --version 1.0
```

---

## 🛠 TODO

- [x] Setup CMD runner for Windows users
- [x] Use Docker for Airflow orchestration
- [x] Use SOPS for secure secret management
- [x] Package code for deployment
- [x] GitHub Actions CI/CD + badge
