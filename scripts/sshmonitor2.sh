#!/bin/bash
function datassh {
awk -F : '$3 >= 500 { print $1 }' /etc/passwd | grep -v '^nobody' | while read user
  do
	expire="$(chage -l $user | grep -E "Account expires" | cut -d ' ' -f3-)"
	if [[ $expire == "never" ]]
	then
		nunca="Nunca"
		printf '  %-30s%s\n' "$user" "Nunca"
	else
		databr="$(date -d "$expire" +"%Y%m%d")"
		hoje="$(date -d today +"%Y%m%d")"
		if [ $hoje -ge $databr ]
		then
			datanormal="$(date -d"$expire" '+%d/%m/%Y')"
			printf '  %-30s%s' "$user" "$datanormal" ; tput setaf 1 ; tput bold ; echo " (Expirado)" ; tput setaf 3
			echo "exp" > /tmp/exp
		else
			datanormal="$(date -d"$expire" '+%d/%m/%Y')"
			printf '  %-30s%s\n' "$user" "$datanormal"
		fi
	fi
  done
}
function dataovpn {
if [ -e "/etc/openvpn/" ]; then
	for _user in $(awk -F: '$3>=1000 {print $1}' /etc/passwd); do
		if [[ ! -z $(cat /etc/openvpn/*.log|grep ,${_user},) ]]; then
			_conn=$(cat /etc/openvpn/*.log|grep ,${_user},| wc -l)
			if [ "$_conn" = "1" ]; then
				_conn="Sim"
			else
				_conn="Não"
			fi
 		fi
	done
else
	stsovpn=1
fi
}
function showdatassh {
database="/root/usuarios.db"
echo $$ > /tmp/kids
while true
do
tput setaf 7 ; tput setab 1 ; tput bold ; printf '%28s%s%-18s\n' "SSH Monitor"
tput setaf 7 ; tput setab 1 ; printf '  %-25s%s\n' "Usuário" "Conexão/Limite"; echo "" ; tput sgr0
	while read usline
	do
		user="$(echo $usline | cut -d' ' -f1)"
		s2ssh="$(echo $usline | cut -d' ' -f2)"
		if [ -z "$user" ] ; then
			echo "" > /dev/null
		else
			ps x | grep [[:space:]]$user[[:space:]] | grep -v grep | grep -v pts > /tmp/tmp8
			s1ssh="$(cat /tmp/tmp8 | wc -l)"
			tput setaf 3 ; tput bold ; printf '  %-30s%s\n' $user $s1ssh/$s2ssh; tput sgr0
		fi
	done < "$database"
	echo ""
	break
done
}
function showdataovpn {
tput setaf 7 ; tput setab 1 ; tput bold ; printf '%28s%s%-18s\n' "OpenVPN Monitor"; tput sgr0
tput setaf 7 ; tput setab 1 ; printf '  %-30s%s\n' "Usuário" "Conectado?" ; tput sgr0
tput setaf 3 ; tput bold ; printf '  %-30s%s\n' $_user $_conn; tput sgr0
}
dataovpn
showdatassh
echo " "
if [ "$stsovpn" = "1" ]; then
	echo "Parece que o OpenVPN não está instalado nesta máquina."
else
	showdataovpn
fi
 read -p "Deseja também verificar a data de expiração dos usuários? (S/n) " -e -i s usrdate
case $usrdate in
	[Ss]) datassh
	;;
	[Nn]) echo " "
	;;
	*) echo "Opção inválida."
	;;
esac
tput sgr0
exit 1