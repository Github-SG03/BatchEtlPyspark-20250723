from pyspark.sql import SparkSession # type: ignore
from pyspark.sql import functions as F # type: ignore

def calculate_total_sales(df):
    return df.agg(F.sum("amount").alias("total_sales"))

def calculate_average_order_value(df):
    return df.agg(F.avg("amount").alias("average_order_value"))

def calculate_sales_by_category(df):
    return df.groupBy("category").agg(F.sum("amount").alias("total_sales_by_category"))

def calculate_top_selling_products(df, top_n=10):
    return df.groupBy("product_id").agg(F.sum("amount").alias("total_sales")) \
             .orderBy(F.desc("total_sales")).limit(top_n)

def calculate_customer_lifetime_value(df):
    return df.groupBy("customer_id").agg(F.sum("amount").alias("customer_lifetime_value"))