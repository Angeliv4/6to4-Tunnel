#! /bin/bash
echo ""
echo ""
echo "Angel IV 6to4 Tunnel SCRIPT "
echo ""
read -p "Which one to choose:

1 == Tunnel IRAN
2 == Tunnel KHAREJ
3 == Remove Tunnel IRAN
4 == Remove Tunnel Kharej

Enter Number Activity : " act
	if [ $act -eq 1 ]
	then
		echo ""
		read -p "Please Enter IPv4 IRAN : " ip_iran
		echo ""
		read -p "Please Enter IPv4 KHAREJ : " ip_kharej
		echo ""
		read -p "Please Enter Port SSH : " ssh_port
		echo ""
		if ! [[ $ssh_port =~ ^[0-9]+$ ]]
		then
			echo "Invalid SSH Port !! "
		else
			ip tunnel add 6to4_To_KH mode sit remote $ip_kharej local $ip_iran
			ip -6 addr add fc00::1/64 dev 6to4_To_KH
			ip link set 6to4_To_KH mtu 1480
			ip link set 6to4_To_KH up
			touch /etc/rc.local
			echo "#! /bin/bash
ip tunnel add 6to4_To_KH mode sit remote $ip_kharej local $ip_iran
ip -6 addr add fc00::1/64 dev 6to4_To_KH
ip link set 6to4_To_KH mtu 1480
ip link set 6to4_To_KH up

ip -6 tunnel add ipip6Tun_To_KH mode ipip6 remote fc00::2 local fc00::1
ip addr add 192.168.13.1/30 dev ipip6Tun_To_KH
ip link set ipip6Tun_To_KH mtu 1440
ip link set ipip6Tun_To_KH up

sysctl net.ipv4.ip_forward=1
iptables -t nat -A PREROUTING -p tcp --dport $ssh_port -j DNAT --to-destination 192.168.13.1
iptables -t nat -A PREROUTING -j DNAT --to-destination 192.168.13.2
iptables -t nat -A POSTROUTING -j MASQUERADE 

exit 0" > /etc/rc.local
			chmod +x /etc/rc.local
			echo "Please configure other server and wait ..."
			sleep 1m
			/etc/rc.local
		fi
	
	elif [ $act -eq 2 ]
	then
		echo ""
		read -p "Please Enter IPv4 IRAN : " ip_iran
		echo ""
		read -p "Please Enter IPv4 KHAREJ : " ip_kharej
		echo ""
		ip tunnel add 6to4_To_IR mode sit remote $ip_iran local $ip_kharej
		ip -6 addr add fc00::2/64 dev 6to4_To_IR
		ip link set 6to4_To_IR mtu 1480
		ip link set 6to4_To_IR up
		touch /etc/rc.local
		echo "#! /bin/bash
ip tunnel add 6to4_To_IR mode sit remote $ip_iran local $ip_kharej
ip -6 addr add fc00::2/64 dev 6to4_To_IR
ip link set 6to4_To_IR mtu 1480
ip link set 6to4_To_IR up

ip -6 tunnel add ipip6Tun_To_IR mode ipip6 remote fc00::1 local fc00::2
ip addr add 192.168.13.2/30 dev ipip6Tun_To_IR
ip link set ipip6Tun_To_IR mtu 1440
ip link set ipip6Tun_To_IR up

exit 0" > /etc/rc.local
		chmod +x /etc/rc.local
		echo "Please configure other server and wait ... "
		sleep 1m
		/etc/rc.local

	elif [ $act -eq 3 ]
	then 
		rm -rf /etc/rc.local
		ip tunnel del ipip6Tun_To_KH
		ip tunnel del 6to4_To_KH
		iptables -F
		iptables -X
		iptables -P INPUT ACCEPT
		iptables -P FORWARD ACCEPT
		iptables -P OUTPUT ACCEPT
		echo ""
		echo "Please reboot server !"
	elif [ $act -eq 4 ]
	then
		rm -rf /etc/rc.local
		ip tunnel del 6to4_To_IR
		ip tunnel del ipip6Tun_To_IR
	else
		echo ""
		echo "Invalid Input Activity !!"
	fi