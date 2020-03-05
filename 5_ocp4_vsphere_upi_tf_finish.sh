#!/usr/bin/env bash

source 0_ocp4_vsphere_upi_init_vars

pushd $CLUSTER/installer/upi/vsphere
terraform apply -auto-approve -var 'bootstrap_complete=true'
[ -d ~/.kube ] && rm -fr ~/.kube
mkdir ~/.kube
cp ../../../../$CLUSTER/auth/kubeconfig ~/.kube/config
popd
