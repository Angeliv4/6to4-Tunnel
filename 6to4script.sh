#! /bin/bash
yellow="\e[93m"
green="\e[92m"
blue="\e[96m"
magenta="\e[95m"
red="\e[91m"
endcolor="\e[0m"
bold="\e[1m"

echo ""
echo ""
echo "${magenta}${bold}Angel IV 6to4 Tunnel SCRIPT${endcolor} "
echo ""
read -e -p "${green}Which One To Choose:${endcolor}

${yellow}1${endcolor} == ${blue}Tunnel IRAN${endcolor}
${yellow}2${endcolor} == ${blue}Tunnel KHAREJ${endcolor}
${yellow}3${endcolor} == ${blue}Remove Tunnel IRAN${endcolor}
${yellow}4${endcolor} == ${blue}Remove Tunnel Kharej${endcolor}

${yellow}5${endcolor} == ${blue}Enable Hybla${endcolor}
${yellow}6${endcolor} == ${blue}Dissable Hybla${endcolor}

${yellow}0${endcolor} == ${blue}Exit${endcolor}


${green}Enter Number Activity :${endcolor} " act
	if [ $act -eq 1 ]
	then
		echo ""
		read -p "${yellow}Please Enter IPv4 IRAN :${endcolor} " ip_iran
		echo ""
		read -p "${yellow}Please Enter IPv4 KHAREJ${endcolor} : " ip_kharej
		echo ""
		read -p "${yellow}Please Enter Port SSH :${endcolor} " ssh_port
		echo ""
		if ! [[ $ssh_port =~ ^[0-9]+$ ]]
		then
			echo -e "${red}Invalid SSH Port !!${endcolor} "
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
			echo "${green}Please Configure Other Server And Wait 1 Minute ...${endcolor}"
			sleep 1m
			/etc/rc.local
		fi
	
	elif [ $act -eq 2 ]
	then
		echo ""
		read -p "${yellow}Please Enter IPv4 IRAN${endcolor} : " ip_iran
		echo ""
		read -p "${yellow}Please Enter IPv4 KHAREJ${endcolor} : " ip_kharej
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
		echo "${green}Please Configure Other Server And Wait ...${endcolor} "
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
		echo "${green}Please Reboot Server !${endcolor}"
	elif [ $act -eq 4 ]
	then
		rm -rf /etc/rc.local
		ip tunnel del 6to4_To_IR
		ip tunnel del ipip6Tun_To_IR
	elif [ $act -eq 5 ]
	then
		kernel="uname -r"
		echo ""
		read -p "${blue}To Run Hybla, Your Kernel Version Must Be Higher Than 2.6.13${endcolor}
${yellow}Your Kernel Version: $kernel${endcolor}

${green}Will The Performance Continue?${endcolor} ${yellow}(default == y)${endcolor} ${green}y\n ${endcolor}" hybla
		hybla=${hybla:-"y"}
		if [[ $hybla == "y" ]]
		then
			sudo modprobe tcp_hybla
			sudo sysctl -w net.ipv4.tcp_congestion_control=hybla
			echo "net.ipv4.tcp_congestion_control=hybla" >> /etc/sysctl.conf
			sudo sysctl -p
			if sysctl net.ipv4.tcp_available_congestion_control | grep -q 'hybla';
			then
				echo ""
				echo "${green}Hybla Is Enabled ...${endcolor}"
			else
				echo ""
				echo "${red}Hybla Is Not Enabled !${endcolor}"
			fi
		elif [[ $hybla == "n" ]]
		then
			bash <(curl -Ls https://raw.githubusercontent.com/Angeliv4/6to4-Tunnel/main/6to4script.sh)
		else
			echo ""
			echo "${red}Invalid Input Activity !!${endcolor}"
		fi
	elif [ $act -eq 6 ]
	then
		if sysctl net.ipv4.tcp_available_congestion_control | grep -q 'hybla';
			then
				sudo sysctl -w net.ipv4.tcp_congestion_control=cubic
				sudo sed -i 's/net.ipv4.tcp_congestion_control=hybla/net.ipv4.tcp_congestion_control=cubic/' /etc/sysctl.conf
				sudo sysctl -p
				echo ""
				echo "${green}Hybla Is Not Enabled !${endcolor}"
				sysctl net.ipv4.tcp_available_congestion_control
			else
				echo ""
				echo "${red}Hybla Is Not Enabled !${endcolor}"
		fi
	elif [ $act -eq 0 ]
	then
		echo ""
		echo "${magenta}${bold}Good By My Freind .${endcolor}"
	
	else
		echo ""
		echo "${red}Invalid Input Activity !!${endcolor}"
	fi