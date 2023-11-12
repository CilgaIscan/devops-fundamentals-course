#!/bin/bash

SCRIPT_DIR=`dirname "$(readlink -f "$BASH_SOURCE")"`
ROOT_DIR=${SCRIPT_DIR%/*}

CLIENT_REPO_NAME=shop-angular-cloudfront

CLIENT_SRC_DIR=$ROOT_DIR/$CLIENT_REPO_NAME

runQuality() {
    cd $CLIENT_SRC_DIR

    npm audit || echo "Audit is failing"
    NG_CLI_ANALYTICS="false" npm run lint || echo "Project has linting problem(s)"
    NG_CLI_ANALYTICS="false" npm run test || echo "Project has error(s) for software tests"
}

main() {
    runQuality
}

main $@
