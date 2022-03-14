## Copyright © 2020, Oracle and/or its affiliates. 
## All rights reserved. The Universal Permissive License (UPL), Version 1.0 as shown at http://oss.oracle.com/licenses/upl

# Create regional subnets in vcn

resource "oci_core_subnet" "public_subnet" {
  cidr_block        = "10.0.0.0/24"
  display_name      = "public_subnet"
  compartment_id    = var.compartment_ocid
  vcn_id            = oci_core_virtual_network.vcn.id
  dhcp_options_id   = oci_core_virtual_network.vcn.default_dhcp_options_id
  route_table_id    = oci_core_route_table.public-routetable.id
  security_list_ids = [oci_core_security_list.public-security-list.id]
  dns_label         = "publicsubnet"

  provisioner "local-exec" {
    command = "sleep 5"
  }
}

resource "oci_core_subnet" "private_subnet" {
  cidr_block        = "10.0.1.0/24"
  display_name      = "private_subnet"
  compartment_id    = var.compartment_ocid
  vcn_id            = oci_core_virtual_network.vcn.id
  dhcp_options_id   = oci_core_virtual_network.vcn.default_dhcp_options_id
#  route_table_id    = oci_core_route_table.default.id
  dns_label         = "privatesubnet"
  provisioner "local-exec" {
    command = "sleep 5"
  }
}


