from airflow import DAG
from airflow.operators.python import PythonOperator #type:ignore
from datetime import datetime, timedelta
import os
import sys

# ✅ Set project root (where 'src' lives)
project_root = os.path.abspath(os.path.join(os.path.dirname(__file__), "..", ".."))
if project_root not in sys.path:
    sys.path.insert(0, project_root)

# ✅ Load .env file
from dotenv import load_dotenv #type:ignore
load_dotenv(dotenv_path=os.path.join(project_root, ".env"))

# ✅ Import custom modules
from src.utils.spark_session import create_spark_session
from src.etl.extract import read_customers, read_products, read_orders
from src.etl.transform import transform_data
from src.etl.load import write_output

# ✅ ETL Function
def run_etl():
    print("🔁 Starting ETL...")
    spark = create_spark_session()
    print("✅ Spark session created")

    orders = read_orders(spark)
    customers = read_customers(spark)
    products = read_products(spark)

    print("📦 DataFrames loaded, transforming...")
    enriched_df = transform_data(orders, customers, products)

    output_path = os.getenv("OUTPUT_PATH")
    if not output_path:
        raise ValueError("OUTPUT_PATH environment variable not set")

    write_output(enriched_df)
    print(f"✅ ETL complete. Data written to {output_path}")

# ✅ DAG Definition
default_args = {
    "owner": "airflow",
    "retries": 1,
    "retry_delay": timedelta(minutes=2),
}

with DAG(
    dag_id="ecommerce_etl",
    default_args=default_args,
    description="E-commerce ETL pipeline using PySpark",
    start_date=datetime(2025, 7, 18),
    schedule_interval=None,         # ✅ Manual only (from .sh trigger)
    catchup=False,
    max_active_runs=1,
    tags=["pyspark", "etl", "ecommerce"]
) as dag:

    etl_task = PythonOperator(
        task_id="run_etl",
        python_callable=run_etl
    )

    etl_task
