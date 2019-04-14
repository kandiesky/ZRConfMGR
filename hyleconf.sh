#!/bin/bash
echo -e "\e[1;104;37m Iniciando o script...! \e[0m"
#Cria a função da logo
function logo_spwn {
if [ -e "/usr/bin/figlet" ]; then
		figlet "VPS-Conf!"
		fig=1
else
	apt-get install figlet -y > /dev/null 2>&1
	if [ -e "/usr/bin/figlet" ];
        then
        logo_spwn
	else
		echo "VPS-Conf!"
		sleep 3
    fi
fi
if [ "$first" = '1' ]; then
    inst_shell
fi
}
#Cria a função de abrir o menu de opções, que analisa primeiro se o script já foi instalado
function menu_spwn {
if [ -e "/bin/ajuda" ]; then
	echo -e "\e[1;104;37m _________________________________________________________________ \e[0m"
    echo -e "\e[1;104;37m |Foi detectada uma instalação antiga. Abrindo menu de opções... | \e[0m"
    echo -e "\e[1;104;37m ¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯ \e[0m"
    sleep 3
    clear
    function menu_txt {
    echo -e "\e[1;104;37m __________________________________________________ \e[0m"
    echo -e "\e[1;104;37m |1. Reinstalar script (Totalmente);              | \e[0m"
    echo -e "\e[1;104;37m |2. Atualizar scripts shell e squid;             | \e[0m"
    echo -e "\e[1;104;37m |3. Instalar BadVPN-UDPGW (UDP para SSH);        | \e[0m"
    echo -e "\e[1;104;37m |4. Instalar/Atualizar Kernel Liquorix;          | \e[0m"
    echo -e "\e[1;104;37m |5. Desinstalar script(s);                       | \e[0m"
    echo -e "\e[1;104;37m |6. Sair.                                        | \e[0m"
    echo -e "\e[1;104;37m ¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯ \e[0m"
    read -p "Selecione uma opção: (1-6): " -e -i 1 menu_opc
        case $menu_opc in
        1)  first=1
            logo_spwn
            ;;
        2)  inst_shell
            ;;
        3)  inst_udpgw
            ;;
        4)  inst_lqrx
            ;;
        5)  wget https://scripts.zrcloud.xyz/vpsmanager/desinstalador.sh
            bash desinstalador.sh
            rm hyleconf.sh
            bye_spwn
            ;;
        6)  bye_spwn
            ;;
        *) echo "Insira uma opção válida (1-6)"
            menu_txt
            ;;
        esac 
}
        menu_txt
else
    first=1
    init_inst
fi
}
#Baixa partes necessárias para o script funcionar
function inst_shell {
echo "Iniciando download de partes do script..."
apt-get install wget -y > /dev/null 2>&1 #Instala o wget, caso o mesmo não esteja instalado
rm /bin/speedtest /bin/velocidade > /dev/null 2>&1 #Remove binárias antigas (VPS-CONF 0.9)
wget https://scripts.zrcloud.xyz/vpsmanager/conf/vpsconf.sh > /dev/null 2>&1
cd /usr/lib/
wget https://scripts.zrcloud.xyz/vpsmanager/conf/speedpy.tar.gz > /dev/null 2>&1
tar -xzf speedpy.tar.gz
rm speedpy.tar.gz #Remove arquivo orfão
cd /root/
ln -s /usr/lib/speedpy/speedtest /bin/speedtest #Symlink para transformar em executável do sistema
ln -s /usr/lib/speedpy/speedtest /bin/velocidade #Outro Symlink com a mesma finalidade
#Linhas a seguir irão corrigir as permissões para que seja possível executar as partes do script
chmod 777 vpsconf.sh
chmod 777 /bin/speedtest
#Inicia a instalação dos shell scripts
echo "Iniciando a instalação..."
echo "Atualizando pacotes antes de prosseguir a instalação..."
echo "Isso pode levar alguns minutos..."
sleep 3
apt-get update && apt-get dist-upgrade -y
clear
echo -e "\e[1;104;37m Terminado! Iniciando a instalação. \e[0m"
sleep 3
./vpsconf.sh
echo -e "\e[1;104;37m Continuando... \e[0m"
if [ "$first" = '1' ]; then
    inst_udpgw
else
    clear
    echo "Completado. Voltando ao menu..."
    sleep 5
    menu_txt
fi
}
#Cria a função para instalação do BADVPN -- UDPGW
function inst_udpgw {
#Verifica se o BadVPN já foi instalado
if [ -e "/bin/badudp" ]; then
	echo "BadVPN já instalado."
else
	read -p "Deseja instalar o UDP agora? (s/n): " -e -i s inst_udp
	case $inst_udp in
        [sS])   wget https://scripts.zrcloud.xyz/vpsmanager/conf/badvpnconf.sh > /dev/null 2>&1
                chmod 777 badvpnconf.sh 
                ./badvpnconf.sh
                sleep 3
            #Ativação de início automático para badudpgw
            read -p "Deseja ativar o início automático do BadUDP no servidor? (s/n): " -e -i s init_udp
                case $init_udp in
                            [sS]) 
                                wget https://scripts.zrcloud.xyz/vpsmanager/badvpn/badudp -O /etc/init.d/badudp
                                chmod 777 /etc/init.d/badudp
                                update-rc.d badudp enable > /dev/null 2>&1
                                echo "Configurado!"
                                echo "O UDP agora rodará automaticamente no boot."
                                ;;
                            [nN]) /bin/dudp > /dev/null 2>&1
                                echo "O UDP |NÃO| rodará automaticamente no boot."
                                ;;
                        esac
                ;;
		[nN])   echo "BadUDP não instalado."
                echo "Prosseguindo com a instalação..."
                ;;
    esac
