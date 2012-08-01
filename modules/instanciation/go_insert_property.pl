#!/usr/bin/env perl

#PATH --------------------------------------------->
$ABS_PATH_EZPROOFC="[<??>]";
$PATH_RESULT_new_code = $ABS_PATH_EZPROOFC."/result_instrument.out";
$DIR_ABS_AND_INST=$ABS_PATH_EZPROOFC."/modules/instanciation/";

#DIR property violated
$DIR_PROPERTY=$DIR_ABS_AND_INST."result_abs_property.p";
#PATH --------------------------------------------->

#inicialização da flag do assert
$flag_assert = 0;

#diretorio onde esta armazena os resultados da abstração da propriedade do contra-exemplo
@listdir = `ls $DIR_PROPERTY/`; 

#lendo os files em cada dir
foreach $dir (@listdir){
	@listfiles = `ls $DIR_PROPERTY/$dir`;
	#remove \n da string
	chomp ($dir);
	
	#ACESSANDO CADA file
	foreach $file (@listfiles){		
		
		chomp ($file);
		
		$pathfile = "$DIR_PROPERTY/$dir/$file";	
		
		#lendo cada arquivo com o RESULTADO DA ABSTRAÇÃO
		open(ENTRADA , "<$pathfile") or die "Nao foi possivel abrir o arquivo.tmp para leitura: $!";
		
		while (<ENTRADA>) { # atribui à variável $_ uma linha de cada vez
			push(@File_abs,$_);
		}
		close ENTRADA;
		
		#ler cada file e aplica a função split para divir as strings pelo simbolo |		
		foreach(@File_abs){
			@rec_each = split(/\|/,$_);	
			push (@rec_split,@rec_each);
		}

		#print $rec_split[0]."\n";
		#removendo \n do finalr 
		chomp ($rec_split[1]);
		
		#remove os espaços -> check melhro esta ER [:punct:] 		
		
		while($rec_split[1] =~ m/([[:alnum:][:punct:]])/g){
			#montando resultado da ER
			$rec_property_er = $rec_property_er.$1;
		}
		
		#print $rec_property_er."\n";
		
		#print "match: <$&>\n" while 'foo' =~ m{ o? }xg;
		
		#obtendo o número da propriedade
		#if($file =~ m/(property_.*)/){
			#$rec_num = $1;	
			#if($rec_num =~ m/(^[^.]*)/){
				#$rec_num_property = $1;
			#}		
		#}else{
			#$rec_num_property = "NID"; #not identified
		#}
		
		
		#PATH
		#lendo o código original e criando uma copia de seu conteudo em uma lista		
		$path_new_c_file = $PATH_RESULT_new_code."/".$dir."/"."new_inst_".$dir.".c";	
		
		
		open(NEW_FILEC , "<$path_new_c_file") or die "Nao foi possivel abrir o novo arquivo.c: $!";
		
		#informando o usuario
		#print ">> Identificando se o código original contem a biblioteca <assert.h> ...\n";
		
		while (<NEW_FILEC>) {
			#verificando se já existe a biblioteca <assert.h>
			
			if($_ =~ m/(<assert.h>)/){
				#flag demarcando que existe a biblioteca no código
				$flag_assert = 1;
			}
			
			push(@New_File_inst,$_);
		}
		
		#*** Close the file ***
		close(NEW_FILEC);
		
		
		#informando o usuario
		#print ">> Reescrevendo o novo código com a assertiva ...\n";
		
		#abrindo o novo code C para escrever e inserir a assertiva
		open(NEW_FILEC , ">$path_new_c_file") or die "Nao foi possivel abrir o novo arquivo.c: $!";
		$size_new_file_inst = @New_File_inst;
		
		for($cont=0;$cont<$size_new_file_inst; $cont++){
			
			#para inserir a biblioteca do assert
			if($flag_assert != 1){
								
				print NEW_FILEC "#include <assert.h> //-> by EZPROOFC \n";
				#print "#include <assert.h> //-> by EZPROOFC \n";
				
				#agora já existe a assertiva
				$flag_assert = 1;
				
			}elsif($cont == ($rec_split[0]-1)){
				#print $cont."-> assert($rec_property_er); \n";
				print NEW_FILEC "assert($rec_property_er); //-> by EZPROOFC \n"
			}
			
			print NEW_FILEC $New_File_inst[$cont];
			#print $cont."-> ".$New_File_inst[$cont];
			
		}
		
		#*** Close the file ***
		close(NEW_FILEC);
		#print "-------------------------------------- \n";
		#na verificação criar opção singlefile
		
		#desalocando valor de variaveis da memoria
		$rec_property_er = "";
		@New_File_inst=();
		@File_abs=();
		@rec_each=();
		@rec_split=();
		$flag_assert = 0;
	}
}
