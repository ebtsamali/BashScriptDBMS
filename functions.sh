#!/bin/bash

function createDB {
	echo "Insert new database name: ";
	read name;

	if [ -d "/bashDBMS/databases/$name" ]
		then
			echo "database already created";
		else
			mkdir -p ./bashDBMS/databases/$name;
		echo "database create successfully";
    	fi
    
}

function dropDB {
    echo "Insert database name to delete: ";
    read name;

    if [ -d "bashDBMS/databases/$name" ]
    then
        cd bashDBMS/databases;
        rm -r $name;
        echo "database dropped successfuly";
    else
        echo "database does not exist";
    fi
    cd ../..
}

function listDBs {
    if [ "$(ls -A bashDBMS/databases)" ]
    then
	cd bashDBMS/databases
        ls .
	echo "choose database : "
	read DBname
    else
        echo "No databases available";
    fi
    cd ../..
}

function DBlist {
	cd /bashDBMS/databases
	for i in $(ls -d */); do echo ${i%%/}; done
	echo "choose database : "
	read DBname
	cd ../..
}

function dropTable {
	cd bashDBMS/databases/$DBname
	ls *data . | cut -d. -f1
	echo "choose table name : "
	read tableName
	rm $tableName*
	cd ../../..
	echo "$tableName was removed"
}

function useDB {
	select choice in List Select Create Insert Update Delete Drop Return Exit
	do
	   case $choice in 
		List) 	
		break;;

		Select)	
		break;;

		Create)	
		break;;

		Insert)	
		break;;
	
		Update)	
		break;;

		Delete)	
		break;;

		Drop)
		  dropTable	
		break;;
	
		Return)	
		break;;

		Exit)	
		break;;
	   esac
	done
}

function mainList {
	PS3="Select or Create DB > "

	select choice in Select-DB Create-DB 
	do
	case $choice in 
	  Select-DB) 
		PS3="Use, Rename or Drop DB : "
		select choice in Use-DB Rename-DB Drop-DB
		  do
		    case $choice in 
			Use-DB) 
			  listDBs
			  PS3="Choose the command $ "
			  useDB
			break;;

			Rename-DB)
			  listDBs
			  cd bashDBMS/databases
			  echo "Enter new name : "
			  read newName 
			  mv ./$DBname ./$newName
			  cd ../..
			break;;

			Drop-DB)
		     	  listDBs
			  dropDB	
			break;;
		    esac
		  done
	  break;;

	  Create-DB)
		createDB
		mainList
	  break;;

	esac
	done
}

mainList


