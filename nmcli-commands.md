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

- Bond documentation:

[Bond documentation](https://www.kernel.org/doc/Documentation/networking/bonding.txt)

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

- Add a default route to a specific routing table

mmcli connection modify enp10s0 ipv4.gateway 10.0.0.87 ipv4.route-table 165
```

- Add a dummy interface and configure routes and policy based routing (from addresses):

```
nmcli connection add type dummy ifname dummy0 con-name dummy0 ipv4.method manual ipv4.addresses 198.51.100.201/25 ipv4.routes "198.41.100.0/25 198.51.100.200 table=140" ipv4.routing-rules "priority 140 from 198.51.100.201 table 140"

nmcli connection up dummy0
```

- Add a vrf interface and enslave it to table 155, then add a dummy interface, add routes for the respective interface:

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

- Create a vxlan interface using nmcli:

Steps:

1. Create a ethernet interface with IP settings

2. Create a bridge over that ethernet interface

3. Create a VXLAN interface and bring it to the bridge

By default NetworkManager uses udp port 8472 for the connection, so I changed it

When a VM connects to this interface `libvirtd` automatically creates a vnetX interface for the VM with type TAP (tunnel access point).

```
nmcli connection add type ethernet ifname enp10s0 con-name enp10s0 ipv4.method manual ipv4.addresses 100.64.0.3/24 ipv4.gateway 100.64.0.1  

nmcli connection add type bridge ifname bridge2 con-name bridge2 ipv4.method disabled ipv6.method disabled 

nmcli connection add type vxlan port-type bridge con-name vxlan-bridge2 ifname vxlan10 id 10 local 100.64.0.3 remote 100.66.0.2 controller bridge2

nmcli connection modify vxlan-bridge2 destination-port 4789

```

If you want to further use the vxlan for VM traffic with virt-manager, add a bridge xml file:

Save this as vxlan-bridge2.xml

```
<network>
 <name>vxlan-bridge2</name>
 <forward mode="bridge" />
 <bridge name="bridge2" />
</network>

```
Then run as root:

```
virsh net-define ~/vxlan-bridge2.xml

virsh net-start vxlan-bridge2

virsh net-autostart vxlan-bridge2
```

To verify vnet interfaces created run the following:
```
ip link show master vxlan-bridge2
```

For other documentation see:

[Vxlan configuration](https://docs.redhat.com/en/documentation/red_hat_enterprise_linux/9/html/configuring_and_managing_networking/assembly_using-a-vxlan-to-create-a-virtual-layer-2-domain-for-vms_configuring-and-managing-networking#proc_configuring-the-ethernet-interface-on-the-hosts_assembly_using-a-vxlan-to-create-a-virtual-layer-2-domain-for-vms)


- Add an IPv6 address to a interface with nmcli:

```
nmcli connection add type dummy ifname dummy6 con-name dummy6 ipv4.method disabled ipv6.method manual ipv6.addresses fe80:1234:1234:1122:1234:1234:1234::/64

nmcli connection up dummy6
```

- Add an IPv6 route, ipv6 routing rule and an ipv6 gateway to the existing connection:


```
 nmcli connection modify dummy6 ipv6.gateway fe80:1234:1234:1122::1 ipv6.routes "fe80:1234:1133:1234::/64 fe80:1234:1234:1122::3 table=160" ipv6.routing-rules "priority 160 from fe80:1234:1234:1122:1234:1234:1234::/64 table 160"
```

Verifying ipv6 routes:

```
ip -6 ro sh table 160
fe80:1234:1133:1234::/64 via fe80:1234:1234:1122::3 dev dummy6 proto static metric 552 pref medium


ip -6 rule
0:      from all lookup local
160:    from fe80:1234:1234:1122:1234:1234:1234:0/64 lookup 160 proto static
1000:   from all lookup [l3mdev-table]
32766:  from all lookup main

ip -6 route 
::1 dev lo proto kernel metric 256 pref medium
fe80::/64 dev enp10s0 proto kernel metric 1024 pref medium
fe80::/64 dev enp1s0 proto kernel metric 1024 pref medium
fe80::/64 dev enp7s0 proto kernel metric 1024 pref medium
fe80::/64 dev enp7s0.50 proto kernel metric 1024 pref medium
fe80::/64 dev bridge0 proto kernel metric 1024 pref medium
fe80::/64 dev bond0 proto kernel metric 1024 pref medium
fe80::/64 dev dummy6 proto kernel metric 1024 pref medium
fe80:1234:1234:1122::/64 dev dummy6 proto kernel metric 552 pref medium
default via fe80:1234:1234:1122::1 dev dummy6 proto static metric 552 pref medium

```
As you can see the default route got added in the main routing table.

Add a bridge interface in virt-manager in order to get bridged networking for the VMs:

Create a file named bridge.xml with the following content:

```
<network>
  <name>bridge0</name>
  <forward mode="bridge"/>
  <bridge name="bridge00"/>
</network
```

Then define the network with virsh:

```
sudo virsh net-define ./bridge.xml

sudo virsh net-start bridge0

sudo virsh net-autostart bridge0
```

Documentation for libvirt networking: https://libvirt.org/formatnetwork.html

- GRE tunnel configuration:

```
nmcli connection add type ip-tunnel ip-tunnel.mode gre con-name gre1 ifname gre1 remote 198.51.100.5 local 203.0.113.10

nmcli connection modify gre1 ipv4.method manual ipv4.addresses '10.0.1.1/30'

nmcli connection modify gre1 +ipv4.routes "172.16.0.0/24 10.0.1.2"

nmcli connection up gre1
```

- Enable IP forwarding:

```
echo "net.ipv4.ip_forward=1" > /etc/sysctl.d/95-IPv4-forwarding.conf
sysctl -p /etc/sysctl.d/95-IPv4-forwarding.conf
```

- Tunnels (ipip, gre, gretap) configuration with nmcli:

  [Documentation](https://docs.redhat.com/en/documentation/red_hat_enterprise_linux/8/html/configuring_and_managing_networking/configuring-ip-tunnels_configuring-and-managing-networking#configuring-a-gretap-tunnel-to-transfer-ethernet-frames-over-ipv4_configuring-ip-tunnels)
