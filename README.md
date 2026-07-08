# GCP Infrastructure using Terraform

This project provisions Google Cloud Platform (GCP) infrastructure using Terraform. It follows Infrastructure as Code (IaC) best practices and is designed to be deployed through a Jenkins CI/CD pipeline.

---

# Project Structure

```
gcp-infra/
│
├── backend.tf
├── provider.tf
├── main.tf
├── variables.tf
├── outputs.tf
├── dev.tfvars
├── Jenkinsfile
├── README.md
│
└── modules
    └── compute-instance
        ├── main.tf
        ├── variables.tf
        └── outputs.tf
```

---

# Features

- Terraform Modules
- Google Compute Engine VM Creation
- Remote Terraform State using Google Cloud Storage
- Jenkins Pipeline Integration
- Environment based deployment (dev, qa, prod)
- Infrastructure as Code
- Workload Identity Federation Ready
- Reusable Terraform Modules

---

# Prerequisites

Install the following tools.

- Terraform >= 1.5
- Google Cloud SDK
- Git
- Jenkins
- Google Cloud Project

---

# Required Google Cloud APIs

Enable the following APIs in your project.

- Cloud Resource Manager API
- IAM API
- IAM Service Account Credentials API
- Security Token Service API
- Compute Engine API

---

# Authentication

This project supports Google Cloud Workload Identity Federation.

Recommended authentication flow:

```
Jenkins
    │
    ▼
OIDC Token
    │
    ▼
Workload Identity Pool
    │
    ▼
Google Service Account
    │
    ▼
Google Cloud
```

No Service Account Key is required.

---

# Terraform Backend

Terraform state is stored in a Google Cloud Storage bucket.

Example backend configuration

```hcl
terraform {
  backend "gcs" {}
}
```

Initialize Terraform

```bash
terraform init \
  -backend-config="bucket=terraform-state-gcp-dev-july-2026" \
  -backend-config="prefix=dev"
```

---

# Provider Configuration

```hcl
terraform {
  required_version = ">=1.5"

  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "~> 6.0"
    }
  }
}

provider "google" {
  project = var.project_id
  region  = var.region
  zone    = var.zone
}
```

---

# Variables

| Variable | Description |
|-----------|-------------|
| project_id | Google Cloud Project ID |
| region | GCP Region |
| zone | GCP Zone |
| vm_name | Compute Engine VM Name |
| machine_type | VM Machine Type |
| image | Operating System Image |

---

# Example dev.tfvars

```hcl
project_id="gcp-dev-july-2026"

region="us-central1"

zone="us-central1-a"

vm_name="terraform-vm"

machine_type="e2-medium"

image="debian-cloud/debian-12"
```

---

# Terraform Commands

Initialize

```bash
terraform init
```

Validate

```bash
terraform validate
```

Format

```bash
terraform fmt
```

Plan

```bash
terraform plan -var-file=dev.tfvars
```

Apply

```bash
terraform apply -var-file=dev.tfvars
```

Destroy

```bash
terraform destroy -var-file=dev.tfvars
```

---

# Jenkins Pipeline

The Jenkins pipeline performs the following stages.

- Checkout Source Code
- Authenticate with Google Cloud
- Terraform Init
- Terraform Validate
- Terraform Workspace
- Terraform Plan
- Manual Approval
- Terraform Apply
- Archive Artifacts
- Workspace Cleanup

---

# Terraform Workspaces

Separate Terraform workspaces are used for different environments.

```
dev
qa
prod
```

Select workspace

```bash
terraform workspace select dev
```

Create workspace

```bash
terraform workspace new dev
```

---

# Remote State Layout

```
terraform-state-gcp-dev-july-2026
│
├── dev
│   └── default.tfstate
│
├── qa
│   └── default.tfstate
│
└── prod
    └── default.tfstate
```

---

# Module

Current module

```
modules/
└── compute-instance
```

Responsible for

- Creating Compute Engine VM
- Boot Disk
- Network Interface
- Service Account
- Tags
- Metadata

---

# Deployment

Clone Repository

```bash
git clone https://github.com/manjunath031984/gcp-infra.git
```

Move into project

```bash
cd gcp-infra
```

Initialize

```bash
terraform init
```

Deploy

```bash
terraform apply -var-file=dev.tfvars
```

---

# Future Enhancements

- VPC Network
- Firewall Rules
- Cloud NAT
- Cloud Router
- Cloud Storage
- Cloud SQL
- GKE Cluster
- Load Balancer
- IAM Automation
- Monitoring
- Logging
- Cloud Armor

---

# Author

**Manjunath V**

Senior Site Reliability Engineer

GitHub

https://github.com/manjunath031984

---

# License

This project is licensed under the MIT License.