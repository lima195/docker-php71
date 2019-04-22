FROM ubuntu:18.04
WORKDIR /usr/share/nginx/www

RUN apt-get update \
    && apt-get install -y build-essential \
    && apt-get install -y nodejs \
    && apt-get install -y npm \
    && /usr/bin/npm install -g grunt \
    && /usr/bin/npm install -g gulp \
    && /usr/bin/npm install -g bower