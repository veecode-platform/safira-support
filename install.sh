#!/bin/bash

# Download Versions of the following software:
VERIONS_PATH="https://veecode-platform.github.io/safira-support/versions"
OPENAPI_GENERATOR_VERSION=$(curl ${VERIONS_PATH}/openapi-codegen -L -s)
GOOGLE_JAVA_FORMAT_VERSION=$(curl ${VERIONS_PATH}/google-java-format -L -s)
INSOMNIA_INSO_VERSION=$(curl ${VERIONS_PATH}/inso -L -s)
OKTETO_VERSION=$(curl ${VERIONS_PATH}/okteto -L -s)
KUBECTL_VERSION=$(curl ${VERIONS_PATH}/kubectl -L -s)
SAFIRA_CLI_VERSION=$(curl ${VERIONS_PATH}/safira-cli -L -s)

SAFIRA_BIN_FOLDER=${HOME}/.safira/bin

function getOSAndArchitecture(){
    SAFIRA_OS=$(uname | tr '[A-Z]' '[a-z]')
    SAFIRA_ARCHITECTURE=$(uname -m )
    if [[ $SAFIRA_ARCHITECTURE = "@(aarch64|aarch64_be|armv8b|armv8l)" ]];then SAFIRA_ARCHITECTURE="arm64";fi
    if [[ "${SAFIRA_OS}" != @(linux|darwin) || ($SAFIRA_OS = 'linux' && $SAFIRA_ARCHITECTURE = 'arm64')]];then
      echo "Sorry, unsupported Operation System ${SAFIRA_OS}-${SAFIRA_ARCHITECTURE}";exit 2;
    fi
}

function downloadOpenapiGenerator(){
    declare DESTINY_FOLDER=${SAFIRA_BIN_FOLDER}/openapi-generator-cli/${OPENAPI_GENERATOR_VERSION}
    declare BIN_FILE="${DESTINY_FOLDER}/openapi-generator-cli"
    [[ -f "$BIN_FILE" ]]&&return;
    mkdir -p ${DESTINY_FOLDER}
    if  command -v mvn &> /dev/null;then
        mvn -q org.apache.maven.plugins:maven-dependency-plugin:2.9:get \
        -Dartifact=org.openapitools:openapi-generator-cli:${OPENAPI_GENERATOR_VERSION} \
        -Dtransitive=false \
        -Ddest=${BIN_FILE}
    else
        curl -sL "https://repo1.maven.org/maven2/org/openapitools/openapi-generator-cli/${OPENAPI_GENERATOR_VERSION}/openapi-generator-cli-${OPENAPI_GENERATOR_VERSION}.jar" --output ${BIN_FILE}
    fi
}

function downloadGoogleJavaFormat() {
    declare DESTINY_FOLDER=${SAFIRA_BIN_FOLDER}/google-java-format/${GOOGLE_JAVA_FORMAT_VERSION}
    declare BIN_FILE="${DESTINY_FOLDER}/google-java-format"
    [[ -f "$BIN_FILE" ]]&&return;
    mkdir -p ${DESTINY_FOLDER}
    curl -sL "https://github.com/google/google-java-format/releases/download/v${GOOGLE_JAVA_FORMAT_VERSION}/google-java-format-${GOOGLE_JAVA_FORMAT_VERSION}-all-deps.jar" --output ${BIN_FILE}

}

function downloadInsomniaInso(){
    declare DESTINY_FOLDER=${SAFIRA_BIN_FOLDER}/inso/${INSOMNIA_INSO_VERSION}
    declare BIN_FILE="${DESTINY_FOLDER}/inso"
    [[ -f "$BIN_FILE" ]]&&return;
    mkdir -p ${DESTINY_FOLDER}
    FILE_NAME="inso"

    if [ "${SAFIRA_OS}" = "linux" ]; then
        FILE_NAME="${FILE_NAME}-${SAFIRA_OS}-${INSOMNIA_INSO_VERSION}"
        COMPRESSED_FILE="${FILE_NAME}.tar.xz"
        elif [ "${SAFIRA_OS}" = "darwin" ]; then
        FILE_NAME="${FILE_NAME}-macos-${INSOMNIA_INSO_VERSION}"
        COMPRESSED_FILE="${FILE_NAME}.zip"
    fi
    DOWNLOAD_URL="https://github.com/Kong/insomnia/releases/download/lib@${INSOMNIA_INSO_VERSION}/${COMPRESSED_FILE}"
    curl -sL ${DOWNLOAD_URL} --output ${DESTINY_FOLDER}/${COMPRESSED_FILE}

    if [ "${SAFIRA_OS}" = "linux" ]; then
        tar -xf ${DESTINY_FOLDER}/${COMPRESSED_FILE} -C ${DESTINY_FOLDER}
        elif [ "${SAFIRA_OS}" = "darwin" ]; then
        unzip -qq ${DESTINY_FOLDER}/${COMPRESSED_FILE} -d ${DESTINY_FOLDER}
    fi
    chmod +x ${BIN_FILE}
    rm "${DESTINY_FOLDER}/${COMPRESSED_FILE}"
}

