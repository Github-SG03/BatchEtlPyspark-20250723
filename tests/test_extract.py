import unittest
from src.etl.extract import extract_customers, extract_products, extract_orders

class TestExtract(unittest.TestCase):

    def test_extract_customers(self):
        customers_df = extract_customers('data/raw/customers.csv')
        self.assertFalse(customers_df.empty)
        self.assertIn('customer_id', customers_df.columns)
        self.assertIn('customer_name', customers_df.columns)

    def test_extract_products(self):
        products_df = extract_products('data/raw/products.csv')
        self.assertFalse(products_df.empty)
        self.assertIn('product_id', products_df.columns)
        self.assertIn('product_name', products_df.columns)

    def test_extract_orders(self):
        orders_df = extract_orders('data/raw/orders.csv')
        self.assertFalse(orders_df.empty)
        self.assertIn('order_id', orders_df.columns)
        self.assertIn('customer_id', orders_df.columns)
        self.assertIn('product_id', orders_df.columns)

if __name__ == '__main__':
    unittest.main()