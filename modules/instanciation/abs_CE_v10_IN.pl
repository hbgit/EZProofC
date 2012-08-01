#!/usr/bin/env perl
#------------------------------------------------------------------
# Autor: Herbert Oliveira Rocha -> UFAM -> GPL
# Year: 2012
# Objetivo: Ler os resultados obtidos na verificação do model checker
#	abstrair os dados referentes: Linha no código, Variavel e valor.
#	E instrumentar os mesmo em uma novas instancia do código.
# Status: OKAY
# Usage way: ./abs code.c file.c ce_file.tmp [--addassert]
#------------------------------------------------------------------


$ABS_PATH_EZPROOFC="[<??>]";
$DIR_ABS_AND_INST=$ABS_PATH_EZPROOFC."/modules/instanciation/";

#removendo diretorio anteriores com resultados anteriores
#system ("rm -rf *.dir");

#criando diretorio dos resultados
mkdir $DIR_ABS_AND_INST."result_abstration.dir";

#===================================================================
#Getting name of the C file and counterexample file,
#as well as the pathes

# Name of the C code and counterexample file without dot
$name_c_file="no";
$name_CE_file="no";
$path_c_file=$ARGV[0];
$pathfile_CE = $ARGV[1];

if($ARGV[0] =~ m/([^\/]*$)/g){
	$tmp = $1;	
	if($tmp =~ m/(^[^.]*)/g){
		$name_c_file=$1;
	}
}

if($ARGV[1] =~ m/([^\/]*$)/g){
	$tmp = $1;	
	if($tmp =~ m/(^[^.]*)/g){
		$name_CE_file=$1;
	}
}
#===================================================================

#DIR for result of abstraction
$name_dir_result = $DIR_ABS_AND_INST."result_abstration.dir/".$name_CE_file;
mkdir $name_dir_result;

#Reading Counterexample file
#===================================================================
open(ENTRADA , "<$pathfile_CE") or die "Nao foi possivel abrir o arquivo_CE.tmp para leitura: $!";
while (<ENTRADA>) { 	
	push(@LinhasFile,$_);
}
close ENTRADA;
#===================================================================

#Reading C file
#===================================================================
open(FILEC , "<$path_c_file") or die "Nao foi possivel abrir o arquivo.c para leitura: $!";
while (<FILEC>) { 		
	push(@Filec,$_);
	#copia para uma lista auxilar para a geração do novo código							
	push(@AuxFile,$_);
}
close ENTRADA;
#===================================================================

#Obtendo o número da propriedade do arquivo CE
if($name_CE_file =~ m/(property_.*)/g){	
	$rec_num_property = $1;
}else{
	$rec_num_property = "NID"; #not identified
}

#criando e abrindo arquivo com os dados abstraidos do CE
$result_file_abs = $name_dir_result."/"."abs_".$name_c_file."_".$rec_num_property;

		
open(RESULTABS, ">$result_file_abs"); #open for write, overwrite
#===================================================================
$sizeLinhasFile = @LinhasFile;

#Identifica a propriedade violada
for ($i=0; $i <= $sizeLinhasFile; $i++) {		
	if($LinhasFile[$i] =~ /^$/){		
		$i++;			
	}			
	if($LinhasFile[$i] =~ /Counter.*/){		
		# recebe a posição de $i onde foi encontrado a string: Counte Example:
		# jump the STring Counte Example: and the first white line		
		$rec_i_postion_CE = $i + 2;			
	}
	if($LinhasFile[$i] =~ /(Violated.*)/){
		# recebe a posição de $i onde foi encontrado a string: Violated Property:		
		$rec_i_postion_VP = $i;			
	}
			
}


#obtendo a propriedade violada
for ($i=$rec_i_postion_VP; $i <= $sizeLinhasFile; $i++) {
	push(@rec_Linhas_VP,$LinhasFile[$i]);				
}


#obtendo os dados referentes ao contraexemplo gerado
for ($i=$rec_i_postion_CE; $i <= ($rec_i_postion_VP - 1); $i++) {		
	
	#for DYNAMIC PATTERN	
	if(not($LinhasFile[$i] =~ m/(^[\--]+)/g) and not($LinhasFile[$i] =~ m/(^[<]+)/g) and not($LinhasFile[$i] =~ m/(^$)/g)){					
		#print $i."IF \n";
		#print $LinhasFile[$i];
		push(@rec_Linhas_CE , $LinhasFile[$i]);
	}
	#else{
		#print $i."ELSE \n";
	#}
						
}


#obtendo do contra exemplo: linhas -> variaveis -> valor;
$size_rec_Linhas_CE = @rec_Linhas_CE;

