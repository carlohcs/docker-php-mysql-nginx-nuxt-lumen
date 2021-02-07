# Source: https://github.com/sourceallies/php-node-docker
FROM ubuntu:18.04

LABEL maintainer="Carlos Henrique Carvalho de Santana<carlohcs@gmail.com>"

# Prevent stuck problems like: "Configuring tzdata"
# https://askubuntu.com/questions/909277/avoiding-user-interaction-with-tzdata-when-installing-certbot-in-a-docker-contai
ENV DEBIAN_FRONTEND=noninteractive
ENV INITRD No

# Add johndoe user
RUN useradd -u 1001 -G www-data -m johndoe
# add our user and group first to make sure their IDs get assigned consistently, regardless of whatever dependencies get added
RUN groupadd -r mysql && useradd -r -g mysql mysql

# Install necessary tools
RUN apt-get clean
RUN apt-get update
RUN apt-get install -y --no-install-recommends \
    apt-utils \
    git \
    curl \
    vim \ 
    # For PHP
    software-properties-common \ 
    # Supervisord
    supervisor \
    # MySQL
    mysql-server \ 
    # Prevents: gpg key failed with gpg-agent not found error
    gpg-agent

# Install PHP and dependencies for Lumen
RUN add-apt-repository -y ppa:ondrej/php

RUN apt-get update
RUN apt-get install -y --no-install-recommends \
    php7.1 \
    php7.1-cli \
    php7.1-fpm \
    php7.1-common \
    php7.1-curl \
    php7.1-json \
    php7.1-xml \
    php7.1-mbstring \
    php7.1-mcrypt \
    php7.1-mysql \
    php7.1-zip \
    php7.1-memcached \
    php7.1-gd \
    php7.1-dev \
    php7.1-soap \
    pkg-config \
    libcurl4-openssl-dev \
    libedit-dev \
    libssl-dev \
    libxml2-dev \
    php7.1-tokenizer \
    php7.1-mysql \
    php7.1-pdo-mysql \ 
    libmagickwand-dev \ 
    php-imagick \ 
    nginx

# Node JS (10.x version)
RUN curl -sL https://deb.nodesource.com/setup_10.x | bash -
RUN apt-get install -y nodejs

# Composer
RUN curl -s http://getcomposer.org/installer | php && \
    echo "export PATH=${PATH}:/var/www/vendor/bin" >> ~/.bashrc && \
    mv composer.phar /usr/local/bin/composer

# Cleanup
RUN apt-get clean
RUN rm -rf /etc/nginx/sites-enabled

# Load .env server files (from docker-compose or cloudformation)
# to be available via dotEnv (and $_SERVER) in php-fpm.
RUN sed -e 's/;clear_env = no/clear_env = no/' -i /etc/php/7.1/fpm/pool.d/www.conf

# MySQL setup
COPY ./config/my.cnf /etc/mysql/
ADD ./config/set-mysql-password.sh /tmp/set-mysql-password.sh
RUN /bin/sh /tmp/set-mysql-password.sh
RUN usermod -d /var/lib/mysql/ mysql

# Nginx setup
ADD ./config/nginx.conf /etc/nginx/conf.d/app.conf

# Supervisor setup
COPY ./config/supervisord.conf /etc/supervisor/conf.d/supervisord.conf
RUN mkdir -p /var/log/supervisor /var/run/php

# Expose to localhost:80 or localhost
EXPOSE 80

# Set workdir
WORKDIR /var/www/app

# Set write permissions
RUN chown -R johndoe:www-data /var/www/app

# Run application
ENTRYPOINT ["/usr/bin/supervisord"]