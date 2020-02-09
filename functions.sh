#!/bin/bash

function createDB {
	echo "Insert new database name: ";
	read -e name;

	if [ -d "bashDBMS/databases/$name" ]
	then
		echo "database already created";
	else
		mkdir -p .bashDBMS/databases/$name;
	echo "database create successfully";
	fi
    
}

function renameDB {
	cd bashDBMS/databases
	echo "Enter new name : "
	read -e newName 
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
		ls bashDBMS/databases;
		echo "select database : "
		read -e DBname

		if [ -d bashDBMS/databases/$DBname ]
		then
			useDB;
		else
			echo "database does not exist";
			listDBs;
		fi
    else
        echo "No databases available";
    fi
}

# function createMetaDataTable {

# 	if [ -e ${newTableName}.metaData ]; then
# 	    echo "table already created";
# 	    cd ../../..
# 	else 
	    
# 	fi

	
# }

function checkNewValueValidation {
	if [[ $1 =~ ^[+-]?[0-9]+$ ]]; then
	echo "int"

	elif [[ $1 =~ ^[+-]?[0-9]+\.$ ]]; then
	echo "varchar"

	elif [[ $1 =~ ^[+-]?[0-9]+\.?[0-9]*$ ]]; then
	echo "float"

	else
	echo "varchar"
	fi
}

function validateType {
	firstLineMetadata=$(head -n 1 $1.metaData) 
	IFS='|' read -r -a firstLineMetadataArr <<< "$firstLineMetadata"

	firstLineData=$(head -n 1 $1.data) 
	IFS='|' read -r -a firstLineDataArr <<< "$firstLineData"

	rowNum=$(sed -n "/^$4|/=" $1.data)

	rowNumData=$(sed -n "${rowNum}p" $1.data)
	IFS='|' read -r -a rowNumDataArr <<< "$rowNumData"

	newValueType=$(checkNewValueValidation $3)

	for index in "${!firstLineDataArr[@]}"
	do
	    if [ $2 == ${firstLineDataArr[$index]} ]
	    then
		if [[ $newValueType == ${firstLineMetadataArr[$index]} ]]
		then
		    oldValue=${rowNumDataArr[$index]} 
		    ex -sc "${rowNum}s/$oldValue/$3/g" -cx $1.data
		    echo "$colName updated successfully"
		else 
		    echo "ERROR, input value is invalid"
		fi
	    fi
	done
}

function listTables {
    cd bashDBMS/databases/$DBname
	ls *data | cut -d"." -f1
    cd ../../..
    useDB
}

