# Terraform AWS EC2 + RDS Assignment

## 📌 Overview
This project provisions AWS infrastructure using **Terraform** to demonstrate Infrastructure as Code (IaC).  
It sets up:  
- An **EC2 instance** in a public subnet with SSH access via a key pair.  
- An attached **20GB EBS volume** with snapshot backup.  
- An **RDS MySQL instance** in private subnets across two Availability Zones for high availability.  
- **Security groups** that follow best practices:
  - EC2: allows SSH (22) and HTTP (80).  
  - RDS: only allows MySQL (3306) traffic from the EC2 instance.  

The EC2 instance is bootstrapped with the **MySQL client**, allowing direct connection to the RDS database.

---

## ⚙️ Architecture
- **VPC**: Default AWS VPC.  
- **Subnets**:
  - 1 public subnet (for EC2, SSH access, outbound internet).  
  - 2 private subnets (for RDS, spread across 2 AZs).  
- **High Availability**: RDS requires multiple subnets in different AZs to support failover.  
- **Networking**: EC2 connects to RDS via internal VPC networking and SG rules.  

---

## 🚀 Setup Instructions

### 1. Prerequisites
- AWS CLI configured (`aws configure`).  
- Terraform installed (`terraform -v`).  
- A key pair uploaded in AWS (here: `marvin-Linux.pem`).  

### 2. Files
- `main.tf` → Terraform resources.  
- `variables.tf` → configurable inputs (region, subnets, DB credentials).  
- `terraform.tfvars` (optional) → your custom variable values.  

### 3. Deploy Infrastructure
```bash
terraform init
terraform plan
terraform apply

