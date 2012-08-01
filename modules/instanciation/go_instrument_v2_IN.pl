#!/usr/bin/env perl

#path from code.c
$PATH_file_c_code = $ARGV[0];

#diretorio onde esta armazena os resultados da abstração do contra-exemplo
$dir_abs_result = $ARGV[1];


#PATH --------------------------->
$ABS_PATH_EZPROOFC="[<??>]";
#criando diretorio dos resultados
$PATH_RESULT_new_code = $ABS_PATH_EZPROOFC."/result_instrument.out";
mkdir $PATH_RESULT_new_code;
#PATH --------------------------->


@listdir = `ls $dir_abs_result`;

#lendo os dir in result_abstration.dir/
foreach $dir (@listdir){
	
	@listfiles = `ls $dir_abs_result/$dir`;
	#remove \n da string
	chomp ($dir);	
	
	#criando diretorio para cada arquivo analisado
	mkdir $PATH_RESULT_new_code."/".$dir;	
			
	#ACESSANDO CADA file
	foreach $file (@listfiles){		
		
		chomp ($file);
		
		#PATH
		$pathfile = $dir_abs_result."/".$dir."/".$file;
								
		#lendo cada arquivo com o RESULTADO DA ABSTRAÇÃO
		open(ENTRADA , "<$pathfile") or die "Nao foi possivel abrir o arquivo_ABS.tmp para leitura: $!";
		
		while (<ENTRADA>) { 			
			push(@File_abs,$_);
		}
		close ENTRADA;
		
		#ler cada file e aplica a função split para divir as strings pelo simbolo |		
		foreach(@File_abs){
			@rec_each = split(/\|/,$_);	
			push (@rec_split,@rec_each);
		}

		$size_r = @rec_split;
		
		#divisão dos valores recebidos pela função split em duas lista uma contendo os número da linha do $file.c e outro
		#a nova linha a ser instrumentada
		#print "-> Listando: (i)- Numero da Linha, (ii)- Nova Linha\n";
		for($a=0;$a<=$size_r;$a++){
			$result = parimpar($a);
		
			if($result == 1){
				push(@list_num,$rec_split[$a]);		
			}else{
				push(@line_inst,$rec_split[$a]);			
			}
		}
				
		#lendo o código original e criando uma copia de seu conteudo em uma lista
		#LEMBRETE neste caso  $dir contem o nome do $file.c		
				
		open(FILEC , "<$PATH_file_c_code") or die "Nao foi possivel abrir o arquivo.c para leitura: $!";
		
		while (<FILEC>) { 			
			push(@File,$_);
		}
		close ENTRADA;	
		
		$size = @File;
		my $size_list_num = @list_num;
		
		#if($file =~ m/(property_.*)/){
			#if($1 =~ m/(^.[^.]*)/){
				#$rec_num_property = $1;
			#}
		#}else{
			#$rec_num_property = "NID"; #not identified
		#}
		
		#PATH --->
		#-> Criando novo codigo C instrumentado;
		$path_new_ccode = $PATH_RESULT_new_code."/".$dir."/"."new_inst_".$dir.".c";				
		
		#----------------------------------------------------------
		
		#ao inves de escrever logo no arquivo manipular os dados em uma lista primeiro
		#para alterar os dados na lista do arquivo
		#percorrer a lista de NL(número de linhas) e então substituir os valor da lista do arquivo
		#diretamente na posição ex. $i == ($list_num[$z] - 1) então $listaarqui[$i] = $line_inst[$z];
		
		#percorre a lista que contem as linhas do contra-exemplo
		for($z=0; $z<($size_list_num - 1);$z++){
			
			#print "->>".$z."->".$list_num[$z]."\n";
						
			$File[$list_num[$z]-1] = $line_inst[$z];								
		}
						
		#CRIANDO -> New C code with instrument
		open(MYOUTFILE, ">$path_new_ccode"); #open for write, overwrite
		foreach(@File){
			#print $_;
			print MYOUTFILE $_;
		}
		#*** Close the file ***
		close(MYOUTFILE);			
		
		#----------------------------------------------------------
				
		#reinicialiando cada lista
		@File_abs = ();
		@rec_each = ();
		@rec_split = ();
		@list_num = ();
		@line_inst = ();
		@File = ();
	#print "-------------------------------------------------------\n";
	}#<- each file
}

#função para dividir o resultado do split(\), ou seja nas posições pares = o numero da linha
# nas impares = o valor da nova linha
sub parimpar{
	if (scalar @_ != 1) {
        print "Função espera 1 argumentos\n";
        return 0;
    }
    my ($valor) = @_;    
    if($valor % 2 == 0){
		return 1;
	}else{
		return 0;
	}
    
}

