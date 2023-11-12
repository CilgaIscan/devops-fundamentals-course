#!/bin/bash

validateEnvironment() {
    if ! command -v jq &> /dev/null
    then
        echo "
jq could not be found!
you can use one of the following to install jq:

Debian and Ubuntu: sudo apt-get install jq
Fedora: sudo dnf install jq
openSUSE: sudo zypper install jq
Arch: sudo pacman -S jq
"
        exit 1
    fi

}

validateJSON() {
    filepath=$1
    if [ ! -f "$filepath" ]; then
        echo "$filepath does not exist!"
        exit 1
    fi

    searchTerms=('{{GitHub Owner}}'
    '{{Branch name}}'
    '{{BUILD_CONFIGURATION value}}'
    '{{PollForSourceChanges}}')
    
    for searchTerm in ${searchTerms[*]}; do
        grep $searchTerm $filepath >> /dev/null
        if [ ! $? -eq 0 ];
        then
            echo "$searchTerm not found!"
            exit 1
        fi
    done
}

updateJSON() {
    filepath=$1
    configuration=$2
    owner=$3
    branch=$4
    pollForSourceChanges=$5
    

    srcFolder=$(dirname $filepath)
    str=$(date +'%Y-%m-%d-%H-%M-%S')
    targetFilePath=$srcFolder/pipeline-$str.json

    jq 'del(.metadata) | map_values(.version+=1)' $filepath | sed "s#{{Branch name}}#$branch#g" | sed "s#{{GitHub Owner}}#$owner#g" | sed "s#{{PollForSourceChanges}}#$pollForSourceChanges#g" | sed "s#{{BUILD_CONFIGURATION value}}#$configuration#g" > $targetFilePath
}

main() {
    POSITIONAL_ARGS=()
    while [[ $# -gt 0 ]]; do
        case $1 in
            -c|--configuration)
                CONFIGURATION="$2"
                shift
                shift
            ;;
            -o|--owner)
                OWNER="$2"
                shift
                shift
            ;;
            -b|--branch)
                BRANCH="$2"
                shift
                shift
            ;;
            -p|--poll-for-source-changes)
                POLL_FOR_SOURCE_CHANGES="$2"
                shift
                shift
            ;;
            *)
                POSITIONAL_ARGS+=("$1") # save positional arg
                shift # past argument
            ;;
        esac
    done
    
    set -- "${POSITIONAL_ARGS[@]}" # restore positional parameters
    if [ -z $BRANCH ];
    then 
        BRANCH=main
    fi

    if [ -z $POLL_FOR_SOURCE_CHANGES ];
    then
        POLL_FOR_SOURCE_CHANGES='false'
    fi

    echo POSITIONAL_ARGS: $POSITIONAL_ARGS
    echo CONFIGURATION: $CONFIGURATION
    echo OWNER: $OWNER
    echo BRANCH: $BRANCH
    echo POLL_FOR_SOURCE_CHANGES: $POLL_FOR_SOURCE_CHANGES

    validateEnvironment
    validateJSON $POSITIONAL_ARGS

    updateJSON $POSITIONAL_ARGS $CONFIGURATION $OWNER $BRANCH $POLL_FOR_SOURCE_CHANGES
}

main $@
