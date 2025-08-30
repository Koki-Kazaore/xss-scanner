# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

This is an XSS scanner implemented as a Google Cloud Function using Ruby. The project is designed for defensive security purposes to help identify Cross-Site Scripting vulnerabilities.

## Prerequisites

- Ruby 3.3.5
- Google Cloud Functions (2nd generation)
- Default region: asia-northeast1

## Architecture

- **app.rb**: Main Cloud Function entry point using Functions Framework v1.4+
- **Gemfile**: Ruby dependencies including `functions_framework`, `httparty`, and `nokogiri`
- Uses frozen string literals for performance
- Returns JSON response with scanner status, timestamp, and request method

## Development Commands

### Local Development
Install dependencies and run locally:
```bash
bundle install
bundle exec functions-framework-ruby --target hello_xss --port 8080
curl http://localhost:8080
```

### Deployment
Authenticate and deploy to Google Cloud Functions:
```bash
gcloud auth login
gcloud functions deploy hello-xss \
  --runtime ruby33 \
  --trigger-http \
  --allow-unauthenticated \
  --entry-point hello_xss \
  --source .
```

### Get Function URL
For 2nd generation Cloud Functions:
```bash
gcloud functions describe hello-xss --format="value(url)"
```

### Testing
Test deployed function:
```bash
curl -X POST [FUNCTION_URL] \
  -H "Content-Type: application/json" \
  -d '{"test": "data"}'
```

### Debugging
```bash
gcloud functions list
gcloud functions describe hello-xss
```

### Code Quality
Install and run RuboCop for linting:
```bash
gem install rubocop
rubocop --autocorrect app.rb
```

## Project Structure

- `app.rb` - Main Cloud Function implementation with frozen string literals
- `Gemfile` - Ruby gem dependencies (functions_framework ~> 1.4, httparty, nokogiri ~> 1.15.0)
- `Gemfile.lock` - Locked gem versions
- `.gcloudignore` - Files to ignore during deployment

## Important Notes

- This is a defensive security tool designed to help identify XSS vulnerabilities
- Function runs on Google Cloud Functions 2nd generation
- Uses asia-northeast1 region by default
- Requires proper frozen string literal comment for RuboCop compliance
- Functions Framework v1.4+ required to avoid deprecation warnings