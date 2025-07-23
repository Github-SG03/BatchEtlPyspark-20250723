import os
from dotenv import load_dotenv #type:ignore
from src.utils.spark_session import create_spark_session
from src.config.settings import Config

load_dotenv()
spark = create_spark_session()

def write_output(df):
    output_path = Config.OUTPUT_PATH
    print(f"Writing data to: {output_path}")
    df.write.mode("overwrite").parquet(output_path)
