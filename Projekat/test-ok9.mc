//OPIS: while iskaz
//RETURN: 10

int funkcija(int a, int b){
	int c;
	c = a + b;
	return c;
}

int main() {
    int a,b,c;
    a = 2;
    b = 3;
    c = funkcija(a,b);
    
    while ( a < 10){
    	b = 0;
    	while (b < 5){
    		
    		b++;
    	}
    	a++;
    }
    return a;
}
