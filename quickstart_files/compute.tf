## Copyright © 2020, Oracle and/or its affiliates. 
## All rights reserved. The Universal Permissive License (UPL), Version 1.0 as shown at http://oss.oracle.com/licenses/upl

# This Terraform script provisions a compute instance, instance configuration, instance pool and autoscaling config.

resource "tls_private_key" "compute_ssh_key" {
  algorithm = "RSA"
  rsa_bits  = 2048
}

# Create Compute Instance

resource "oci_core_instance" "compute_instance1" {
#  availability_domain = data.oci_identity_availability_domains.ads.availability_domains[var.availability_domain - 2]["name"]
  availability_domain = data.oci_identity_availability_domains.ads.availability_domains[0].name
  compartment_id      = var.compartment_ocid
  display_name        = "App-Server-1"
  shape               = var.instance_shape

#  dynamic "shape_config" {
#    for_each = local.is_flexible_node_shape ? [1] : []
#    content {
#      memory_in_gbs = var.instance_flex_shape_memory
#      ocpus = var.instance_flex_shape_ocpus
#    }
#  }

  fault_domain        = "FAULT-DOMAIN-1"

  source_details {
    source_type             = "image"
    source_id               = data.oci_core_images.InstanceImageOCID.images[0].id
    boot_volume_size_in_gbs = "50"
  }

  create_vnic_details {
    assign_public_ip = true
    subnet_id = oci_core_subnet.public_subnet.id
#     nsg_ids = [oci_core_network_security_group.WebSecurityGroup.id, oci_core_network_security_group.SSHSecurityGroup.id]
  }

  metadata = {
    ssh_authorized_keys = tls_private_key.compute_ssh_key.public_key_openssh
    #user_data = data.template_cloudinit_config.cloud_init.rendered
  }

  timeouts {
    create = "60m"
  }
}
