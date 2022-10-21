#!/bin/bash

touch /var/log/bootscript.log

#Variável para log
log="/var/log/bootscript.log"

echo '===========================' >> $log
echo '====== Início Script ======' >> $log
echo '===========================' >> $log

# ========= Ajsute o Hostname da máquina

sudo echo "DevOpsXperience" > /etc/hostname
sudo hostname DevOpsXperience
bash

host_name=`cat /etc/hostname | grep DevOpsXperience`

if [ -z host_name ] # valida se a variável está vazia
then
	echo 'Arquivo Hostname NÃO foi atualizado' >> $log
	echo '===========================' >> $log
else
	echo 'Atualizado arquivo Hostname' >> $log
	echo '===========================' >> $log
fi

# ========= Instalação os pacotes ntpdate e curl

sudo apt update -y

echo 'Repositórios atualizados' >> $log
echo '===========================' >> $log

sudo apt install curl -y
sudo apt install ntpdate -y

# ========= Validando a isntalação

install_curl=`dpkg --list | grep curl | awk '{print $2}' | head -1`


	if [ -z $install_curl ]
	then
		echo "CURL não foi instalado" >> $log
		echo '===========================' >> $log
	else
		echo "CURL instalado com sucesso" >> $log
		echo '===========================' >> $log
	fi

install_ntpdate=`dpkg --list | grep ntpdate | awk '{print $2}' | head -1`

	if [ -z $install_ntpdate ]
	then
		echo "ntpdate não foi instalado" >> $log
	else
		echo "ntpdate instalado com sucesso" >> $log
	fi

# ========= Ajsute de data e fuso horário por NTP

sudo rm /etc/localtime
sudo ln -s /usr/share/zoneinfo/America/Sao_Paulo /etc/localtime
export TZ=America/Sao_Paulo

tz_date=`echo $TZ`

	if [ -n tz_date ] #Valida se a quantidade de caracteres na string é diferente de zero
	then
		echo "Arquivo localtime e variável TZ ajustados com sucesso" >> $log
		echo '===========================' >> $log
	else
		echo "Arquivo localtime e variável TZ NÃO foram ajustados" >> $log
		echo '===========================' >> $log
	fi

sudo ntpdate a.ntp.br

# ========= Validando o horário e data

horacerta=`date | awk '{print $5}' | grep 03`

	if [ -z horacerta]
	then
		echo "Fuso horário NÃO ajustado - verificar ntpdate e fuso horário" >> $log
		echo '===========================' >> $log
	else
		echo "Fuso horário ajustado para GMT -03 com sucesso" >> $log
		date >> $log
		echo '===========================' >> $log

	fi

# ========= Instalação do Docker

curl -sSL https://get.docker.com | bash
echo 'Instalado Docker' >> $log
echo '===========================' >> $log

# ========= Validando instalação do Docker

install_docker=`dpkg --list | grep docker | awk '{print $2}' | head -1`

	if [ -z $install_docker ]
	then
		echo "docker NÃO foi instalado" >> $log
		echo '===========================' >> $log
	else
		echo "docker instalado com sucesso" >> $log
		echo '===========================' >> $log
	fi

# ========= Iniciando o Docker

sudo systemctl start docker.service

docker_ativo=`sudo systemctl status docker.service | grep Active`

	if [ -z docker_ativo]
	then
		echo 'docker.service NÃO foi ativado' >> $log
		echo '===========================' >> $log
	else
		echo 'docker.service ativado' >> $log
		echo '===========================' >> $log
	fi

# ========= Adicionando usuario ubuntu no grupo Docker

sudo usermod -aG docker ubuntu

grupo_docker=`cat /etc/group | grep "docker.*ubuntu"`

	if [-z grupo_docker ]
	then
		echo 'Usuario Ubuntu NÃO FOI adicionado no grupo Docker' >> $log
		echo '===========================' >> $log
	else
		echo 'Usuario Ubuntu adicionado no grupo Docker' >> $log
		echo '===========================' >> $log
	fi

# ========= Criando o Container NGNIX

sudo docker run --name DevOps_Xperience -p 80:80 -d nginx
echo 'Iniciado Container NGINX' >> $log

# ========= Validando a criação do Container NGNIX

cont_nginx=`docker container ls | grep -i nginx`

if [ -z cont_nginx ]
then
	echo 'Erro ao criar Container NGNIX' >> $log
	echo '===========================' >> $log
else
	echo 'Container NGNIX criado com sucesso' >> $log
	echo '===========================' >> $log
fi

echo '===========================' >> $log
echo '============FIM============' >> $log
echo '===========================' >> $log