#!/bin/bash
USER='nobody'
GROUP='nogroup'
ADMIN_PASS='litespeed'
LSDIR='/usr/local/lslb'
LSLB_VERSION=''

check_input(){
    if [ -z "${1}" ]; then
        echo 'Please specify a version!'
        exit 1
    else
        LSLB_VERSION="${1}"
    fi
}

basic_install(){
    apt-get update && apt-get install net-tools apt-utils openssl -y
}

add_trial(){
    wget -q --no-check-certificate http://license.litespeedtech.com/reseller/trial.key
}

del_trial(){
    rm -f ${LSDIR}/conf/trial.key*
}

lslb_download(){
    cd
    wget -q --no-check-certificate https://www.litespeedtech.com/packages/lslb/lslb-${LSLB_VERSION}-x86_64-linux.tar.gz
    tar xzf lslb-*-x86_64-linux.tar.gz && rm -f lslb-*.tar.gz
    cd lslb-${LSLB_VERSION}
    add_trial
}


update_install(){
    sed -i '/^license$/d' install.sh
    sed -i 's/read TMPS/TMPS=0/g' install.sh
    sed -i 's/read TMP_YN/TMP_YN=N/g' install.sh
}

update_function(){
    sed -i '/read [A-Z]/d' functions.sh
    sed -i 's/HTTP_PORT=$TMP_PORT/HTTP_PORT=8090/g' functions.sh
    sed -i 's/ADMIN_PORT=$TMP_PORT/ADMIN_PORT=7090/g' functions.sh
    sed -i '/DEFAULT_PORT=/a \ \ \ \ TMP_PORT=""' functions.sh
    sed -i "/^license()/i\
    PASS_ONE=${ADMIN_PASS}\
    PASS_TWO=${ADMIN_PASS}\
    TMP_USER=${USER}\
    TMP_GROUP=${GROUP}\
    TMP_PORT=''\
    TMP_DEST=''\
    ADMIN_USER=''\
    ADMIN_EMAIL=''
    " functions.sh
}

gen_selfsigned_cert(){
    KEYNAME="${LSDIR}/admin/conf/webadmin.key"
    CERTNAME="${LSDIR}/admin/conf/webadmin.crt"
    openssl req -x509 -nodes -days 365 -newkey rsa:2048 -keyout ${KEYNAME} -out ${CERTNAME} <<csrconf
US
NJ
Virtual
docker
Testing
webadmin
.
.
.
csrconf
}

rpm_install(){
    echo 'Install LiteSpeed repo ...'
    wget -O - http://rpms.litespeedtech.com/debian/enable_lst_debian_repo.sh | bash >/dev/null 2>&1
}

check_version(){
    SERVERV=$(cat /usr/local/lslb/VERSION)
    echo "Version: ${SERVERV}"
}

run_install(){
    echo 'Main LSLB install ...'
    /bin/bash install.sh >/dev/null 2>&1
    echo 'Main LSLB install finished !'
}

lslb_restart(){
    ${LSDIR}/bin/lslbctrl start
}

main(){
    check_input ${1}
    basic_install
    lslb_download
    update_install
    update_function
    run_install
    lslb_restart
    gen_selfsigned_cert
    rpm_install
    check_version
    del_trial
}

main ${1}