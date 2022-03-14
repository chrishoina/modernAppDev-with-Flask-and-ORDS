output "rest_get_url" {

  value = replace("${oci_database_autonomous_database.quickstart_autonomous_database.connection_urls.0.sql_dev_web_url}quickstart/employees/","sql-developer","")

}

output "sdw_url" {

  value = replace("${oci_database_autonomous_database.quickstart_autonomous_database.connection_urls.0.sql_dev_web_url}quickstart/sign-in/?username=QUICKSTART&r=_sdw%2F","sql-developer","")

}

output "password" {
  value = "The password is ${random_string.password.result}"
}