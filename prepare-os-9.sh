#!/bin/bash

# Used to prepare almalinux VMs to run labs in GNS3
# Add frr repo, add epel repo, install frr, install kernel-modules-extra

if [ $(id -u) != 0 ]; then
	echo "Please run as root or with sudo privileges"
	exit 17
fi

sed -i 's/^SELINUX=.*/SELINUX=disabled/' /etc/selinux/config

grep "^SELINUX" /etc/selinux/config

dnf install curl -y

# possible values for FRRVER: frr-6 frr-7 frr-8 frr-9 frr-10 frr-stable
# frr-stable will be the latest official stable release
FRRVER="frr-stable"

# add RPM repository on CentOS 6
#    Note: FRR only supported up to Version 7.4.x
#curl -O https://rpm.frrouting.org/repo/$FRRVER-repo-1-0.el6.noarch.rpm
#sudo yum install ./$FRRVER*

# add RPM repository on CentOS 7
#curl -O https://rpm.frrouting.org/repo/$FRRVER-repo-1-0.el7.noarch.rpm
#sudo yum install ./$FRRVER*

# add RPM repository on RedHat 8
#    Note: Supported since FRR 7.3
#curl -O https://rpm.frrouting.org/repo/$FRRVER-repo-1-0.el8.noarch.rpm
#sudo yum install ./$FRRVER*

# add RPM repository on RedHat 9
#    Note: Supported since FRR 8.3
curl -O https://rpm.frrouting.org/repo/$FRRVER-repo-1-0.el9.noarch.rpm
dnf install -y ./$FRRVER*

# install FRR
dnf install -y frr frr-pythontools epel-release kernel-modules-extra vim git-all iptables-services

dnf install -y libreswan openvpn easy-rsa

sed -i '$anet.ipv4.ip_forward = 1' /etc/sysctl.conf

cat /etc/sysctl.conf

sysctl -p

systemctl enable --now frr

systemctl enable --now iptables

echo "Selinux have been disabled. Please reboot the system to get the benefits."