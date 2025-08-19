@echo off
setlocal enabledelayedexpansion

REM ========== CONFIGURATION ==========
set PROJECT_NAME=BatchEtlPyspark-20250723
set VENV_DIR=.venv
set LOG_FILE=pipeline.log
set ENV_FILE=.env
set ENCRYPTED_ENV_FILE=.env.enc
set AGE_KEY_FILE=.\keys\age.key
set DAG_ID=ecommerce_etl_dag
set SOPS_CONFIG_FILE=.sops.yaml
set CONTAINER_IMAGE_NAME=apache/airflow
set CONTAINER_SERVICE_NAME=airflow-webserver
set NOTEBOOK_PATH=/opt/airflow/dags/notebooks/etl_report.ipynb
set NOTEBOOK_OUTPUT=/opt/airflow/dags/output/etl_report_output.ipynb
set S3_UPLOAD_PATH=s3://your-bucket-name/final_output/
REM ====================================

echo [INFO] Starting full pipeline run... > %LOG_FILE%
echo.

REM ========== STEP 1: Create virtual env if missing ==========
if not exist %VENV_DIR% (
    echo [INFO] Creating virtual environment... >> %LOG_FILE%
    python -m venv %VENV_DIR%
)
call %VENV_DIR%\Scripts\activate

REM ========== STEP 2: Verify venv activation ==========
where python >> %LOG_FILE%
python -c "import sys; print('[DEBUG] Python used:', sys.executable)" >> %LOG_FILE%

REM ========== STEP 3: Install requirements ==========
echo [INFO] Installing dependencies... >> %LOG_FILE%
pip install --upgrade pip >> %LOG_FILE%
pip install -r requirements.txt >> %LOG_FILE%

REM ========== STEP 4: Encrypt .env with SOPS ==========
echo [INFO] Encrypting .env with sops... >> %LOG_FILE%
if exist %SOPS_CONFIG_FILE% (
    echo [INFO] Using .sops.yaml config >> %LOG_FILE%
    sops --encrypt %ENV_FILE% > %ENCRYPTED_ENV_FILE%
) else (
    echo [WARN] .sops.yaml not found. Falling back to direct --age key. >> %LOG_FILE%
    if exist %AGE_KEY_FILE% (
        set /p AGE_KEY=<%AGE_KEY_FILE%
        sops --encrypt --age !AGE_KEY! %ENV_FILE% > %ENCRYPTED_ENV_FILE%
    ) else (
        echo [ERROR] No .sops.yaml or age key found. Aborting. >> %LOG_FILE%
        exit /b 1
    )
)

REM ========== STEP 5: Launch Docker containers ==========
echo [INFO] Starting Airflow via Docker Compose... >> %LOG_FILE%
docker compose up -d >> %LOG_FILE%

REM ========== STEP 6: Wait for DAG to be parsed ==========
echo [INFO] Waiting for DAG to be parsed... >> %LOG_FILE%
set CONTAINER_NAME=
FOR /F "tokens=*" %%i IN ('docker ps --filter "name=%CONTAINER_SERVICE_NAME%" --format "{{.Names}}"') DO (
    set CONTAINER_NAME=%%i
)

REM Wait until DAG appears in Airflow
set /a RETRIES=10
:wait_loop
docker exec %CONTAINER_NAME% airflow dags list | findstr %DAG_ID% >nul
if %errorlevel% NEQ 0 (
    if %RETRIES% LEQ 0 (
        echo [ERROR] DAG %DAG_ID% not found. Timeout. >> %LOG_FILE%
        goto end
    )
    echo [INFO] DAG not yet parsed. Waiting... (%RETRIES% retries left) >> %LOG_FILE%
    timeout /t 10 >nul
    set /a RETRIES-=1
    goto wait_loop
)

REM ========== STEP 7: Trigger DAG ==========
echo [INFO] Triggering DAG: %DAG_ID% >> %LOG_FILE%
docker exec %CONTAINER_NAME% airflow dags trigger %DAG_ID%

REM ========== STEP 8: Execute Jupyter Notebook inside Airflow ==========
echo [INFO] Executing notebook inside container... >> %LOG_FILE%
docker exec %CONTAINER_NAME% papermill %NOTEBOOK_PATH% %NOTEBOOK_OUTPUT% >> %LOG_FILE%

REM ========== STEP 9: Upload to AWS S3 ==========
echo [INFO] Uploading output to AWS S3... >> %LOG_FILE%
aws s3 cp %NOTEBOOK_OUTPUT% %S3_UPLOAD_PATH% >> %LOG_FILE%

REM ========== STEP 10: GitHub Actions CI/CD ==========
echo [INFO] CI/CD Setup: Updating GitHub Actions config... >> %LOG_FILE%

REM Check if .github/workflows directory exists
if not exist ".github\workflows" (
    mkdir .github\workflows
)

REM Copy template if ci.yml not present
if not exist ".github\workflows\ci.yml" (
    echo [INFO] No GitHub Actions workflow found. Adding default ci.yml... >> %LOG_FILE%
    copy templates\ci.yml .github\workflows\ci.yml >> %LOG_FILE%
)

REM Optional: Ensure README has a badge
findstr /C:"github/workflows/ci.yml/badge.svg" README.md >nul
if %errorlevel% NEQ 0 (
    echo ![CI](https://github.com/your-username/%PROJECT_NAME%/actions/workflows/ci.yml/badge.svg) >> README.md
    echo [INFO] Added CI badge to README.md >> %LOG_FILE%
)

REM Git push only if there are changes
git add .github README.md >> %LOG_FILE%
git diff --cached --quiet
if %errorlevel% NEQ 0 (
    git commit -m "🚀 Add GitHub Actions CI/CD workflow" >> %LOG_FILE%
    git push origin main >> %LOG_FILE%
    echo [INFO] Changes pushed to GitHub. >> %LOG_FILE%
) else (
    echo [INFO] No CI/CD-related changes to push. >> %LOG_FILE%
)

REM ========== STEP 11: Package as wheel & deb ==========

echo [INFO] Packaging as .whl... >> %LOGFILE%
python setup.py bdist_wheel || (
    echo ❌ Wheel packaging failed >> %LOGFILE%
    exit /b 1
	
if "%ENABLE_DEB_PACKAGE%"=="true" (
    echo [INFO] Packaging as .deb... >> %LOGFILE%
    fpm -s python -t deb dist\*.whl --name batch-etl-pyspark --version 1.0 || (
        echo ❌ .deb packaging failed >> %LOGFILE%
        exit /b 1
    )
)

REM ========== Final ==========
:end
echo [SUCCESS] Full pipeline execution complete. >> %LOG_FILE%
echo Done.
pause
