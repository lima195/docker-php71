#!make

## Edit this vars:

MYSQL_DUMP_FILE=database.sql
BASE_URL=http://www.magento2.com/
PROJECT_NAME=magento2

## CUSTOM VARS


## Do not edit vars above:

DOCKER_DIR=docker-php71

NGINX_DOCKER=container_nginx
PHP_DOCKER=container_php
MYSQL_DOCKER=container_mysql
NGINX_WEB_ROOT=/usr/share/nginx/www

MAGENTO_LOCAL_XML=../$(DOCKER_DIR)/etc/magento/app/etc/local.xml
MAGENTO_LOCAL_XML_TO=$(NGINX_WEB_ROOT)/app/etc/local.xml
MAGENTO_MAGERUN=n98-magerun.phar
MAGENTO_MAGERUN_TO=/usr/local/bin

MAGENTO2_ENVPHP=../$(DOCKER_DIR)/etc/magento2/app/etc/env.php
MAGENTO2_ENVPHP_TO=$(NGINX_WEB_ROOT)/app/etc/env.php

MYSQL_DUMP_FILE_DIR=../mysql_dump
# MYSQL_USER=$(PROJECT_NAME)
MYSQL_USER=root
MYSQL_PASS=$(PROJECT_NAME)
MYSQL_DB_NAME=$(PROJECT_NAME)
MYSQL_HOST=172.22.0.103
MYSQL_PORT=3306

default:
	@echo "Please, specify a task to run:"
	@echo " "
	@echo " == Instal All =="
	@echo " - make install"
	@echo " "
	@echo " == Database =="
	@echo " - make db_install_pv"
	@echo " - make db_import"
	@echo " - make db_import_pv"
	@echo " - make db_drop_tables"
	@echo " "
	@echo " == Magento =="
	@echo " - make setup_magento (This will run all tasks above)"
	@echo " - make magento_update_baseurl"
	@echo " - make magento_create_localxml"
	@echo " - make magento_magerun_install"
	@echo " - make magento_magerun_create_admin"
	@echo " - make magento_cron_setup"
	@echo " - make magento_clear_cache"
	@echo " - make magento_set_permissions"
	@echo " "
	@echo " == Magento 2 =="
	@echo " - make setup_magento (This will run all tasks above)"
	@echo " - make magento2_update_baseurl"
	@echo " - make magento2_create_envphp"
	@echo " - make magento2_composer_install"
	@echo " - make magento_magerun_create_admin"
	@echo " - make magento_cron_setup"
	@echo " - make magento_clear_cache"
	@echo " - make magento_set_permissions"
	@echo " "
	@echo " == Docker =="
	@echo " - make install_cron"
	@echo " - make docker_up"
	@echo " "
	@echo " == Custom tasks for project =="
	@echo " "

## TASKS

## Custom Tasks



# Do not edit tasks above

# DATABASE

db_install_pv:
	sudo docker exec -it $(MYSQL_DOCKER) sh -c "apt-get update; apt-get install -y pv"

db_import:
	sudo docker cp $(MYSQL_DUMP_FILE_DIR)/$(MYSQL_DUMP_FILE) $(MYSQL_DOCKER):/$(MYSQL_DUMP_FILE);
	sudo docker exec -it $(MYSQL_DOCKER) sh -c "mysql -u $(MYSQL_USER) -p$(MYSQL_PASS) -h $(MYSQL_HOST) $(MYSQL_DB_NAME) < /$(MYSQL_DUMP_FILE) -P $(MYSQL_PORT)"

db_import_pv:
	sudo docker cp $(MYSQL_DUMP_FILE_DIR)/$(MYSQL_DUMP_FILE) $(MYSQL_DOCKER):/$(MYSQL_DUMP_FILE);
	sudo docker exec -it $(MYSQL_DOCKER) sh -c "pv $(MYSQL_DUMP_FILE) | mysql -u $(MYSQL_USER) -p$(MYSQL_PASS) -h $(MYSQL_HOST) -P $(MYSQL_PORT) $(MYSQL_DB_NAME)"

