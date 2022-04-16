## Copyright (c) 2020, Oracle and/or its affiliates. 
## All rights reserved. The Universal Permissive License (UPL), Version 1.0 as shown at http://oss.oracle.com/licenses/upl

resource "oci_core_virtual_network" "redis_vcn" {
  cidr_block     = var.VCN_CIDR
  compartment_id = var.compartment_ocid
  display_name   = "${var.redis_prefix}_vcn"
  dns_label      = var.redis_prefix

  defined_tags = {"${oci_identity_tag_namespace.redis_manager_tag_namespace.name}.${oci_identity_tag.redis_manager_tag.name}" = var.release }

}

resource "oci_core_subnet" "redis_subnet" {
  cidr_block        = var.Subnet_CIDR
  display_name      = "${var.redis_prefix}_subnet"
  dns_label         = var.redis_prefix
  security_list_ids = [oci_core_security_list.redis_securitylist.id]
  compartment_id    = var.compartment_ocid
  vcn_id            = oci_core_virtual_network.redis_vcn.id
  route_table_id    = oci_core_route_table.redis_rt.id
  dhcp_options_id   = oci_core_virtual_network.redis_vcn.default_dhcp_options_id

  defined_tags = {"${oci_identity_tag_namespace.redis_manager_tag_namespace.name}.${oci_identity_tag.redis_manager_tag.name}" = var.release }
}

resource "oci_core_internet_gateway" "redis_igw" {
  compartment_id = var.compartment_ocid
  display_name   = "${var.redis_prefix}_igw"
  vcn_id         = oci_core_virtual_network.redis_vcn.id

  defined_tags = {"${oci_identity_tag_namespace.redis_manager_tag_namespace.name}.${oci_identity_tag.redis_manager_tag.name}" = var.release }
}

resource "oci_core_route_table" "redis_rt" {
  compartment_id = var.compartment_ocid
  vcn_id         = oci_core_virtual_network.redis_vcn.id
  display_name   = "${var.redis_prefix}_rt"

  route_rules {
    destination       = "0.0.0.0/0"
    destination_type  = "CIDR_BLOCK"
    network_entity_id = oci_core_internet_gateway.redis_igw.id
  }

  defined_tags = {"${oci_identity_tag_namespace.redis_manager_tag_namespace.name}.${oci_identity_tag.redis_manager_tag.name}" = var.release }
}

