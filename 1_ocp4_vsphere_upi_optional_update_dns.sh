#!/usr/bin/env bash

source 0_ocp4_vsphere_upi_init_vars

DT=$(date +%Y%m%d%H%M%S)

cat >$CLUSTER.conf <<EOF
\$ORIGIN apps.${CLUSTER}.${BASE_DOMAIN}.
EOF

for i in $(echo $WORKER_IPS | tr -d '",'); do 
  echo "* A $i" >>${CLUSTER}.conf
done

cat >>$CLUSTER.conf <<EOF

\$ORIGIN ${CLUSTER}.${BASE_DOMAIN}.
EOF

for i in $(seq 1 ${MASTER_COUNT}); do
  COUNT=$(($i - 1))
  echo "_etcd-server-ssl._tcp SRV 0 10 2380 etcd-${COUNT}" >>${CLUSTER}.conf
done

echo "bootstrap-0 A ${BOOTSTRAP_IP}" >>${CLUSTER}.conf

COUNT=0
for i in $(echo $MASTER_IPS | tr -d '",'); do
  echo "control-plane-${COUNT} A $i" >>${CLUSTER}.conf
  COUNT=$(($COUNT + 1))
done

echo "api A ${BOOTSTRAP_IP}" >>${CLUSTER}.conf

for i in $(echo $MASTER_IPS | tr -d '",'); do
  echo "api A $i" >>${CLUSTER}.conf
done

echo "api-int A ${BOOTSTRAP_IP}" >>${CLUSTER}.conf

for i in $(echo $MASTER_IPS | tr -d '",'); do
  echo "api-int A $i" >>${CLUSTER}.conf
done

COUNT=0
for i in $(echo $MASTER_IPS | tr -d '",'); do
  echo "etcd-${COUNT} A $i" >>${CLUSTER}.conf
  COUNT=$(($COUNT + 1))
done

COUNT=0
for i in $(echo $WORKER_IPS | tr -d '",'); do
  echo "compute-${COUNT} A $i" >>${CLUSTER}.conf
  COUNT=$(($COUNT + 1))
done

echo >>${CLUSTER}.conf

if [ "$BOOTSTRAP_DISABLE_DNS" = "Y" ]; then
  sed -i -e "s/^\(.*\)${BOOTSTRAP_IP}/;\1${BOOTSTRAP_IP}/g" $CLUSTER.conf
fi

systemctl status named >/dev/null 2>&1
if [ $? -ne 0 ]; then
  echo "WARNING:  DNS (named) service is not running on this system.  Zone file (${CLUSTER}.conf) has been generated in the current directory.  You will need to copy this file to your DNS (named) server manually and activate it using \"\$INCLUDE /var/named/${CLUSTER}.conf\" directly in the base domain zone file (${NAMED_ZONE}) found in the /var/named directory." >&2
  exit 1
fi

DNS_CONFIG_CHANGED="N"
diff ${CLUSTER}.conf /var/named/$CLUSTER.conf >/dev/null
if [ $? -ne 0 ]; then
  [ -f /var/named/$CLUSTER.conf ] && mv /var/named/$CLUSTER.conf /var/named/$CLUSTER.conf.bak
  cp ${CLUSTER}.conf /var/named/$CLUSTER.conf
  DNS_CONFIG_CHANGED="Y"
fi

grep "^\$INCLUDE ./${CLUSTER}.conf" /var/named/${NAMED_ZONE} >/dev/null
if [ $? -ne 0 ]; then
  cp /var/named/${NAMED_ZONE} /var/named/${NAMED_ZONE}.${DT}
  echo "\$INCLUDE ./${CLUSTER}.conf" >>/var/named/${NAMED_ZONE}
  DNS_CONFIG_CHANGED="Y"
fi

if [ "$DNS_CONFIG_CHANGED" = "Y" ]; then
  sed -i -e "s/^\([[:space:]]\)\(.*\)\([[:space:]]\); serial number/                    ${DT}      ; serial number/" /var/named/${NAMED_ZONE}
  systemctl restart named
fi

rm -f ${CLUSTER}.conf

