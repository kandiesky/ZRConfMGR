#!/bin/bash
IP=$(wget -qO- ipv4.icanhazip.com)

function chk_db {
if [ -f "/root/usuarios.db" ]
then
tput setaf 6 ; tput bold ;	echo ""
	echo "Uma base de dados de usuários ('usuarios.db') foi encontrada!"
	echo "Deseja mantê-la (preservando o limite de conexões simultâneas dos usuários)"
	echo "ou criar uma nova base de dados?"
	tput setaf 6 ; tput bold ;	echo ""
	echo "[1] Manter Base de Dados Atual"
	echo "[2] Criar uma Nova Base de Dados"
	echo "" ; tput sgr0
	read -p "Opção?: " -e -i 1 optiondb
else
	awk -F : '$3 >= 500 { print $1 " 1" }' /etc/passwd | grep -v '^nobody' > /root/usuarios.db
fi
if [[ "$optiondb" = '2' ]]; then
	awk -F : '$3 >= 500 { print $1 " 1" }' /etc/passwd | grep -v '^nobody' > /root/usuarios.db
fi
}
function qst_sqd {
if [ -e "/usr/sbin/squid3" ]; then
	echo -e "\e[1;34mSquid já instalado, prosseguindo... \e[0m"
else
	read -p "Você deseja instalar o Squid? (S/n) " sqd_aswn
	case "$sqd_aswn" in
		[Ss])	sqd_def=1
			;;
		[Nn])	sqd_def=0
			;;
		*)	echo "Resposta inválida. Tente novamente."
			qst_sqd
			;;
	esac
