# provider "boundary" {
#   #   addr                            = "http://127.0.0.1:9200"
#   #   auth_method_id                  = "ampw_1234567890" # changeme
#   #   password_auth_method_login_name = "myuser"          # changeme
#   #   password_auth_method_password   = "passpass"        # changeme
#   addr                            = var.boundary_cluster_url
#   #auth_method_id                  = data.http.boundary_cluster_auth_methods.id
#   auth_method_id                  = var.boundary_auth_method_id
#   password_auth_method_login_name = var.boundary_username
#   password_auth_method_password   = var.boundary_password
# }

data "http" "boundary_cluster_auth_methods" {
  url = "${var.boundary_cluster_url}/v1/auth-methods?filter=%22password%22+in+%22%2Fitem%2Ftype%22&scope_id=global"
}

