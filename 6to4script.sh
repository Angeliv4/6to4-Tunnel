echo "6to4 Tunnel FOR IRAN SERVER"
echo "Please Enter IPv4 IRAN "
read ip_iran
echo "Please Enter IPv4 KHAREJ"
read ip_kharej
echo "Which one to choose:
1 == Tunnel IRAN
2 == Tunnel KHAREJ
3 == Remove Tunnel IRAN
4 == Remove Tunnel Kharej
Enter Number Activity : " 
read act
if [ $act -eq 1 ]
then
	touch /etc/rc.local
	chmod +w "/etc/rc.local"
	echo "#! /bin/bash
ip tunnel add 6to4_To_KH mode sit remote $ip_kharej local $ip_iran
ip -6 addr add fde8:b030:25cf::de01/64 dev 6to4_To_KH
ip link set 6to4_To_KH mtu 1480
ip link set 6to4_To_KH up

ip -6 tunnel add GRE6Tun_To_KH mode ip6gre remote fde8:b030:25cf::de02 local fde8:b030:25cf::de01
ip addr add 172.20.20.1/30 dev GRE6Tun_To_KH
ip link set GRE6Tun_To_KH mtu 1436
ip link set GRE6Tun_To_KH up

sysctl net.ipv4.ip_forward=1
iptables -t nat -A PREROUTING -p tcp --dport 22 -j DNAT --to-destination 172.20.20.1
iptables -t nat -A PREROUTING -j DNAT --to-destination 172.20.20.2
iptables -t nat -A POSTROUTING -j MASQUERADE 

exit 0" > /etc/rc.local
	
elif [ $act -eq 2 ]
then
	touch /etc/rc.local
	chmod +w "/etc/rc.local"
	echo "#! /bin/bash
ip tunnel add 6to4_To_IR mode sit remote $ip_iran local $ip_kharej
ip -6 addr add fde8:b030:25cf::de02/64 dev 6to4_To_IR
ip link set 6to4_To_IR mtu 1480
ip link set 6to4_To_IR up

ip -6 tunnel add GRE6Tun_To_IR mode ip6gre remote fde8:b030:25cf::de01 local fde8:b030:25cf::de02
ip addr add 172.20.20.2/30 dev GRE6Tun_To_IR
ip link set GRE6Tun_To_IR mtu 1436
ip link set GRE6Tun_To_IR up

exit 0" > /etc/rc.local

elif [ $act -eq 3 ]
then 
	rm -rf /etc/rc.local
	ip tunnel del 6to4_To_IR
	ip tunnel del GRE6Tun_To_IR
	iptables -F
	iptables -X
	iptables -P INPUT ACCEPT
	iptables -P FORWARD ACCEPT
	iptables -P OUTPUT ACCEPT
elif [ $act -eq 4 ]
then
	rm -rf /etc/rc.local
	ip tunnel del 6to4_To_IR
	ip tunnel del GRE6Tun_To_IR
else
	echo "Invalid Input Activity !!"
fi