fi
}
function chk_fw { 
if [ -f "/usr/sbin/ufw" ] ; then
	ufw allow 443/tcp ; ufw allow 80/tcp ; ufw allow 3128/tcp ; ufw allow 8799/tcp ; ufw allow 8080/tcp ; ufw allow 143/tcp
fi
}
function inst_szip {
read -p "Deseja ativar a compressão SSH (pode aumentar o consumo de RAM)? [s/n]) " -e -i n sshcompression
if [[ "$sshcompression" = 's' ]]; then
	grep -v "^Compression yes" /etc/ssh/sshd_config > /tmp/sshcp && mv /tmp/sshcp /etc/ssh/sshd_config
	echo "Compression yes" >> /etc/ssh/sshd_config
else
	grep -v "^Compression yes" /etc/ssh/sshd_config > /tmp/sshcp && mv /tmp/sshcp /etc/ssh/sshd_config
fi
}
function inst_dep { 
tput setaf 7 ; tput setab 4 ; tput bold ; echo "" ; echo "Aguarde a configuração automática" ; echo "" ; tput sgr0
sleep 3
apt-get update -y > /dev/null 2>&1
apt-get dist-upgrade -y > /dev/null 2>&1
apt-get install bc screen nano unzip dos2unix wget -y > /dev/null 2>&1
}
function inst_rmold {
rm /bin/criarusuario /bin/expcleaner /bin/sshlimiter /bin/addhost /bin/listar /bin/sshmonitor /bin/ajuda > /dev/null 2>&1
rm /root/ExpCleaner.sh /root/CriarUsuario.sh /root/sshlimiter.sh > /dev/null 2>&1
}
function inst_sqd {
apt-get install squid3 -y > /dev/null 2>&1
if [ -d "/etc/squid3/" ]
then
	echo "http_port 80
http_port 8080
http_port 8799
http_port 3128
visible_hostname BETA
acl ip dstdomain $IP
http_access allow ip" > /etc/squid3/squid.conf
	echo 'acl accept dstdomain -i "/etc/squid3/payload.txt"
http_access allow accept
acl local dstdomain localhost
http_access allow local
acl iplocal dstdomain 127.0.0.1
http_access allow iplocal
http_access deny all' >> /etc/squid3/squid.conf
	echo "minhaclaro.claro.com.br
recargafacil.claro.com.br
frontend.claro.com.br
appfb.claro.com.sv
empresas.claro.com.br
d1n212ccp6ldpw.cloudfront.net
claro-gestoronline.claro.com.br
forms.claro.com.br
golpf.claro.com.br
logtiscap.claro.com.br
www.recargafacil.claro.com.br
.vivo.com.br
.bradescocelular.com.br
.claroseguridad.com" > /etc/squid3/payload.txt
	echo " " >> /etc/squid3/payload.txt
fi
if [ -d "/etc/squid/" ]
then
	wget https://scripts.zrcloud.xyz/vpsmanager/squid1.txt -O /tmp/sqd1
	echo "acl url3 dstdomain -i $ipdovps" > /tmp/sqd2
	wget https://scripts.zrcloud.xyz/vpsmanager/squid.txt -O /tmp/sqd3
	cat /tmp/sqd1 /tmp/sqd2 /tmp/sqd3 > /etc/squid/squid.conf
	wget https://scripts.zrcloud.xyz/vpsmanager/payload.txt -O /etc/squid/payload.txt
	echo " " >> /etc/squid/payload.txt
fi
if [ ! -f "/etc/init.d/squid3" ]
	then
		service squid3 reload
	else
		systemctl restart squid
fi
}
function inst_shell {
	wget https://scripts.zrcloud.xyz/vpsmanager/scripts/addhost.sh -O /bin/addhost
	chmod +x /bin/addhost
	wget https://scripts.zrcloud.xyz/vpsmanager/scripts/alterarsenha.sh -O /bin/alterarsenha
	chmod +x /bin/alterarsenha
	wget https://scripts.zrcloud.xyz/vpsmanager/scripts/criarusuario2.sh -O /bin/criarusuario
	chmod +x /bin/criarusuario
	wget https://scripts.zrcloud.xyz/vpsmanager/scripts/delhost.sh -O /bin/delhost
	chmod +x /bin/delhost
	wget https://scripts.zrcloud.xyz/vpsmanager/scripts/expcleaner2.sh -O /bin/expcleaner
	chmod +x /bin/expcleaner
	wget https://scripts.zrcloud.xyz/vpsmanager/scripts/mudardata.sh -O /bin/mudardata
	chmod +x /bin/mudardata
	wget https://scripts.zrcloud.xyz/vpsmanager/scripts/remover.sh -O /bin/remover
	chmod +x /bin/remover
	wget https://scripts.zrcloud.xyz/vpsmanager/scripts/sshlimiter2.sh -O /bin/sshlimiter
	chmod +x /bin/sshlimiter
	wget https://scripts.zrcloud.xyz/vpsmanager/scripts/alterarlimite.sh -O /bin/alterarlimite
	chmod +x /bin/alterarlimite
	wget https://scripts.zrcloud.xyz/vpsmanager/scripts/ajuda.sh -O /bin/ajuda
	chmod +x /bin/ajuda
	wget https://scripts.zrcloud.xyz/vpsmanager/scripts/sshmonitor2.sh -O /bin/sshmonitor
	chmod +x /bin/sshmonitor
	wget https://scripts.zrcloud.xyz/vpsmanager/scripts/iudp.sh -O /bin/iudp
	chmod +x /bin/iudp
	wget https://scripts.zrcloud.xyz/vpsmanager/scripts/dudp.sh -O /bin/dudp
	chmod +x /bin/dudp
	wget https://scripts.zrcloud.xyz/vpsmanager/scripts/menu.sh -O /bin/menu
	chmod +x /bin/menu
	grep -v "^Port 443" /etc/ssh/sshd_config > /tmp/ssh && mv /tmp/ssh /etc/ssh/sshd_config
	echo "Port 443" >> /etc/ssh/sshd_config
	echo "Port 143" >> /etc/ssh/sshd_config
	grep -v "^PasswordAuthentication" /etc/ssh/sshd_config > /tmp/passlogin && mv /tmp/passlogin /etc/ssh/sshd_config
	echo "PasswordAuthentication yes
Banner /etc/banner" >> /etc/ssh/sshd_config
	service ssh restart
}
case "$1" in
	1)	inst_sqd
		rm conf.sh
		;;
	2)	inst_shell
		rm conf.sh
		;;
	"-i")
		chk_db
		chk_fw
		inst_szip
		inst_dep
		inst_rmold
		inst_sqd
		inst_shell
		;;
	"-id")
		chk_db
		chk_fw
		qst_sqd
		inst_szip
		inst_dep
		inst_rmold
		if [ "sqd_def" = '1' ]; then
			inst_sqd
		fi
		inst_shell
		;;
	*)	echo "Você está executando o script errado."
		exit 4
		;;
esac
