import unittest
from src.etl.load import load_data

class TestLoadData(unittest.TestCase):

    def setUp(self):
        self.test_data = {
            'product_id': [1, 2, 3],
            'product_name': ['Product A', 'Product B', 'Product C'],
            'price': [10.0, 20.0, 30.0],
            'quantity': [100, 200, 300]
        }
        self.output_path = 'data/processed/test_output.parquet'

    def test_load_data_parquet(self):
        load_data(self.test_data, self.output_path)
        # Add assertions to verify the data was loaded correctly
        # For example, check if the file exists and if it contains the expected data

    def tearDown(self):
        import os
        if os.path.exists(self.output_path):
            os.remove(self.output_path)

if __name__ == '__main__':
    unittest.main()