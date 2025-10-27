#!/bin/bash
USER='nobody'
GROUP='nogroup'
ADMIN_PASS='litespeed'
LSDIR='/usr/local/lsws'
LSWS_MAIN='6'
LSWS_VERSION=''
EPACE='        '
ARCH='x86_64'

echow(){
    FLAG=${1}
    shift
    echo -e "\033[1m${EPACE}${FLAG}\033[0m${@}"
}

help_message(){
    echo -e "\033[1mOPTIONS\033[0m"
    echow '-L, --lsws [VERSION]'
    echo "${EPACE}${EPACE}Example: bash lsws_install.sh --lsws 6.3.4"
    echow '--arch'
    echo "${EPACE}${EPACE}Example: build.sh --lsws 6.3.4 --arch [x86_64|aarch64], will build image for amd64 or arm64"
    exit 0
}

check_input(){
    if [ -z "${1}" ]; then
        help_message
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

get_main_ver(){
   LSWS_MAIN=${LSWS_VERSION:0:1}
}

lsws_download(){
    wget -q --no-check-certificate https://www.litespeedtech.com/packages/${LSWS_MAIN}.0/lsws-${LSWS_VERSION}-ent-${ARCH}-linux.tar.gz
    tar xzf lsws-*-ent-${ARCH}-linux.tar.gz && rm -f lsws-*.tar.gz
    cd lsws-${LSWS_VERSION}
    add_trial
}


update_install(){
    sed -i '/^license$/d' install.sh
    sed -i 's/read TMPS/TMPS=0/g' install.sh
    sed -i 's/read TMP_YN/TMP_YN=N/g' install.sh
}

update_function(){
    sed -i '/read [A-Z]/d' functions.sh
    sed -i 's/HTTP_PORT=$TMP_PORT/HTTP_PORT=8080/g' functions.sh
    sed -i 's/ADMIN_PORT=$TMP_PORT/ADMIN_PORT=7080/g' functions.sh
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
    SERVERV=$(cat /usr/local/lsws/VERSION)
    echo "Version: ${SERVERV}"
}

run_install(){
    echo 'Main LSWS install ...'
    /bin/bash install.sh >/dev/null 2>&1
    echo 'Main LSWS install finished !'
}

lsws_restart(){
    ${LSDIR}/bin/lswsctrl start
}

check_input ${1}
while [ ! -z "${1}" ]; do
    case ${1} in
        -[lL] | -lsws | --lsws) shift
            check_input "${1}"
            LSWS_VERSION="${1}"
            ;;
        -[aA] | -arch | --arch) shift
            check_input "${1}"
            ARCH="${1}"
            ;;
        *)
            help_message
            ;;                
    esac
    shift
done

main(){    
    basic_install
    get_main_ver
    lsws_download
    update_install
    update_function
    run_install
    lsws_restart
    gen_selfsigned_cert
    rpm_install
    check_version
    del_trial
}

main ${1} ${2}