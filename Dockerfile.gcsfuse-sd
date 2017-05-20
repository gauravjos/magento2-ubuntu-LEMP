FROM ubuntu:16.04
ARG MAGENTO_HOME="/var/www/html/magento2"
ARG MAGENTO_VERSION="2.1.5"
ARG MAGENTO_MODE="default"
ARG MAGENTO_BASEURL="http://magento.dev/"
ARG MAGENTO_SECURE_BASEURL="https://magento.dev/"
ARG BG_FRONTNAME="admin"
ARG DB_HOST=127.0.0.1
ARG DB_USER="magento"
ARG DB_PASSWD="password"
ARG DB_NAME="magento"
ARG ADMIN_FIRSTNAME="Magento"
ARG ADMIN_LASTNAME="Admin"
ARG ADMIN_EMAIL="admin@admin.com"
ARG ADMIN_USER="admin"
ARG ADMIN_PASSWD="admin@123"
ARG LANG="en_US"
ARG CURRENCY="USD"
ARG TIMEZONE="Asia/Kolkata"
RUN requirements="mysql-client ca-certificates curl cron openssl git libpng12-dev libmcrypt-dev libmcrypt4 libcurl3-dev libfreetype6 libjpeg-turbo8 libjpeg-turbo8-dev libpng12-dev libfreetype6-dev libicu-dev libxslt1-dev" \
    && apt-get update && apt-get install -y --no-install-recommends --no-install-suggests $requirements \
    && apt-get install --no-install-recommends --no-install-suggests -y \
                        php7.0 \
                        php7.0-bcmath \
                        php7.0-cli \
                        php7.0-cgi \
                        php7.0-common \
                        php7.0-curl \
                        php7.0-fpm \
                        php7.0-gd \
                        php7.0-intl \  
                        php7.0-json \
                        php7.0-mysql \
                        php7.0-opcache \ 
                        php7.0-soap \
                        php7.0-xml \
                        php7.0-xsl \
                        php7.0-zip \
                        php7.0-mcrypt \
                        php7.0-mbstring \

    && apt-get install  --no-install-recommends --no-install-suggests -y nginx \
    && rm -rf /var/lib/apt/lists/*
RUN echo "deb http://packages.cloud.google.com/apt gcsfuse-xenial main" >> /etc/apt/sources.list.d/gcsfuse.list \
    && curl https://packages.cloud.google.com/apt/doc/apt-key.gpg | apt-key add - \
    && apt-get update \
    && apt-get install --no-install-recommends --no-install-suggests -y gcsfuse libfuse2 fuse \
    && rm -rf /var/lib/apt/lists/*
RUN ln -sf /dev/stdout /var/log/nginx/access.log \
        && ln -sf /dev/stderr /var/log/nginx/error.log
RUN sed -i 's/;listen.mode = 0660/listen.mode = 0660/g' /etc/php/7.0/fpm/pool.d/www.conf && sed -i 's/memory_limit = 128M/memory_limit = 2048M/g' /etc/php/7.0/fpm/php.ini 
COPY magento  /etc/nginx/sites-available/default
RUN curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/local/bin --filename=composer
EXPOSE 80 443
#RUN curl -L -o /tmp/magento2.tar.gz https://codeload.github.com/magento/magento2/tar.gz/$MAGENTO_VERSION && tar -xzvf /tmp/magento2.tar.gz && mv magento2-$MAGENTO_VERSION $MAGENTO_HOME && rm -f /tmp/magento2.tar.gz
ADD magento-2-community-sample-data-2.1.5 $MAGENTO_HOME
RUN cd $MAGENTO_HOME && composer install -v && php bin/magento setup:install \
                                                        --base-url=$MAGENTO_BASEURL  \ 
                                                        --base-url-secure=$MAGENTO_SECURE_BASEURL  \ 
                                                        --backend-frontname=$BG_FRONTNAME \ 
                                                        --db-host=$DB_HOST \ 
                                                        --db-name=$DB_NAME \ 
                                                        --db-user=$DB_USER \ 
                                                        --db-password=$DB_PASSWD \ 
                                                        --admin-firstname=$ADMIN_FIRSTNAME \ 
                                                        --admin-lastname=$ADMIN_LASTNAME  \
                                                        --admin-email=$ADMIN_EMAIL  \ 
                                                        --admin-user=$ADMIN_USER  \ 
                                                        --admin-password=$ADMIN_PASSWD \ 
                                                        --language=$LANG \ 
                                                        --currency=$CURRENCY \ 
                                                        --timezone=$TIMEZONE  \ 
                                                        --use-rewrites=1 
COPY magento.cron /tmp/magento.cron
RUN crontab -u www-data /tmp/magento.cron && rm -f /tmp/magento.cron
RUN cd $MAGENTO_HOME && chown -R www-data:www-data . && find . -type d -exec chmod 770 {} \; && find . -type f -exec chmod 660 {} \; && chmod u+x bin/magento
RUN  sed -i "s/set \$MAGE_MODE.*/set \$MAGE_MODE $MAGENTO_MODE;/g" /etc/nginx/sites-available/default && cd $MAGENTO_HOME && if [ "$MAGENTO_MODE" != "default" ] ;then bin/magento deploy:mode:set $MAGENTO_MODE ;fi
WORKDIR $MAGENTO_HOME
RUN "$MAGENTO_HOME"/bin/magento cache:clean
COPY gcsfuse-run.sh /usr/local/bin/run
RUN chmod +x /usr/local/bin/run
CMD ["/usr/local/bin/run"]
