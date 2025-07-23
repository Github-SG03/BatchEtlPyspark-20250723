import os

# Get the absolute path to the project root (two levels up from this file)
BASE_DIR = os.path.dirname(os.path.dirname(os.path.dirname(os.path.abspath(__file__))))

class Config:
    # Directory paths
    RAW_DATA_PATH = os.path.join(BASE_DIR, os.getenv('RAW_DATA_DIR_NAME', 'data/raw'))
    PROCESSED_DATA_PATH = os.path.join(BASE_DIR, os.getenv('PROCESSED_DATA_DIR_NAME', 'data/processed'))
    ANALYTICS_DATA_PATH = os.path.join(BASE_DIR, os.getenv('ANALYTICS_DATA_DIR_NAME', 'data/analytics'))

    # ✅ Add OUTPUT_PATH from .env or default
    OUTPUT_PATH = os.path.join(BASE_DIR, os.getenv('OUTPUT_PATH', 'data/analytics/output'))

    # File names
    CUSTOMERS_FILE = os.getenv('CUSTOMERS_FILE', 'customers.csv')
    PRODUCTS_FILE = os.getenv('PRODUCTS_FILE', 'products.csv')
    ORDERS_FILE = os.getenv('ORDERS_FILE', 'orders.csv')

    # Database connection settings (placeholder or optional)
    DB_HOST = os.getenv('DB_HOST', 'localhost')
    DB_PORT = os.getenv('DB_PORT', '5432')
    DB_NAME = os.getenv('DB_NAME', 'ecommerce')
    DB_USER = os.getenv('DB_USER', 'user')
    DB_PASSWORD = os.getenv('DB_PASSWORD', 'password')

    # Spark configuration
    SPARK_APP_NAME = os.getenv('SPARK_APP_NAME', 'EcommerceSalesAnalytics')
    SPARK_MASTER = os.getenv('SPARK_MASTER', 'local[*]')  # Use all cores
