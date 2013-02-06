#!/usr/bin/env perl

# -------------------------------------------------------------------
# GOAL: Splits a single-line multi-variable declarations into multiple 
# lines, with a separate variable declaration on each line.
# Works with these patterns:
#		int a,b; and int q, *p, k=3;
# DOES NOT WORK with these patterns:
#		int r,yu[2]={1,2}; and b = f(2,1); and p=&a, b = 3;

# [TODO] coma in the end of the line
# -------------------------------------------------------------------

if($#ARGV != 0 ){
	print "Sorry, you need a file.c -> ./aux_formatation <file.c> \n";
	exit;
}

$pathfile = $ARGV[0];

open(ENTRADA , "<$pathfile") or die "Could not possible open the file: $!";
while (<ENTRADA>) { 
	push(@LineFile,$_);
}
close ENTRADA;

for($count_i=0; $count_i <= $#LineFile; $count_i++){
	
	#skip blank lines, lines that starts with delimiters { or }, # macros
	# and lines starts with comments
	if(not($LineFile[$count_i] =~ m/^[{}]+/) and not($LineFile[$count_i] =~ m/^$/)
	   and not($LineFile[$count_i] =~ m/^#/) and not($LineFile[$count_i] =~ m/^\//)){		
			
			#removing blank space front of the line code
			$LineFile[$count_i] =~ s/^[ ]+//;
										
			if(not($LineFile[$count_i] =~ m/^[\/]/) and is_a_comment($LineFile[$count_i]) == 1){
				$LineFile[$count_i] = remove_comment_end_line($LineFile[$count_i]);
			}			
				
			
			#Gathering lines that could be a possible multi-variable declarations			
			if($LineFile[$count_i]  =~ m/[,]+/ and ($LineFile[$count_i]  =~ m/[;]+/ or $LineFile[$count_i]  =~ m/.[^ ,]+[ ]+[^ ,]+[,]/) #){
			   and not($LineFile[$count_i]  =~ m/^.[^ ]*[ ]*\(/) and not($LineFile[$count_i]  =~ m/^[:]/)){		   		
						
					#if($LineFile[$count_i] =~ m/^.[^ ,]*[ ]+[-+]*=/){
						#print ">>>".$LineFile[$count_i];
					#}
					#controle run times to preprocessing the actual line that has been analised
					$CONTROL_RUN = 1;
					
					
					my $flag_coma = 0;
					if($LineFile[$count_i]  =~ m/,$/){
						$flag_coma = 1;						
						#print "OUT: ".$flag_coma." <-> ".$LineFile[$count_i];
					}
						
					#my $flag_get_pattern = 0;
					my $flag_tmp=0;
					$TYPE = "";
					while($CONTROL_RUN == 1){
						
						$flag_tmp = $CONTROL_RUN;
						
						if($flag_coma == 1 and not($LineFile[$count_i]  =~ m/[;]$/)){
							$CONTROL_RUN = 1;								 
						}else{
							$CONTROL_RUN = 0;
						}
						
						
						######### RUN SPLITS
					    #else if ((ret > maxFixed(k, l)) || (ret < minFixed(k, l)))
						#DECLARATION and DECLARATION with ASSIGMENT										
						if(not($LineFile[$count_i] =~ m/^.[^ ,]*[ ]+[-+]*=/) and 
						   not($LineFile[$count_i] =~ m/[<>][ ]*.[^ ,]*[,]/) and $flag_tmp == 1){						
							#print ">>>".$LineFile[$count_i];					
														
							$LineFile[$count_i] =~ m/(^.[^ =]+)[\s]+(.+)/;
							
							
							#if($flag_get_pattern != 1){
							$TYPE = $1;
							#	$flag_get_pattern = 1;								
							#}
							
							
							
							#print ">>>>>".$2."\n";																			
							@rec_split_coma = split(/,/,$2);
							
							#HIP -> validar cada split
							
							for($count_c=0; $count_c <= $#rec_split_coma; $count_c++){
								$tmp = $rec_split_coma[$count_c];
								$tmp =~ s/^[\s]+//;
								
								if($tmp =~ m/[{]+/){
									print $TYPE." ".$tmp;
									$count_c++;
									while(not($rec_split_coma[$count_c] =~ m/[}]+/)){
										print ",".$rec_split_coma[$count_c];
										$count_c++;
									}
									print ",".$rec_split_coma[$count_c]."\n";
									
								}
								elsif($tmp =~ m/[\(]+/){
									print $TYPE." ".$tmp;
									$count_c++;
									while(not($rec_split_coma[$count_c] =~ m/[\)]+/)){
										print ",".$rec_split_coma[$count_c];
										$count_c++;
									}
									print ",".$rec_split_coma[$count_c]."\n";
								}
								else{
									if($tmp =~ m/[;]+/){
										print $TYPE." ".$tmp."\n";
									}else{
										print $TYPE." ".$tmp.";\n";
									}
									
								}
								
							}
						}					
						#ASSIGMENT
						else{
							#print ":::::".$LineFile[$count_i];
							#Here it knows that we have a coma, now we'll check if we have at least an '='
							
							@split_igual=split(/=/,$LineFile[$count_i]);
							#print "Sizeof: ".$#split_igual."\n";
							if($#split_igual > 1){
								@rec_split_coma = split(/,/,$LineFile[$count_i]);
								#print ">>>> ".($count_i+1)."\n";
								for($count_c=0; $count_c <= $#rec_split_coma; $count_c++){
									$tmp = $rec_split_coma[$count_c];
									$tmp =~ s/^[\s]+//;
									
									if($tmp =~ m/[(]+/){
										print $tmp;
										$count_c++;
										while(not($rec_split_coma[$count_c] =~ m/[)]+/)){										
											print ",".$rec_split_coma[$count_c];
											$count_c++;
										}					
																			
										print ",".$rec_split_coma[$count_c];
										
									}else{
										chomp($tmp);
										if($tmp =~ m/[;]+/){
											print $tmp."\n";
										}else{
											print $tmp.";\n";
										}									
									}
									
								}
							}else{
								print $LineFile[$count_i];
							}
							
						}
						
						#check if is necessary to try one more time
						if($CONTROL_RUN == 1){
							$count_i++;
							#generate the new string
							$LineFile[$count_i] = $TYPE."".$LineFile[$count_i];
							#print ":::::::".$LineFile[$count_i];
						}
						
							
					}
			}else{
				print $LineFile[$count_i];
				#$a = 2;
			}	
			
	}else{		
		#$a = 2;
		print $LineFile[$count_i];
	}			
}
	






######## remove a coment in the end of the line
sub remove_comment_end_line{
	
	my ($txt_line_code) = @_;
	
	if($txt_line_code =~ m/\/\//){ 
		$txt_line_code =~ s/\/\/.+/ /;			
		return $txt_line_code;
	}
	elsif($txt_line_code =~ m/(\/[*]+)/){
		$txt_line_code =~ s/\/[*]+.+/ /;	
		return $txt_line_code;
	}
	
}

######## check if in the line has comments
sub is_a_comment{	
	
	my ($txt_line_code) = @_;
	
	if($txt_line_code =~ m/(\/\/)/ or $txt_line_code =~ m/(\/[*]+)/){ 
		#print $txt_line_code."P: ".$1."\n";
		return 1;
	}	
}

