//OPIS: promenljiva i literal nisu istog tipa
int main() {
	int d;
    unsigned a,b,c;
    a = 2u;
    b = 3u;
    c = 4u;
    c++;
    loop ( d, 2u, 7u, 9u ){
    	b = a + c;
    	loop ( d, 2u, 7u, 9u ){
    		b = a + c;
    	}
    }
}

