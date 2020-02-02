#!/bin/bash

function createDB {
	echo "Insert new database name: ";
    read name;

    if [ -d "/bashDBMS/databases/$name" ]
    then
        echo "database already created";
    else
        mkdir -p /bashDBMS/databases/$name;
        echo "database create successfully";
    fi
    
}

function dropDB {
    echo "Insert database name to delete: ";
    read name;

    if [ -d "/bashDBMS/databases/$name" ]
    then
        cd /bashDBMS/databases;
        rm -r $name;
        echo "database dropped successfuly";
    else
        echo "database does not exist";
    fi
}

dropDB;