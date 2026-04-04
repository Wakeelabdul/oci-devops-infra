# 1. Create the Virtual Cloud Network (VCN)
resource "oci_core_vcn" "oke_vcn" {
  cidr_block     = "10.105.0.0/16"
  compartment_id = var.compartment_id
  display_name   = "devops-project-vcn"
  dns_label      = "okevcn"
}

# 2. Create an Internet Gateway
resource "oci_core_internet_gateway" "ig" {
  compartment_id = var.compartment_id
  display_name   = "ig-gateway"
  vcn_id         = oci_core_vcn.oke_vcn.id
}

# The Endpoint Subnet (Where the K8s API lives)
resource "oci_core_subnet" "endpoint_subnet" {
  cidr_block          = "10.105.0.0/28"
  compartment_id      = var.compartment_id
  vcn_id              = oci_core_vcn.oke_vcn.id
  display_name        = "oke-endpoint-subnet"
  security_list_ids   = [oci_core_security_list.endpoint_sec_list.id]
  prohibit_public_ip_on_vnic = false
}

# The Worker Node Subnet (Where your actual servers live)
resource "oci_core_subnet" "node_subnet" {
  cidr_block          = "10.105.1.0/24"
  compartment_id      = var.compartment_id
  vcn_id              = oci_core_vcn.oke_vcn.id
  display_name        = "oke-node-subnet"
  security_list_ids   = [oci_core_security_list.node_sec_list.id]
  prohibit_public_ip_on_vnic = true # Keep workers private for security
}

# 3. Create the OKE Cluster
resource "oci_containerengine_cluster" "oke_cluster" {
  compartment_id     = var.compartment_id
  endpoint_config {
    is_public_ip_enabled = true
    subnet_id            = oci_core_subnet.endpoint_subnet.id
  }
  kubernetes_version = var.kubernetes_version
  name               = "devops-hands-on-cluster"
  vcn_id             = oci_core_vcn.oke_vcn.id
  }

# 4. Create a Node Pool (The actual servers/workers)
resource "oci_containerengine_node_pool" "oke_node_pool" {
  cluster_id         = oci_containerengine_cluster.oke_cluster.id
  compartment_id     = var.compartment_id
  kubernetes_version = var.kubernetes_version
  name               = "primary-node-pool"
  node_shape         = var.node_shape

  node_source_details {
    image_id    = data.oci_core_images.latest_node_image.images[0].id
    source_type = "IMAGE"
  }

  node_config_details {
    placement_configs {
      availability_domain = data.oci_identity_availability_domains.ads.availability_domains[0].name
      subnet_id          = oci_core_subnet.node_subnet.id
    }
    size = 2 # Starts with 2 worker nodes
  }
}

# Data sources to get the latest Image and Availability Domains
data "oci_identity_availability_domains" "ads" {
  compartment_id = var.compartment_id
}

data "oci_core_images" "latest_node_image" {
  compartment_id           = var.compartment_id
  operating_system         = "Oracle Linux"
  operating_system_version = "8"
  shape                   = var.node_shape
  sort_by                 = "TIMECREATED"
  sort_order              = "DESC"
}
