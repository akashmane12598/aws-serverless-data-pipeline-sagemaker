# AWS Serverless Data Pipeline and ML Deployment Project

## Overview

This project implements an end-to-end AWS architecture using Terraform, Spring Boot, AWS Glue, Step Functions, and SageMaker.

The system allows users to generate a pre-signed S3 upload URL through a Spring Boot application hosted on EC2 behind an internal Application Load Balancer. Uploaded CSV sensor data is stored in S3, processed using AWS Glue, orchestrated through Step Functions, and used to train a machine learning model with SageMaker. The trained model is then deployed to a SageMaker real-time endpoint for inference.

## Architecture

```text
User/Postman
    |
    v
API Gateway HTTP API
    |
    v
VPC Link
    |
    v
Internal ALB
    |
    v
EC2 Spring Boot Application
    |
    v
Generate S3 Pre-Signed URL
    |
    v
S3 raw/ CSV Upload
    |
    v
EventBridge
    |
    v
Step Functions
    |
    v
AWS Glue ETL Jobs
    |
    v
SageMaker Training Job
    |
    v
SageMaker Endpoint



### AWS Services Used

 **Terraform** for Infrastructure as Code
* **API Gateway** for public API access
* **AWS Lambda** for serverless API testing
* **AWS Cognito** for authentication
* **VPC, Subnets, NACLs, and Security Groups** for networking
* **EC2** for hosting the Spring Boot application
* **Internal Application Load Balancer** for private backend routing
* **S3** for file storage, Glue scripts, SageMaker scripts, and model artifacts
* **EventBridge** for triggering workflows on S3 upload
* **Step Functions** for orchestration
* **AWS Glue** for ETL processing
* **SageMaker** for model training and deployment

### Main Features

* Infrastructure provisioned using Terraform modules
* Secured API Gateway endpoint using Cognito
* Spring Boot application hosted on EC2
* S3 pre-signed URL generation for direct file upload
* Event-driven pipeline triggered by S3 upload
* Glue Job 1 cleans raw CSV sensor data
* Glue Job 2 converts cleaned data to Parquet
* Step Functions orchestrates Glue and SageMaker
* SageMaker trains a machine learning model
* SageMaker endpoint serves predictions
