#!/usr/bin/env bash

docker login
docker build -t programic/pipe-dotenv:latest .
docker push programic/pipe-dotenv:latest