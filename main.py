# 1. Setup SparkSession
from pyspark.sql import SparkSession
from pyspark.sql.types import StructType, StructField, StringType, IntegerType, DoubleType

spark = SparkSession.builder \
    .appName("EcommerceDataAnalysis") \
    .master("local[*]") \
    .getOrCreate()

# Define the schema
schema = StructType([
    StructField("column1", StringType(), True),
    StructField("column2", IntegerType(), True),
    StructField("column3", DoubleType(), True),
    # Add more fields as needed
])

# 2. Read the output Parquet with the specified schema
df = spark.read.schema(schema).parquet("/mnt/c/Users/Shivam Gupta/OneDrive/Documents/Shivam_Developement/DATA_ENGINEERING/data_engineering_project/batch-etl-pyspark/data/analytics/output")
df.show(5)
df.printSchema()
print(f"Total Records: {df.count()}")

# 3. Optional: GroupBy Analysis
df.groupBy("category").count().show()

# 4. Save to CSV
import os
output_dir = "../data/processed"
os.makedirs(output_dir, exist_ok=True)
df.coalesce(1).write.mode("overwrite").csv(output_dir, header=True)
print(f"✅ CSV written to: {output_dir}")

# 5. Stop Spark
spark.stop()