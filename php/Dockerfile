FROM php:7.1-fpm

RUN usermod -u 1000 www-data
ARG DEBIAN_FRONTEND=noninteractive

ENV GOPATH /root/gocode

RUN apt-get update && apt-get install -y --no-install-recommends apt-utils

# Get repository and install wget and vim
RUN apt-get update && apt-get install --no-install-recommends -y \
        wget \
        vim \
        git \
        apt-utils \
        unzip

# Install PHP extensions deps
RUN apt-get update \
    && apt-get install --no-install-recommends -y \
        libfreetype6-dev \
        libjpeg62-turbo-dev \
        libmcrypt-dev \
        zlib1g-dev \
        libicu-dev \
        g++ \
        unixodbc-dev \
        libxml2-dev \
        libaio-dev \
        libmemcached-dev \
        freetds-dev \
		libssl-dev \
		openssl

# Install Composer
RUN curl -sS https://getcomposer.org/installer | php \
	&& mv composer.phar /usr/local/bin/composer \
	&& composer global require hirak/prestissimo --no-plugins --no-scripts

# Install PHP extensions
RUN docker-php-ext-configure gd --with-freetype-dir=/usr/include/ --with-jpeg-dir=/usr/include/ \
    && pecl install redis \
    && pecl install memcached \
    && docker-php-ext-install \
            iconv \
            mbstring \
            intl \
            mcrypt \
            gd \
            mysqli \
            pdo_mysql \
            soap \
            zip \
            xmlrpc \
    		&& docker-php-ext-enable \
            redis \
            memcached \
            opcache

# Install APCu and APC backward compatibility
RUN pecl install apcu \
    && pecl install apcu_bc-1.0.3 \
    && docker-php-ext-enable apcu --ini-name 10-docker-php-ext-apcu.ini \
    && docker-php-ext-enable apc --ini-name 20-docker-php-ext-apc.ini

# Install PHPUnit
RUN wget https://phar.phpunit.de/phpunit.phar -O /usr/local/bin/phpunit \
    && chmod +x /usr/local/bin/phpunit

# Mailhog
RUN apt-get update && apt-get install -q -y ssmtp mailutils && rm -rf /var/lib/apt/lists/*
RUN apt-get update
RUN apt-get install -y golang-go
RUN echo $HOME
RUN mkdir $HOME/gocode
# RUN echo "export GOPATH=\$HOME/gocode" >> ~/.profile
RUN echo "export GOPATH=/root/gocode" >> ~/.profile
RUN /bin/bash -c "source ~/.profile"
RUN go get github.com/mailhog/MailHog
RUN go get github.com/mailhog/mhsendmail
# RUN wget https://github.com/mailhog/MailHog/releases/download/v0.2.1/MailHog_linux_amd64
# RUN cp MailHog_linux_amd64 /usr/bin/mailhog
ENV GOPATH $HOME/gocode
# RUN ln $GOPATH/bin/mhsendmail /usr/local/bin/mhsendmail
RUN ln /root/gocode/bin/mhsendmail /usr/local/bin/mail
RUN ln /root/gocode/bin/mhsendmail /usr/local/bin/sendmail
RUN ln /root/gocode/bin/mhsendmail /usr/local/bin/mhsendmail
RUN mv /usr/bin/mail /usr/bin/mail_bkp
RUN ln /root/gocode/bin/mhsendmail /usr/bin/mail
RUN ln /root/gocode/bin/mhsendmail /usr/bin/sendmail
RUN ln /root/gocode/bin/mhsendmail /usr/bin/mhsendmail
COPY ./etc/php_ini/php.ini /usr/local/etc/php/
COPY ./etc/ssmtp/ssmtp.conf /etc/ssmtp/ssmtp.conf
# test Mailhog
# php -r "\$from = \$to = 'your.emailaddress@gmail.com'; \$x = mail(\$to, 'subject'.time(), 'Hello World', 'From: '. \$from); var_dump(\$x);"
#/etc/ssmtp/ssmtp.conf

# Install xdebug

#RUN apt-get update \
#    && echo "zend_extension=/usr/lib/php/20160303/xdebug.so" > /etc/php/7.1/mods-available/xdebug.ini \
#    && echo "xdebug.remote_enable=on" >> /etc/php/7.1/mods-available/xdebug.ini \
#    && echo "xdebug.remote_handler=dbgp" >> /etc/php/7.1/mods-available/xdebug.ini \
#    && echo "xdebug.remote_port=9000" >> /etc/php/7.1/mods-available/xdebug.ini \
#    && echo "xdebug.remote_autostart=on" >> /etc/php/7.1/mods-available/xdebug.ini \
#    && echo "xdebug.remote_connect_back=0" >> /etc/php/7.1/mods-available/xdebug.ini \
#    && echo "xdebug.idekey=docker" >> /etc/php/7.1/mods-available/xdebug.ini

# Clean repository
RUN apt-get clean \
    && rm -rf /var/lib/apt/lists/*

COPY ./bin/* /usr/local/bin/

#COPY ./etc/ssmtp/ssmtp.conf /etc/ssmtp/ssmtp.conf 
# WORKDIR /usr/share/nginx/www
# VOLUME /usr/share/nginx/www