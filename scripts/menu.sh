#!/bin/bash
update_enabled=`egrep "^Update" /etc/hconf/config | sed "s/Update =//"`
if [ "$update_enabled" = ' 1' ]; then
	txt_1="Desativar"
	place_blank=""
else
	txt_1="Ativar"
	place_blank="   "
fi
if [ -e "/usr/sbin/openvpn" ]; then
	txt_2="Criar arquivo"
	place_blank2=""
	ovpn=1
else
	txt_2="Instalar"
	place_blank2="     "
	ovpn=0
fi
function menu_spwn {
echo ""
	echo -e "\e[1;104;37m _________________________________________________________ \e[0m"
    echo -e "\e[1;104;37m |1. $txt_1 atualizações automáticas do script;   $place_blank    | \e[0m"
    echo -e "\e[1;104;37m |2. Editar Banner (OpenSSH/Dropbear);                   | \e[0m"
    echo -e "\e[1;104;37m |3. $txt_2 OpenVPN;           $place_blank2                   | \e[0m"
    echo -e "\e[1;104;37m |4. Instalar/Reinstalar Dropbear;                       | \e[0m"
	echo -e "\e[1;104;37m |5. Instalar/Reinstalar GetTunnel (Doador);             | \e[0m"
	echo -e "\e[1;104;37m |6. Instalar/Reinstalar SocksV5 (Custom Proxy);         | \e[0m"
	echo -e "\e[1;104;37m |7. Instalar/Reinstalar SSLTunnel                       | \e[0m"
    echo -e "\e[1;104;37m |8. Desinstalar script (somente base);                  | \e[0m"
    echo -e "\e[1;104;37m |9. Reinstalar totalmente o script base;                | \e[0m"
	echo -e "\e[1;104;37m |U. Verificar se há atualizações;                       | \e[0m"
	echo -e "\e[1;104;37m |V. Informações sobre o script;                         | \e[0m"
    echo -e "\e[1;104;37m |0(Zero). Sair.                                         | \e[0m"
    echo -e "\e[1;104;37m ¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯ \e[0m"
read -p "Selecione uma opção: " -e -i V menu_opc
case "$menu_opc" in
	1)	if [ "$update_enabled" = '0' ]; then
			valor="1"
		else
			valor="0"
		fi
		sed "s/Update = 0/Update = $valor/" /etc/hconf/config > /tmp/config && mv /tmp/config /etc/hconf/config
		echo "Concluído! Voltando ao menu..."
		sleep 3
		menu_spwn
		;;
	2) 	echo "Banner atual:"
		echo " "
		cat /etc/banner
		echo " "
		read -p "Digite o novo texto para o banner: " bann
		echo "$bann" > /etc/banner
		;;
	3)	wget http://kanprojects.zapto.org/vpsmanager/conf/openvivoPWD.sh -O openvivoPWD.sh
		bash openvivoPWD.sh
		;;
	4) 	sleep 3
		clear
		if [ -e "/etc/squid3/squid.conf" ]; then
			squidfs="/etc/squid3"
		elif [ -e "/etc/squid/squid.conf" ]; then
			squidfs="/etc/squid"
		else
			squidfs="NS"
		fi
		echo -e "\e[1;104;37m __________________________________________________________________________ \e[0m"
		echo -e "\e[1;104;37m |Iniciando a instalação do Dropbear.                                     | \e[0m"
		echo -e "\e[1;104;37m |Se ela já estiver instalada, o script irá tentar atualizá-la.           | \e[0m"
		echo -e "\e[1;104;37m |Caso não hajam atualizações, não acontecerá nada e o script prosseguirá.| \e[0m"
		echo -e "\e[1;104;37m ¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯ \e[0m"
		echo " "
		read -p "Digite a porta que deseja que o dropbear execute(Padrão 80): " PORTADR
		wget http://kanprojects.zapto.org/vpsmanager/conf/conf.sh > /dev/null 2>&1
		chmod +x conf.sh
		bash conf.sh -id
		rm conf.sh > /dev/null 2>&1 
		apt-get install dropbear -y
		grep -v "^NO_START=1" /etc/default/dropbear > /tmp/drop1
		grep -v "^DROPBEAR_PORT=22" /tmp/drop1 > /tmp/drop2
		grep -v "^DROPBEAR_BANNER" /tmp/drop2 > /tmp/drop3
		if [ "$PORTADR" = '80' ]; then
			chk_sqd
				if [ "$squidfs" = 'NS' ]; then
					echo "Squid não instalado. Pulando a remoção de porta."
					PORTADR=80
				else
					grep -v "http_port 80" $squidfs/squid.conf > /tmp/sqdp
					mv /tmp/sqdp $squidfs/squid.conf
				fi
		elif [ "$PORTADR" = '443' ]; then
			grep -v "^Port 443" /etc/ssh/sshd_config > /tmp/sshd
			mv /tmp/sshd /etc/ssh/sshd_config
		else
			echo " "
		fi
		echo "NO_START=0
DROPBEAR_PORT=$PORTADR
DROPBEAR_BANNER=/etc/banner" >> /tmp/drop3
		mv /tmp/drop3 /etc/default/dropbear
		service dropbear start
		wget http://kanprojects.zapto.org/vpsmanager/scripts/criarusuario2drop.sh -O /bin/criarusuario
		clear
		echo "Completado. Voltando ao menu..."
		sleep 5
		menu_spwn
		;;
	5)	tput setaf 4; tput setab 7; echo "Insira a chave de doador! Caso não tenha uma, entre em contato com o Kandiesky no Telegram. " ; tput sgr0
		echo ""
		tput smul ; read -p "Chave: " ; tput rmul
		wget https://kanprojects.zapto.org/vpsconf/doador/$chavedoador/servercore.elf
		if [ -e "servercore.elf" ]; then
		chmod +x servercore.elf
