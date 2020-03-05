#!/usr/bin/env bash

source 0_ocp4_vsphere_upi_init_vars

echo "Downloading release $BUILDNUMBER..."

# Download terraform

curl -s -O https://releases.hashicorp.com/terraform/${TERRAFORM_VER}/${TERRAFORM}
unzip ${TERRAFORM}
rm -f /usr/local/bin/terraform
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
rm -f /usr/local/bin/oc /usr/local/bin/kubectl /usr/local/bin/openshift-install
cp oc kubectl openshift-install /usr/local/bin
chmod +x /usr/local/bin/oc /usr/local/bin/kubectl /usr/local/bin/openshift-install
rm -f oc kubectl openshift-install README.md
rm -f ${CLIENT} ${INSTALLER}

# Download GOVC
curl -s -L https://github.com/vmware/govmomi/releases/download/${GOVC_VER}/govc_linux_amd64.gz | gunzip > /usr/local/bin/govc
chmod +x /usr/local/bin/govc

# Download RHCOS ova image
for i in $(curl -s --list-only https://mirror.openshift.com/pub/openshift-v4/dependencies/rhcos/${RHCOS}/latest/ | egrep "\-vmware" | grep href | sed 's/.*href="//' | sed 's/".*//' | grep '^[a-zA-Z].*'); do
  curl -s -O https://mirror.openshift.com/pub/openshift-v4/dependencies/rhcos/${RHCOS}/latest/$i
  govc vm.destroy /${GOVC_DATACENTER}/vm/${RHCOS_TEMPLATE}
  govc import.ova -name=${RHCOS_TEMPLATE} $i
done
rm -f rhcos-*

# Download RHCOS bare-metal image
for i in $(curl -s --list-only https://mirror.openshift.com/pub/openshift-v4/dependencies/rhcos/${RHCOS}/latest/ | egrep "\-installer|\-metal" | grep href | sed 's/.*href="//' | sed 's/".*//' | grep '^[a-zA-Z].*'); do
  curl -s -O https://mirror.openshift.com/pub/openshift-v4/dependencies/rhcos/${RHCOS}/latest/$i
done
if [ ! -d /var/www/html ]; then
  echo "WARNING:  /var/www/html does not exist!  Please make sure to install httpd service on this system.  The rhcos installer files will need to be copied to /var/www/html directory manually once HTTPD is installed." >&2
  exit 1
else
  rm -f /var/www/html/rhcos-*
  cp rhcos-* /var/www/html
  chmod 644 /var/www/html/rhcos-*
  rm -f rhcos-*
  if [ ! -d /var/lib/tftpboot ]; then
    echo "WARNING:  /var/lib/tftpboot does not exist!  Please make sure to install tftp-server on this system.  The rhcos installer kernel and image files will need to be copied to /var/lib/tftpboot directory manually once tftp-server is installed." >&2
    exit 1
  else
    rm -fr /var/lib/tftpboot/rhcos
    mkdir -p /var/lib/tftpboot/rhcos
    cp /var/www/html/rhcos-*-installer-initramfs.img /var/www/html/rhcos-*-installer-kernel /var/lib/tftpboot/rhcos
  fi
fi

