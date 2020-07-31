//////
// vSphere variables
//////

variable "vsphere_server" {
  type        = string
  description = "This is the vSphere server for the environment."
}

variable "vsphere_user" {
  type        = string
  description = "vSphere server user for the environment."
}

variable "vsphere_password" {
  type        = string
  description = "vSphere server password"
}

variable "vsphere_cluster" {
  type        = string
  description = "This is the name of the vSphere cluster."
}

variable "vsphere_datacenter" {
  type        = string
  description = "This is the name of the vSphere data center."
}

variable "vsphere_datastore" {
  type        = string
  description = "This is the name of the vSphere data store."
}

variable "vm_template" {
  type        = string
  description = "This is the name of the VM template to clone."
}

variable "vm_network" {
  type        = string
  description = "This is the name of the publicly accessible network for cluster ingress and access."
}

/////////
// OpenShift cluster variables
/////////

variable "cluster_id" {
  type        = string
  description = "This cluster id must be of max length 27 and must have only alphanumeric or hyphen characters."
}

variable "base_domain" {
  type        = string
  description = "The base DNS zone to add the sub zone to."
}

variable "cluster_domain" {
  type        = string
  description = "The base DNS zone to add the sub zone to."
}

variable "machine_cidr" {
  type = string
}

variable "machine_gateway" {
  type = string
}

variable "machine_dns1" {
  type = string
}

variable "machine_dns2" {
  type = string
}

/////////
/////////
// Bootstrap machine variables
/////////

variable "bootstrap_prefix" {
  type = string
}

variable "bootstrap_complete" {
  type    = string
  default = "false"
}

variable "bootstrap_ignition_url" {
  type = string
}

variable "bootstrap_ip" {
  type = string
}

variable "bootstrap_disk" {
  type = string
}

variable "bootstrap_mem" {
  type = string
}

variable "bootstrap_cpu" {
  type = string
}

///////////
// Control Plane machine variables
///////////

variable "control_plane_prefix" {
  type = string
}

variable "control_plane_count" {
  type    = string
}

variable "control_plane_ignition" {
  type = string
}

variable "control_plane_ips" {
  type    = list
}

variable "control_plane_disk" {
  type = string
}

variable "control_plane_mem" {
  type = string
}

variable "control_plane_cpu" {
  type = string
}

//////////
// Compute machine variables
//////////

variable "compute_prefix" {
  type = string
}

variable "compute_count" {
  type    = string
}

variable "compute_ignition" {
  type = string
}

variable "compute_ips" {
  type    = list
}

variable "compute_disk" {
  type = string
}

variable "compute_mem" {
  type = string
}

variable "compute_cpu" {
  type = string
}
