#!/usr/bin/env bash
sed '/<listenerList>/a\
    <listener> \
      <name>HTTP</name> \
      <address>*:80</address> \
      <secure>0</secure> \
    </listener> \
    <listener> \
      <name>HTTPS</name> \
      <address>*:443</address> \
      <reusePort>1</reusePort> \
      <secure>1</secure> \
      <keyFile>/usr/local/lsws/admin/conf/webadmin.key</keyFile> \
      <certFile>/usr/local/lsws/admin/conf/webadmin.crt</certFile> \
    </listener>
' /usr/local/lsws/conf/httpd_config.xml