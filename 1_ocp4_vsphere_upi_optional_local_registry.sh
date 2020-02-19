#!/bin/bash

### THIS STEP IS ONLY REQUIRED IF YOU PLAN TO PERFORM A DISCONNECTED INSTALLATION ###

source 0_ocp4_vsphere_upi_init_vars

# Setup podman and httpd for local registry and webserver 
yum -y install podman httpd httpd-tools
firewall-cmd --add-port=5000/tcp --zone=internal --permanent
firewall-cmd --add-port=5000/tcp --zone=public   --permanent
firewall-cmd --add-service=http  --permanent
firewall-cmd --reload

podman stop -a
podman rm -a

[ -d ${PWD}/opt ] && rm -fr ${PWD}/opt
mkdir -p ${PWD}/opt/registry/{auth,certs,data}

pushd opt/registry/certs
openssl req -newkey rsa:4096 -nodes -sha256 -days 365 -x509 -subj "/C=US/ST=NC/L=Raleigh/O=GCS/CN=${HOST_SHORT}.${BASE_DOMAIN}" -keyout domain.key -out domain.crt
popd

htpasswd -bBc ${PWD}/opt/registry/auth/htpasswd ${LOCAL_REG_USER} ${LOCAL_REG_PWD}

podman run --name poc-registry -d -p 5000:5000 \
-v ${PWD}/opt/registry/data:/var/lib/registry:z \
-v ${PWD}/opt/registry/auth:/auth:z \
-e "REGISTRY_AUTH=htpasswd" \
-e "REGISTRY_AUTH_HTPASSWD_REALM=Registry" \
-e "REGISTRY_HTTP_SECRET=ALongRandomSecretForRegistry" \
-e REGISTRY_AUTH_HTPASSWD_PATH=/auth/htpasswd \
-v ${PWD}/opt/registry/certs:/certs:z \
-e REGISTRY_HTTP_TLS_CERTIFICATE=/certs/domain.crt \
-e REGISTRY_HTTP_TLS_KEY=/certs/domain.key \
docker.io/library/registry:2

podman stop poc-registry
podman start poc-registry

cp ${PWD}/opt/registry/certs/domain.crt /etc/pki/ca-trust/source/anchors/
update-ca-trust extract

curl -u ${LOCAL_REG_USER}:${LOCAL_REG_PWD} https://${LOCAL_REG}/v2/_catalog

