### Setting a password to a Debian cloud vm using qemu (useful to install it in gns3)

```
sudo dnf install guestfs-tools

virt-customize --add "debian-13-generic-amd64-20250911-2232.qcow2" --root-password password:<mypass> --hostname "debian13" --firstboot-command 'ssh-keygen -A && systemctl restart sshd'
```
