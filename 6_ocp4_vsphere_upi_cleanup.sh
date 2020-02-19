#!/usr/bin/env bash

#DELETE THE BOOTSTRAP'S DNS RECORDS AND INFORM THE INSTALLER TO PROCEED
#Note, the remaining api and api-int records should continue pointing towards the control-plane servers.

#If you are using a named service for DNS, you can set  BOOTSTRAP_DISABLE_DNS="Y" in 0_ocp4_vsphere_upi_init_vars config file and re-run the 1_ocp4_vsphere_upi_optional_update_dns.sh.  This will generate and push a new DNS config which will disable/remove the bootstrap server from DNS.

source 0_ocp4_vsphere_upi_init_vars

openshift-install --dir $CLUSTER wait-for install-complete
