#!/bin/bash
# export all virt-manager VMs in one go
mkdir -p storage/virt-xml
for vm in `sudo virsh list --all | awk 'NR>2 && $2 != "" {print $2}'`; do sudo virsh dumpxml $vm > storage/virt-xml/$vm.vml; done
