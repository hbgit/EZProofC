#!/bin/bash

#--------------------------------------------------------------------
#acesso as pasta dos codes que serão analisados
CCODE=ccode_here
cd ../$CCODE
#list of files
SOURCES=$(ls *.c)
cd ..
cd preprocessador/
#-------------------------------------------------------------------- 

#------------------------------ functions ---------------------------
list_file()
{
	echo "##################################################"
	echo "List of ANSI-C programs:"
	echo " "
	echo "--------------------------------------------------"
	#se não for vazio o resultado do ls
	if [ -n "$SOURCES" ]; 
	then
		for file in $SOURCES
		do
			echo $file			
			number_of_files=`expr $number_of_files + 1`
		done	
	echo "--------------------------------------------------"
	echo " " 
	echo "Total number of ANSI-C programs:" $number_of_files
	echo "##################################################"
	
	#pre-processa os códigos que serão analisados
	exec_processadorc	
	
	#se não
	else
	  #display
	  echo "No files.c or with extension *.c \nNo diretorio: ccode_here" 
	fi
	
}

exec_processadorc()
{
	echo ""
	echo "######################################################"
	echo ""
	echo "-> Starting the process of pre-processing code"
	for file in $SOURCES
	do
		echo "-> File: $file"
		#criando pastas para os files analisados
		mkdir $file"_result.dir" 
		(time ./uncrustify -q -l C -c ben.cfg -f ../$CCODE/$file) 2> $file"_result.dir"/"pre_"$file_"time" | 1>&2
		./uncrustify -q -l C -c ben.cfg -f ../$CCODE/$file > $file"_result.dir"/"pre_"$file
		
		#aux.pre
		(time aux_pre_processamento/aux_formatation.pl $file"_result.dir"/"pre_"$file) 2> $file"_result.dir"/"pre_aux_"$file_"time" | 1>&2
	done
	echo ""
	echo "######################################################"
		
}

list_file
