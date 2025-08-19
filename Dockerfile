FROM apache/airflow:2.9.1-python3.10

# Switch to airflow user before installing
USER airflow

# Copy your requirements.txt into the image
COPY requirements.txt /requirements.txt

# Install all your packages inside container
RUN pip install --no-cache-dir -r /requirements.txt
