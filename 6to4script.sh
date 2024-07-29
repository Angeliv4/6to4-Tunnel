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
echo -e "${magenta}${bold}Angel IV 6to4 Tunnel SCRIPT${endcolor} "
echo ""
read -p "$(echo -e "${green}Which One To Choose:${endcolor}\n\n\
${yellow}1${endcolor} == ${blue}Tunnel IRAN${endcolor}\n\
${yellow}2${endcolor} == ${blue}Tunnel KHAREJ${endcolor}\n\
${yellow}3${endcolor} == ${blue}Remove Tunnel IRAN${endcolor}\n\
${yellow}4${endcolor} == ${blue}Remove Tunnel Kharej${endcolor}\n\n\
${yellow}5${endcolor} == ${blue}Enable Hybla${endcolor}\n\
${yellow}6${endcolor} == ${blue}Dissable Hybla${endcolor}\n\n\
${yellow}0${endcolor} == ${blue}Exit${endcolor}\n\n\
${green}Enter Number Activity :${endcolor}")" act
	if [ $act -eq 1 ]
	then
		echo ""
		read -p "$(echo -e ${yellow}Please Enter IPv4 IRAN :${endcolor}) " ip_iran
		echo ""
		read -p "$(echo -e ${yellow}Please Enter IPv4 KHAREJ${endcolor} :) " ip_kharej
		echo ""
		read -p "$(echo -e ${yellow}Please Enter Port SSH :${endcolor}) " ssh_port
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
			echo -e "${green}Please Configure Other Server And Wait 1 Minute ...${endcolor}"
			sleep 1m
			chmod +x /etc/rc.local
			/etc/rc.local
		fi
	
	elif [ $act -eq 2 ]
	then
		echo ""
		read -p "$(echo ${yellow}Please Enter IPv4 IRAN${endcolor} :) " ip_iran
		echo ""
		read -p "$(echo -e ${yellow}Please Enter IPv4 KHAREJ${endcolor}) : " ip_kharej
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
		echo -e "${green}Please Configure Other Server And Wait ...${endcolor} "
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
		echo -e "${green}Please Reboot Server !${endcolor}"
	elif [ $act -eq 4 ]
	then
		rm -rf /etc/rc.local
		ip tunnel del 6to4_To_IR
		ip tunnel del ipip6Tun_To_IR
	elif [ $act -eq 5 ]
	then
		kernel="uname -r"
		echo ""
		read -p "$(echo -e ${blue}To Run Hybla, Your Kernel Version Must Be Higher Than 2.6.13${endcolor}
${yellow}Your Kernel Version: $kernel${endcolor}

${green}Will The Performance Continue?${endcolor} ${yellow}(default == y)${endcolor} ${green}y\n ${endcolor})" hybla
		hybla=${hybla:-"y"}
		if [[ $hybla == "y" ]]
		then
			sudo modprobe tcp_hybla
			sudo sysctl -w net.ipv4.tcp_congestion_control=hybla
			echo -e "net.ipv4.tcp_congestion_control=hybla" >> /etc/sysctl.conf
			sudo sysctl -p
			if sysctl net.ipv4.tcp_available_congestion_control | grep -q 'hybla';
			then
				echo ""
				echo -e "${green}Hybla Is Enabled ...${endcolor}"
			else
				echo ""
				echo -e "${red}Hybla Is Not Enabled !${endcolor}"
			fi
		elif [[ $hybla == "n" ]]
		then
			bash <(curl -Ls https://raw.githubusercontent.com/Angeliv4/6to4-Tunnel/main/6to4script.sh)
		else
			echo ""
			echo -e "${red}Invalid Input Activity !!${endcolor}"
		fi
	elif [ $act -eq 6 ]
	then
		if sysctl net.ipv4.tcp_available_congestion_control | grep -q 'hybla';
			then
				sudo sysctl -w net.ipv4.tcp_congestion_control=cubic
				sudo sed -i 's/net.ipv4.tcp_congestion_control=hybla/net.ipv4.tcp_congestion_control=cubic/' /etc/sysctl.conf
				sudo sysctl -p
				echo ""
				echo -e "${green}Hybla Is Not Enabled !${endcolor}"
				sysctl net.ipv4.tcp_congestion_control
			else
				echo ""
				echo -e "${red}Hybla Is Not Enabled !${endcolor}"
		fi
	elif [ $act -eq 0 ]
	then
		echo ""
		echo -e "${magenta}${bold}Good By My Freind .${endcolor}"
	
	else
		echo ""
		echo -e "${red}Invalid Input Activity !!${endcolor}"
	fi