db_drop_tables:
	sudo docker exec -it $(MYSQL_DOCKER) sh -c "mysqldump --add-drop-table --no-data -u $(MYSQL_USER) -p$(MYSQL_PASS) -h $(MYSQL_HOST) $(MYSQL_DB_NAME) -P $(MYSQL_PORT) | grep 'DROP TABLE' ) > ../mysql_dump/drop_all_tables.sql"
	sudo docker exec -it $(MYSQL_DOCKER) sh -c "mysql -u $(MYSQL_USER) -p$(MYSQL_PASS) -h $(MYSQL_HOST) $(MYSQL_DB_NAME) < ../mysql_dump/drop_all_tables.sql -P $(MYSQL_PORT)"

# MAGENTO

magento_update_baseurl:
	sudo docker exec -it $(MYSQL_DOCKER) sh -c "mysql -u $(MYSQL_USER) -p$(MYSQL_PASS) -h $(MYSQL_HOST) $(MYSQL_DB_NAME) -e \"UPDATE core_config_data SET value = '$(BASE_URL)' WHERE path in ('web/unsecure/base_url', 'web/secure/base_url')\"" -P $(MYSQL_PORT)

magento_create_localxml:
	sudo docker cp $(MAGENTO_LOCAL_XML) $(NGINX_DOCKER):/$(MAGENTO_LOCAL_XML_TO);

magento_magerun_install:
	sudo docker exec -it $(NGINX_DOCKER) sh -c "apt-get update; apt-get install -y php php-mysql php-xml;"
	sudo docker cp bin/$(MAGENTO_MAGERUN) $(NGINX_DOCKER):$(NGINX_WEB_ROOT)/$(MAGENTO_MAGERUN);
	sudo docker cp bin/$(MAGENTO_MAGERUN) $(NGINX_DOCKER):$(MAGENTO_MAGERUN_TO)/$(MAGENTO_MAGERUN);

magento_magerun_create_admin:
	sudo docker exec -it $(NGINX_DOCKER) sh -c "cd $(NGINX_WEB_ROOT)/; $(MAGENTO_MAGERUN) admin:user:create"

magento_clear_cache:
	sudo docker exec -it $(NGINX_DOCKER) sh -c "cd $(NGINX_WEB_ROOT); rm -rf var/cache/*; rm -rf var/session/*;"

magento_set_permissions:
	sudo docker exec -it $(NGINX_DOCKER) sh -c "chown 1000:1000 $(NGINX_WEB_ROOT)/ -R; chmod 777 -R $(NGINX_WEB_ROOT)/var/ $(NGINX_WEB_ROOT)/media/"

magento_cron_setup:
	@echo "Write this:"
	@echo "*/5 * * * * sh $(NGINX_WEB_ROOT)/cron.sh >/dev/null 2>&1"
	sudo docker exec -it $(NGINX_DOCKER) sh -c "crontab -e"

# MAGENTO2 

magento2_update_baseurl:
	sudo docker exec -it $(MYSQL_DOCKER) sh -c "mysql -u $(MYSQL_USER) -p$(MYSQL_PASS) -h $(MYSQL_HOST) $(MYSQL_DB_NAME) -e \"UPDATE core_config_data SET value = '$(BASE_URL)' WHERE path in ('web/unsecure/base_url', 'web/secure/base_url')\"" -P $(MYSQL_PORT)

magento2_create_phpenv:
	sudo docker cp $(MAGENTO2_ENVPHP) $(NGINX_DOCKER):/$(MAGENTO2_ENVPHP_TO);

magento2_magerun_create_admin:
	sudo docker exec -it $(PHP_DOCKER) sh -c "php bin/magento admin:user:create"

magento2_composer_install:
	sudo docker exec -it --user 1000 $(PHP_DOCKER) sh -c "composer install"

