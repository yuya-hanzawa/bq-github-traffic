import datetime
import os
import requests
from google.cloud import bigquery

PROJECT_ID        = os.environ.get('PROJECT_ID')
DATASET_ID        = os.environ.get('DATASET_ID')
AUTHORIZATION_KEY = os.environ.get('AUTHORIZATION_KEY')

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

    try:
        traffic_json_data = get_traffic_json()

    except Exception as e:
        raise(e)

    job_config = bigquery.LoadJobConfig()
    job_config.autodetect = True

    try:
        bq = bigquery.Client(project=PROJECT_ID)
        dataset = bq.dataset(DATASET_ID)

        bq.load_table_from_json(
            traffic_json_data,
            dataset.table(f'github_traffic_{day:%Y%m%d}'),
            job_config).result()

        print("Successful")

    except Exception as e:
        raise(e)
