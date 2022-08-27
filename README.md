## Terraform GCE Example

---

This repository acts as the location for deploying the infrastructure needed for a gce infrastructure example, satisfying the specification:

```
- 2 Windows virtual machines hosted in Google Cloud Europe West 2 region
- The virtual machines must be labelled with `environment: test`
- Each virtual machine must have 1 data drive
- IAC must be written in Terraform
- IAC must be reusable to allow deployments to other regions.
- Employees require RDP access from the office IP 80.193.23.74/32
- Port 443 must be open to the internet.

```

The main file used to achieve this is [gce-default.tf](./gce-default.tf).

Runbooks for two use cases can be also found at the runbook directory [runbooks](./runbooks/)

---

## Setting up your environment

This repo has been strucured to allow for easy deployment to a each region. We achieve this by using terraform's input variables, defined in `variables.tf` at the root level of the repo.

Looking at this file you can see there are three variables we setup:

- `project`
  - The target GCP project we wish to deploy our infrastructure to.
  - This defaults to our `gce-test` project, but can be overidden with the explicit project you wish for the resources to deploy in.
- `environment`
  - The working environment for our deployment
  - This defaults to our only use case of `test` but can be overidden for any env use case such as `preprod` or `prod`
- `region`
  - This must be explictly set each time we want to deploy

The values for these variables can be assigned using [multiple methods](https://www.terraform.io/language/values/variables#assigning-values-to-root-module-variables), in this repository we leverage the `.tfvars` file method:

- Create a new `.tfvars` file in the `environments/` directory e.g:

  ```
  gce-eu-west2.tfvars
  ```

2. In this file, assign your region:

   ```
   region = europe-west2
   ```

   Note: If you wish to change environment and project, they can be declared here using the same method.

3. Follow the next steps on running your IAC locally:

## Running locally

- Ensure you have [terraform](https://www.terraform.io/downloads.html) installed on your machine

- To initialise your working directory, first run `terraform init`
  - `init` command documentation can be found [here](https://www.terraform.io/cli/commands/init)
- Next, create your execution plan by running `terraform plan`

  - Target your enviroment specific tfvars file by appending the `-var-file` flag to your plan command e.g.:

    ```
    terraform plan -var-file=./environments/gce-eu-west2.tfvars
    ```

  - `plan` command documentation can be found [here](https://www.terraform.io/cli/commands/plan)

- Finally, once satisfied with the changes to your infrastrucure outlined in the plan, action your `plan` by runnning `terraform apply`

  - Equally with the apply command, target your enviroment specific tfvars file by appending the `-var-file` flag to your apply command e.g.:

    ```
    terraform apply -var-file=./environments/gce-eu-west2.tfvars
    ```

  - `apply` command documentation can be found [here](https://www.terraform.io/cli/commands/apply)
