#!/bin/bash
DATA_FOLDER=../data
DB_NAME=users.db
DB_PATH=$DATA_FOLDER/$DB_NAME

checkDb() {
   if [[ ! -f $DB_PATH ]];
   then
        read -r -p "$DB_NAME does not exist. Do you want to create it? [Y/n] " answer
        answer=${answer,,}
        if [[ "$answer" =~ ^(yes|y)$ ]];
        then
            touch $DB_PATH
            echo "File ${DB_PATH} is created."
        else
            echo "File ${DB_PATH} must be created to continue. Try again." >&2
            exit 1
        fi
    fi 
}

validateLetters() {
    if [[ $1 =~ ^[A-Za-z_]+$ ]]; then return 0; else return 1; fi
}

add() {
    checkDb

    read -p "Enter user name: " username
    validateLetters $username
    if [[ "$?" == 1 ]];
    then
      echo "Name must have only latin letters."
      exit 1
    fi

    read -p "Enter user role: " role
    validateLetters $role
    if [[ "$?" == 1 ]]
    then
      echo "Role must have only latin letters."
      exit 1
    fi

    echo "${username}, ${role}" | tee -a $DB_PATH
}

backup() {
    checkDb

    backupFileName=$(date +'%Y-%m-%d-%H-%M-%S')-$DB_NAME.backup
    cp $DB_PATH $DATA_FOLDER/$backupFileName

    echo "Backup is created."
}

restore() {
    checkDb

    latestBackupFile=$(ls $DATA_FOLDER/*-$DB_NAME.backup | tail -n 1)

    if [[ ! -f $latestBackupFile ]]
    then
        echo "No backup file found."
        exit 1
    fi

    cat $latestBackupFile > $DB_PATH

    echo "Backup is restored."
}

find() {
    checkDb

    read -p "Enter username to search: " username

    awk -F, -v x=$username '$1 ~ x' $DB_PATH
    # output=`awk -F, -v x=$username '$1 ~ x' ../data/users.db`
    # output=$(awk -F, -v x=$username '$1 ~ x' ../data/users.db)

    # don't work =(
    if [[ "$?" == 1 ]]
    then
        echo "User not found."
        exit 1
    fi
}

inverseParam="$2"
list() {
    checkDb
    if [[ $inverseParam == "--inverse" ]]
    then
      cat --number $DB_PATH | sort -r 
    else
      cat --number $DB_PATH
    fi
}

help() {
    echo "Manages users in db. It accepts a single parameter with a command name."
    echo
    echo "Syntax: db.sh [command]"
    echo
    echo "List of available commands:"
    echo
    echo "add       Adds a new line to the $DB_NAME. Script must prompt user to type a
                    username of new entity. After entering username, user must be prompted to
                    type a role."
    echo "backup    Creates a new file, named" $DB_PATH".backup which is a copy of
                    current" $DB_NAME
    echo "find      Prompts user to type a username, then prints username and role if such
                    exists in $DB_NAME. If there is no user with selected username, script must print:
                    “User not found”. If there is more than one user with such username, print all
                    found entries."
    echo "list      Prints contents of $DB_NAME in format: N. username, role
                    where N – a line number of an actual record
                    Accepts an additional optional parameter inverse which allows to get
                    result in an opposite order – from bottom to top"
}

func() {
    case $1 in
        add)            add ;;
        backup)         backup ;;
        restore)        restore ;;
        find)           find ;;
        list)           list ;;
        help | '' | *)  help ;;
    esac
}

func $1