function downloadOkteto(){
    declare DESTINY_FOLDER=${SAFIRA_BIN_FOLDER}/okteto/${OKTETO_VERSION}
    declare BIN_FILE="${DESTINY_FOLDER}/okteto"
    [[ -f "$BIN_FILE" ]]&&return;
    mkdir -p ${DESTINY_FOLDER}
    FILE_NAME=$(echo "okteto-${SAFIRA_OS^}-${SAFIRA_ARCHITECTURE}")

    DOWNLOAD_URL="https://github.com/okteto/okteto/releases/download/${OKTETO_VERSION}/${FILE_NAME}"
    curl -sL ${DOWNLOAD_URL} --output ${BIN_FILE}
    chmod +x ${BIN_FILE}
}

function downloadKubectl(){
    declare DESTINY_FOLDER=${SAFIRA_BIN_FOLDER}/kubectl/${KUBECTL_VERSION}
    declare BIN_FILE="${DESTINY_FOLDER}/kubectl"
    [[ -f "$BIN_FILE" ]]&&return;
    mkdir -p ${DESTINY_FOLDER}

    if [ "${SAFIRA_ARCHITECTURE}" = "x86_64" ]; then
        ARCHITECTURE="amd64"
        elif [ "${SAFIRA_ARCHITECTURE}" = "arm64" ]; then
        ARCHITECTURE="arm64"
    fi

    DOWNLOAD_URL="https://dl.k8s.io/release/v${KUBECTL_VERSION}/bin/${SAFIRA_OS}/${ARCHITECTURE}/kubectl"
    curl -sL ${DOWNLOAD_URL} --output ${BIN_FILE}
    chmod +x ${BIN_FILE}
}

function downloadSafira(){
    declare DESTINY_FOLDER=/usr/local/bin
    FILE_NAME="safira-cli"

    if [ "${SAFIRA_ARCHITECTURE}" = "x86_64" ]; then
        ARCHITECTURE="x64"
        elif [ "${SAFIRA_ARCHITECTURE}" = "arm64" ]; then
        ARCHITECTURE="arm64"
    fi

    if [ "${SAFIRA_OS}" = "linux" ]; then
        FILE_NAME="${FILE_NAME}-linux-${ARCHITECTURE}"
        COMPRESSED_FILE="${FILE_NAME}.tar.gz"
        elif [ "${SAFIRA_OS}" = "darwin" ]; then
        FILE_NAME="${FILE_NAME}-macos-${ARCHITECTURE}"
        COMPRESSED_FILE="${FILE_NAME}.zip"
    fi

    DOWNLOAD_URL="https://github.com/veecode-platform/safira-support/releases/download/${SAFIRA_CLI_VERSION}/${COMPRESSED_FILE}"

    sudo curl -sL ${DOWNLOAD_URL} --output ${DESTINY_FOLDER}/${COMPRESSED_FILE}
    if [ "${SAFIRA_OS}" = "linux" ]; then
        sudo tar -xf ${DESTINY_FOLDER}/${COMPRESSED_FILE} -C ${DESTINY_FOLDER}
        elif [ "${SAFIRA_OS}" = "darwin" ]; then
        sudo unzip -oqq ${DESTINY_FOLDER}/${COMPRESSED_FILE} -d ${DESTINY_FOLDER}
    fi
    sudo rm ${DESTINY_FOLDER}/${COMPRESSED_FILE}
    sudo chmod +x ${DESTINY_FOLDER}/safira-cli
    ${DESTINY_FOLDER}/safira-cli autocomplete --refresh-cache
}

function downloadAll() {
    echo "Installing Dependencies 1/5"
    downloadOpenapiGenerator
    echo "Installing Dependencies 2/5"
    downloadGoogleJavaFormat
    echo "Installing Dependencies 3/5"
    downloadInsomniaInso
    echo "Installing Dependencies 4/5"
    downloadOkteto
    echo "Installing Dependencies 5/5"
    downloadKubectl
    echo "Installing safira-cli"
    downloadSafira
    echo "Installation Finished"
}

getOSAndArchitecture
downloadAll
