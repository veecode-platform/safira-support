#!/bin/bash
# Download Versions of the following software:

VERIONS_PATH="https://vfipaas.github.io/safira-support/versions"
OPENAPI_GENERATOR_VERSION=$(curl ${VERIONS_PATH}/openapi-codegen.txt -L -s)
GOOGLE_JAVA_FORMAT_VERSION=$(curl ${VERIONS_PATH}/google-java-format.txt -L -s)
INSOMNIA_INSO_VERSION=$(curl ${VERIONS_PATH}/inso.txt -L -s)
OKTETO_VERSION=$(curl ${VERIONS_PATH}/okteto.txt -L -s)
KUBECTL_VERSION=$(curl ${VERIONS_PATH}/kubectl.txt -L -s)
SAFIRA_CLI_VERSION=$(curl ${VERIONS_PATH}/safira-cli.txt -L -s)

SAFIRA_BIN_FOLDER=${HOME}/.safira/bin

function getOS(){
    declare RESPONSE
    if [ $(uname) = "Linux" ]; then
        SAFIRA_OS="linux"
        elif [ $(uname) = "Darwin" ]; then
        SAFIRA_OS="darwin"
    else
        echo "Unsupported OS"
        exit 1
    fi
}

# x86_64, i686, arm, or aarch64
function getArchitecture(){
    SAFIRA_ARCHITECTURE=`uname -m`
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
        curl -L "https://repo1.maven.org/maven2/org/openapitools/openapi-generator-cli/${OPENAPI_GENERATOR_VERSION}/openapi-generator-cli-${OPENAPI_GENERATOR_VERSION}.jar" --output ${BIN_FILE}
    fi
}

#https://github.com/google/google-java-format/releases/download/v${GOOGLE_JAVA_FORMAT_VERSION}/google-java-format-${GOOGLE_JAVA_FORMAT_VERSION}-all-deps.jar
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
    FILE_NAME="inso-${SAFIRA_OS}-${INSOMNIA_INSO_VERSION}"

    if [ "${SAFIRA_OS}" = "linux" ]; then
        COMPRESSED_FILE="${FILE_NAME}.tar.xz"
        elif [ "${SAFIRA_OS}" = "darwin" ]; then
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

# https://github.com/okteto/okteto/releases/download/2.4.0/okteto-Darwin-arm64
# https://github.com/okteto/okteto/releases/download/2.4.0/okteto-Darwin-x86_64
# https://github.com/okteto/okteto/releases/download/2.4.0/okteto-Linux-arm64
# https://github.com/okteto/okteto/releases/download/2.4.0/okteto-Linux-x86_64
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

# curl -LO "https://dl.k8s.io/release/v1.23.3/bin/darwin/amd64/kubectl"
# curl -LO "https://dl.k8s.io/release/v1.23.3/bin/darwin/arm64/kubectl"
# curl -LO "https://dl.k8s.io/release/v1.23.3/bin/linux/amd64/kubectl"
function downloadKubectl(){
    declare DESTINY_FOLDER=${SAFIRA_BIN_FOLDER}/kubectl/${KUBECTL_VERSION}
    declare BIN_FILE="${DESTINY_FOLDER}/kubectl"
    [[ -f "$BIN_FILE" ]]&&return;
    mkdir -p ${DESTINY_FOLDER}
    # FILE_NAME="kubectl"

    if [ "${SAFIRA_ARCHITECTURE}" = "x86_64" ]; then
        ARCHITECTURE="amd64"
        elif [ "${SAFIRA_ARCHITECTURE}" = "arm" ]; then
        ARCHITECTURE="arm64"
    fi

    DOWNLOAD_URL="https://dl.k8s.io/release/v${KUBECTL_VERSION}/bin/${SAFIRA_OS}/${ARCHITECTURE}/kubectl"
    curl -sL ${DOWNLOAD_URL} --output ${BIN_FILE}
    chmod +x ${BIN_FILE}
}
# https://github.com/vfipaas/safira-cli/releases/download/0.6.0/safira-cli-linux-arm64.tar.gz
# https://github.com/vfipaas/safira-cli/releases/download/0.6.0/safira-cli-linux-x64.tar.gz
# https://github.com/vfipaas/safira-cli/releases/download/0.6.0/safira-cli-macos-arm64.zip
# https://github.com/vfipaas/safira-cli/releases/download/0.6.0/safira-cli-macos-x64.zip
function downloadSafira(){
    declare DESTINY_FOLDER=/usr/local/bin
    FILE_NAME="safira-cli"

    if [ "${SAFIRA_ARCHITECTURE}" = "x86_64" ]; then
        ARCHITECTURE="x64"
        elif [ "${SAFIRA_ARCHITECTURE}" = "arm" ]; then
        ARCHITECTURE="arm64"
    fi

    if [ "${SAFIRA_OS}" = "linux" ]; then
        FILE_NAME="${FILE_NAME}-linux-${ARCHITECTURE}"
        COMPRESSED_FILE="${FILE_NAME}.tar.gz"
        elif [ "${SAFIRA_OS}" = "darwin" ]; then
        FILE_NAME="${FILE_NAME}-macos-${ARCHITECTURE}"
        COMPRESSED_FILE="${FILE_NAME}.zip"
    fi

    DOWNLOAD_URL="https://github.com/vfipaas/safira-support/releases/download/${SAFIRA_CLI_VERSION}/${COMPRESSED_FILE}"

    sudo curl -sL ${DOWNLOAD_URL} --output ${DESTINY_FOLDER}/${COMPRESSED_FILE}
    if [ "${SAFIRA_OS}" = "linux" ]; then
        sudo tar -xf ${DESTINY_FOLDER}/${COMPRESSED_FILE} -C ${DESTINY_FOLDER}
        elif [ "${SAFIRA_OS}" = "darwin" ]; then
        sudo unzip -qq ${DESTINY_FOLDER}/${COMPRESSED_FILE} -d ${DESTINY_FOLDER}
    fi
    sudo rm ${DESTINY_FOLDER}/${COMPRESSED_FILE}
    sudo chmod +x ${DESTINY_FOLDER}/safira-cli
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

getOS
getArchitecture
downloadAll
# curl https://vfipaas.github.io/safira-support/install.sh -sSfL | bash

