resource "random_id" "dynamic_group" {
  byte_length = 2
}

resource "oci_identity_dynamic_group" "redis_dynamic_group" {

  provider = oci.homeregion

  compartment_id = var.tenancy_ocid

  name        = "redis_cluster_dynamic_group_${random_id.dynamic_group.hex}"
  description = "Dynamic Group of Redis Cluster Compute Instances"

  matching_rule = "tag.${oci_identity_tag_namespace.redis_manager_tag_namespace.name}.${oci_identity_tag.redis_manager_tag.name}.value = '${var.release}'"
}