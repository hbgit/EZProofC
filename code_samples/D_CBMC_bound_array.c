#include <stdio.h>

int a[5], b[6];
int main ( ){
	int i, j, temp; 
	a[0], b[0] = 1 ;
	for(i=1; i<5; i++){
		a[i]= a[i-1]+ i;		
		int temp = a[i]*(i+1);
		for(j=1; j<temp; j++){
			b[j]= b[i-1]+(temp*2);			
		}
	}
}

