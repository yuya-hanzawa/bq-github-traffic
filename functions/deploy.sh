gcloud functions deploy Get-github-traffic \
    --entry-point=main \
    --region=us-central1 \
    --runtime=python39 \
    --timeout=60 \
    --memory=256MB \
    --env-vars-file=env.yaml \
    --trigger-http
