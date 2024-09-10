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
${yellow}6${endcolor} == ${blue}Disable Hybla${endcolor}\n\
${yellow}7${endcolor} == ${blue}Enable Bbr${endcolor}\n\
${yellow}8${endcolor} == ${blue}Disable Bbr${endcolor}\n\n\
${yellow}9${endcolor} == ${blue}Run Bench Script${endcolor}\n\n\
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
			/etc/rc.local > /dev/null
			echo ""
			echo -e "${green}tunnel is running ...${endcolor}"
		fi
	
	elif [ $act -eq 2 ]
	then
		echo ""
		read -p "$(echo -e ${yellow}Please Enter IPv4 IRAN${endcolor} :) " ip_iran
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
		echo -e "${green}Please Configure Other Server And Wait 1 Minute ...${endcolor} "
		sleep 1m
		/etc/rc.local > /dev/null
		echo ""
		echo -e "${green}tunnel is running ...${endcolor}"
	elif [ $act -eq 3 ]
	then 
		ip tunnel del ipip6Tun_To_KH
		ip tunnel del 6to4_To_KH
		iptables -F
		iptables -X
		iptables -P INPUT ACCEPT
		iptables -P FORWARD ACCEPT
		iptables -P OUTPUT ACCEPT
		rm -r /etc/rc.local
		echo ""
		echo -e "${green}Please Reboot Server !${endcolor}"
	elif [ $act -eq 4 ]
	then
		rm -rf /etc/rc.local
		ip tunnel del 6to4_To_IR
		ip tunnel del ipip6Tun_To_IR
	elif [ $act -eq 5 ]
	then
		kernel=$(uname -r)
		echo ""
		read -p "$(echo -e "${blue}To Run Hybla, Your Kernel Version Must Be Higher Than 2.6.13${endcolor}\n\
${yellow}Your Kernel Version: $kernel${endcolor}\n\n\
${green}Will The Performance Continue?${endcolor} ${yellow}(default = y)${endcolor}${green} y/n : ${endcolor}")" hybla
		hybla=${hybla:-"y"}
		if [[ $hybla == "y" ]]
		then
			sudo modprobe tcp_hybla
			sudo sysctl -w net.ipv4.tcp_congestion_control=hybla
			order="net.ipv4.tcp_congestion_control"
			feedback="hybla"
			file="/etc/sysctl.conf"
			if grep -q "^$order" "$file"; 
			then
				sudo sed -i "s/^$order.*/$order=$feedback/" "$file"
			else
				echo "net.ipv4.tcp_congestion_control=hybla" >> /etc/sysctl.conf
			fi
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
			else
				echo ""
				echo -e "${red}Hybla Is Not Enabled !${endcolor}"
		fi
	elif [ $act -eq 7 ]
	then
		kernel=$(uname -r)
		echo ""
		read -p "$(echo -e "${blue}To Run Bbr, Your Kernel Version Must Be Higher Than 4.9${endcolor}\n\
${yellow}Your Kernel Version: $kernel${endcolor}\n\n\
${green}Will The Performance Continue?${endcolor} ${yellow}(default = y)${endcolor}${green} y/n : ${endcolor}")" bbr
		bbr=${bbr:-"y"}
		if [[ $bbr == "y" ]]
		then
			sudo modprobe tcp_bbr
			grep -qxF "tcp_bbr" /etc/modules-load.d/modules.conf || echo "tcp_bbr" | sudo tee -a /etc/modules-load.d/modules.conf
			if grep -q "net.core.default_qdisc=" /etc/sysctl.conf; 
			then
				sudo sed -i 's/^net.core.default_qdisc=.*/net.core.default_qdisc=fq/' /etc/sysctl.conf
			else
				echo "net.core.default_qdisc=fq" | sudo tee -a /etc/sysctl.conf
			fi
			if grep -q "net.ipv4.tcp_congestion_control=" /etc/sysctl.conf;
			then
				sudo sed -i 's/^net.ipv4.tcp_congestion_control=.*/net.ipv4.tcp_congestion_control=bbr/' /etc/sysctl.conf
			else
				echo "net.ipv4.tcp_congestion_control=bbr" | sudo tee -a /etc/sysctl.conf
			fi
			sudo sysctl -p
			echo ""
			echo -e "${green}Bbr Is Enabled !${endcolor}"
		elif [[ $bbr == "n" ]]
		then
			bash <(curl -Ls https://raw.githubusercontent.com/Angeliv4/6to4-Tunnel/main/6to4script.sh)
		else
			echo ""
			echo -e "${red}Invalid Input Activity !!${endcolor}"
		fi
	elif [ $act -eq 8 ]
	then
		if grep -q "net.core.default_qdisc=" /etc/sysctl.conf; 
			then
				sudo sed -i 's/^net.core.default_qdisc=.*/net.core.default_qdisc=fq_codel/' /etc/sysctl.conf
			else
				echo "net.core.default_qdisc=fq" | sudo tee -a /etc/sysctl.conf
		fi
		if grep -q "net.ipv4.tcp_congestion_control=" /etc/sysctl.conf;
			then
				sudo sed -i 's/^net.ipv4.tcp_congestion_control=.*/net.ipv4.tcp_congestion_control=cubic/' /etc/sysctl.conf
			else
				echo "net.ipv4.tcp_congestion_control=cubic" | sudo tee -a /etc/sysctl.conf
		fi
		sudo sysctl -p
		echo ""
		echo -e "${green}Bbr Is Not Enabled !${endcolor}"
	elif [ $act -eq 9 ]
	then
		curl -Lso- bench.sh | bash
	elif [ $act -eq 0 ]
	then
		echo ""
		echo -e "${magenta}${bold}Good Bye My Freind .${endcolor}"
	
	else
		echo ""
		echo -e "${red}Invalid Input Activity !!${endcolor}"
	fi