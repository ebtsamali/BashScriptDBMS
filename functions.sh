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
	if [ -d "bashDBMS/databases/$DBname" ]
	then
	   cd bashDBMS/databases;
	   rm -r $DBname;
	   echo "database dropped successfuly";
	   else
	   echo "database does not exist";
	fi
	cd ../..
	mainList
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

function createMetaDataTable {
	typeArr=(int double decimal float bigint boolean date time datetime timestamp varchar text char)
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

	    for (( i = 0; i<${columnNumber}; i++ ))
	    do
		echo "Enter name and type of column $i : "
		read colName colType
		for (( j=0; j<${#typeArr[@]}; j++ ))
		do
		    	if [[ ${typeArr[$j]} == $colType ]]
		    	then
				if [[ $i == $(expr $columnNumber - 1) ]]
				then
					printf ${colType} >> ${newTableName}.metaData

					else printf ${colType}"|" >> ${newTableName}.metaData
				fi
		      		
		    	fi
		done

	    done
	    cd ../../..
	fi

	useDB
}

function updateTable {
	cd bashDBMS/databases/$DBname
	printf "write update command by using id condition : "	
	read update tableName Set colName equal newValue where Id equal idNum
	if [[ $update == "update" && $Set == "set" && $equal == "=" && $where == "where" && $Id == "id" ]]
	then 
		tablesNameArr=($(ls *data | cut -d"." -f1))
		
		for (( j=0; j<${#tablesNameArr[@]}; j++ ))
		do
			if [[ ${tablesNameArr[$j]} == $tableName ]]
			then
				typeset -i ID=$Id
				if [[ ("$(sed -n "1{/$colName/p};q" ${tableName}.data)")  &&  ("$(sed -n "/^$Id/p" ${tableName}.data)") ]]
                   		then
			 		echo "colName exists"
				fi
			fi
		done

		if [[ ! " ${tablesNameArr[@]} " =~ " ${tableName} " ]]; then
    			echo "ERROR, $tableName table does not exist in database"
		fi
		
	else 
		echo "ERROR, write valid command"
	fi

	cd ../../..
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

function useDB {
	select choice in List Select Create Insert Update Delete Drop Return Exit
	do
	   case $choice in 
		List) 	
		break;;

		Select)	
		break;;

		Create)
		   createMetaDataTable	
		break;;

		Insert)	
		break;;
	
		Update)
		   updateTable	
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