fi
if [ "$first" = '1' ]; then
    inst_lqrx
else
    clear
    echo "Completado. Voltando ao menu..."
    sleep 5
    menu_txt
fi
}
#Cria a função para instalação da kernel liquorix
function inst_lqrx {
echo -e "\e[1;104;37m _________________________________________________________________________ \e[0m"
echo -e "\e[1;104;37m |Agora o Script tentará instalar a kernel modificada Liquorix.          | \e[0m"
echo -e "\e[1;104;37m |Se ela já estiver instalada, o script irá tentar atualizá-la.          | \e[0m"
echo -e "\e[1;104;37m |Caso não hajam atualizações, não acontecerá nada e o script finalizará.| \e[0m"
echo -e "\e[1;104;37m ¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯ \e[0m"
echo " "
read -p "Deseja instalar a kernel? (s/n) " -e -i s inst_kern
    case $inst_kern in
        [sS]) VERSAO=`lsb_release -c -s`
                if [ "$VERSAO" = 'trusty' ]; then
                echo "Não é possível instalar a kernel nesta versão do sistema."
                read -p "Gostaria de iniciar a atualização do sistema? (s/n): " -e -i s att_sist
                    if [[ "$att_sist" = 's' ]]; then
						rm badvpnconf.sh vpsconf.sh hyleconf.sh > /dev/null 2>&1
						do-release-upgrade
                    else
                        echo "Caso queira atualizar, utilize o comando do-release-upgrade manualmente."
                        inst_end
                    fi
                fi
                if [ "$VERSAO" = 'xenial' ]; then
                add-apt-repository ppa:ubuntu-toolchain-r/test -y
                clear
                echo "deb http://liquorix.net/debian sid main" | sudo tee /etc/apt/sources.list.d/liquorix.list
                apt-get update > /dev/null 2>&1
                apt-get install liquorix-keyring -y --allow-unauthenticated
                arch_type=`arch`
                    if [ "$arch_type" = 'x86_64' ]; then
                        apt-get install linux-image-liquorix-amd64 linux-headers-liquorix-amd64 -y --allow-unauthenticated
                        inst_end
                    else
                        apt-get install linux-image-liquorix-686 linux-headers-liquorix-686 -y --allow-unauthenticated
                        inst_end
                    fi
                else
                    echo "A kernel não pôde ser instalada. (Sistema imcompatível ou não propriamente detectado"
                    inst_end
                fi
                ;;
        [nN])   echo "A Kernel não foi instalada."
                inst_end
                ;;
    esac
if [ "$first" = '1' ]; then
    inst_end
else
    clear
    echo "Completado. Voltando ao menu..."
    sleep 5
    menu_txt
fi
}
#Executa uma leve limpeza para finalizar a instalação
function inst_end {
rm badvpnconf.sh vpsconf.sh hyleconf.sh > /dev/null 2>&1
echo -e "\e[1;104;37m Finalizando algumas modificações... \e[0m"
apt-get autoremove -y > /dev/null 2>&1
sleep 4
bye_spwn
}
function bye_spwn {
clear
if [ "$fig" = '1' ]; then
	figlet "Obrigado!"
else
	echo -e "\e[1;104;37m Obrigado! \e[0m"
fi
exit 1
}
function init_inst {
logo_spwn
inst_shell
}
#Roda a função para que o script seja carregado em cadeia.
menu_spwn
