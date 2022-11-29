FROM ubuntu:22.04
ENV LS_FD='/usr/local/lsws'

ARG LSWS_VERSION
ARG PHP_VERSION

RUN apt-get update && apt-get install wget curl tzdata cron -y

COPY lsws-install.sh /
RUN chmod +x /lsws-install.sh && bash /lsws-install.sh $LSWS_VERSION

RUN apt-get install mysql-client $PHP_VERSION $PHP_VERSION-common $PHP_VERSION-mysql $PHP_VERSION-opcache \
    $PHP_VERSION-curl $PHP_VERSION-imagick $PHP_VERSION-redis $PHP_VERSION-memcached $PHP_VERSION-intl -y

RUN ["/bin/bash", "-c", "if [[ $PHP_VERSION == lsphp7* ]]; then apt-get install $PHP_VERSION-json -y; fi"]

RUN curl -O https://raw.githubusercontent.com/wp-cli/builds/gh-pages/phar/wp-cli.phar && \
	chmod +x wp-cli.phar && mv wp-cli.phar /usr/bin/wp && \
	ln -s /usr/local/lsws/$PHP_VERSION/bin/php /usr/bin/php

RUN wget -O -  https://get.acme.sh | sh

EXPOSE 7080
ENV PATH="/usr/local/sbin:/usr/sbin:/usr/bin:/sbin:/bin:/usr/local/bin"

ADD docker.xml $LS_FD/conf/templates/docker.xml
ADD setup_docker.sh $LS_FD/bin/setup_docker.sh
ADD httpd_config.conf $LS_FD/conf/httpd_config.conf
ADD htpasswd $LS_FD/admin/conf/htpasswd

RUN $LS_FD/bin/setup_docker.sh $PHP_VERSION && rm $LS_FD/bin/setup_docker.sh
RUN chown 999:999 $LS_FD/conf -R
RUN cp -RP $LS_FD/conf/ $LS_FD/.conf/
RUN cp -RP $LS_FD/admin/conf $LS_FD/admin/.conf/
RUN ["/bin/bash", "-c", "if [[ $PHP_VERSION == lsphp8* ]]; then ln -sf $LS_FD/$PHP_VERSION/bin/lsphp $LS_FD/fcgi-bin/lsphp8; fi"]
RUN ["/bin/bash", "-c", "if [[ $PHP_VERSION == lsphp8* ]]; then ln -sf $LS_FD/fcgi-bin/lsphp8 $LS_FD/fcgi-bin/lsphp; fi"]
RUN ["/bin/bash", "-c", "if [[ $PHP_VERSION == lsphp7* ]]; then ln -sf $LS_FD/$PHP_VERSION/bin/lsphp $LS_FD/fcgi-bin/lsphp7; fi"]
RUN ["/bin/bash", "-c", "if [[ $PHP_VERSION == lsphp7* ]]; then ln -sf $LS_FD/fcgi-bin/lsphp7 $LS_FD/fcgi-bin/lsphp; fi"]
COPY entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh
ENTRYPOINT ["/entrypoint.sh"]
WORKDIR /var/www/vhosts/