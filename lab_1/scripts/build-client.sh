#!/bin/bash

SCRIPT_DIR=`dirname "$(readlink -f "$BASH_SOURCE")"`
ROOT_DIR=${SCRIPT_DIR%/*}

CLIENT_REPO_NAME=shop-angular-cloudfront
CLIENT_ZIP_FILE_NAME=client-app.zip

CLIENT_SRC_DIR=$ROOT_DIR/$CLIENT_REPO_NAME
CLIENT_DIST_DIR=$CLIENT_SRC_DIR/dist
CLIENT_APP_DIR=$CLIENT_DIST_DIR/app
CLIENT_APP_ZIP_FILE=$CLIENT_DIST_DIR/$CLIENT_ZIP_FILE_NAME

NG_BIN=$CLIENT_SRC_DIR/node_modules/@angular/cli/bin/ng.js

checkZipFile() {
    if [ -e "$CLIENT_APP_ZIP_FILE" ]; then
        rm "$CLIENT_APP_ZIP_FILE"
        echo "$CLIENT_APP_ZIP_FILE was removed."
    fi
}

installDependencies() {
    cd $CLIENT_SRC_DIR
    npm install
    npm install -D
    cd $ROOT_DIR
}

build() {
    cd $CLIENT_SRC_DIR
    NG_CLI_ANALYTICS="false" $NG_BIN build --configuration=${ENV_CONFIGRATURATION:-}
    cd $ROOT_DIR
}

compress() {
    cd $CLIENT_DIST_DIR
    zip -r $CLIENT_APP_ZIP_FILE app
}

main() {
    installDependencies
    checkZipFile
    build
    compress
}

main $@
