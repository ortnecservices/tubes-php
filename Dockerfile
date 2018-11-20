FROM ubuntu:18.04
RUN apt update && apt dist-upgrade -y && \
    apt install -y wget curl git && \
#    apt install -y software-properties-common python-software-properties && \
#    LC_ALL=C.UTF-8 add-apt-repository ppa:ondrej/php && \
    apt update
RUN DEBIAN_FRONTEND=noninteractive apt install -y --no-install-recommends php7.2 php7.2-common php7.2-cli php7.2-fpm \
    php7.2-mbstring \
    php7.2-json \
    php7.2-xml \
    php7.2-readline \
    php7.2-curl \
    php7.2-zip \
    php7.2-intl \
    php7.2-bcmath \
#    php7.2-mcrypt \
    php7.2-pdo \
    php7.2-mysql \
    php7.2-mysqli \
    php7.2-apc \
    php7.2-memcached \
    php7.2-redis \
    php7.2-gd \
    php7.2-gmp \
    php7.2-ssh2 \
    php7.2-imap \
    php7.2-tideways \
    php7.2-xdebug \
    php7.2-mongodb
RUN curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/local/bin --filename=composer && \
    composer global require "hirak/prestissimo:^0.3"
RUN apt-get clean -y && \
    apt-get autoclean -y && \
    apt-get remove -y wget curl && \
    apt-get autoremove -y && \
    rm -rf /var/lib/apt/lists/* /var/lib/log/* /tmp/* /var/tmp/*
#RUN sed -i 's/^listen[ ]*=.*$/listen = 9000/g' /etc/php/7.1/fpm/pool.d/www.conf
#RUN sed -i 's/^[; ]*daemonize[ ]*=.*$/daemonize = no/g' /etc/php/7.1/fpm/php-fpm.conf
RUN mkdir -p /run/php/
RUN { \
    echo '[global]'; \
    echo 'error_log = /proc/self/fd/2'; \
    echo; \
    echo '[www]'; \
    echo '; if we send this to /proc/self/fd/1, it never appears'; \
    echo 'access.log = /proc/self/fd/2'; \
    echo; \
    echo 'clear_env = no'; \
    echo; \
    echo '; Ensure worker stdout and stderr are sent to the main error log.'; \
    echo 'catch_workers_output = yes'; \
    } | tee /etc/php/7.2/fpm/pool.d/docker.conf \
    && { \
    echo '[global]'; \
    echo 'daemonize = no'; \
    echo; \
    echo '[www]'; \
    echo 'listen = 9000'; \
    } | tee /etc/php/7.2/fpm/pool.d/zz-docker.conf
RUN echo "xdebug.remote_enable=1\nxdebug.remote_autostart=0\n" >> /etc/php/7.2/fpm/conf.d/docker-php-ext-xdebug.ini \
    && echo "xdebug.remote_connect_back=0\nxdebug.remote_host=10.254.254.254\n" >> /etc/php/7.2/fpm/conf.d/docker-php-ext-xdebug.ini \
    && echo "xdebug.profiler_enable_trigger=1\n" >> /etc/php/7.2/fpm/conf.d/docker-php-ext-xdebug.ini
EXPOSE 9000
CMD ["php-fpm7.2"]