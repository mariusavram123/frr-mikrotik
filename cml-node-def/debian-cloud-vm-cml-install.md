### Import debian 13 VM in CML

- Download the debian cloud qcow2 image from here:

[debian-cloud-init-vms](https://cloud.debian.org/images/cloud/trixie/)

- Choose the one with generic in name and format qcow2

- Example: debian-13-generic-amd64-20250911-2232.qcow2

- Set up a root password for the VM (fedora linux host):

```
sudo dnf install guestfs-tools

virt-customize --add "debian-13-generic-amd64-20250911-2232.qcow2" --root-password password:<mypass> --hostname "debian13" --firstboot-command 'ssh-keygen -A && systemctl restart sshd'
```

- Upload the qcow2 file in cml - from image definitions

- Import the two yaml files in CML (node definition first and image definition second)
