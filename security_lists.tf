## Copyright (c) 2020, Oracle and/or its affiliates. 
## All rights reserved. The Universal Permissive License (UPL), Version 1.0 as shown at http://oss.oracle.com/licenses/upl

locals {
  tcp_protocol  = "6"
  all_protocols = "all"
  anywhere      = "0.0.0.0/0"
}

resource "oci_core_security_list" "redis_securitylist" {
  compartment_id = var.compartment_ocid
  vcn_id         = oci_core_virtual_network.redis_vcn.id
  display_name   = "${var.redis_prefix}_securitylist"

  defined_tags = {
    "${oci_identity_tag_namespace.redis_manager_tag_namespace.name}.${oci_identity_tag.redis_manager_tag.name}" = var.release
  }

  egress_security_rules {
    protocol    = local.tcp_protocol
    destination = local.anywhere
  }

  ingress_security_rules {
    protocol = local.tcp_protocol
    source   = local.anywhere

    tcp_options {
      max = "22"
      min = "22"
    }
  }

  ingress_security_rules {
    protocol    = local.tcp_protocol
    source      = local.anywhere
    description = "rancher"

    tcp_options {
      max = "443"
      min = "443"
    }
  }

  ingress_security_rules {
    protocol = local.tcp_protocol
    source   = local.anywhere

    tcp_options {
      max = "6379"
      min = "6379"
    }
  }

  ingress_security_rules {
    protocol = local.tcp_protocol
    source   = local.anywhere

    tcp_options {
      max = "16379"
      min = "16379"
    }
  }

  ingress_security_rules {
    protocol = local.tcp_protocol
    source   = var.VCN_CIDR

    tcp_options {
      max = "26379"
      min = "26379"
    }
  }

  ingress_security_rules {
    protocol    = local.tcp_protocol
    source      = local.anywhere
    description = "redis insight v2"

    tcp_options {
      max = "5000"
      min = "5000"
    }
  }

  ingress_security_rules {
    protocol    = local.tcp_protocol
    source      = local.anywhere
    description = "redis insight"

    tcp_options {
      max = "8001"
      min = "8001"
    }
  }

  ingress_security_rules {
    protocol    = local.tcp_protocol
    source      = local.anywhere
    description = "prometheus"

    tcp_options {
      max = "9090"
      min = "9090"
    }
  }

  ingress_security_rules {
    protocol    = local.tcp_protocol
    source      = local.anywhere
    description = "redis-prometheus"

    tcp_options {
      max = "9091"
      min = "9091"
    }
  }

  ingress_security_rules {
    protocol    = local.tcp_protocol
    source      = local.anywhere
    description = "redis exporter"

    tcp_options {
      max = "9121"
      min = "9121"
    }
  }

  ingress_security_rules {
    protocol    = local.tcp_protocol
    source      = local.anywhere
    description = "grafana"

    tcp_options {
      max = "3000"
      min = "3000"
    }
  }
}

