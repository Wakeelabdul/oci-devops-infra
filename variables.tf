variable "compartment_id" {
  type        = string
  default = "ocid1.compartment.oc1..aaaaaaaao7qsoex4zk56vll7m33lwidivuvrh34iwnrfcl2pkstavqk3s5da"
  description = "The OCID of the compartment where resources will be created."
}

variable "region" {
  type        = string
  default     = "me-riyadh-1" # Set your local region
}

variable "kubernetes_version" {
  type    = string
  default = "v1.35.0" # Check OCI Console for the latest supported version
}

variable "node_shape" {
  type    = string
  default = "VM.Standard.E4.Flex"
}
