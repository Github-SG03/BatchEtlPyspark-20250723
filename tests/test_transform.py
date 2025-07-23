from dotenv import load_dotenv #type:ignore
load_dotenv()

from src.etl.transform import transform_data

def test_enrich_orders_schema(spark):
    orders = spark.createDataFrame([(1, 101, "2024-01-01", 2)], ["order_id", "product_id", "order_date", "quantity"])
    customers = spark.createDataFrame([(1, "Alice", "NY")], ["customer_id", "name", "location"])
    products = spark.createDataFrame([(101, "Laptop", "Electronics", 1000.0)], ["product_id", "name", "category", "price"])

    df = transform_data(orders, customers, products)
    assert "total_amount" in df.columns