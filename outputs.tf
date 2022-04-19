## Copyright (c) 2020, Oracle and/or its affiliates. 
## All rights reserved. The Universal Permissive License (UPL), Version 1.0 as shown at http://oss.oracle.com/licenses/upl

output "generated_ssh_private_key" {
  value     = tls_private_key.public_private_key_pair.private_key_pem
  sensitive = true
}

output "redis_manager_public_ip_address" {
  value = data.oci_core_vnic.redis_manager_vnic.public_ip_address
}

output "ssh_to_redis_manager" {
  description = "convenient command to ssh to the redismanager host"
  value       = "ssh -i id_rsa -o ServerAliveInterval=10 opc@${data.oci_core_vnic.redis_manager_vnic.public_ip_address}"
}

output "rancher_url" {
  description = "rancher url"
  value       = "https://${data.oci_core_vnic.redis_manager_vnic.public_ip_address}:443"
}

output "grafana_url" {
  description = "grafana url"
  value       = "http://${data.oci_core_vnic.redis_manager_vnic.public_ip_address}:3000"
}

output "redis_insight_url" {
  description = "redis insight url"
  value       = "http://${data.oci_core_vnic.redis_manager_vnic.public_ip_address}:8001"
}

output "redis_manager_tag_namespace_name" {
  value = oci_identity_tag_namespace.redis_manager_tag_namespace.name
}

output "redis_manager_tag_namespace_id" {
  value = oci_identity_tag_namespace.redis_manager_tag_namespace.id
}

output "redis_manager_tag_name" {
  value = oci_identity_tag.redis_manager_tag.name
}

output "redis_manager_tag_id" {
  value = oci_identity_tag.redis_manager_tag.id
}

output "dynamic_group_redis_dynamic_group" {
  value = oci_identity_dynamic_group.redis_dynamic_group.name
}

output "virtual_network_redis_vcn_id" {
  value = oci_core_virtual_network.redis_vcn.id
}

output "subnet_redis_subnet_id" {
  value = oci_core_subnet.redis_subnet.id
}