magento2_create_authjson:
	sudo docker exec -it $(PHP_DOCKER) sh -c "composer install"

magento2_grunt:
	sudo docker exec -it $(PHP_DOCKER) sh -c "composer install"

magento2_grunt_install:
	sudo docker exec -it $(PHP_DOCKER) sh -c "cp Gruntfile.js.sample Grunfile.js"
	sudo docker exec -it $(PHP_DOCKER) sh -c "npm install"

magento2_gulp:
	sudo docker exec -it $(PHP_DOCKER) sh -c "composer install"

magento2_snowdog_install:
	sudo docker exec -it $(PHP_DOCKER) sh -c "composer install"

magento2_setup_upgrade:
	sudo docker exec -it --user 1000:1000 $(PHP_DOCKER) sh -c "php bin/magento setup:upgrade "

magento2_clear_cache:
	sudo docker exec -it $(NGINX_DOCKER) sh -c "rm -rf var/cache/*; rm -rf var/session/*;"

magento2_set_permissions:
	sudo docker exec -it $(NGINX_DOCKER) sh -c "chmod 777 -R $(NGINX_WEB_ROOT)/var/ $(NGINX_WEB_ROOT)/pub/media $(NGINX_WEB_ROOT)/pub/static;"
	sudo docker exec -it $(NGINX_DOCKER) sh -c "chown 1000:1000 $(NGINX_WEB_ROOT)/ -R;"
	sudo docker exec -it $(NGINX_DOCKER) sh -c "chmod u+x ./bin/magento;"
# 	sudo docker exec -it --user 1000:1000 $(NGINX_DOCKER) sh -c "find . -type f -exec chmod 644 {} \;"
# 	sudo docker exec -it --user 1000:1000 $(NGINX_DOCKER) sh -c "find ./var -type d -exec chmod 777 {} \;"
# 	sudo docker exec -it --user 1000:1000 $(NGINX_DOCKER) sh -c "find ./pub/media -type d -exec chmod 777 {} \;"
# 	sudo docker exec -it --user 1000:1000 $(NGINX_DOCKER) sh -c "find ./pub/static -type d -exec chmod 777 {} \;"
# 	sudo docker exec -it --user 1000:1000 $(NGINX_DOCKER) sh -c "chmod 777 ./app/etc;"
# 	sudo docker exec -it --user 1000:1000 $(NGINX_DOCKER) sh -c "chmod 644 ./app/etc/*.xml"
# 	sudo docker exec -it --user 1000:1000 $(NGINX_DOCKER) sh -c "chown 1000:1000 $(NGINX_WEB_ROOT)/"
# 	sudo docker exec -it --user 1000:1000 $(NGINX_DOCKER) sh -c "chmod u+x ./bin/magento"

# ETC 

install_cron:
	sudo docker exec -it $(NGINX_DOCKER) sh -c "apt-get update; apt-get install -y cron; apt-get install -y vim; export VISUAL=vim;"

docker_up:
	sudo docker-compose up -d

setup_magento:
	make magento2_update_baseurl
	make magento2_create_localxml
	make magento2_magerun_install
	make magento2_set_permissions
	make magento2_magerun_create_admin
# 	make magento_cron_setup

setup_magento2:
	make db_install_pv
	make db_import_pv
	make magento2_update_baseurl
	make magento2_create_phpenv
	make magento2_composer_install
# 	make magento2_set_permissions
# 	make magento2_magerun_create_admin

install:
	make docker_up
	make db_install_pv
	make db_import_pv
	make install_cron
	make setup_magento

PHONY: \
	db_install_pv \
	db_import \
	db_import_pv \
	db_drop_tables \
	magento_update_baseurl \
	magento_create_localxml \
	magento_magerun_install \
	magento_magerun_create_admin \
	magento_cron_setup \
	install_cron \
	docker_up \
	magento_clear_cache \
	magento_set_permissions \
	install \
	setup_magento
