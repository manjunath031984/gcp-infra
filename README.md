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
- Cloud Storage API

---

# Authentication

This project supports Google Cloud Workload Identity Federation.

The current Jenkins pipeline authenticates with a Google Cloud service account key stored securely in Jenkins credentials as `gcp-sa-key`. Do not commit service account keys to the repository.

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

Workload Identity Federation does not require a service account key. If you use the current Jenkinsfile as-is, store the service account key only in Jenkins credentials.

---

# Terraform Backend

Terraform state is stored in a Google Cloud Storage bucket.

Current backend configuration

```hcl
terraform {
  backend "gcs" {
    bucket = "terraform-state-gcp"
    prefix = "dev"
  }
}
```

The Jenkins pipeline overrides the backend bucket and prefix during `terraform init` by using `-backend-config` values.

Initialize Terraform manually with explicit backend settings when needed.

```bash
terraform init \
  -reconfigure \
  -backend-config="bucket=gcp-dev-july-2026-terraform-state" \
  -backend-config="prefix=dev"
```

---

# Provider Configuration

```hcl
terraform {
  required_version = ">= 1.5.0"

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

---

# Example dev.tfvars

```hcl
project_id="gcp-dev-july-2026"

region="us-central1"

zone="us-central1-a"

vm_name="terraform-gcp"

machine_type="e2-micro"
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
- Check and install required tools
- Authenticate with Google Cloud using Jenkins credential `gcp-sa-key`
- Terraform Version
- Terraform Init
- Terraform Validate
- Terraform Workspace
- Terraform Plan
- Manual Approval when `AUTO_APPROVE` is disabled
- Terraform Apply
- Archive Artifacts
- Workspace Cleanup

Pipeline parameters:

| Parameter | Allowed Values | Description |
|-----------|----------------|-------------|
| ENVIRONMENT | dev, qa, prod | Terraform workspace and tfvars file name |
| ACTION | apply, destroy | Creates/updates or destroys infrastructure |
| AUTO_APPROVE | true, false | Skips the manual approval gate when set to true |

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
gcp-dev-july-2026-terraform-state
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

# Detailed Deployment Steps

Follow these steps to deploy the infrastructure from a local workstation or through Jenkins.

## 1. Prepare Google Cloud Project

Set the project ID.

```bash
export PROJECT_ID="gcp-dev-july-2026"
gcloud config set project ${PROJECT_ID}
```

Enable the required Google Cloud APIs.

```bash
gcloud services enable \
  cloudresourcemanager.googleapis.com \
  iam.googleapis.com \
  iamcredentials.googleapis.com \
  sts.googleapis.com \
  compute.googleapis.com \
  storage.googleapis.com
```

## 2. Create Terraform State Bucket

Create the GCS bucket used for remote Terraform state. Bucket names must be globally unique, so update the value if the example name is already taken.

```bash
export TF_STATE_BUCKET="gcp-dev-july-2026-terraform-state"
export REGION="us-central1"

gcloud storage buckets create gs://${TF_STATE_BUCKET} \
  --location=${REGION} \
  --uniform-bucket-level-access
```

Enable versioning on the state bucket.

```bash
gcloud storage buckets update gs://${TF_STATE_BUCKET} --versioning
```

## 3. Configure Terraform Variables

Update `dev.tfvars` with your project and VM values.

```hcl
project_id   = "gcp-dev-july-2026"
region       = "us-central1"
zone         = "us-central1-a"
vm_name      = "terraform-gcp"
machine_type = "e2-micro"
```

For `qa` or `prod` deployments, create matching variable files before running the Jenkins pipeline.

```bash
cp dev.tfvars qa.tfvars
cp dev.tfvars prod.tfvars
```

Edit each file with environment-specific values.

## 4. Clone Repository

```bash
git clone https://github.com/manjunath031984/gcp-infra.git
```

Move into the project directory.

```bash
cd gcp-infra
```

## 5. Authenticate Locally

Use application default credentials for local Terraform runs.

```bash
gcloud auth application-default login
gcloud config set project ${PROJECT_ID}
```

## 6. Initialize Terraform

Initialize Terraform with the GCS backend. Use the same prefix as the target environment.

```bash
terraform init \
  -reconfigure \
  -backend-config="bucket=${TF_STATE_BUCKET}" \
  -backend-config="prefix=dev"
```

## 7. Select Terraform Workspace

Create or select the workspace for the target environment.

```bash
terraform workspace select dev || terraform workspace new dev
```

## 8. Format, Validate, and Plan

Format Terraform files.

```bash
terraform fmt -recursive
```

Validate the configuration.

```bash
terraform validate
```

Create a plan.

```bash
terraform plan -var-file=dev.tfvars -out=tfplan
```

## 9. Apply Infrastructure

Apply the reviewed plan.

```bash
terraform apply tfplan
```

## 10. Verify Deployment

Confirm that the VM was created.

```bash
gcloud compute instances list --filter="name=terraform-gcp"
```

## 11. Destroy Infrastructure When Required

Destroy the environment only when the resources are no longer needed.

```bash
terraform plan -destroy -var-file=dev.tfvars -out=tfplan.destroy
terraform apply tfplan.destroy
```

## 12. Deploy Through Jenkins

Create a Jenkins file credential with ID `gcp-sa-key`. The credential must contain the Google Cloud service account key JSON used by the pipeline.

Configure the Jenkins pipeline job to use this repository and `Jenkinsfile`.

Run the pipeline with these parameters:

| Parameter | Example | Notes |
|-----------|---------|-------|
| ENVIRONMENT | dev | Requires a matching `dev.tfvars` file |
| ACTION | apply | Use `destroy` only for cleanup |
| AUTO_APPROVE | false | Keep false for manual approval in shared environments |

The pipeline performs checkout, tool validation, GCP authentication, backend initialization, workspace selection, planning, approval, apply, artifact archival, and workspace cleanup.

For Jenkins deployments to `qa` or `prod`, ensure `qa.tfvars` or `prod.tfvars` exists before selecting that environment.

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