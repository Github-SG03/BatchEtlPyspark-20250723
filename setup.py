from setuptools import setup, find_packages

setup(
    name="batch_etl_pyspark",
    version="1.0",
    packages=find_packages(),
    install_requires=[
        "pyspark==3.5.1",
        "apache-airflow",
        "papermill",
        "graphviz",
        "awscli",
    ],
    entry_points={
        "console_scripts": [
            "run_etl=etl_package.main:main",
        ],
    },
)
