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
        is_auto_scaling_enabled = "false"
        is_data_guard_enabled = "false"
        is_dedicated = "false"
        is_preview_version_with_service_terms_accepted = false   
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

resource "null_resource" "sqlcl-load-data" {

        provisioner "local-exec" {    
            command = <<-EOT
                wget https://download.oracle.com/otn_software/java/sqldeveloper/sqlcl-latest.zip
                unzip sqlcl-latest.zip
                ./sqlcl/bin/sql -cloudconfig wallet.zip admin/${random_string.password.result}@QUIKDB_high @./db_scripts/quickstart.sql
            EOT
        }

depends_on = [
    local_file.autonomous_data_warehouse_wallet_file,
  ]

}



output "password" {
  value = "The password is ${random_string.password.result}"
}