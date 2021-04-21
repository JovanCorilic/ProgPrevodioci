//OPIS: LOOP nije dobro napisan
int main() {
    unsigned a,b,c,d;
    a = 2u;
    b = 3u;
    c = 4u;
    c++;
    loo ( d, 2u, 7u, 9u ){
    	b = a + c;
    	lo ( d, 2u, 7u, 9u ){
    		b = a + c;
    	}
    }
}
