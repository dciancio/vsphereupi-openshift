#!/usr/bin/env bash

# Delete bootstrap VM
govc vm.destroy /${GOVC_DATACENTER}/vm/${BOOTSTRAP_PREFIX}-0

# Delete master VMs
for i in $(seq 1 ${MASTER_COUNT}); do
  COUNT=$(($i - 1))
  govc vm.destroy /${GOVC_DATACENTER}/vm/${MASTER_PREFIX}-${COUNT}
done

# Delete worker VMs
for i in $(seq 1 ${WORKER_COUNT}); do
  COUNT=$(($i - 1))
  govc vm.destroy /${GOVC_DATACENTER}/vm/${WORKER_PREFIX}-${COUNT}
done

govc folder.delete /${GOVC_DATACENTER}/vm/${CLUSTER}
govc pool.delete   /${GOVC_DATACENTER}/host/${GOVC_CLUSTER}/Resources/${CLUSTER}

