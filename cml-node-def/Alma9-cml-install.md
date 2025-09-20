### Import almalinux 9 VM in CML

- Download the almalinux generic cloud qcow2 image from here:

[Almalinux-cloud-vm](https://almalinux.org/get-almalinux/) - Cloud images section

- Set up a root password for the VM (fedora linux host):

```
sudo dnf install guestfs-tools

 virt-customize --add "AlmaLinux-9-GenericCloud-latest.x86_64.qcow2" --root-password password:<pass> --hostname "almalinux9-frr" --firstboot-command 'ssh-keygen -A && systemctl restart sshd'
```

- You can import it in virt-manager and customize it before importing in CML:

    - Start it, log in, install vim and git and disable selinux

    - Clone this git repo

    - Then run the `prepare-os-9.sh` script to get frr and everything up and running

- Upload the qcow2 file in CML - from image definitions

- Import the two yaml files in CML (node definition first and image definition second)
