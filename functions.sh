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

