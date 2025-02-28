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

- Adding a bond interface and enslave a physical ethernet under it. Set mode, miimon and xmit_hash_policy:

    - Mode 4 = lacp (Link aggregation control protocol)

    - miimon = link monitoring packet interval
    
    - xmit_hash_policy = what policy to use when load-balancing traffic between the ports of a bond

Bond documentation: https://www.kernel.org/doc/Documentation/networking/bonding.txt

```
nmcli connection add type bond ifname bond0 con-name bond0

nmcli connection modify bond0 bond.options "mode=4,miimon=100,xmit_hash_policy=layer2+3"

nmcli connection add type ethernet ifname enp9s0 con-name bond0-port1 slave-type bond master bond0 

nmcli connection modify bond0 ipv4.method manual ipv4.addresses 10.178.121.23/24

nmcli connection up bond0-port1 

nmcli connection up bond0
```

- Adding ipv4 routes to a nmcli interface:

```
- One route:

nmcli connection modify bridge0 +ipv4.routes "192.168.121.0/24 10.74.7.3"

- Multiple routes:

nmcli connection modify bridge0 +ipv4.routes "192.168.121.0/24 10.74.7.3, 192.168.123.9/24 10.74.34.11"

- Route with source address:

nmcli connection modify bridge0 +ipv4.routes "192.168.182.0/24 10.185.111.111 src=10.185.111.112"
```

- Add a dummy interface and configure routes and policy based routing (from addresses):

```
nmcli connection add type dummy ifname dummy0 con-name dummy0 ipv4.method manual ipv4.addresses 198.51.100.201/25 ipv4.routes "198.41.100.0/25 198.51.100.200 table=140" ipv4.routing-rules "priority 140 from 198.51.100.201 table 140"

nmcli connection up dummy0
```

- Add a vrf interface and enslave it to table 150, then add a dummy interface, add routes for the respective interface:

```
nmcli connection add type vrf ifname vrf1 con-name vrf1 table 155 ipv4.method disabled ipv6.method disabled 

nmcli connection add type dummy ifname dummy1 con-name dummy1 master vrf1 ipv4.method manual ipv4.addresses 192.0.2.1/24 ipv4.gateway 10.85.0.1

nmcli connection up vrf1

nmcli connection up dummy1

```

- Verify ip routes on the vrf interface:

```
ip route sh ta 155
```

```
default via 10.85.0.1 dev dummy1 proto static metric 551 
10.85.0.1 dev dummy1 proto static scope link metric 551 
192.0.2.0/24 dev dummy1 proto kernel scope link src 192.0.2.1 metric 551 
local 192.0.2.1 dev dummy1 proto kernel scope host src 192.0.2.1 
broadcast 192.0.2.255 dev dummy1 proto kernel scope link src 192.0.2.1 
```


