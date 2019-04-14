#!/bin/bash
function delete_sc {
read -p "Você deseja desinstalar VpsManager(1), VpsPack?(2) ou VPS-Conf(3): " -e -i 2 del
case "$1" in
    1)  echo "Removendo VPSManager"
        echo "Aguarde um instante..."
        sleep 4 
        rm /bin/criarusuario /bin/expcleaner /bin/sshlimiter /bin/addhost /bin/listar /bin/sshmonitor /bin/ajuda > /dev/null 2>&1
        rm /root/ExpCleaner.sh /root/CriarUsuario.sh /root/sshlimiter.sh > /dev/null 2>&1
        rm /bin/alterarsenha /bin/delhost /bin/mudardata /bin/remover /bin/alterarlimite > /dev/null 2>&1
        echo "VpsManager removido (Scripts Shell). Prosseguindo..."
        sleep 3
        delete_sq
        ;;
    2)  rm -rf /etc/VpsPackdir > /dev/null 2>&1
        rm /bin/limite /bin/criarusuario /bin/deletarusuario /bin/redefinirusuario /bin/vpspack /bin/speedtest.py /bin/removerhost /bin/addhost /etc/payloads > /dev/null 2>&1
        rm /etc/bannerssh > /dev/null 2>&1
        echo "VpsPack removido (Scripts Shell). Prosseguindo..."
        sleep 3
        delete_sq
        ;;
    3)  echo "Removendo VPS-Conf"
        echo "Aguarde um instante..."
        sleep 3
        rm /bin/criarusuario /bin/expcleaner /bin/sshlimiter /bin/addhost /bin/listar /bin/sshmonitor /bin/ajuda > /dev/null 2>&1
        rm /root/ExpCleaner.sh /root/CriarUsuario.sh /root/sshlimiter.sh > /dev/null 2>&1
        rm /bin/alterarsenha /bin/delhost /bin/mudardata /bin/remover /bin/alterarlimite > /dev/null 2>&1
        rm /bin/iudp /bin/dudp /etc/init.d/badudp /etc/systemd/system/badvpn.service > /dev/null 2>&1
        echo "VPS-Conf removido (Scripts Shell). Prosseguindo..."
        sleep 2
        delete_sq
        ;;
    *)
		echo "Opção inválida. Por favor, coloque uma opção válida."
		delete_sc
        ;;
esac
}
function delete_sq {
read -p "Deseja remover também as configurações do squid? (s/n): " -e -i n dsquid
case $dsquid in
    [sS][yY]) echo "Iniciando a remoção do squid com as configurações..."
		sleep 2
		rm -rf /etc/squid > /dev/null 2>&1
		rm -rf /etc/squid3 > /dev/null 2>&1
		apt-get remove --purge squid* -y
		echo "Concluído."
		sleep 2
		delete_ss
		;;
    [nN])   echo "Você optou por não remover o squid"
            echo "Concluído."
            sleep 3
            delete_ss
            ;;
    *)  echo "Insira uma opção válida."
        delete_sq
        ;;
esac
}
function delete_ss {
read -p "Deseja resetar as configurações do OpenSSH?(s/n): " -e -i n dssh
case $dssh in
    [nN])   echo "Concluído!"
            ;;
    [yY][sS])   echo "Removendo configurações feitas no sshd_config"
                cat /etc/ssh/sshd_config | grep -v "port 143" | grep -v "port 443" > /tmp/sshd
                mv /tmp/sshd /etc/ssh/sshd_config
                systemctl restart ssh > /dev/null 2>&1
                service ssh restart > /dev/null 2>&1
                echo "Concluído!"
            ;;
esac
}
delete_sc
echo "Não é preciso reiniciar a máquina para as alterações fazerem efeito"
echo "Contato: http://t.me/kandiesky"
rm desinstalar.sh > /dev/null 2>&1
