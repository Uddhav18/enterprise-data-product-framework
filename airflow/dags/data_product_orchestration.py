from airflow import DAG
from airflow.operators.bash import BashOperator
from datetime import datetime

default_args = {"owner": "data_engineering", "retries": 2}

with DAG(
dag_id="enterprise_data_product_pipeline",
start_date=datetime(2025, 1, 1),
schedule_interval="@daily",
catchup=False,
default_args=default_args
) as dag:

dbt_run = BashOperator(
task_id="run_dbt_models",
bash_command="cd /opt/dbt_project && dbt run"
)

dbt_test = BashOperator(
task_id="run_dbt_tests",
bash_command="cd /opt/dbt_project && dbt test"
)

dbt_run >> dbt_test
