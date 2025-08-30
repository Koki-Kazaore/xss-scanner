# xss-scanner

## Prerequisites
| Item | Description |
| ----- | ----- |
| Ruby | 3.3.5 |
| Cloud Functions | 2nd generation |
| Default Region | asia-northeast1 |

## Local Development
```bash
bundle exec functions-framework-ruby --target hello_xss --port 8080

# GET
curl http://localhost:8080

# POST
curl -X POST http://localhost:8080 \
  -H "Content-Type: application/json" \
  -d '{"target_url": "http://testphp.vulnweb.com/artists.php"}'
```

## Deploy and Test

```bash
# login
gcloud auth login

# Deploy
gcloud functions deploy xss-scanner \
  --runtime ruby33 \
  --trigger-http \
  --allow-unauthenticated \
  --entry-point xss_scanner \
  --source .

# Get function URL
gcloud functions describe xss-scanner --format="value(url)"
```
```bash
# Test with curl
curl -X POST [FUNCTION_URL] \
  -H "Content-Type: application/json" \
  -d '{"test": "data"}'
```

## Debug
```bash
# Other commands
gcloud functions list
gcloud functions describe xss-scanner
```