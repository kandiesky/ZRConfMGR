#!/bin/bash
#@Guilherme2041

#Instalação do Stunnel
echo Instalando Stunnel...
sleep 1
apt-get update
clear
apt-get install stunnel -y
clear
echo Instalado.
sleep 1

#Configuração
echo Configurando...
sleep 1
cat stunnel.conf >> /etc/stunnel/stunnel.conf
cat stunnel4 >> /etc/default/stunnel4
clear
echo Instalado.
echo Configurado.
sleep 1

#Gerando Certificado
echo Gerando Certifidado...
sleep 1
openssl genrsa -out key.pem 2048
openssl req -new -x509 -key key.pem -out cert.pem -days 1095
cat key.pem cert.pem >> /etc/stunnel/stunnel.pem
clear
echo Instalado.
echo Configurado.
echo Certificado Gerado.
sleep 1

#Iniciando Stunnel
echo Iniciando Stunnel...
sleep 1
service stunnel4 restart
clear
echo Instalado.
echo Configurado.
echo Certificado Gerado.
echo Stunnel iniciado.
sleep 1

echo Stunnel Instalado.
sleep 1