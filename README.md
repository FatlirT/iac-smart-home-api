# iac-smart-home-api

> Terraform Infrastructure as Code (IaC) for deploying a modular **Smart Home API** on AWS.  
> This project provisions the networking, compute, security, and data layers required to run multiple smart-home microservices in a secure multi-tier architecture.

![Terraform](https://img.shields.io/badge/Terraform-1.3%2B-623CE4?logo=terraform&logoColor=white)
![AWS](https://img.shields.io/badge/AWS-eu--west--2-FF9900?logo=amazonaws&logoColor=white)
![IaC](https://img.shields.io/badge/Infrastructure%20as%20Code-Terraform-blue)
![Architecture](https://img.shields.io/badge/Architecture-Microservices-success)

---

## Overview

This repository contains the **infrastructure layer** for a Smart Home backend platform built with a **microservices architecture**.

It uses **Terraform** to provision AWS resources for:

- **Networking** (VPC, subnets, routing, NAT gateway)
- **Security** (segmented security groups for app traffic and SSH access)
- **Compute** (EC2 instances for public-facing and internal services)
- **Data** (DynamoDB tables for smart-home domains)
- **Access control** (IAM instance profile for retrieving secrets securely)

The current environment deploys services such as:

- `lights`
- `heating`
- `status`
- `auth` (internal/private)

This project is designed to demonstrate:

- modular Terraform design
- AWS networking fundamentals
- secure private/public subnet separation
- bastion-based SSH access
- microservice-oriented infrastructure provisioning

---

## Architecture

### High-level design

- **VPC** in `eu-west-2`
- **3 public subnets** across multiple AZs
- **3 private subnets** across multiple AZs
- **Internet Gateway** for public access
- **NAT Gateway** for outbound internet access from private workloads
- **Bastion host** for controlled SSH access
- **Public web EC2 instances** for externally reachable services
- **Private internal EC2 instances** for internal-only services
- **DynamoDB tables** for domain data (`lights`, `heating`)
- **IAM instance profile** to allow instances to retrieve secrets from AWS Secrets Manager

---

## Architecture Diagram

```text
                           ┌────────────────────────────┐
                           │        Internet            │
                           └─────────────┬──────────────┘
                                         │
                                 ┌───────▼────────┐
                                 │ Internet GW    │
                                 └───────┬────────┘
                                         │
                    ┌────────────────────▼────────────────────┐
                    │                 VPC                     │
                    │             10.0.1.0/24                │
                    └─────────────────────────────────────────┘
                         │                              │
         ┌───────────────┴───────────────┐   ┌──────────┴───────────┐
         │        Public Subnets         │   │    Private Subnets   │
         │  (multi-AZ, public routing)   │   │ (multi-AZ via NAT)   │
         └───────────────┬───────────────┘   └──────────┬───────────┘
                         │                              │
              ┌──────────▼──────────┐         ┌─────────▼──────────┐
              │   Bastion Host      │         │ Internal Services   │
              │     (SSH entry)     │         │     auth            │
              └──────────┬──────────┘         └─────────────────────┘
                         │
         ┌───────────────▼────────────────────────────┐
         │          Public Web Services               │
         │   lights / heating / status (EC2)          │
         └────────────────────────────────────────────┘

                     ┌─────────────────────────────┐
                     │       DynamoDB Tables       │
                     │      lights / heating       │
                     └─────────────────────────────┘
```

---

## Features

### Networking
- Custom **VPC** with DNS support enabled
- **Public and private subnet segmentation**
- **Internet Gateway** for internet-facing services
- **NAT Gateway** for secure outbound access from private subnets
- Separate route tables for public and private traffic

### Security
- Public application ingress on **port 3000**
- Internal-only application ingress restricted by **security group source**
- Bastion-controlled SSH access
- Outbound rules separated by purpose:
  - SSH egress
  - HTTP egress
  - HTTPS egress

### Compute
- Reusable EC2 server module
- Public web service instances deployed dynamically from a map of microservices
- Internal service instances deployed into private subnets
- Bastion host for secure administrative access

### Data
- DynamoDB tables created per domain using `for_each`
- Current domains:
  - `lights`
  - `heating`

### Secrets & IAM
- EC2 instance profile with permission to read tagged secrets from **AWS Secrets Manager**
- Demonstrates secure secret retrieval without hardcoding credentials in Terraform

---

## Tech Stack

- **Terraform** `>= 1.3.7`
- **AWS Provider** `~> 5.0`
- **AWS Region:** `eu-west-2` (London)
- **Services Used:**
  - Amazon VPC
  - Amazon EC2
  - AWS IAM
  - AWS Secrets Manager
  - Amazon DynamoDB
  - Elastic IP
  - NAT Gateway

---

## Repository Structure

```bash
iac-smart-home-api/
├── main.tf
├── inputs.tf
├── outputs.tf
├── providers.tf
├── .tfvars
├── modules/
│   ├── dynamo/
│   │   ├── main.tf
│   │   ├── inputs.tf
│   │   └── outputs.tf
│   ├── networking/
│   │   ├── main.tf
│   │   ├── inputs.tf
│   │   └── outputs.tf
│   ├── security/
│   │   ├── app_ingress/
│   │   ├── app_ingress_internal/
│   │   ├── ssh_bastion/
│   │   ├── ssh_egress/
│   │   └── web_egress/
│   └── servers/
│       ├── key_pair/
│       ├── secrets-ip/
│       └── server/
└── credentials/
    └── <public key files>
```

---

## Infrastructure Modules

### `networking`
Creates the foundational network:

- VPC
- Internet Gateway
- Public subnets
- Private subnets
- Public route table
- NAT Gateway
- Private route table

### `security`
Reusable security group modules for:

- public app ingress
- internal app ingress
- bastion SSH access
- SSH egress
- web egress (HTTP/HTTPS)

### `servers`
Reusable EC2-related modules for:

- generic EC2 server provisioning
- SSH key pair creation
- IAM instance profile for Secrets Manager access

### `dynamo`
Reusable DynamoDB module for domain tables.

---

## Current Microservices

The environment currently provisions these services from the `app_info` object:

### Public-facing services
- `lights`
- `heating`
- `status`

These are deployed to **public subnets** and exposed via the public app ingress security group on **port 3000**.

### Internal services
- `auth`

This is deployed to a **private subnet** and only accepts traffic from an internal security group source.

---

## Configuration

### Example variables

This project is driven by Terraform variables for:

- VPC CIDR
- availability zones
- public subnet CIDRs
- private subnet CIDRs
- application metadata
- microservice maps

Example configuration:

```hcl
vpc_cidr_range    = "10.0.1.0/24"

availability_zones = [
  "eu-west-2a",
  "eu-west-2b",
  "eu-west-2c"
]

public_subnets = [
  "10.0.1.0/28",
  "10.0.1.16/28",
  "10.0.1.32/28"
]

private_subnets = [
  "10.0.1.48/28",
  "10.0.1.64/28",
  "10.0.1.80/28"
]

app_info = {
  name = "ce-smart-home"

  microservices = {
    web = {
      lights  = {}
      heating = {}
      status  = {}
    }

    internal = {
      auth = {}
    }
  }
}
```

---

## Prerequisites

Before deploying, ensure you have:

- [Terraform](https://developer.hashicorp.com/terraform/downloads) `>= 1.3.7`
- An AWS account
- AWS credentials configured locally (e.g. via AWS CLI)
- An SSH public key available in:

```bash
credentials/ssh-bastion.pub
```

You should also have:

- appropriate IAM permissions to create:
  - VPC resources
  - EC2 resources
  - IAM roles / instance profiles
  - DynamoDB tables
  - Elastic IPs
  - NAT Gateways

---

## Getting Started

### 1) Clone the repository

```bash
git clone https://github.com/FatlirT/iac-smart-home-api.git
cd iac-smart-home-api
```

### 2) Create your variable file

> Recommended: rename `.tfvars` to `terraform.tfvars` or create a separate environment file.

Example:

```bash
cp .tfvars terraform.tfvars
```

### 3) Add your SSH public key

Place your public key in:

```bash
credentials/ssh-bastion.pub
```

### 4) Initialize Terraform

```bash
terraform init
```

### 5) Review the execution plan

```bash
terraform plan -var-file="terraform.tfvars"
```

### 6) Apply the infrastructure

```bash
terraform apply -var-file="terraform.tfvars"
```

---

To destroy:

```bash
terraform destroy -var-file="terraform.tfvars"
```

---

## Security / Reliability Notes

Project was for for practicing Terraform and should be made more secure and reliable for use in production by:

- Restricting public ingress further (e.g. behind an **Application Load Balancer** instead of direct EC2 exposure)
- Avoiding committed environment variable files with real values
- Avoiding committing real `.tfvars` files
- Rotating any existing secrets if they were ever exposed
- Replacing hardcoded ARNs/account-specific references with variables
- Using **SSM Session Manager** instead of SSH where possible
- Using **Auto Scaling Groups** or **ECS/EKS** instead of single EC2 instances for resilience

---

## Suggested Improvements / Roadmap

Future enhancements:

- [ ] Add **Auto Scaling Groups**
- [ ] Replace direct app bootstrapping with immutable image or user-data templates
- [ ] Parameterise AMIs via data sources

- [ ] Harden security with remote state
      
- [ ] Containerise with Docker and move compute to **ECS Fargate** or **EKS**
- [ ] Add CICD pipeline (e.g. GitHub Actions)
- [ ] Add **CloudWatch logs/metrics/alarms**


## Author

**Fatlir T.**
