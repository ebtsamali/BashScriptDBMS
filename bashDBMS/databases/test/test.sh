#!/bin/bash

tableName="t6"
colName="pass"
typeset -i Id=1

if [ "$(sed -n "1{/$colName/p};q" ${tableName}.data)" ] && [ "$(sed -n "/^$Id/p" ${tableName}.data)" ]
then
	echo "colName exists"
fi
