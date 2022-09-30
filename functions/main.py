import datetime
import os
import requests
from google.cloud import bigquery
from google.cloud import secretmanager

PROJECT_ID = os.environ.get('PROJECT_ID')
DATASET_ID = os.environ.get('DATASET_ID')

def access_secret_version(project_id, secret_name, secret_ver='latest'):
    client = secretmanager.SecretManagerServiceClient()
    name = client.secret_version_path(project_id, secret_name, secret_ver)
    response = client.access_secret_version(name=name)
    return response.payload.data.decode('UTF-8')

AUTHORIZATION_KEY = access_secret_version(PROJECT_ID, 'AUTHORIZATION_KEY')

headers = {
    'Accept': 'application/vnd.github+json',
    'Authorization': AUTHORIZATION_KEY,
}

def get_repo_list():
    repo_list = requests.get('https://api.github.com/users/zawa1120/repos', headers=headers).json()
    return [repo["name"] for repo in repo_list]

def get_traffic_json():
    traffic_data = []
    for repo_name in get_repo_list():
        response_dict = requests.get(f'https://api.github.com/repos/zawa1120/{repo_name}/traffic/views', headers=headers).json()
        if response_dict["count"] != 0:
            response_dict["name"] = repo_name
            traffic_data.append(response_dict)
    return traffic_data

def main(request):
    """Responds to any HTTP request.
    Args:
        request (flask.Request): HTTP request object.
    Returns:
        The response text or any set of values that can be turned into a
        Response object using
        `make_response <http://flask.pocoo.org/docs/1.0/api/#flask.Flask.make_response>`.
    """
    day = datetime.datetime.now() - datetime.timedelta(days=1)

    job_config = bigquery.LoadJobConfig(
        schema=[
            bigquery.SchemaField("name", "STRING", mode='NULLABLE', description='リポジトリの名前'),
            bigquery.SchemaField("uniques", "INTEGER", mode='NULLABLE', description='ユニークなビュアー'),
            bigquery.SchemaField("views", "RECORD", mode='NULLABLE', description='ビューレコード'),
            bigquery.SchemaField("views.count", "INTEGER", mode='NULLABLE', description='ビュアーの合計'),
            bigquery.SchemaField("views.uniques", "INTEGER", mode='NULLABLE', description='ユニークなビュアー'),
            bigquery.SchemaField("views.timestamp", "TIMESTAMP", mode='NULLABLE', description='レコードの日付'),
            bigquery.SchemaField("count", "INTEGER", mode='NULLABLE', description='ビュアーの合計')
        ],
        write_disposition = 'WRITE_TRUNCATE'
    )

    try:
        traffic_json_data = get_traffic_json()

        bq = bigquery.Client(project=PROJECT_ID)
        dataset = bq.dataset(DATASET_ID)

        bq.load_table_from_json(
            traffic_json_data,
            dataset.table(f'github_traffic_{day:%Y%m%d}'),
            job_config).result()

    except Exception as e:
        raise(e)

    return str(day)
