#!/usr/bin/env bash

##### THIS SCRIPT REQUIRES THAT PXE BOOT/TFTP SERVER ALREADY BE CONFIGURED

##### Make sure to have DRS enabled to allow for creation of resource pool for the cluster

source 0_ocp4_vsphere_upi_init_vars

govc pool.create   /${GOVC_DATACENTER}/host/${GOVC_CLUSTER}/Resources/${CLUSTER}
govc folder.create /${GOVC_DATACENTER}/vm/${CLUSTER}

# Create bootstrap VM
govc vm.create -m=8192 -c=4 -g=coreos64Guest -net.adapter=vmxnet3 -net=${GOVC_NETWORK} -disk.controller=pvscsi -disk=60GB -on=false -pool=/${GOVC_DATACENTER}/host/${GOVC_CLUSTER}/Resources/${CLUSTER} -folder=/${GOVC_DATACENTER}/vm/${CLUSTER} ${BOOTSTRAP_PREFIX}-0
govc vm.change -e="disk.enableUUID=1" -vm="/${GOVC_DATACENTER}/vm/${CLUSTER}/${BOOTSTRAP_PREFIX}-0"
govc vm.power -on=true /${GOVC_DATACENTER}/vm/${CLUSTER}/${BOOTSTRAP_PREFIX}-0

# Create master VMs
for i in $(seq 1 ${MASTER_COUNT}); do
  COUNT=$(($i - 1))
  govc vm.create -m=16384 -c=4 -g=coreos64Guest -net.adapter=vmxnet3 -net=${GOVC_NETWORK} -disk.controller=pvscsi -disk=60GB -on=false -pool=/${GOVC_DATACENTER}/host/${GOVC_CLUSTER}/Resources/${CLUSTER} -folder=/${GOVC_DATACENTER}/vm/${CLUSTER} ${MASTER_PREFIX}-${COUNT}
  govc vm.change -e="disk.enableUUID=1" -vm="/${GOVC_DATACENTER}/vm/${CLUSTER}/${MASTER_PREFIX}-${COUNT}"
  govc vm.power -on=true /${GOVC_DATACENTER}/vm/${CLUSTER}/${MASTER_PREFIX}-${COUNT}
done

# Create worker VMs
for i in $(seq 1 ${WORKER_COUNT}); do
  COUNT=$(($i - 1))
  govc vm.create -m=8192 -c=4 -g=coreos64Guest -net.adapter=vmxnet3 -net=${GOVC_NETWORK} -disk.controller=pvscsi -disk=60GB -on=false -pool=/${GOVC_DATACENTER}/host/${GOVC_CLUSTER}/Resources/${CLUSTER} -folder=/${GOVC_DATACENTER}/vm/${CLUSTER} ${WORKER_PREFIX}-${COUNT}
  govc vm.change -e="disk.enableUUID=1" -vm="/${GOVC_DATACENTER}/vm/${CLUSTER}/${WORKER_PREFIX}-${COUNT}"
  govc vm.power -on=true /${GOVC_DATACENTER}/vm/${CLUSTER}/${WORKER_PREFIX}-${COUNT}
done

# Generate PXE boot file

cat >default <<EOF
# Explicitly set default label to an unknown value.  Force user to enter a correct one below.
DEFAULT dummy
TIMEOUT 20
PROMPT 0

EOF

KERNEL=$(basename `ls /var/lib/tftpboot/rhcos/*-installer-kernel | sort | tail -1`)
INITRD=$(basename `ls /var/lib/tftpboot/rhcos/*-installer-initramfs.img | sort | tail -1`)
IMAGE=$(basename `ls /var/www/html/*-metal-bios* | sort | tail -1`)
NETMASK=$(ipcalc -m ${MACHINE_CIDR} | awk -F= '{print $2}')

# Add bootstrap entries
cat >>default <<EOF
LABEL ${CLUSTER}-${BOOTSTRAP_PREFIX}
    KERNEL rhcos/${KERNEL}
    APPEND rd.neednet=1 initrd=rhcos/${INITRD} console=tty0 console=ttyS0 coreos.inst=yes coreos.inst.install_dev=sda coreos.inst.image_url=http://${HOST_SHORT}.${BASE_DOMAIN}/${IMAGE} coreos.inst.ignition_url=http://${HOST_SHORT}.${BASE_DOMAIN}/${CLUSTER}-bootstrap.ign ip=${BOOTSTRAP_IP}::${MACHINE_GW}:${NETMASK}:${BOOTSTRAP_PREFIX}-0.${CLUSTER}.${BASE_DOMAIN}:ens192:none nameserver=${MACHINE_DNS1}
EOF

# Add master entries
COUNT=0
for i in $(echo $MASTER_IPS | tr -d '",'); do
cat >>default <<EOF
LABEL ${CLUSTER}-${MASTER_PREFIX}-${COUNT}
    KERNEL rhcos/${KERNEL}
    APPEND rd.neednet=1 initrd=rhcos/${INITRD} console=tty0 console=ttyS0 coreos.inst=yes coreos.inst.install_dev=sda coreos.inst.image_url=http://${HOST_SHORT}.${BASE_DOMAIN}/${IMAGE} coreos.inst.ignition_url=http://${HOST_SHORT}.${BASE_DOMAIN}/${CLUSTER}-master.ign ip=${$i}::${MACHINE_GW}:${NETMASK}:${MASTER_PREFIX}-${COUNT}.${CLUSTER}.${BASE_DOMAIN}:ens192:none nameserver=${MACHINE_DNS1}
EOF
COUNT=$(($COUNT + 1))
done

# Add worker entries
COUNT=0
for i in $(echo $WORKER_IPS | tr -d '",'); do
cat >>default <<EOF
LABEL ${CLUSTER}-${WORKER_PREFIX}-${COUNT}
    KERNEL rhcos/${KERNEL}
    APPEND rd.neednet=1 initrd=rhcos/${INITRD} console=tty0 console=ttyS0 coreos.inst=yes coreos.inst.install_dev=sda coreos.inst.image_url=http://${HOST_SHORT}.${BASE_DOMAIN}/${IMAGE} coreos.inst.ignition_url=http://${HOST_SHORT}.${BASE_DOMAIN}/${CLUSTER}-worker.ign ip=${$i}::${MACHINE_GW}:${NETMASK}:${WORKER_PREFIX}-${COUNT}.${CLUSTER}.${BASE_DOMAIN}:ens192:none nameserver=${MACHINE_DNS1}
EOF
COUNT=$(($COUNT + 1))
done

# Copy generated PXE boot file to /var/lib/tftpboot/pxelinux.cfg

if [ ! -d /var/lib/tftpboot/pxelinux.cfg ]; then
  echo "WARNING:  /var/lib/tftpboot/pxelinux.cfg does not exist!  Please make sure to create the directory on this system and copy the generated default pxe boot file to it." >&2
  exit 1
else
  mv /var/lib/tftpboot/pxelinux.cfg/default /var/lib/tftpboot/pxelinux.cfg/default.bak
  cp default /var/lib/tftpboot/pxelinux.cfg
  rm -f default
fi

