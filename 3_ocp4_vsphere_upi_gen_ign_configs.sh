#!/usr/bin/env bash

source 0_ocp4_vsphere_upi_init_vars

openshift-install --dir $CLUSTER create ignition-configs

systemctl status httpd >/dev/null 2>&1
if [ $? -ne 0 ]; then
  echo "WARNING:  HTTPD service is not running on this system.  The bootstrap.ign file has been generated but will need to manually be copied to the HTTPD server." >&2
  exit 1
else
  rm -f /var/www/html/bootstrap.ign
  cp ${CLUSTER}/bootstrap.ign /var/www/html
fi

