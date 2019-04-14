#!/bin/bash
if [ -e "/bin/badudp" ];
	then
		rm /etc/init.d/badudp
		echo "Concluído! Início automático do UDP desativado com sucesso!"
		echo "Reinicie para que faça efeito."
else
	echo "O BadVPN não está instalado. Não é possível concluir a ação."
fi
exit 1