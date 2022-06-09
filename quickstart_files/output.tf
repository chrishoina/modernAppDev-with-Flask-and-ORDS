output "rest_get_url" {

  value = replace("${oci_database_autonomous_database.quickstart_autonomous_database.connection_urls.0.sql_dev_web_url}admin/notes/","sql-developer","")

}

output "sdw_url" {

  value = oci_database_autonomous_database.quickstart_autonomous_database.connection_urls.0.sql_dev_web_url

}

output "endpoint_url" {

  value = replace("${oci_database_autonomous_database.quickstart_autonomous_database.connection_urls.0.sql_dev_web_url}","/ords/sql-developer","")

}


output "autonomous_database_password" {
  value = random_string.password.result
  sensitive = true
}

output "generated_private_key_pem" {
  value     = tls_private_key.compute_ssh_key.private_key_pem
  sensitive = true
}

output "dev" {
  value = "Made with \u2764 by the Oracle Database Development Tools Folks"
}

output "lb_ip" {
  value = oci_load_balancer_load_balancer.webapp_load_balancer.ip_address_details.0.ip_address
}