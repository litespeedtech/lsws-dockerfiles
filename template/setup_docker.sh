#!/usr/bin/env bash
LS_FD='/usr/local/lsws'
WEBCF="${LS_FD}/conf/httpd_config.xml"
VHCF="${LS_FD}/conf/templates/docker.xml"
PHP_VER='lsphp83'

check_php_input(){
    if [ -z "${1}" ]; then
        echo "Use default value ${PHP_VER}"
    else
        echo ${1} | grep lsphp >/dev/null
        if [ ${?} = 0 ]; then
            PHP_VER=${1}
        fi
    fi
}

cleanup_listener(){
    echo 'Remove listeners'
    grep '<listener>' ${WEBCF} >/dev/null 2>&1
    if [ ${?} = 0 ]; then
        FIRST_LINE_NUM=$(grep -n -m 1 '<listener>' ${WEBCF} | awk -F ':' '{print $1}')
        LAST_LINE_NUM=$(grep -n '</listener>' ${WEBCF} | tail -n 1 | awk -F ':' '{print $1}')
        echo 'Remove the default listener from serevr config'
        sed -i "${FIRST_LINE_NUM},${LAST_LINE_NUM}d" ${WEBCF}
    else
        echo "<listener> does not found, skip!"
    fi    
}

update_listener(){
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
' ${WEBCF}
}

update_template(){
    sed -i '/<vhTemplateList>/a\
    <vhTemplate> \
      <name>docker</name> \
      <templateFile>$SERVER_ROOT/conf/templates/docker.xml</templateFile> \
      <listeners>HTTP, HTTPS</listeners> \
      <member> \
        <vhName>localhost</vhName> \
        <vhDomain>*, localhost</vhDomain> \
      </member> \
    </vhTemplate>
' ${WEBCF}
}

php_path(){
    if [ -f ${VHCF} ]; then
        sed -i "s/lsphpver/${1}/" ${VHCF}
    else
        echo 'docker.xml template not found!'
        exit 1
    fi
}

create_doc_fd(){
    mkdir -p /var/www/vhosts/localhost/{html,logs,certs}
    chown 1000:1000 /var/www/vhosts/localhost/ -R
}

main(){
    check_php_input ${1}
    php_path ${PHP_VER}
    cleanup_listener
    update_listener
    update_template
    create_doc_fd
}
main ${1}