#!/bin/bash

source 0_ocp4_vsphere_upi_init_vars

[ -d $CLUSTER ] && rm -fr $CLUSTER
mkdir $CLUSTER
cat >$CLUSTER/install-config.yaml <<EOF
apiVersion: v1
baseDomain: "${BASE_DOMAIN}"
metadata:
  name: "${CLUSTER}"
networking:
  machineCIDR: "${MACHINE_CIDR}"
platform:
  vsphere:
    vCenter: "${GOVC_URL}"
    username: "${GOVC_USERNAME}" 
    password: "${GOVC_PASSWORD}"
    datacenter: "${GOVC_DATACENTER}"
    defaultDatastore: "${GOVC_DATASTORE}"
EOF
if [ "$DISCONNECTED_INSTALL" = "Y" ]; then
cat >>$CLUSTER/install-config.yaml <<EOF
pullSecret: '{"auths":{"${LOCAL_REG}": {"auth": "${SECRET}","email": "noemail@localhost"}}}'
additionalTrustBundle: |
EOF
sed -e 's/^/  /' ${PWD}/opt/registry/certs/domain.crt >>$CLUSTER/install-config.yaml
cat >>$CLUSTER/install-config.yaml <<EOF
imageContentSources:
- mirrors:
  - ${LOCAL_REG}/${LOCAL_REPO}
  source: quay.io/${UPSTREAM_REPO}/${RELEASE_NAME}
- mirrors:
  - ${LOCAL_REG}/${LOCAL_REPO}
  source: quay.io/${UPSTREAM_REPO}/${IMG_DIGEST_PREFIX}
EOF
else
cat >>$CLUSTER/install-config.yaml <<EOF
pullsecret: '${PULL_SECRET}'
EOF
fi
cat >>$CLUSTER/install-config.yaml <<EOF
sshKey: '${SSH_KEY}'
EOF

