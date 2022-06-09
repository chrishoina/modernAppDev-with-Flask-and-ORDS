## Copyright © 2020, Oracle and/or its affiliates. 
## All rights reserved. The Universal Permissive License (UPL), Version 1.0 as shown at http://oss.oracle.com/licenses/upl

# This Terraform script provisions a compute instance, instance configuration, instance pool and autoscaling config.

resource "tls_private_key" "compute_ssh_key" {
  algorithm = "RSA"
  rsa_bits  = 2048
}

# Create Compute Instance

resource "oci_core_instance" "compute_instance1" {
  availability_domain = data.oci_identity_availability_domains.ads.availability_domains[0].name
  compartment_id      = var.compartment_ocid
  display_name        = "App-Server-1"
  shape               = "VM.Standard.A1.Flex"
	shape_config {
		memory_in_gbs = "6"
		ocpus = "1"
	}



  fault_domain        = "FAULT-DOMAIN-1"

  source_details {
    source_type             = "image"
    source_id               = data.oci_core_images.InstanceImageOCID.images[0].id
    boot_volume_size_in_gbs = "50"
  }

  create_vnic_details {
    assign_public_ip = true
    subnet_id = oci_core_subnet.public_subnet.id
  }

  metadata = {
    ssh_authorized_keys = tls_private_key.compute_ssh_key.public_key_openssh
  }

  timeouts {
    create = "10m"
  }
}

resource "oci_vault_secret" "demo_ssh_keys" {
    #Required
    compartment_id = var.compartment_ocid
    secret_content {
        #Required
        content_type = "BASE64"

        #Optional
        content = "${base64encode(tls_private_key.compute_ssh_key.private_key_pem)}"
    }
    key_id = oci_kms_key.demo_key.id
    secret_name = "quickstartSSHKeys"
    vault_id = oci_kms_vault.demo_vault.id
}