#!/bin/bash
#======================================================
#Goal: 1) Verificar todas as claims do programa em C;
#		  Restrições de Verificação:
#		  TIMEOUT=3600s; UpperBound=100;
#      2) Armazenar cada resultado
#      3) Exibir o resultado geral da verificação.
#======================================================

#PATH -------->
ABS_PATH_EZPROOFC="/home/hrocha/Documents/Projects/EZProofC"
DIR_VERIFICATION=$ABS_PATH_EZPROOFC"/modules/verification"
#PATH -------->

#--------------------------------------------------------
#Get arch
get_arch=`arch`
set_arch=0

if [ $get_arch == "x86_64" ];
then
	set_arch="--64"		
else
	set_arch="--32"	
fi
#--------------------------------------------------------


#Global VARS
#--------------------------------------------------------
PATH_c_code=$1
name_file=`echo $PATH_c_code | grep -o "[^/]*$" | grep -o "^.[^.]*"`

#Configurações de verificação com ESBMC
TIMEOUT=3600s #1h=3600s
UpperBound=100

#Variaveis dos resultados da verificação
VC_total=0
VC_successful=0
VC_violated=0
VC_failed=0
number_of_files=0


print_results()
{
  echo " "
  echo "---------------------------------------------------------"
  echo ">> Results from:" 
  echo "    "$PATH_c_code
  echo "---------------------------------------------------------"
  echo "Lines of Code:" $loc  
  echo "Total Claim(s):"  $VC_total
  echo "Passed Claim(s):" $VC_successful
  echo "Violated Claim(s):" $VC_violated
  echo "Time Out(s):" $VC_failed
  echo "Total Time:" $total_time "s"  
  echo "---------------------------------------------------------"  
}

#************************ Functions ********************************
init_vars()
{
  loc=0  
  bound=0
  VC_total=0
  VC_successful=0
  VC_violated=0
  VC_timeout=0
  VC_Exc_UpperBound=0
  number_of_files=0
}

#************************ End Functions ********************************

#=====================================================================
#MAIN

      
#Identificando as Claims do programa analisado   
matches=`esbmc --no-library --show-claims $PATH_c_code` 
matches=`echo $matches| egrep -o 'Claims*'`

#Count and Store the number of claims
for claim_nr in $matches
do
	VC_total=`expr $VC_total + 1`
done

#criando pastas para os resultados das claims veerificadas
if [ -e $DIR_VERIFICATION"/"$name_file"_result.dir" ];
then
	rm -rf $DIR_VERIFICATION"/"$name_file"_result.dir"
	mkdir $DIR_VERIFICATION"/"$name_file"_result.dir"
else
	mkdir $DIR_VERIFICATION"/"$name_file"_result.dir"
fi

#Testando propriedades
echo "________________________________________________________"
i=1
while [ $i -le $VC_total ]; 
do
	#While the flag it was iguals to 1 the new bound will be tested
	test_bound=1
	rec_unwind=1
	bound=0
	depth=0				
	claim=0
	
	echo "Checking property" $i "of" $VC_total	
	
	#global time
	START=$(date +%s)		
			
	while [ $rec_unwind -eq 1 ];
	do		
		bound=`expr $bound + 5`
		#PATH
		esbmc $set_arch --no-library --timeout $TIMEOUT --unwind $bound --claim $i  $PATH_c_code &> $DIR_VERIFICATION"/"$name_file"_result.dir"/$name_file"_property_"$i.tmp
		
		END=$(date +%s)
		total_time=$(( $END - $START ))
		
		#PATH
		#checking if verification was sucessul about bound
		#Checking if the bound was enough
		rec_msn_bound=`cat $DIR_VERIFICATION"/"$name_file"_result.dir"/$name_file"_property_"$i.tmp | grep -c 'unwinding assertion loop'`			
		#Checking if had been generated a TIMEOUT set on ESBMC
		recived_TO=`cat $DIR_VERIFICATION"/"$name_file"_result.dir"/$name_file"_property_"$i.tmp | grep -c 'Timed out'`
		#Propriedades okay
		result_VC=`cat $DIR_VERIFICATION"/"$name_file"_result.dir"/$name_file"_property_"$i.tmp | grep -c 'SUCCESSFUL'`
		
				
		#Checking the 'unwinding assertion loop'
		#We got a unwinding assertion loop
		if [ $rec_msn_bound -eq 1 ] && [ $recived_TO -eq 0 ] && [ $bound -le $UpperBound ];
		then
			rec_unwind=`expr $rec_unwind`	
		#We stop the verification	
		else	
			rec_unwind=`expr $rec_unwind - 1`			
		fi	
		
	done
	
	#Check In das propriedades testadas
	#Time Out
	if [ $recived_TO -eq 1 ];
	then
		VC_timeout=`expr $VC_timeout + 1`
		echo "Status: Time Out"
	elif [ $result_VC -eq 1 ];
	then 
		VC_successful=`expr $VC_successful + 1`
		echo "Status: Passed"
	elif [ $bound -gt $UpperBound ];
	then
		VC_Exc_UpperBound=`expr $VC_Exc_UpperBound + 1`
		echo "Status: Exceeded the Upper Bound"
	else
		VC_violated=`expr $VC_violated + 1`
		echo "Status: Violated"
	fi
	
	i=`expr $i + 1`
done 

#numero de linhas do código
loc=`cat $PATH_c_code | wc -l`

print_results
init_vars
echo "________________________________________________________"
   
  

