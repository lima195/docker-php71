FROM php:7.1-fpm

RUN usermod -u 1000 www-data
ARG DEBIAN_FRONTEND=noninteractive
COPY ./bin/* /usr/local/bin/

ENV GOPATH /root/gocode

RUN apt-get update \
        && apt-get install -y --no-install-recommends apt-utils

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
            opcache \
            && \
            rm -rf /var/lib/apt/lists/*

# Common
RUN apt-get update \
    && apt-get install -y \
        openssl \
        git \
        gnupg2


# PHP
# intl
RUN apt-get update \
    && apt-get install -y libicu-dev \
    && docker-php-ext-configure intl \
    && docker-php-ext-install -j$(nproc) intl

# xml
RUN apt-get update \
    && apt-get install -y \
    libxml2-dev \
    libxslt-dev \
    && docker-php-ext-install -j$(nproc) \
        dom \
        xmlrpc \
        xsl

# images
RUN apt-get update \
    && apt-get install -y \
    libfreetype6-dev \
    libjpeg62-turbo-dev \
    libpng-dev \
    libgd-dev \
    && docker-php-ext-configure gd --with-freetype-dir=/usr/include/ --with-jpeg-dir=/usr/include/ \
    && docker-php-ext-install -j$(nproc) \
        gd \
        exif

# database
RUN docker-php-ext-install -j$(nproc) \
    mysqli \
    pdo \
    pdo_mysql

# strings
RUN docker-php-ext-install -j$(nproc) \
    gettext \
    mbstring

# math
RUN apt-get update \
    && apt-get install -y libgmp-dev \
    && ln -s /usr/include/x86_64-linux-gnu/gmp.h /usr/include/gmp.h \
    && docker-php-ext-install -j$(nproc) \
        gmp \
        bcmath

# compression
RUN apt-get update \
    && apt-get install -y \
    libbz2-dev \
    zlib1g-dev \
    && docker-php-ext-install -j$(nproc) \
        zip \
        bz2

# ftp
RUN apt-get update \
    && apt-get install -y \
    libssl-dev \
    && docker-php-ext-install -j$(nproc) \
        ftp

# ssh2
RUN apt-get update \
    && apt-get install -y \
    libssh2-1-dev

# memcached
RUN apt-get update \
    && apt-get install -y \
    libmemcached-dev \
    libmemcached11


# others
RUN docker-php-ext-install -j$(nproc) \
    soap \
    sockets \
    calendar \
    sysvmsg \
    sysvsem \
    sysvshm

# Install PHP Code sniffer
RUN curl -OL https://squizlabs.github.io/PHP_CodeSniffer/phpcs.phar \
    && chmod 755 phpcs.phar \
    && mv phpcs.phar /usr/local/bin/ \
    && ln -s /usr/local/bin/phpcs.phar /usr/local/bin/phpcs \
    && curl -OL https://squizlabs.github.io/PHP_CodeSniffer/phpcbf.phar \
    && chmod 755 phpcbf.phar \
    && mv phpcbf.phar /usr/local/bin/ \
    && ln -s /usr/local/bin/phpcbf.phar /usr/local/bin/phpcbf

# Install Composer
RUN curl -sS https://getcomposer.org/installer | php \
    && mv composer.phar /usr/local/bin/composer \
    && composer global require hirak/prestissimo --no-plugins --no-scripts


# Install APCu and APC backward compatibility
RUN pecl install apcu \
    && pecl install apcu_bc-1.0.3 \
    && docker-php-ext-enable apcu --ini-name 10-docker-php-ext-apcu.ini \
    && docker-php-ext-enable apc --ini-name 20-docker-php-ext-apc.ini

# Install PHPUnit
RUN curl -OL https://phar.phpunit.de/phpunit.phar \
    && chmod 755 phpunit.phar \
    && mv phpunit.phar /usr/local/bin/ \
    && ln -s /usr/local/bin/phpunit.phar /usr/local/bin/phpunit

# ## NodeJS, NPM
# # Install NodeJS
# RUN curl -sL https://deb.nodesource.com/setup_8.x | bash - \
#     && apt-get install -y nodejs

# # Install Yarn
# RUN curl -sS https://dl.yarnpkg.com/debian/pubkey.gpg | apt-key add - \
#     && echo "deb https://dl.yarnpkg.com/debian/ stable main" | tee /etc/apt/sources.list.d/yarn.list \
#     && apt-get update && apt-get install -y yarn

# # Install Grunt globally
# RUN npm install -g grunt-cli

# # Install Gulp globally
# RUN npm install -g gulp-cli

# # Install Bower globally
# RUN npm install -g bower


# Mailhog
RUN apt-get update \
        && apt-get install -q -y ssmtp mailutils \
        && rm -rf /var/lib/apt/lists/*

RUN apt-get update \
        && apt-get install -y golang-go \
        && echo $HOME \
        && mkdir $HOME/gocode

RUN echo "export GOPATH=/root/gocode" >> ~/.profile \
        && /bin/bash -c "source ~/.profile" \
        && go get github.com/mailhog/MailHog \
        && go get github.com/mailhog/mhsendmail

ENV GOPATH $HOME/gocode

RUN ln /root/gocode/bin/mhsendmail /usr/local/bin/mail \
        && ln /root/gocode/bin/mhsendmail /usr/local/bin/sendmail \
        && ln /root/gocode/bin/mhsendmail /usr/local/bin/mhsendmail \
        && mv /usr/bin/mail /usr/bin/mail_bkp \
        && ln /root/gocode/bin/mhsendmail /usr/bin/mail \
        && ln /root/gocode/bin/mhsendmail /usr/bin/sendmail \
        && ln /root/gocode/bin/mhsendmail /usr/bin/mhsendmail

COPY ./etc/php_ini/php.ini /usr/local/etc/php/
COPY ./etc/ssmtp/ssmtp.conf /etc/ssmtp/ssmtp.conf
# test Mailhog
# php -r "\$from = \$to = 'your.emailaddress@gmail.com'; \$x = mail(\$to, 'subject'.time(), 'Hello World', 'From: '. \$from); var_dump(\$x);"
#/etc/ssmtp/ssmtp.conf

# Clean repository
RUN apt-get clean \
    && rm -rf /var/lib/apt/lists/*

#COPY ./etc/ssmtp/ssmtp.conf /etc/ssmtp/ssmtp.conf 
WORKDIR /usr/share/nginx/www
# VOLUME /usr/share/nginx/www