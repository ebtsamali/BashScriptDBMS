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

function validateType {
	firstLineMetadata=$(head -n 1 $1.metaData) 
	IFS='|' read -r -a firstLineMetadataArr <<< "$firstLineMetadata"

	firstLineData=$(head -n 1 $1.data) 
	IFS='|' read -r -a firstLineDataArr <<< "$firstLineData"

	if [[ $3 =~ ^[+-]?[0-9]+$ ]]; then
	type=int

	elif [[ $3 =~ ^[+-]?[0-9]+\.$ ]]; then
	type=string

	elif [[ $3 =~ ^[+-]?[0-9]+\.?[0-9]*$ ]]; then
	type=float

	else
	type=string
	fi

	for index in "${!firstLineDataArr[@]}"
	do
	    if [ $2 == ${firstLineDataArr[$index]} ]
	    then
		
		echo ${firstLineDataArr[$index]} $2
		if [[ $type == ${firstLineMetadataArr[$index]} ]]
		then
		echo "AA $type ${firstLineMetadataArr[$index]}";
		    echo "true"
		    validateRes=1
		else 
			echo "BB $type ${firstLineMetadataArr[$index]}";
		    echo "false"
		    validateRes=0
		fi
	    fi
	done
	echo "res = $validateRes"
	return $validateRes
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
				if [[ ("$(sed -n "1{/$colName/p};q" ${tableName}.data)")  &&  ("$(sed -n "/^$idNum/p" ${tableName}.data)") ]]
                   		then
					validateType $tableName $colName $newValue 
			 		if [ $? == 1 ] 
					then 
					    echo "yes"
					else 
					    echo "ERROR, input value is invalid"
					fi
				else echo "ERROR, $colName not exist or invalid id"
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
	rm $tableName.*
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
		   createMetaDataTable	
		break;;

		Insert)	
			insert;
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
		   mainList
		break;;

		Exit)
		   exit	
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


