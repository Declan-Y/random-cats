# Random Cats

This is a toy project to practice DevOps/Platform engineering principles.
It displays a random cat picture on page load.

It is a dockerised React/Typescript and Python application using FastAPI as the Python framework. The infrastructure is on AWS and uses the following AWS Services:
1. Fargate Elastic Container Service is used to run the docker container services.
2. ECR is used to host the Docker images.
3. S3 is used to hold the cat pictures
4. VPC is used for networking.
5. Load balancer.
6. IAM for permission policies and roles


There is a Github action set up that runs some tests on merge to main. 

## TODO
Automate the creation of the AWS infrastructure using Terraform

Add pushing docker images to ECR to Github Actions

Add other checks like security checks to Github Actions

Add monitoring with Prometheus and Grafana






