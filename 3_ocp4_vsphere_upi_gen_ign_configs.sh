#!/usr/bin/env bash

source 0_ocp4_vsphere_upi_init_vars

openshift-install --dir $CLUSTER create ignition-configs

[ -f /var/www/html/bootstrap.ign ] && rm -f /var/www/html/bootstrap.ign
pushd $CLUSTER
cp bootstrap.ign /var/www/html
popd

