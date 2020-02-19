#!/usr/bin/env bash

#DELETE THE BOOTSTRAP'S DNS RECORDS AND INFORM THE INSTALLER TO PROCEED
#Note, the remaining api and api-int records should continue pointing towards the control-plane servers.

source 0_ocp4_vsphere_upi_init_vars

openshift-install --dir $CLUSTER wait-for install-complete
