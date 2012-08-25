#!/usr/bin/env perl
#------------------------------------------------------------------
# Autor: Herbert Oliveira Rocha -> UFAM -> GPL
# Year: 2012
# Objetivo: Ler os resultados obtidos na verificação do model checker
#	abstrair os dados referentes: Linha no código, Variavel e valor.
#	E instrumentar os mesmo em uma novas instancia do código.
# Status: ON DEV
# NOTE: Alterar a partir da linha 288, verificar se o assume será inserido antes ou depois da VAR??
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
	#TODO: efetuar o tratamento para retorno de funções	
	if(not($LinhasFile[$i] =~ m/(^[\--]+)/g) and not($LinhasFile[$i] =~ m/(^[<]+)/g) and not($LinhasFile[$i] =~ m/(^$)/g) and not($LinhasFile[$i] =~ m/(return_)/g)){					
		#print $i."IF \n";
		#print $LinhasFile[$i];
		push(@rec_Linhas_CE , $LinhasFile[$i]);
	}	
						
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
			###print $rec_number_line." | ".$rec_var_CE." | ".$rec_value_CE."\n";	
								
			savelist($rec_number_line,$rec_var_CE,$rec_value_CE);	
				
			}														
	}						

}#-> For dos valores do CE

#================================================================
# CALL geralist
geraLista();

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



#função que gera as listas já com os valores abstraidos
#===================================================================
#lists
@number_lines=();
@v_var_CE=();
@v_value_CE=();
sub savelist{
	if (scalar @_ != 3) {
        print "Função espera 3 argumentos\n";
        return 0;
    }
    my ($v_number_line,$v_var_CE,$v_value_CE) = @_;   
    	
	if(not($Filec[$v_number_line-1] =~ m/for(.*)/)){	
		#print $v_number_line.$v_var_CE.$v_value_CE."\n";		
		push(@number_lines,$v_number_line);
		push(@v_var_CE,$v_var_CE);
		push(@v_value_CE,$v_value_CE);
	}else{
		next;
	}	
	
}


#função que gera as linhas já com os valores intrumentados
#===================================================================
sub geraLista{
	$count_data = 0;	
		
	#Identifica as linhas sem duplicadas
	my %unique = ();
	foreach my $item (@number_lines)
	{
		$unique{$item} ++;
	}
	my @myunique = keys %unique;
	
	@num_lines = sort { $a <=> $b } @myunique;
	
	#verifica se a valores para a mesma linha		
	$count_igual=0;
	$mount_line="";
	foreach(@num_lines){
		$tmp = $_;		
		$mount_line = $tmp+1; #pois o assume será colocado na proxima linha identificado pelo CE
		foreach(@number_lines){			
			if($tmp == $_){
				$count_igual = $count_igual + 1;					
				if($count_igual == 1){
					$mount_line = $mount_line."| __ESBMC_assume( ".$v_var_CE[$count_data]."!=".$v_value_CE[$count_data];					
				}else{
					$count_data = $count_data + 1;
					$mount_line = $mount_line."&& ".$v_var_CE[$count_data]."!=".$v_value_CE[$count_data];					
				}				
			}			
		}
		$mount_line = $mount_line."); // by EZProofC\n";
		print RESULTABS $mount_line;
		###print $mount_line;
		$mount_line="";
		$count_igual=0;
		$count_data = $count_data + 1;
	}
	
	
}
