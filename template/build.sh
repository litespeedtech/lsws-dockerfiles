#!/usr/bin/env bash
set -x 
LSWS_VERSION=''
PHP_VERSION=''
PUSH=''
CONFIG=''
TAG=''
BUILDER='litespeedtech'
REPO='litespeed-beta'

help_message(){
    echo 'Command [-lsws XX] [-php lsphpXX]'
    echo 'Command [-lsws XX] [-php lsphpXX] --push'
    echo 'Example: build.sh -lsws 5.4.5 -php lsphp74 --push'
    exit 0
}

check_input(){
    if [ -z "${1}" ]; then
        help_message
    fi
}

build_image(){
    if [ -z "${1}" ] || [ -z "${2}" ]; then
        help_message
    else
        echo "${1} ${2}"
        docker build . --tag ${BUILDER}/${REPO}:${1}-${2} --build-arg LSWS_VERSION=${1} --build-arg PHP_VERSION=${2}
    fi    
}

test_image(){
    ID=$(docker run -d ${BUILDER}/${REPO}:${1}-${2})
    docker exec -it ${ID} su -c 'mkdir -p /var/www/vhosts/localhost/html/ \
    && echo "<?php phpinfo();" > /var/www/vhosts/localhost/html/index.php \
    && /usr/local/lsws/bin/lswsctrl restart'
    HTTP=$(docker exec -it ${ID} curl -s -o /dev/null -Ik -w "%{http_code}" http://localhost)
    HTTPS=$(docker exec -it ${ID} curl -s -o /dev/null -Ik -w "%{http_code}" https://localhost)
    docker kill ${ID}
    if [[ "${HTTP}" != "200" || "${HTTPS}" != "200" ]]; then
        echo '[X] Test failed!'
        echo "http://localhost returned ${HTTP}"
        echo "https://localhost returned ${HTTPS}"
        exit 1
    else
        echo '[O] Tests passed!' 
    fi
}

push_image(){
    if [ ! -z "${PUSH}" ]; then
        if [ -f ~/.docker/litespeedtech/config.json ]; then
            CONFIG=$(echo --config ~/.docker/litespeedtech)
        fi
        docker ${CONFIG} push ${BUILDER}/${REPO}:${1}-${2}
        if [ ! -z "${TAG}" ]; then
            docker tag ${BUILDER}/${REPO}:${1}-${2} ${BUILDER}/${REPO}:${3}
            docker ${CONFIG} push ${BUILDER}/${REPO}:${3}
        fi
    else
        echo 'Skip Push.'    
    fi
}

main(){
    build_image ${LSWS_VERSION} ${PHP_VERSION}
    test_image ${LSWS_VERSION} ${PHP_VERSION}
    push_image ${LSWS_VERSION} ${PHP_VERSION} ${TAG}
}

check_input ${1}
while [ ! -z "${1}" ]; do
    case ${1} in
        -[hH] | -help | --help)
            help_message
            ;;
        -lsws | --lsws | -LSWS_VERSION | -L) shift
            check_input "${1}"
            LSWS_VERSION="${1}"
            ;;
        -php | --php | -PHP_VERSION | -P) shift
            check_input "${1}"
            PHP_VERSION="${1}"
            ;;
        -tag | --tag | -TAG | -T) shift
            TAG="${1}"
            ;;       
        --push ) shift
            PUSH=true
            ;;            
        *) 
            help_message
            ;;              
    esac
    shift
done

main