function updateTable {
	cd bashDBMS/databases/$DBname
	printf "write update command by using id condition : "	
	read -e update tableName Set colName equal newValue where Id equal idNum
	if [[ $update == "update" && $Set == "set" && $equal == "=" && $where == "where" && $Id == "id" ]]
	then 
		tablesNameArr=($(ls *data | cut -d"." -f1))
		
		for (( j=0; j<${#tablesNameArr[@]}; j++ ))
		do
			if [[ ${tablesNameArr[$j]} == $tableName ]]
			then
				if [[ ("$(sed -n "1{/$colName/p};q" ${tableName}.data)")  &&  ("$(sed -n "/^$idNum/p" ${tableName}.data)") ]]
                then
				    validateType $tableName $colName $newValue $idNum
				else 
			   	    echo "ERROR, $colName not exist or invalid id"
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

function deleteRow {
    cd bashDBMS/databases/$DBname
	printf "write delete command by using id condition : "	
	read -e delete from tableName where Id equal idNum
	if [[ $delete == "delete" && $from == "from" && $equal == "=" && $where == "where" && $Id == "id" ]]
	then 
        tablesNameArr=($(ls *data | cut -d"." -f1))
		
		for (( j=0; j<${#tablesNameArr[@]}; j++ ))
		do
			if [[ ${tablesNameArr[$j]} == $tableName ]]
			then                
                if [[ "$(sed -n "/^$idNum/p" ${tableName}.data)" ]]
                then
                    sed -i "/^${idNum}|/d" ${tableName}.data 
                    echo "one row deleted successfully"
				else 
			   	    echo "ERROR, invalid id"
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
	ls *data | cut -d"." -f1
	echo "select table name : "
	read -e tableName
	rm $tableName.*
	cd ../../..
	echo "$tableName removed successfuly"
	useDB
}

function renameDB {
	cd bashDBMS/databases
	echo "Enter new name : "
	read -e newName 
	mv ./$DBname ./$newName
	cd ../..
	echo "Database renamed successfuly"
	mainList
}

function createTable {
	typeArr=(int double decimal float bigint boolean date time datetime timestamp varchar text char)

    echo "Insert table name: ";
    read -e table;

    file=bashDBMS/databases/$DBname/$table.data;
	metaData=bashDBMS/databases/$DBname/$table.metaData;

	if [ -f $file ]
    then
        echo "Table is already created!";
    else       
        touch $file $metaData;

	    echo "table created successfully";

        echo "Insert number of table columns: ";
        read -e number;
        
        for (( i=1; i<=$number; i++ ))
        do
            echo "Enter name and type of column $i : "
			read -e colName colType;

			if [ $colName ] && [ $colType ]
			then 
				cols[$i-1]=$colName;

				for (( j=0; j<${#typeArr[@]}; j++ ))
				do
						if [[ ${typeArr[$j]} == $colType ]]
						then
						if [[ $i == $(expr $number) ]]
						then
							printf ${colType} >> $metaData

							else printf ${colType}"|" >> $metaData
						fi
							
						fi
				done
			else
				echo "Insert column name and it is data type";
				rm $file $metaData;
				createTable;
				return;
			fi

			
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
	read -e command into table values array;

	file=bashDBMS/databases/$DBname/$table.data;
	metaData=bashDBMS/databases/$DBname/$table.metaData;

	types=($(head -n 1 $metaData | sed -e 's/|/ /g'));

	if [ $command = 'insert' ] && [ $into = 'into' ] && [ $values = 'values' ]
	then
		cd bashDBMS/databases/$DBname;
		tablesNameArr=($(ls *data | cut -d"." -f1));
		cd ../../..;

		for (( j=0; j<${#tablesNameArr[@]}; j++ ))
		do
			if [[ ${tablesNameArr[$j]} == $table ]]
			then
				values=$(echo $array | sed -e 's/(/ /g' -e 's/,/ /g' -e 's/)/ /g');
				read -a arr <<< $values;

				printf "\n" >> $file;

				error=0;
				for (( i=1; i<=${#arr[@]}; i++ ))
				do
					if [ ${types[$i-1]} = $(checkNewValueValidation ${arr[$i-1]}) ]
					then
						if [ $i -eq ${#arr[@]} ]
						then
							printf ${arr[$i-1]} >> $file;
						else
							printf ${arr[$i-1]}"|" >> $file;
						fi
					else
						if [ $error -eq 0 ]
						then
							index=$i;
						fi
						error+=1;
					fi
				done

				if [ $error -gt 0 ]
				then
					sed -i '$d' $file;
					echo "Error: check value $index datatype";
					insert;
				fi

			fi
		done
		echo "Data inserted successfully";
		if [[ ! " ${tablesNameArr[@]} " =~ " ${table} " ]]; then
				echo "ERROR, $table table does not exist in database"
		fi
	else
		echo "Syntax error!";
		insert;
	fi
}

function selectAll {
	echo "Write your select query: ";
	read -e command col from table;
	file=bashDBMS/databases/$DBname/$table.data;
	
	if [ $command = "select" ] && [ $from = "from" ]
	then
		if [ $col = "all" ]
		then
			printf "\n";
			cat $file;
			printf "\n\n";
		else
			headers=($(head -n 1 $file | sed -e 's/|/ /g'));

			for (( k=1; k<=${#headers[@]}; k++ ))
			do
				if [ $col == ${headers[$k-1]} ] 
				then
					awk -F "|" -v a="$k" '{print $a}' $file;
				fi
			done
		fi
	else
		echo "Syntax error!";
		selectAll;
	fi
	
}

function useDB {
	PS3="select command : "
	select choice in List Select Create Insert Update Delete Drop Return Exit
	do
	   case $choice in 
		List)
			listTables;	
		break;;

		Select)	
			selectAll
		break;;

		Create)
		   createTable	
		break;;

		Insert)	
			insert;
		break;;
	
		Update)
			updateTable	
		break;;

		Delete)	
			deleteRow
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

	useDB;
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
			  PS3="select the command $ "
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