for($cont=0;$cont <= $size_rec_Linhas_CE; $cont++){
	
	#obtem a string "line n", o n é o numero da linha
	if($rec_Linhas_CE[$cont] =~ /(line.[0-9]*)/){
		
		#obtem o número na linha
		if($1 =~ /([0-9]*$)/){
		   #Line do CE		   
		   $rec_number_line = $1;				   
		}
		
		#obtendo apenas as linhas com as variaveis que iniciam com o nome do código
		#deste modo abstraindo os valores da funções
		$conca_string = $name_c_file."::";
		
		$nextLine = $cont + 1;
					
		#ANALISE DAS LINHAS IDENTIFICADA					
		if($rec_Linhas_CE[$nextLine]=~ /$conca_string/){
			
			#TESTAR MAIS ESTA REGEX
			#----------------------------------------------------------------------------------
			#print $rec_Linhas_CE[$nextLine]."\n"; -> REGEX -> \w[^:]*=.[^\(\)]*
			
			# -> backup da versão anteior if($rec_Linhas_CE[$nextLine] =~ /(\w[^:]*=.[^ ]*)/){
			#A expressão enterior não trava a questão dos vetores
			#A ainda falta verificar a possibilidade para ex. a = (x + y) 
			#necessario mais testes para verificar contra-exemplo compativel
			#----------------------------------------------------------------------------------
			if($rec_Linhas_CE[$nextLine] =~ /(\w[^:]*=.[^\(\)]*)/){			
				
				$rec_1 = $1;						
				if($rec_1 =~ /(^.[^=]*)/){
					
					#Criando escapes para simbolos como [], para poder aplicar regex depois para validação					
					if($1 =~ m/[][]/){
						while($1 =~ m/([][])/g){
							$left = $1;
							$left =~ s/[\[]/\\[/g; 
							$right = $left;
							$right =~ s/[\]]/\\]/g;
						}
						#VAR do CE
						$rec_var_CE = $right;
					}							
					
					#VAR do CE
					$rec_var_CE = $1;
				}						
				if($rec_1 =~ /(=.*)/){
					$rec_temp_valor = $1;							
					if($rec_temp_valor =~ /([^=].*)/){
						#Value do CE
						$rec_value_CE = $1;								
					}
				}
			}
			#Lista os valores coletados:
			#Aqui pois é o lugar onde e finalizado a validação da especificação
			#para a coleta de dados. Pois para a captura dos valores foi definido que
			#a proxima apos a linha analisada deve conter o nome do arquivo no linha, deste modo
			#isolando as outras linhas que não contem o que foi especificado
			#print $rec_number_line." | ".$rec_var_CE." | ".$rec_value_CE."\n";	
								
			geraLista($rec_number_line,$rec_var_CE,$rec_value_CE);	
				
			}														
	}						

}#-> For dos valores do CE


if($ARGV[2]){
	$ARGV[2] =~ m/(\w+)/;
	#opção --addassert -> inserir assert com a propriedade
	if($1 eq "addassert"){
		#opção confirmada @rec_Linhas_VP

		#PATH------------------------------------------------>
		#criando diretorio geral dos resultados das propriedades.
		mkdir $DIR_ABS_AND_INST."result_abs_property.p";
		
		#criando diretorio especifico para cada code
		mkdir $DIR_ABS_AND_INST."result_abs_property.p/".$name_CE_file;
		
		#criando e abrindo arquivo que conterá a propriedade abstraida
		$result_file_abs_property = $DIR_ABS_AND_INST."result_abs_property.p/".$name_CE_file."/"."abs_".$name_CE_file;
		
		#PATH------------------------------------------------>
		
		open(RESULT_ABS_P, ">$result_file_abs_property"); #open for write, overwrite
		
		#removendo linhas em branco
		$size_PV = @rec_Linhas_VP;	#vetor a ser liberado
		
		# - 1 colocado para evitar gerar uma linha em branco
		# na ultima repetição do laço
		for ($cont_PV=0; $cont_PV < ($size_PV-1);$cont_PV++){
			
			if($rec_Linhas_VP[$cont_PV] =~ /^$/){
				$cont_PV++;			
			}				
			#obtendo dados da propriedade violada
			
			push(@rec_new_linhas_vp, $rec_Linhas_VP[$cont_PV]); # vetor a ser liberado
			
		}
		
		$size_new_linhas_vp = @rec_new_linhas_vp;
		#percorrendo novo vetor sem linhas em branco
				
		for($new_cont_pv=0; $new_cont_pv < $size_new_linhas_vp; $new_cont_pv++){
						
			#obtendo a string "line_nº"			
			if($rec_new_linhas_vp[$new_cont_pv] =~ m/(line.[0-9]*)/){
				#obtem somente o número na linha da propriedade violada
				$1 =~ /([0-9]*$)/;
				$line_PV = $1;						
			}
			
			# -1 devido ao vetor começar com zero
			if($new_cont_pv == ($size_new_linhas_vp - 1)){
				#para obter a propriedade baseado no padrão do contra-exemplo gerado pelo
				#ESBMC verifica-se que a propriedade -1 linha da linha "VERIFICATION FAILED"
				# logo aplicamos (end_line - 1)
				#penultima posição
				#print $rec_new_linhas_vp[$new_cont_pv - 1];
				
				$rec_property = $rec_new_linhas_vp[$new_cont_pv - 1];
				
			}	
		}
		
		#ESCRVEVENDO resultados da propriedade no arquivo 
		print RESULT_ABS_P $line_PV." | ".$rec_property;		
		
		
	}#elsif(){ !para futuras opções!
	#}
	
	#fechando arquivo com os resultados da propriedade abstraida
	close(RESULT_ABS_P);			
}


