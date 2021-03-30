# vsphereupi-openshift

Pre-Requisites:
- Clone repo to the infra/helper host (running DNS/DHCP/PXE) and run scripts locally there.
- Installation supports configuring static IPs and will inject them via ignition configuration.

Before executing:
- Copy 0_ocp4_vsphere_upi_init_vars.template as 0_ocp4_vsphere_upi_init_vars and adapt the configuration to your environment.

To install:
- Run each shell script in order.
- There are some "optional" scripts such as DNS and local registry configuration which are optional steps.
- Normally, steps 1 - 8 would be the only steps needed to fully install a cluster.
  - Scripts identified with *_bm_* are meant for a bare-metal installation on Vsphere via PXE using the RHCOS raw image.
  - Scripts identified with *_tf_* are meant for a terraform installation on Vsphere using the RHCOS OVA.
- Step 8 will allow you to perform a kubeadmin password reset, if needed.
- Step 9 will destroy a provisioned cluster.

