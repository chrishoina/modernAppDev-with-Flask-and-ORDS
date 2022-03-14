output "rest_get_url" {

  value = replace("${oci_database_autonomous_database.quickstart_autonomous_database.connection_urls.0.sql_dev_web_url}quickstart/employees/","sql-developer","")

}

output "sdw_url" {

  value = replace("${oci_database_autonomous_database.quickstart_autonomous_database.connection_urls.0.sql_dev_web_url}quickstart/sign-in/?username=QUICKSTART&r=_sdw%2F","sql-developer","")

}

output "autonomous_database_password" {
  value = "The password is ${random_string.password.result}"
  sensitive = true
}

output "generated_private_key_pem" {
  value     = tls_private_key.compute_ssh_key.private_key_pem
  sensitive = true
}

output "dev" {
  value = "Made with \u2764 by the Oracle Database Development Tools Folks"
}