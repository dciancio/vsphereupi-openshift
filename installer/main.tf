provider "vsphere" {
  user                 = var.vsphere_user
  password             = var.vsphere_password
  vsphere_server       = var.vsphere_server
  allow_unverified_ssl = true
}

data "vsphere_datacenter" "dc" {
  name = var.vsphere_datacenter
}

module "folder" {
  source = "./folder"

  path          = var.cluster_id
  datacenter_id = "${data.vsphere_datacenter.dc.id}"
}

module "resource_pool" {
  source = "./resource_pool"

  name            = "${var.cluster_id}"
  datacenter_id   = "${data.vsphere_datacenter.dc.id}"
  vsphere_cluster = "${var.vsphere_cluster}"
}

module "bootstrap" {
  source = "./machine"

  name             = "${var.bootstrap_prefix}"
  instance_count   = "${var.bootstrap_complete ? 0 : 1}"
  ignition_url     = "${var.bootstrap_ignition_url}"
  resource_pool_id = "${module.resource_pool.pool_id}"
  datastore        = "${var.vsphere_datastore}"
  folder           = "${module.folder.path}"
  network          = "${var.vm_network}"
  datacenter_id    = "${data.vsphere_datacenter.dc.id}"
  template         = "${var.vm_template}"
  cluster_domain   = "${var.cluster_domain}"
  ip_addresses     = "${compact(list(var.bootstrap_ip))}"
  machine_cidr     = "${var.machine_cidr}"
  machine_gw       = "${var.machine_gateway}"
  machine_dns1     = "${var.machine_dns1}"
  machine_dns2     = "${var.machine_dns2}"
  disk             = "${var.bootstrap_disk}"
  memory           = "${var.bootstrap_mem}"
  num_cpu          = "${var.bootstrap_cpu}"
}

module "control_plane" {
  source = "./machine"

  name             = "${var.control_plane_prefix}"
  instance_count   = "${var.control_plane_count}"
  ignition         = "${var.control_plane_ignition}"
  resource_pool_id = "${module.resource_pool.pool_id}"
  folder           = "${module.folder.path}"
  datastore        = "${var.vsphere_datastore}"
  network          = "${var.vm_network}"
  datacenter_id    = "${data.vsphere_datacenter.dc.id}"
  template         = "${var.vm_template}"
  cluster_domain   = "${var.cluster_domain}"
  ip_addresses     = "${var.control_plane_ips}"
  machine_cidr     = "${var.machine_cidr}"
  machine_gw       = "${var.machine_gateway}"
  machine_dns1     = "${var.machine_dns1}"
  machine_dns2     = "${var.machine_dns2}"
  disk             = "${var.control_plane_disk}"
  memory           = "${var.control_plane_mem}"
  num_cpu          = "${var.control_plane_cpu}"
}

module "compute" {
  source = "./machine"

  name             = "${var.compute_prefix}"
  instance_count   = "${var.compute_count}"
  ignition         = "${var.compute_ignition}"
  resource_pool_id = "${module.resource_pool.pool_id}"
  folder           = "${module.folder.path}"
  datastore        = "${var.vsphere_datastore}"
  network          = "${var.vm_network}"
  datacenter_id    = "${data.vsphere_datacenter.dc.id}"
  template         = "${var.vm_template}"
  cluster_domain   = "${var.cluster_domain}"
  ip_addresses     = "${var.compute_ips}"
  machine_cidr     = "${var.machine_cidr}"
  machine_gw       = "${var.machine_gateway}"
  machine_dns1     = "${var.machine_dns1}"
  machine_dns2     = "${var.machine_dns2}"
  disk             = "${var.compute_disk}"
  memory           = "${var.compute_mem}"
  num_cpu          = "${var.compute_cpu}"
}

