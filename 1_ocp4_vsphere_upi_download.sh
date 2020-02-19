#!/bin/bash

source 0_ocp4_vsphere_upi_init_vars

echo "Downloading release $BUILDNUMBER..."

# Download terraform

curl -s -O https://releases.hashicorp.com/terraform/${TERRAFORM_VER}/${TERRAFORM}
unzip ${TERRAFORM}
cp terraform /usr/local/bin
rm -f terraform 
rm -f ${TERRAFORM}

# Download JQ
yum install http://fedora-epel.mirror.iweb.com/7/x86_64/Packages/j/jq-1.6-1.el7.x86_64.rpm \
            http://fedora-epel.mirror.iweb.com/7/x86_64/Packages/o/oniguruma-5.9.5-3.el7.x86_64.rpm

# Download client and installer binaries
[ -f $CLIENT ] || curl -s -O https://mirror.openshift.com/pub/openshift-v4/clients/ocp/${RELEASE}/${CLIENT}
tar xzvf ${CLIENT}
[ -f $INSTALLER ] || curl -s -O https://mirror.openshift.com/pub/openshift-v4/clients/ocp/${RELEASE}/${INSTALLER}
tar xzvf ${INSTALLER}
cp oc kubectl openshift-install /usr/local/bin
chmod +x /usr/local/bin/oc /usr/local/bin/kubectl /usr/local/bin/openshift-install
rm -f oc kubectl openshift-install README.md
rm -f ${CLIENT} ${INSTALLER}

# Download GOVC
curl -s -L https://github.com/vmware/govmomi/releases/download/${GOVC_VER}/govc_linux_amd64.gz | gunzip > /usr/local/bin/govc
chmod +x /usr/local/bin/govc

# Download RHCOS image
curl -s -O https://mirror.openshift.com/pub/openshift-v4/dependencies/rhcos/${RHCOS}/latest/rhcos-${RHCOS}.0-x86_64-vmware.ova
govc vm.destroy /${GOVC_DATACENTER}/vm/${RHCOS_TEMPLATE}
govc import.ova -name=${RHCOS_TEMPLATE} rhcos-${RHCOS}.0-x86_64-vmware.ova
rm -f rhcos-${RHCOS}.0-x86_64-vmware.ova

