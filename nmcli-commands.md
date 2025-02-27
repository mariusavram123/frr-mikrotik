NetworkManager - nmcli commands for specific tasks:


- Add a ethernet interface with static IP configured:

```
nmcli connection add type ethernet ifname <interface-name> con-name <connection-name> ipv4.method manual ipv4.address <IP>/<prefix> ipv4.gateway <GW-address>
```

Example:

```
nmcli connection add type ethernet ifname enp7s0 con-name enp7s0 ipv4.method manual ipv4.address 10.85.0.1/28
```

Rise the interface up:

```
nmcli connection up <connection-name>
```

Example:

```
nmcli connection up enp7s0
```

- Add one more ip to existing connection:

```
nmcli connection modify "enp7s0" +ipv4.address "192.168.56.200"
```

- Add a vlan interface to a existing connection:

```
nmcli connection add type vlan con-name enp7s0.50 ifname enp7s0.50 dev enp7s0 id 50 ipv4.method manual ipv4.addresses 10.85.150.2/28 ipv4.gateway 10.85.150.2

nmcli connection up enp7s0.50
```

- Modify connection parameters using the editor:

```
nmcli connection edit enp7s0.50

print

set connection.interface-name enp7s0.50

save 

quit
```

- Adding a bridge interface and add a slave interface under it:

```
nmcli connection add ifname bridge0 type bridge con-name bridge0

nmcli connection add type ethernet slave-type bridge con-name bridge0-port1 ifname enp8s0 master bridge0

nmcli connection up bridge0-port1

mmcli connection up bridge0

nmcli connection modify bridge0 ipv4.method manual ipv4.addresses 10.185.111.112/24

nmcli connection modify bridge0 bridge.stp no
```


