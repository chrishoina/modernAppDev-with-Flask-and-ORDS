#
# Start

# Get ADs

# <tenancy-ocid> is the compartment OCID for the root compartment.
# Use <tenancy-ocid> for the compartment OCID.

data "oci_identity_availability_domains" "ads" {
  compartment_id = var.tenancy_ocid
}

resource "random_string" "password" {
  length  = 16
  special = true
  min_special = 2
  min_numeric = 2
  override_special = "#"

}

resource "oci_database_autonomous_database" "quickstart_autonomous_database" {
        #Required
        compartment_id = var.compartment_ocid
        cpu_core_count = "1"
        data_storage_size_in_tbs = "1"
        db_name = "QUIKDB"

        admin_password = random_string.password.result
        db_workload = "DW"
        display_name = "QUIKDB"
        is_free_tier ="true"
        license_model = "LICENSE_INCLUDED"
        #is_access_control_enabled = "false"
        is_mtls_connection_required = "false"
        whitelisted_ips = ["0.0.0.0/0"]
        is_auto_scaling_enabled = "false"
        is_data_guard_enabled = "false"
        is_dedicated = "false"
        is_preview_version_with_service_terms_accepted = false   
}

resource "oci_kms_vault" "demo_vault" {
    #Required
    compartment_id = var.compartment_ocid
    display_name = "demoVault"
    vault_type = "DEFAULT"
}

resource "oci_kms_key" "demo_key" {
  #Required
  compartment_id      = var.compartment_ocid
  display_name        = "demoKey"
  management_endpoint = oci_kms_vault.demo_vault.management_endpoint

  key_shape {
    #Required
    algorithm = "AES"
    length    = 32
  }
}

resource "oci_vault_secret" "demo_secret" {
    #Required
    compartment_id = var.compartment_ocid
    secret_content {
        #Required
        content_type = "BASE64"

        #Optional
        content = "${base64encode(random_string.password.result)}"
    }
    key_id = oci_kms_key.demo_key.id
    secret_name = "quickstartPassword"
    vault_id = oci_kms_vault.demo_vault.id
}

data "oci_database_autonomous_database" "quickstart_autonomous_database" {
    #Required
    autonomous_database_id = oci_database_autonomous_database.quickstart_autonomous_database.id
}

resource "oci_database_autonomous_database_wallet" "autonomous_data_warehouse_wallet" {
    #Required
    autonomous_database_id = oci_database_autonomous_database.quickstart_autonomous_database.id
    password = random_string.password.result

    #Optional
    base64_encode_content = "true"
    generate_type = "SINGLE"
}

resource "local_file" "autonomous_data_warehouse_wallet_file" {
  content_base64 = oci_database_autonomous_database_wallet.autonomous_data_warehouse_wallet.content
  filename       = "wallet.zip"
  
}

resource "oci_database_tools_database_tools_connection" "test_database_tools_connection" {
    #Required
    compartment_id = var.compartment_ocid
    display_name = "QUIKDB DB Tools Connection"
    type = "ORACLE_DATABASE"
    connection_string = oci_database_autonomous_database.quickstart_autonomous_database.connection_strings.0.profiles.0.value

    related_resource {
        #Required
        entity_type = "AUTONOMOUSDATABASE"
        identifier = oci_database_autonomous_database.quickstart_autonomous_database.id
    }
    user_name = "quickstart"
    user_password {
        #Required
        value_type = "SECRETID"

        #Optional
        secret_id = oci_vault_secret.demo_secret.id
    }

depends_on = [
    local_file.autonomous_data_warehouse_wallet_file,
    oci_vault_secret.demo_secret
  ]

}

resource "null_resource" "sqlcl-load-data" {

        provisioner "local-exec" {    
            command = <<-EOT
                wget https://download.oracle.com/otn_software/java/sqldeveloper/sqlcl-latest.zip
                unzip sqlcl-latest.zip
                sed -i 's/NEW_PASSWORD/${random_string.password.result}/g' ./db_scripts/new_password.sql
                ./sqlcl/bin/sql -cloudconfig wallet.zip admin/${random_string.password.result}@QUIKDB_high @./db_scripts/quickstart.sql
            EOT
        }

depends_on = [
    oci_database_tools_database_tools_connection.test_database_tools_connection,
    local_file.autonomous_data_warehouse_wallet_file
  ]

}

output "rest_get_url" {

  value = replace("${oci_database_autonomous_database.quickstart_autonomous_database.connection_urls.0.sql_dev_web_url}quickstart/employees/","sql-developer","")

}

output "sdw_url" {

  value = replace("${oci_database_autonomous_database.quickstart_autonomous_database.connection_urls.0.sql_dev_web_url}quickstart/sign-in/?username=QUICKSTART&r=_sdw%2F","sql-developer","")

}

output "password" {
  value = "The password is ${random_string.password.result}"
}