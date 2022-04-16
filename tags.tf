## Copyright (c) 2020, Oracle and/or its affiliates. 
## All rights reserved. The Universal Permissive License (UPL), Version 1.0 as shown at http://oss.oracle.com/licenses/upl

resource "random_id" "tag" {
  byte_length = 2
}

resource "oci_identity_tag_namespace" "redis_manager_tag_namespace" {
    provider = oci.homeregion
    compartment_id = var.compartment_ocid
    description = "RedisManagerTagNamespace"
    name = "RedisManager\\deploy-redis-cluster-${random_id.tag.hex}"
  
    provisioner "local-exec" {
       command = "sleep 10"
    }
}

resource "oci_identity_tag" "redis_manager_tag" {
    provider = oci.homeregion
    description = "RedisManagerTag"
    name = "release"
    tag_namespace_id = oci_identity_tag_namespace.redis_manager_tag_namespace.id

    validator {
        validator_type = "ENUM"
        values         = ["release", "1.1"]
    }

    provisioner "local-exec" {
       command = "sleep 120"
    }

}
