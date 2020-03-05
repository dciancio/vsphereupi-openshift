#!/usr/bin/env bash

source 0_ocp4_vsphere_upi_init_vars

pushd $CLUSTER/installer/upi/vsphere
terraform destroy -auto-approve
popd

