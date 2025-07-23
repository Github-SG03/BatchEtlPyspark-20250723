from pyspark.sql import SparkSession # type: ignore
from pyspark.sql.functions import col, when # type: ignore

def segment_customers(df):
    """
    Segments customers based on their purchasing behavior.
    
    Args:
        df (DataFrame): DataFrame containing customer data with relevant metrics.
        
    Returns:
        DataFrame: DataFrame with an additional column for customer segments.
    """
    return df.withColumn(
        "customer_segment",
        when(col("total_spent") < 100, "Low Value")
        .when((col("total_spent") >= 100) & (col("total_spent") < 500), "Medium Value")
        .otherwise("High Value")
    )

def get_customer_segments(spark, input_path):
    """
    Reads customer data and applies segmentation.
    
    Args:
        spark (SparkSession): Spark session object.
        input_path (str): Path to the input customer data.
        
    Returns:
        DataFrame: DataFrame with customer segments.
    """
    customer_data = spark.read.csv(input_path, header=True, inferSchema=True)
    segmented_data = segment_customers(customer_data)
    return segmented_data.select("customer_id", "customer_segment")