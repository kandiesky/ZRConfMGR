#!/bin/bash
if [ -e "/bin/badudp" ];
	then
		wget http://kanprojects.zapto.org/vpsmanager/badvpn/badudp -O /etc/init.d/badudp
		chmod 777 /etc/init.d/badudp
		update-rc.d badudp enable > /dev/null 2>&1
		echo "Concluído! Início automático do UDP ativado com sucesso."
else
	echo "O BadVPN não está instalado. Não é possível concluir a ação"
fi
exit 1