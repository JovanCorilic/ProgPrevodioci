//OPIS: while iskaz

int funkcija(int a, int b){
	int c;
	c = a + b;
	return c;
}

void main() {
    int a,b,c;
    a = 2;
    b = 3;
    c = funkcija(a,b);
    
    while ( a > 3){
    	while (b <2){
    		a++;
    	}
    }
}
