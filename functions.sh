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

function renameDB {
	cd bashDBMS/databases
	echo "Enter new name : "
	read newName 
	mv ./$DBname ./$newName
	cd ../..
	echo "Database renamed successfuly"
	mainList
}

function dropDB {
	if [ -d "/bashDBMS/databases/$DBname" ]
	then
	   cd /bashDBMS/databases;
	   rm -r $DBname;
	   echo "database dropped successfuly";
	   else
	   echo "database does not exist";
	fi
	cd ../..
	mainList
}

function listDBs {
    if [ "$(ls -A /bashDBMS/databases)" ]
    then
	cd /bashDBMS/databases
        ls .
	echo "choose database : "
	read DBname
    else
        echo "No databases available";
    fi
    cd ../..
}

function createMetaDataTable {
	echo "Enter table name : "
	read newTableName
	
	cd bashDBMS/databases/$DBname

	if [ -e ${newTableName}.metaData ]; then
	    echo "table already created";
	    cd ../../..
	else 
	    touch ${newTableName}.metaData
	    echo "table created successfully"

	    echo "Number of column : "
	    read columnNumber

	    for ((i = 0; i<${columnNumber}; ++i))
	    do
		echo "Enter name and type of column $i : "
		read col
		colType=$(cut -f2 "$col") 
		echo $colType
	    done
	    cd ../../..
	fi

	useDB
}

function dropTable {
	cd bashDBMS/databases/$DBname
	echo $DBname
	ls *data | cut -d"." -f1
	echo "choose table name : "
	read tableName
	rm $tableName*
	cd ../../..
	echo "$tableName removed successfuly"
	useDB
}

function renameDB {
	cd /bashDBMS/databases
	echo "Enter new name : "
	read newName 
	mv ./$DBname ./$newName
	cd ../..
	echo "Database renamed successfuly"
	mainList
}

function createTable {
    echo "Insert table name: ";
    read table;

    file=/bashDBMS/databases/$DBname/$table.data;

    if [ -f $file ]
    then
        echo "Table is already created!";
    else       
        touch $file;

        echo "Insert number of table columns: ";
        read number;
        
        for (( i=1; i<=$number; i++ ))
        do
            echo "Insert $i column: ";
            read cols[$i-1];
        done

		
        for (( i=1; i<=$number; i++ ))
        do
			if [ $i -eq ${#cols[@]} ]
			then
				echo -n ${cols[$i-1]} >> $file;
			else
            	echo -n ${cols[$i-1]}"|" >> $file;
			fi
        done
    fi
}

function insert {
	echo "Write your insert query: ";
	read command into table values array;

	file=/bashDBMS/databases/$DBname/$table.data;

	if [ $command = 'insert' ] && [ $into = 'into' ] && [ $values = 'values' ]
	then
		for (( x=1; x<=${#array[@]}; x++ ))
        do
			printf "%s\n" "${array[$x-1]}"
        done
	else
		echo "Syntax error!";
		insert;
	fi
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
            createTable;
            createMetaDataTable;
		break;;

		Insert)	
			insert;
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
			  renameDB
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

