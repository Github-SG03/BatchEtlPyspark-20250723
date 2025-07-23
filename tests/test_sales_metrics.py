
"""
import unittest
from src.analytics.sales_metrics import calculate_revenue_by_category, calculate_top_selling_products, calculate_customer_lifetime_value

class TestSalesMetrics(unittest.TestCase):

    def setUp(self):
        # Sample data for testing
        self.sales_data = [
            {'category': 'Electronics', 'revenue': 200, 'customer_id': 1},
            {'category': 'Electronics', 'revenue': 150, 'customer_id': 2},
            {'category': 'Clothing', 'revenue': 100, 'customer_id': 1},
            {'category': 'Clothing', 'revenue': 300, 'customer_id': 3},
            {'category': 'Electronics', 'revenue': 400, 'customer_id': 3},
        ]

    def test_calculate_revenue_by_category(self):
        expected = {'Electronics': 750, 'Clothing': 400}
        result = calculate_revenue_by_category(self.sales_data)
        self.assertEqual(result, expected)

    def test_calculate_top_selling_products(self):
        # Assuming a function that returns top selling products based on revenue
        expected = ['Electronics', 'Clothing']
        result = calculate_top_selling_products(self.sales_data)
        self.assertEqual(result, expected)

    def test_calculate_customer_lifetime_value(self):
        expected = {1: 300, 2: 150, 3: 700}
        result = calculate_customer_lifetime_value(self.sales_data)
        self.assertEqual(result, expected)

if __name__ == '__main__':
    unittest.main()
    
    """