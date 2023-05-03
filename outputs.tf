output "auth_method_id" {
  value = data.http.boundary_cluster_auth_methods
}

output "boundary_worker_registration" {
  value = boundary_worker.worker_1
}