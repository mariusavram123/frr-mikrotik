THIS IS PURELY EXPERIMENTAL - DO NOT TRY IT

#Install frr on Mageia linux 9 (To test on Mageia linux 8 also)

```bash
#!/bin/bash
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
sudo dnf install ./$FRRVER*
sudo dnf install https://repo.almalinux.org/almalinux/9/BaseOS/x86_64/os/Packages/libxcrypt-4.4.18-3.el9.x86_64.rpm
# install FRR
sudo sed -i 's/gpgcheck=1/gpgcheck=0/' /etc/yum.repos.d/$FRRVER.repo
sudo dnf install frr frr-pythontools
```

frr service does not start
