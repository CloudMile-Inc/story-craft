# StoryCraft Deployment Scripts

This directory contains scripts for building and deploying the StoryCraft application to Google Cloud Platform.

## Prerequisites

Before running these scripts, ensure you have:

1. **Google Cloud SDK** installed and configured
   ```bash
   gcloud auth login
   gcloud config set project mp-ai-video
   ```

2. **Docker** installed and running

3. **Terraform** installed (for infrastructure management)

4. **Required permissions** in the GCP project:
   - Cloud Run Admin
   - Artifact Registry Admin
   - Service Account User

## Deployment Workflow

### Step 1: Build and Deploy the Application

After making code changes (like updating to Veo 3.1), run the build and deploy script:

```bash
# Make the script executable (first time only)
chmod +x scripts/build-and-deploy.sh

# Run the deployment script
./scripts/build-and-deploy.sh
```

**What this script does:**
- Builds a new Docker container image with your latest code changes
- Tags the image with the current git commit hash
- Pushes the image to Google Artifact Registry
- Deploys the new image to Cloud Run
- Displays the service URL

**Expected output:**
```
🚀 Building and deploying StoryCraft application
📋 Configuration:
  Project ID: mp-ai-video
  Region: asia-southeast1
  Image URI: asia-southeast1-docker.pkg.dev/mp-ai-video/storycraft/storycraft:abc1234

🔐 Checking authentication...
🐳 Configuring Docker for Artifact Registry...
🔨 Building Docker image...
📤 Pushing image to Artifact Registry...
☁️ Deploying to Cloud Run...

✅ Deployment completed successfully!
🌐 Service URL: https://storycraft-xxxxx-as.a.run.app
```

### Step 2: Update Terraform Configuration

After the deployment completes, update the `terraform/terraform.tfvars` file with the new image URI:

```bash
cd terraform
```

Edit `terraform.tfvars` and update the `container_image` value with the image URI from Step 1:

```hcl
# Update this line with the new image URI
container_image = "asia-southeast1-docker.pkg.dev/mp-ai-video/storycraft/storycraft:abc1234"

# Also verify the nextauth_url matches your service URL
nextauth_url = "https://storycraft-xxxxx-as.a.run.app"
```

### Step 3: Apply Terraform Changes

Run the Terraform workflow to update the infrastructure with the new container image:

```bash
# Initialize Terraform (first time only, or if providers changed)
terraform init

# Preview the changes
terraform plan

# Apply the changes
terraform apply
```

**Review the plan carefully** before typing `yes` to confirm.

**What Terraform does:**
- Updates the Cloud Run service with the new container image
- Ensures all environment variables are properly configured
- Maintains infrastructure consistency

### Step 4: Verify Deployment

After Terraform completes, verify the deployment:

```bash
# Check the service status
gcloud run services describe storycraft \
  --region=asia-southeast1 \
  --project=mp-ai-video

# View recent logs
gcloud logging read "resource.type=cloud_run_revision AND resource.labels.service_name=storycraft" \
  --limit=20 \
  --project=mp-ai-video

# Test the service URL
curl https://storycraft-xxxxx-as.a.run.app
```

## Quick Reference

### Environment Variables

The deployment script uses these environment variables (with defaults):

- `PROJECT_ID` - GCP project ID (default: `mp-ai-video`)
- `REGION` - GCP region (default: `asia-southeast1`)
- `TAG` - Image tag (default: current git commit hash)

You can override them:

```bash
PROJECT_ID=my-project REGION=us-central1 ./scripts/build-and-deploy.sh
```

### Common Issues

**Issue: Docker authentication fails**
```bash
# Solution: Re-authenticate Docker
gcloud auth configure-docker asia-southeast1-docker.pkg.dev
```

**Issue: Permission denied**
```bash
# Solution: Make script executable
chmod +x scripts/build-and-deploy.sh
```

**Issue: Terraform state lock**
```bash
# Solution: Wait for other operations to complete, or force unlock (use carefully)
terraform force-unlock LOCK_ID
```

**Issue: Container build fails**
```bash
# Solution: Check Docker is running and you have enough disk space
docker system prune -a  # Clean up old images
```

## Initial Setup (First Time Only)

If this is your first time deploying, run the setup script first:

```bash
# Make the script executable
chmod +x scripts/setup-terraform.sh

# Run the setup
cd terraform
../scripts/setup-terraform.sh
```

This will:
1. Initialize Terraform
2. Validate the configuration
3. Create all required GCP resources (Cloud Run, Storage, Firestore, etc.)

## Rollback Procedure

If you need to rollback to a previous version:

```bash
# List available images
gcloud artifacts docker images list \
  asia-southeast1-docker.pkg.dev/mp-ai-video/storycraft/storycraft

# Deploy a specific version
gcloud run deploy storycraft \
  --image=asia-southeast1-docker.pkg.dev/mp-ai-video/storycraft/storycraft:OLD_TAG \
  --region=asia-southeast1 \
  --project=mp-ai-video

# Update terraform.tfvars with the old image URI
# Then run: terraform apply
```

## Summary: Complete Deployment Checklist

- [ ] Make code changes (e.g., update to Veo 3.1)
- [ ] Run `./scripts/build-and-deploy.sh`
- [ ] Copy the image URI from the output
- [ ] Update `terraform/terraform.tfvars` with the new image URI
- [ ] Run `terraform plan` to preview changes
- [ ] Run `terraform apply` to apply changes
- [ ] Verify deployment with logs and service URL
- [ ] Test the application functionality

## Support

For issues or questions:
- Check Cloud Run logs: `gcloud logging read "resource.type=cloud_run_revision"`
- Review Terraform state: `terraform show`
- Contact the DevOps team or refer to the main documentation
