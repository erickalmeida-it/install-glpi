#!/bin/bash
# Descrição: GLPI INSTALL
# Criado por: Erick Almeida
# Data de Criacao: 25/08/2020
# Ultima Modificacao: 26/08/2020
# Compativél com o Ubuntu 18.04 (Homologado)

echo -e "\e[01;31m                    SCRIPT DE INSTALAÇÃO PARA O GLPI - INTERATIVO - UBUNTU SERVER 18.04     \e[00m"
echo -e "\e[01;31m                                       Tecle <ENTER> para iniciar...                       \e[00m"
read #pausa até que o ENTER seja pressionado

# ATUALIZAR REPOSITÓRIOS,PACOTES E A DISTRIBUIÇÃO DO SISTEMA OPERACIONAL

echo -e "\e[01;31m                  ATUALIZANDO PACOTES,REPOSITÓRIOS E A DISTRIBUIÇÃO DO SISTEMA OPERACIONAL                                \e[00m"
echo -e "\e[01;31m                                       Tecle <ENTER> para continuar...                       \e[00m"
read #pausa até que o ENTER seja pressionado

apt update -y
apt upgrade -y
apt dist-upgrade -y

# INSTALAR DE DEPENDENCIAS

echo -e "\e[01;31m                                          INSTALANDO DEPENDENCIAS                                 \e[00m"
echo -e "\e[01;31m                                       Tecle <ENTER> para continuar...                       \e[00m"
read #pausa até que o ENTER seja pressionado

apt-get install zip ca-certificates apache2 bsdtar bzip2 curl php7.2-json php7.2-bz2 libapache2-mod-php7.2 libmariadbd-dev mariadb-server php-soap php-cas php7.2 php-apcu php7.2-cli php7.2-common php7.2-curl php7.2-gd php7.2-imap php7.2-ldap php7.2-mysql php7.2-snmp php7.2-xmlrpc php7.2-xml php7.2-mbstring php7.2-bcmath php7.2-zip php7.2-intl php7.2-bz2 php-pear php-imagick php-memcache php7.2-pspell php7.2-recode php7.2-tidy php7.2-xsl php-gettext -y

# BAIXAR, EXTRAIR, MOVER E APAGAR DOWNLOAD DO GLPI 

echo -e "\e[01;31m                       BAIXAR, EXTRAIR, MOVER E APAGAR DOWNLOAD DO GLPI E PLUGINS                               \e[00m"
echo -e "\e[01;31m                                       Tecle <ENTER> para continuar...                       \e[00m"
read #pausa até que o ENTER seja pressionado

wget https://github.com/glpi-project/glpi/releases/download/9.5.1/glpi-9.5.1.tgz
tar -zxvf glpi-9.5.1.tgz
mv glpi /var/www/
rm -rf glpi-9.5.1.tgz
wget https://github.com/erickalmeida-it/downloads/raw/master/plugins-glpi.zip
unzip plugins-glpi.zip && rm -rf plugins-glpi.zip && mv * /var/www/glpi/plugins/

# AJUSTAR OS PERMISSIONAMENTOS DE ESCRITA 

echo -e "\e[01;31m                                AJUSTANDO OS PERMISSIONAMENTOS DE ESCRITA                            \e[00m"
echo -e "\e[01;31m                                       Tecle <ENTER> para continuar...                       \e[00m"
read #pausa até que o ENTER seja pressionado

chown www-data:www-data /var/www/glpi -Rf
chmod 775 /var/www/glpi -Rf

# CRIAÇÃO DO BANCO DE DADOS

echo -e "\e[01;31m                                         CRIANDO DO BANCO DE DADOS                          \e[00m"
echo -e "\e[01;31m                                       Tecle <ENTER> para continuar...                       \e[00m"
read #pausa até que o ENTER seja pressionado
echo -e "\e[01;31m                                     SIGA OS PASSOS NA SEGUINTE ORDEM:                         \e[00m"
echo -e "\e[01;31m                                             ENTER,N,Y,N,Y & Y                       \e[00m"
echo -e "\e[01;31m                                    USUARIO E SENHA PADRÃO DO DB É glpi                         \e[00m"
echo -e "\e[01;31m  CASO NECESSÁRIO VOCÊ PODE ALTERAR AS LINHAS 63,64 E 65 PARA DIFINIR USUARIO E SENHA DE ACORDO COM SUA PREFERENCIA \e[00m"

