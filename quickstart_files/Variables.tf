# Variables
# Please fill in the xxxxxx with your account values

variable "region" {
  # sample: eu-frankfurt-1
}

variable "tenancy_ocid" {
  # OCID of your OCI Account Tenancy
}

variable "compartment_ocid" {
# OCID of the compartment the existing VCN is in
}

# OS Images
variable "instance_os" {
  description = "Operating system for compute instances"
  default     = "Oracle Linux"
}

variable "linux_os_version" {
  description = "Operating system version for all Linux instances"
  default     = "8"
}

variable "instance_shape" {
   default = "VM.Standard.E2.1.Micro"
}

variable "instance_flex_shape_ocpus" {
    default = 1
}

variable "instance_flex_shape_memory" {
    default = 10
}

variable "ssh_public_key" {
  default = ""
}