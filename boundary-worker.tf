resource "random_pet" "server" {
  #   keepers = {
  #     # Generate a new pet name each time we switch to a new AMI id
  #     ami_id = var.ami_id
  #   }
}

resource "boundary_worker" "fafa" {
  description = "boundary self-managed-worker"
  name        = "${random_pet.server}-worker"
  scope_id = var.scope_id
  worker_generated_auth_token = "" # blank results in controller-generated-token
}

