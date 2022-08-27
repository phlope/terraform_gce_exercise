# Runbook-1: Deploying the infrastructure to the us-west1 region

Before starting, ensure you have checked out the [terraform_gce_exercise terraform repository](../terraform).

1. When deploying the infrastructure to us-west1, you need to first create a new `tf.vars` file in the `environments/` directory e.g:

   ```
   gce-us-west1.tfvars
   ```

2. In this file, assign your region:

   ```
   region = us-west1
   ```

   Note: If you wish to override the default environment and project, they can be declared here using the same method. See the [root variables file](../terraform/variables.tf) for the defaults

3. Initialise the terraform working directory by running:

   ```
   terraform init
   ```

4. Check your plan locally by running:

   ```
   terraform plan -var-file=./environments/gce-us-west1.tfvars
   ```

5. Once happy with the changes made to the infrastructure outlined in the plan, action these modifications by running:
   ```
   terraform apply -var-file=./environments/gce-us-west1.tfvars
   ```