./servercore.elf
			if [ -e "/bin/systemctl" ]; then 
				systemctl enable 96initsr
				systemctl start 96initsr
		else
				update-rc.d 96initsr defaults
			fi
		else
			echo "Chave digitada incorreta. Por favor, tente novamente."
			menu_spwn
		fi
		;;
	6)	wget http://kanprojects.zapto.org/vpsmanager/conf/soc.elf
		chmod +x soc.elf
./soc.elf
		if [ -e "/bin/systemctl" ]; then 
			systemctl enable 97initsr
			systemctl start 97initsr
		else
			update-rc.d 97initsr defaults
		fi
		;;
	7)	tput setaf 1 ; tput setab 3 ; echo "[ Iniciando instalação do SSLTunnel ]" ; tput sgr0
		sleep 4
		echo " " 
		echo " "
		tput setaf 1 ; tput setab 3
		echo "É preciso tirar algumas portas para que seja possível usar o SSLTunnel."
		echo "Você concorda com a remoção do uso da porta 443 de alguns programas?"
		echo "(Serão removidas apenas as portas das configurações de: OpenSSH e Dropbear, caso tenham)"
		echo "(Os programas em si não serão removidos, e serão configurados para executarem em outra porta automaticamente pelo script)" ; tput sgr0
		read -p "Concorda? (S ou N) " ssl_qst
		case $ssl_qst in
			[Ss])	if [ -e "/etc/default/dropbear" ]; then
						grep -v "Port 443" /etc/default/dropbear > /tmp/drop1
						mv /tmp/drop1 /etc/default/dropbear
						echo "Port 1043" >> /etc/default/dropbear
						echo "Adicionada porta 1043 ao Dropbear e removida 443"
					fi
					if [ -e "/etc/ssh/sshd_config" ]; then
						grep -v "Port 443" /etc/ssh/sshd_config > /tmp/ssh1
						mv /tmp/ssh1 /etc/ssh/sshd_config
						echo "Port 22" >> /etc/ssh/sshd_config
						echo "Adicionada porta 22 ao OpenSSH (Desconsidere cajo já tivesse)"
					fi
					wget https://kanprojects.zapto.org/vpsmanager/conf/stunnel.conf -O stunnel.conf
					wget https://kanprojects.zapto.org/vpsmanager/conf/stunnel4 -O stunnel4
					wget https://kanprojects.zapto.org/vpsmanager/conf/stunnel.sh -O stunnel.sh
					wget https://kanprojects.zapto.org/vpsmanager/conf/initsrStun -O /etc/init.d/69stunnel
					chmod +x /etc/init.d/69stunnel
					bash stunnel.sh
					rm stunnel*
					if [ -e "/bin/systemctl" ]; then
						systemctl enable 69stunnel
					else
						update.rc-d 69stunnel defaults
					fi
					tput setaf 1 ; tput setab 3 ; echo "[ Finalizado! ]" ; tput sgr0
					sleep 4
				;;
			[Nn])	echo "Voltando ao menu inicial então..."
					sleep 4
					menu_spwn
				;;
		esac
		;;
	8)	wget http://kanprojects.zapto.org/vpsmanager/desinstalador.sh
        bash desinstalador.sh 3
        rm vpsconf.sh
		;;
	9)	wget https://kanprojects.zapto.org/vpsconf/vpsconf.sh -O vpsconf.sh
		bash vpsconf.sh
		;;
	[Uu])	bash /etc/hconf/autoupdate
		;;
	[Vv])	versao=`cat /etc/hconf/versao.inf`
			echo -e "\e[1;104;37m Versão instalada: $versao \e[0m"
			echo -e "\e[1;104;37m Você tem as seguintes opções do script instaladas: \e[0m"
			echo " "
			echo " "
			echo -e "\e[1;104;37m------------------\e[0m"
			if [ -e "/bin/menu" ]; then
				echo -e "\e[1;104;37m●Menu - Script base \e[0m"
			fi
			if [ -e "/etc/default/dropbear" ]; then
				echo -e "\e[1;104;37m●Dropbear \e[0m"
			fi
			if [ -e "/bin/badudp" ]; then
				echo -e "\e[1;104;37m●BadVPN-UDPGW \e[0m"
			fi
			if [ -e "/usr/lib/squid/" ]; then
				echo -e "\e[1;104;37m●Squid(3) \e[0m"
			fi
			if [ -e "/etc/openvpn" ]; then
				echo -e "\e[1;104;37m●OpenVPN \e[0m"
			fi
			if [ -e "/usr/lib/greenview" ]; then
				echo -e "\e[1;104;37m●GetTunnel (Obrigado) \e[0m"
			fi
			if [ -e "/usr/lib/socksv6" ]; then
				echo -e "\e[1;104;37m●SocksV6 \e[0m"
			fi
			if [ -e "/etc/stunnel" ]; then
				echo -e "\e[1;104;37m●SSLTunnel \e[0m"
			fi
			echo -e "\e[1;104;37m------------------\e[0m"
			sleep 3	 
		;;
	0)	exit 1
		;;
esac
}
menu_spwn