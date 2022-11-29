FROM ubuntu:22.04
ENV LS_FD='/usr/local/lslb'

ARG LSLB_VERSION
ARG PHP_VERSION

RUN apt-get update && apt-get install wget curl tzdata cron vim git -y

COPY lslb-install.sh /
RUN chmod +x /lslb-install.sh && bash /lslb-install.sh $LSLB_VERSION

EXPOSE 7090

ADD htpasswd $LS_FD/admin/conf/htpasswd

RUN chown 999:999 $LS_FD/conf -R
RUN cp -RP $LS_FD/conf/ $LS_FD/.conf/
RUN cp -RP $LS_FD/admin/conf $LS_FD/admin/.conf/
COPY entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh
ENTRYPOINT ["/entrypoint.sh"]
WORKDIR /home/