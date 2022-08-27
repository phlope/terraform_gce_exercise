# Runbook 2: Adding an additional data drive for logs to the existing deployment

Before starting, ensure you have checked out the [terraform repository](../terraform).

1. In order to create a new data disk, use the [google_compute_disk](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/compute_disk#type) resource.

   As default, we provide the following fields:

   - `name`: Disk name
   - `type`: Disk type (SSD or HDD)
   - `project` : GCP project for deployment
   - `zone`: GCP zone where the disk resides
   - `image` : The image from which to initialize this disk
   - `size` : Size of the persistent disk, in GB

   Declare the disk resource using the format below, replacing the values where necessary:

   ```
    resource "google_compute_disk" "vm-log-disk" {
        name                      = "log-disk"
        type                      = "pd-ssd"
        project                   = var.project
        zone                      = "europe-west2-a"
        image                     = "windows-cloud/window-server-2022"
        size                      = 10
    }
   ```

2. At this state terraform will provision a single new disk instance in the specified location. Should you need to attach the disk to each VM instance we deploy, you can do so using the `gce_instance_template` module declaration.

   Append your disk resource name to the list as shown in the example below:

   ```
   additional_disks = [{
       source      = google_compute_disk.vm-datadisk.name
       auto_delete = false
       boot        = false
       },
       {
       source      = google_compute_disk.vm-log-disk.name
       auto_delete = false
       boot        = false
       }
   ]
   }
   ```

   This list is dynamically assigns to the instance template and for each instance replicated, your disk is attached.

3. When deploying the infrastructure to you will need to a `tf.vars` file containing your environment values in the `environments/` directory e.g:

   ```
   gce-eu-west2.tfvars
   ```

4. In this file, assign your region:

   ```
   region = us-west1
   ```

   Note: If you wish to override the default environment and project, they can be declared here using the same method. See the [root variables file](../terraform/variables.tf) for the defaults

5. Initialise the terraform working directory by running:

   ```
   terraform init
   ```

6. Check your plan locally by running:

   ```
   terraform plan -var-file=./environments/gce-eu-west2.tfvars
   ```

7. Once happy with the changes made to the infrastructure outlined in the plan, action these modifications by running:
   ```
   terraform apply -var-file=./environments/gce-eu-west2.tfvars
   ```
