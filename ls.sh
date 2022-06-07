#!bin/bash

#colors
YELLOW='\033[1;33m'

NC='\033[0m' 

GREEN='\033[0;32m'

RED='\033[0;31m'

echo -e "${YELLOW}>>CONFIGURING IP TABLES..${NC}"
iptables -P INPUT ACCEPT
iptables -P OUTPUT ACCEPT
iptables -P FORWARD ACCEPT
iptables -F
echo -e "${GREEN}>>FINISHED IP TABLES!${NC}"
echo -e "${YELLOW}>>ADDING "add-apt-repository" COMMAND..${NC}"
apt -y install software-properties-common curl apt-transport-https ca-certificates gnupg
echo -e "${GREEN}>>FINISHED ADDING "add-apt-repository" COMMAND!${NC}"
echo -e "${YELLOW}>>ADDING ADDITIONAL REPOSITORIES FOR PHP, REDIS AND MARIADB..${NC}"
LC_ALL=C.UTF-8 add-apt-repository -y ppa:ondrej/php
add-apt-repository ppa:redislabs/redis -y
echo -e "${GREEN}>>FINISHED ADDING ADDITIONAL REPOSITORIES FOR PHP, REDIS AND MARIADB!${NC}"
echo -e "${YELLOW}>>DOWNLOADING MARIADB REPO SETUP AND RUNNING IT...${NC}"
curl -sS https://downloads.mariadb.com/MariaDB/mariadb_repo_setup | sudo bash
echo -e "${GREEN}>>FINISHED DOWNLOADING MARIADB REPO SETUP AND RUNNING IT!${NC}"
echo -e "${YELLOW}>>INSTALLING NEEDED DEPENDENCIES..${NC}"
apt -y install php8.0 php8.0-{cli,gd,mysql,pdo,mbstring,tokenizer,bcmath,xml,fpm,curl,zip} mariadb-server nginx tar unzip git redis-server
echo -e "${GREEN}>>FINISHED DOWNLOADING DEPENDENCIES!${NC}"
echo -e "${RED}>>WANRING! MAKE SURE TO ADD THE INGRESS RULES FOR 80,8080,443,2022,25565-25665 TCP and 80,443,2022,25565-25665 UDP FOR MINECRAFT!${NC}"
echo -e "${YELLOW}>>INSTALLING COMPOSER..${NC}"
curl -sS https://getcomposer.org/installer | sudo php -- --install-dir=/usr/local/bin --filename=composer 
echo -e "${GREEN}>>FINISHED INSTALLING COMPOSER!${NC}"
echo -e "${YELLOW}>>CREATING NEEDED DIRECTORIES..${NC}"
mkdir -p /var/www/pterodactyl
cd /var/www/pterodactyl
echo -e "${GREEN}>>FINISHED CREATING DIRECTORIES!${NC}"
echo -e "${YELLOW}>>DOWNLOADING PANEL FILES..${NC}"
curl -Lo panel.tar.gz https://github.com/pterodactyl/panel/releases/latest/download/panel.tar.gz
tar -xzvf panel.tar.gz
chmod -R 755 storage/* bootstrap/cache/
echo -e "${GREEN}>>FINISHED DOWNLOADING PANEL FILES!${NC}"
echo -e "${YELLOW}>>CONFIGURING MYSQL..${NC}"
echo -e "${YELLOW}^What do you want your username to be? (pterodactyl)${NC}"
read MYSQL_USERNAME
echo -e "${YELLOW}^What do you want your password to be?${NC}"
read MYSQL_PASSWORD
echo -e "${YELLOW}^What do you want your panel name to be?(panel)${NC}"
read MYSQL_PANEL_NAME
mysql -u root -e "CREATE USER '$MYSQL_USERNAME'@'127.0.0.1' IDENTIFIED BY '$MYSQL_PASSWORD'"
mysql -u root -e "CREATE DATABASE $MYSQL_PANEL_NAME"
mysql -u root -e "GRANT ALL PRIVILEGES ON $MYSQL_PANEL_NAME.* TO '$MYSQL_USERNAME'@'127.0.0.1' WITH GRANT OPTION"
echo -e "${GREEN}>>FINISHED MYSQL CONFIGURATION!${NC}"
echo -e "${YELLOW}>>COPYING DEFAULT ENVIRONMENT SETTINGS FILE...${NC}"
cp .env.example .env
echo -e "${GREEN}>>FINISHED COPYING DEFAULT ENVIRONMENT SETTINGS FILE!${NC}"
echo -e "${YELLOW}>>INSTALLING CORE DEPENDANCIES...${NC}"
composer install --no-dev --optimize-autoloader
echo -e "${GREEN}>>FINISHED INSTALLING CORE DEPENDANCIES!${NC}"
echo -e "${YELLOW}>>CREATING ENCRYPTION KEY...${NC}"
php artisan key:generate --force
echo -e "${GREEN}>>FINISHED CREATING ENCRYPTION KEY!${NC}"
echo -e "${YELLOW}>>SETTING UP ENVIRONMENT...${NC}"
echo -e "${YELLOW}^What do you want your egg author email to be?${NC}"
read EGG_AUTHOR_EMAIL
echo -e "${YELLOW}^Please insert FQDN below without http(s)://${NC}"
read FQDN_VAR
php artisan p:environment:setup -n --author=$EGG_AUTHOR_EMAIL --url=https://$FQDN_VAR --timezone=America/New_York --cache=redis --session=redis --queue=redis --redis-host=127.0.0.1 --redis-pass= --redis-port=6379
echo -e "${GREEN}>>FINISHED SETTING UP ENVIRONMENT!${NC}"
echo -e "${YELLOW}>>SETTING UP DATABASE ENVIRONMENT..${NC}"
php artisan p:environment:database --host=127.0.0.1 --port=3306 --database=$MYSQL_PANEL_NAME --username=$MYSQL_USERNAME --password=$MYSQL_PASSWORD
echo -e "${GREEN}>>FINISHED SETTING UP DATABASE ENVIRONMENT!${NC}"
echo -e "${YELLOW}>>FINISHING DATABASE SETUP..${NC}"
php artisan migrate --seed --force
echo -e "${GREEN}>>FINISHED DATABASE SETUP!${NC}"
echo -e "${YELLOW}>>ADDING THE FIRST USER..${NC}"
php artisan p:user:make
echo -e "${GREEN}>>FINISHED MAKING USER!${NC}"
echo -e "${YELLOW}>>SETTING UP PERMISSIONS ON PANEL FILES (NGINX)..${NC}"
chown -R www-data:www-data /var/www/pterodactyl/*
echo -e "${GREEN}>>FINISHED FILE PERMISSIONS!${NC}"
(crontab -l ; echo "* * * * * php /var/www/pterodactyl/artisan schedule:run >> /dev/null 2>&1")cat
echo 'hi'
crontab -l ; echo "* * * * * php /var/www/pterodactyl/artisan schedule:run >> /dev/null 2>&1"cat
echo 'he'
(crontab -l ; echo "* * * * * php /var/www/pterodactyl/artisan schedule:run >> /dev/null 2>&1")
echo 'ea'
crontab -l ; echo "* * * * * php /var/www/pterodactyl/artisan schedule:run >> /dev/null 2>&1"