from pyspark.sql import DataFrame #type: ignore

def transform_data(orders_df: DataFrame, customers_df: DataFrame, products_df: DataFrame) -> DataFrame:
    # Optional: Rename 'name' in customers before join to avoid duplication
    customers_df = customers_df.withColumnRenamed("name", "customer_name")
    products_df = products_df.withColumnRenamed("name", "product_name")

    # Join orders with customers
    orders_customers_df = orders_df.join(customers_df, on="customer_id", how="inner")

    # Join with products
    enriched_df = orders_customers_df.join(products_df, on="product_id", how="inner")

    return enriched_df
