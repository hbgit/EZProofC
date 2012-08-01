#include <stdio.h>
#include <stdlib.h>

int nondet_uint();

int nondet_uint(){
	
	srand(time(NULL));
 	int result = rand() % 10;
	return result;
		
}


int main() {
	
 	unsigned int a; 
  unsigned int  b;
  unsigned int  c;
	
    a=nondet_uint();
	b=nondet_uint();
	int i;

	if(a>0 || b>0){
		for(i=0; i < 12; i++){
		   if (i == 11){			  
			  c=1/(a+b);
			  c=a;
	       }
	    }
	}
	
		
}
