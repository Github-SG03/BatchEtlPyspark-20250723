# File: DATA_ENGINEERING/data_engineering_project/batch-etl-pyspark/src/utils/spark_session.py
from pyspark.sql import SparkSession #type: ignore
from src.config.settings import Config # <--- This import is correct, assuming settings.py is in src/config

def create_spark_session():
    """
    Creates and returns a SparkSession using settings from Config.
    """
    print(f"Creating SparkSession with appName: {Config.SPARK_APP_NAME} and master: {Config.SPARK_MASTER}")
    spark = SparkSession.builder \
        .appName(Config.SPARK_APP_NAME) \
        .master(Config.SPARK_MASTER) \
        .config("spark.sql.legacy.timeParserPolicy", "LEGACY") \
        .getOrCreate()
    print("SparkSession created successfully.")
    return spark
