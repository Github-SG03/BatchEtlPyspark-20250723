# File: DATA_ENGINEERING/data_engineering_project/batch-etl-pyspark/src/extract/extract_data.py
import os
from src.config.settings import Config

def read_csv(spark, file_name):
    """Reads a CSV file from the raw data path."""
    file_path = os.path.join(Config.RAW_DATA_PATH, file_name)
    print(f"Attempting to read from: {file_path}") # Added for debugging
    return spark.read.csv(file_path, header=True, inferSchema=True)

def read_customers(spark):
    return read_csv(spark, Config.CUSTOMERS_FILE)

def read_products(spark):
    return read_csv(spark, Config.PRODUCTS_FILE)

def read_orders(spark):
    return read_csv(spark, Config.ORDERS_FILE)
