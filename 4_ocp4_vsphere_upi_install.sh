#!/usr/bin/env bash

##### Make sure to have DRS enabled to allow for creation of resource pool for the cluster

source 0_ocp4_vsphere_upi_init_vars

pushd $CLUSTER
[ -d installer ] && rm -fr installer
git clone -b release-${RHCOS} https://github.com/openshift/installer
sed -e "s|\${CLUSTER}|${CLUSTER}|g" ../terraform.tfvars.template >terraform.tfvars.$$
sed -i -e "s|\${BASE_DOMAIN}|${BASE_DOMAIN}|g" terraform.tfvars.$$
sed -i -e "s|\${GOVC_URL}|${GOVC_URL}|" terraform.tfvars.$$
sed -i -e "s|\${GOVC_USERNAME}|${GOVC_USERNAME}|" terraform.tfvars.$$
sed -i -e "s|\${GOVC_PASSWORD}|${GOVC_PASSWORD}|" terraform.tfvars.$$
sed -i -e "s|\${GOVC_CLUSTER}|${GOVC_CLUSTER}|" terraform.tfvars.$$
sed -i -e "s|\${GOVC_DATACENTER}|${GOVC_DATACENTER}|" terraform.tfvars.$$
sed -i -e "s|\${GOVC_DATASTORE}|${GOVC_DATASTORE}|" terraform.tfvars.$$
sed -i -e "s|\${RHCOS_TEMPLATE}|${RHCOS_TEMPLATE}|" terraform.tfvars.$$
sed -i -e "s|\${GOVC_NETWORK}|${GOVC_NETWORK}|" terraform.tfvars.$$
sed -i -e "s|\${MACHINE_CIDR}|${MACHINE_CIDR}|" terraform.tfvars.$$
sed -i -e "s|\${MASTER_COUNT}|${MASTER_COUNT}|" terraform.tfvars.$$
sed -i -e "s|\${WORKER_COUNT}|${WORKER_COUNT}|" terraform.tfvars.$$
sed -i -e "s|\${BOOTSTRAP_IP}|${BOOTSTRAP_IP}|" terraform.tfvars.$$
sed -i -e "s|\${MASTER_IPS}|${MASTER_IPS}|" terraform.tfvars.$$
sed -i -e "s|\${WORKER_IPS}|${WORKER_IPS}|" terraform.tfvars.$$
sed -i -e "s|\${HOST_SHORT}|${HOST_SHORT}|" terraform.tfvars.$$
awk '/^END_OF_MASTER_IGNITION/{while(getline line<"master.ign"){print line}} //' terraform.tfvars.$$ >terraform.tfvars.$$.1
awk '/^END_OF_WORKER_IGNITION/{while(getline line<"worker.ign"){print line}} //' terraform.tfvars.$$.1 >installer/upi/vsphere/terraform.tfvars
rm -f terraform.tfvars.$$*

sed -i -e "s|gw   = \"\${cidrhost(var.machine_cidr,1)}\"|gw   = \"${MACHINE_GW}\"|" installer/upi/vsphere/machine/ignition.tf
sed -i -e "s|DNS1=1.1.1.1|DNS1=${MACHINE_DNS1}|" installer/upi/vsphere/machine/ignition.tf
sed -i -e "s|DNS2=9.9.9.9|DNS2=${MACHINE_DNS2}|" installer/upi/vsphere/machine/ignition.tf
sed -i -e 's|properties {|properties = {|' installer/upi/vsphere/machine/main.tf
sed -i -e '/module "dns"/i \
\/*' installer/upi/vsphere/main.tf
sed -i -e '$a\
*\/' installer/upi/vsphere/main.tf
sed -i -e "s|name             = \"bootstrap\"|name             = \"${BOOTSTRAP_PREFIX}\"|" installer/upi/vsphere/main.tf
sed -i -e "s|name             = \"control-plane\"|name             = \"${MASTER_PREFIX}\"|" installer/upi/vsphere/main.tf
sed -i -e "s|name             = \"compute\"|name             = \"${WORKER_PREFIX}\"|" installer/upi/vsphere/main.tf

pushd installer/upi/vsphere
terraform init
terraform apply -auto-approve
openshift-install --dir ../../../../$CLUSTER wait-for bootstrap-complete --log-level debug
popd
popd
