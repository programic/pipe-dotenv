# Note
This Bitbucket dotenv pipe uses a dotenv application which has not yet been made public.

# Bitbucket pipeline example
The example below shows how to use the Bitbucket pipe in your bitbucket-pipelines.yml.

```yaml
script:
  - pipe: docker://programic/pipe-dotenv:latest
    variables:
      DOTENV_PROJECT: $DOTENV_PROJECT
      DOTENV_ENVIRONMENT: $DOTENV_ENVIRONMENT
      DOTENV_API_URL: $DOTENV_API_URL
      DOTENV_API_TOKEN: $DOTENV_API_TOKEN
      DOTENV_FILE_SOURCE: ".env.example"
      DOTENV_FILE_TARGET: ".env"
      EXTRAS_BITBUCKET_COMMIT: $BITBUCKET_COMMIT
      EXTRAS_BITBUCKET_BUILD_NUMBER: $BITBUCKET_BUILD_NUMBER
      EXTRAS_BITBUCKET_DEPLOYMENT_ENVIRONMENT: $BITBUCKET_DEPLOYMENT_ENVIRONMENT
```

# Example .env.example
Below is an example of what an .env.example can look like.

```dotenv
APP_NAME="My Project"
APP_ENV=local
APP_KEY=
APP_DEBUG=true
APP_URL=https://my-project.test

BITBUCKET_COMMIT=
BITBUCKET_BUILD_NUMBER=
BITBUCKET_DEPLOYMENT_ENVIRONMENT=

SENTRY_LARAVEL_DSN=
SENTRY_ENVIRONMENT="${BITBUCKET_DEPLOYMENT_ENVIRONMENT}"
SENTRY_RELEASE="${BITBUCKET_COMMIT}"
```