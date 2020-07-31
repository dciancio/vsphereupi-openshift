#!/usr/bin/env bash

source 0_ocp4_vsphere_upi_init_vars

pushd $CLUSTER/installer
terraform destroy -auto-approve
popd

