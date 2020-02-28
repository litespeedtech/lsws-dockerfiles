#!/usr/bin/env bash
sed -i '/<listenerList>/a\
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

sed -i '/<vhTemplateList>/a\
    <vhTemplate> \
      <name>docker</name> \
      <templateFile>$SERVER_ROOT/conf/templates/docker.xml</templateFile> \
      <listeners>Default, HTTP, HTTPS</listeners> \
      <member> \
        <vhName>localhost</vhName> \
        <vhDomain>*, localhost</vhDomain> \
      </member> \
    </vhTemplate>
' /usr/local/lsws/conf/httpd_config.xml