@Filec = ();
@AuxFile = ();	
@rec_Linhas_CE  = ();

#fechando arquivo com os resultados
close(RESULTABS);
#===================================================================




#função que gera as linhas já com os valores intrumentados
#===================================================================
sub geraLista{
	if (scalar @_ != 3) {
        print "Função espera 3 argumentos\n";
        return 0;
    }
    my ($v_number_line,$v_var_CE,$v_value_CE) = @_;   
  
		$rec_type_ini = "";		
			
			if(not($Filec[$v_number_line-1] =~ m/for(.*)/)){			
				
				#verifica se é uma atribuição de valor	
				#$Filec[$v_number_line-1] =~ s/\s//gi;		
				if($Filec[$v_number_line-1] =~ m/(=)/){
					
					#UPDATE - BUG ABOUT SPACE
					#while($Filec[$v_number_line-1] =~ m/(int|char|float|double|unsigned|long|short)/g){	
						#if($1 eq ""){
							#$rec_type_ini = "";
						#}else{							
							#$rec_type_ini = $rec_type_ini." ".$1." ";
						#}	
					#}	
						
														
					if($Filec[$v_number_line-1] =~ m/(.*=)/){
						#obtem só a variavel depois da manipulação anterior de concatenação com =
						if($1 =~ m/(^.[^=]*)/){
							#VAR
							$rec_var = $1;
							#Verificando se é vetor -> delimitar so se for vetor
							#aplicar primeira etapa do algoritmo para vetor aqui "!HERE!"
							# 1º- obtendo posição no array ex. a[0] -> posição = 0;
												
							#abstraindo so a posição [0]
							if($rec_var =~ m/([\[\]].*)/){							
								$abs_vetor = $1;
								if($abs_vetor =~ m/([^\[\]])/){							   
								   $posi_vetor = $1;
								}
							}							
															
							#VALOR a ser inserido no código
							if($Filec[$v_number_line-1] =~ m/(=.*)/){
														
								$insere_value_CE = $1;
								
								#verificando se o valor é uma lista do vetor ex: { 1, 0 }
								#OBS: checar mais esta ER
								if($v_value_CE =~ /([\{\}]+)/){
									#aplicar segunda etapa do algoritmo HERE
									#Tratar o vetor ex: { 0 , 1}
									#2.1- removendo as chaves do vetor 
									
									$v_value_CE =~ m/([^\{\}]+)/;
									
									#2.2- efetuando slipt para obter os valores da lista
									@rec_split_vetor = split(/,/,$1);
									
									#percorrendo a lista de valores do vetor baseando-se na posição obtida da etapa 1
									#e adcionar a variavel o valor estipulado pelo contra-exemplo
									#baseado no indice do vetor da variavel obtida
									$size_vetor = @rec_split_vetor;
									for($cont_v=0; $cont_v < $size_vetor;$cont_v++){
										#print $rec_split_vetor[$cont_v]."\n";
										#print $cont_v."\n";
										if($cont_v == $posi_vetor){
											#print $rec_split_vetor[$cont_v]."\n";
											$v_value_CE = $rec_split_vetor[$cont_v];
										}
									}								
									
								}
							}						
							
							$insere_value_CE =~ s/[^=].*/$v_value_CE/g; 
							
													
							#nova linha já INSTRUMENTADA para ser inserida no código
							#$new_instrucao = $rec_type_ini.$rec_var.$insere_value_CE.";";	
							$new_instrucao = $rec_type_ini.$rec_var.$insere_value_CE."; //-> by EZPROOFC";	
										
							#ESCRVEVENDO resultados da instrumentação no arquivo result_instru_$file.txt
							#dados de cada linha: line_number|new_line
							print RESULTABS $v_number_line."|".$new_instrucao."\n";							
							#print "New Line -> ".$new_instrucao."\n";												
									
							}
					}
					
				}else{
					#casos como i++; | i--;				
					$new_instrucao = $v_var_CE." = ".$v_value_CE."; //-> by EZPROOFC";
					print RESULTABS $v_number_line."|".$new_instrucao."\n";						
					
				}
			}else{
				next;
			}

}			
			


	









