output "auth_method_id" {
  value = data.http.boundary_cluster_auth_methods
}

output "controller_generated_activation_token" {
  value = boundary_worker
}

output "boundary_worker_registration" {
  value = boundary_worker.worker_1
}