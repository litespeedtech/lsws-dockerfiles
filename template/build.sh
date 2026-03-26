#!/usr/bin/env bash
LSWS_VERSION=''
PHP_VERSION=''
PUSH=''
CONFIG=''
TAG=''
BUILDER='litespeedtech'
REPO='litespeed'
EPACE='        '
ARCH='linux/amd64'
BUILD_PLATFORM='linux/amd64'
UBUNTU_VERSION='24.04'

echow(){
    FLAG=${1}
    shift
    echo -e "\033[1m${EPACE}${FLAG}\033[0m${@}"
}

help_message(){
    echo -e "\033[1mOPTIONS\033[0m" 
    echow '-L, --lsws [VERSION] -P, --php [lsphpVERSION]'
    echo "${EPACE}${EPACE}Examples: bash build.sh --lsws 6.3.4 --php lsphp84"
    echo "${EPACE}${EPACE}          bash build.sh --lsws 6.3.4 --php lsphp74 (Ubuntu22.04)"
    echow '--push'
    echo "${EPACE}${EPACE}Example: build.sh --lsws 6.3.4 --php lsphp84 --push, will push to the dockerhub"
    echow '--arch'
    echo "${EPACE}${EPACE}Example: build.sh --lsws 6.3.4 --php lsphp84 --arch linux/amd64,linux/arm64, will build image for both amd64 and arm64, otherwise linux/amd64 will be applied."        
    exit 0
}

check_input(){
    if [ -z "${1}" ]; then
        help_message
    fi
}

normalize_php_version(){
    RAW_VERSION="${1}"
    if [[ "${RAW_VERSION}" =~ ^lsphp([0-9]+)\.([0-9]+)$ ]]; then
        echo "lsphp${BASH_REMATCH[1]}${BASH_REMATCH[2]}"
    else
        echo "${RAW_VERSION}"
    fi
}

resolve_platform(){
    BUILD_PLATFORM="${ARCH%%,*}"
    if [ -z "${BUILD_PLATFORM}" ]; then
        BUILD_PLATFORM='linux/amd64'
    fi
}

resolve_ubuntu_version(){
    if [[ "${PHP_VERSION}" == lsphp7* ]]; then
        UBUNTU_VERSION='22.04'
    else
        UBUNTU_VERSION='24.04'
    fi
}

build_image(){
    if [ -z "${1}" ] || [ -z "${2}" ]; then
        help_message
    else
        echo "Build image: ${1} ${2}"
        echo "Use platform: ${BUILD_PLATFORM}, Ubuntu: ${UBUNTU_VERSION}"
        docker buildx build . \
            --platform "${BUILD_PLATFORM}" \
            --tag "${BUILDER}/${REPO}:${1}-${2}" \
            --build-arg LSWS_VERSION="${1}" \
            --build-arg PHP_VERSION="${2}" \
            --build-arg UBUNTU_VERSION="${UBUNTU_VERSION}" \
            --load
    fi    
}

test_image(){
    ID=$(docker run -d --platform "${BUILD_PLATFORM}" "${BUILDER}/${REPO}:${1}-${2}")
    sleep 1
    docker exec -i "${ID}" su -c 'mkdir -p /var/www/vhosts/localhost/html/ \
    && echo "<?php phpinfo();" > /var/www/vhosts/localhost/html/index.php \
    && /usr/local/lsws/bin/lswsctrl restart >/dev/null '

    HTTP=$(docker exec -i "${ID}" curl -s -o /dev/null -Ik -w "%{http_code}" http://localhost)
    HTTPS=$(docker exec -i "${ID}" curl -s -o /dev/null -Ik -w "%{http_code}" https://localhost)
    docker kill "${ID}" >/dev/null 2>&1 || true
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
        if [ -z "${TAG}" ]; then
            docker buildx build . --platform "${ARCH}" --tag "${BUILDER}/${REPO}:${1}-${2}" --build-arg LSWS_VERSION="${1}" --build-arg PHP_VERSION="${2}" --build-arg UBUNTU_VERSION="${UBUNTU_VERSION}" --output=type=registry --push
        else
            docker buildx build . --platform "${ARCH}" --tag "${BUILDER}/${REPO}:${3}" --build-arg LSWS_VERSION="${1}" --build-arg PHP_VERSION="${2}" --build-arg UBUNTU_VERSION="${UBUNTU_VERSION}" --output=type=registry --push
        fi
    else
        echo 'Skip Push.'    
    fi
}

main(){
    resolve_platform
    resolve_ubuntu_version
    build_image "${LSWS_VERSION}" "${PHP_VERSION}" || exit 1
    test_image "${LSWS_VERSION}" "${PHP_VERSION}" || exit 1
    push_image "${LSWS_VERSION}" "${PHP_VERSION}" "${TAG}"
}

check_input ${1}
while [ ! -z "${1}" ]; do
    case ${1} in
        -[hH] | -help | --help)
            help_message
            ;;
        -[lL] | -lsws | --lsws) shift
            check_input "${1}"
            LSWS_VERSION="${1}"
            ;;
        -[pP] | -php | --php) shift
            check_input "${1}"
            RAW_PHP_VERSION="${1}"
            PHP_VERSION="$(normalize_php_version "${RAW_PHP_VERSION}")"
            if [ "${RAW_PHP_VERSION}" != "${PHP_VERSION}" ]; then
                echo "Normalize PHP version: ${RAW_PHP_VERSION} -> ${PHP_VERSION}"
            fi
            ;;
        -[tT] | -tag | -TAG | --tag) shift
            TAG="${1}"
            ;;
        -[aA] | -arch | --arch) shift
            check_input "${1}"
            ARCH="${1}"
            ;;                        
        --push )
            PUSH=true
            ;;            
        *) 
            help_message
            ;;              
    esac
    shift
done

main