mysql_secure_installation 
mysql -e "create database glpidb character set utf8"
mysql -e "create user 'glpi'@'localhost' identified by 'glpi'"
mysql -e "grant all privileges on glpidb.* to 'glpi'@'localhost' with grant option"
mysql -e "flush privileges"

# CRIAR VIRTALHOST E HABILITAR O ACESSO WEB

echo -e "\e[01;31m                               CRIANDO VIRTALHOST E HABILITANDO O ACESSO WEB                          \e[00m"
echo -e "\e[01;31m                                       Tecle <ENTER> para continuar...                       \e[00m"
read #pausa até que o ENTER seja pressionado


echo "NameVirtualHost *:72
<VirtualHost *:72> 
  DocumentRoot /var/www/glpi
  #ServerName localhost
 <Directory /var/www/html/glpi>
  AllowOverride All
 </Directory>
 <Directory /var/www/html/glpi/config>
 Options -Indexes
  </Directory>
 <Directory /var/www/html/glpi/files> Options -Indexes
 </Directory>
</VirtualHost>" > /etc/apache2/sites-available/glpi.conf

sed -i '7i\\' /etc/apache2/ports.conf
sed -i '6s/$/ /' /etc/apache2/ports.conf
sed -i "6s/^./Listen 72/" /etc/apache2/ports.conf

a2ensite glpi
systemctl reload apache2


# AJUSTAR O APACHE

echo -e "\e[01;31m                                            AJUSTANDO O APACHE                          \e[00m"
echo -e "\e[01;31m                                       Tecle <ENTER> para continuar...                       \e[00m"
read #pausa até que o ENTER seja pressionado

sed -i 's/memory_limit = 128M/memory_limit = 512M/g' /etc/php/7.2/apache2/php.ini
sed -i 's/max_execution_time = 30/max_execution_time = 600/g' /etc/php/7.2/apache2/php.ini
sed -i 's/session.use_strict_mode = 0/session.use_strict_mode = 0/g' /etc/php/7.2/apache2/php.ini
sed -i 's/session.use_trans_sid = 0/session.use_trans_sid = 0/g' /etc/php/7.2/apache2/php.ini
sed -i 's/session.auto_start = 0/session.auto_start = off/g' /etc/php/7.2/apache2/php.ini
sed -i 's/upload_max_filesize = 2M/upload_max_filesize = 128M/g' /etc/php/7.2/apache2/php.ini
sed -i 's/file_uploads = On/file_uploads = On/g' /etc/php/7.2/apache2/php.ini

/etc/init.d/apache2 restart

# EFETUADO AJUSTE DE FIREWALL

echo -e "\e[01;31m                                            AJUSTANDO FIREWALL                          \e[00m"
echo -e "\e[01;31m                                       Tecle <ENTER> para continuar...                       \e[00m"
read #pausa até que o ENTER seja pressionado

systemctl enable ufw
ufw allow 22
ufw allow 80
ufw allow 443
ufw allow 72

echo -e "\e[01;31m                    NA INSTALAÇÃO ESTÁ INCLUSO OS PLUGINS ACTUAL-TIME E O MOD, HABILITE-OS     \e[00m"
echo -e "\e[01;31m             A INSTALAÇÃO SUCEDEU BEM, SEU SERVIDOR SERÁ REINICIADO E PODERÁS UTILIZAR O ERPNEXT     \e[00m"
echo -e "\e[01;31m                              EM SEU NAVEGADOR ACESSE http://IPDOSEUSERVIDOR:72     \e[00m"
echo -e "\e[01;31m                                       Tecle <ENTER> para encerrar...                       \e[00m"
read #pausa até que o ENTER seja pressionado
reboot