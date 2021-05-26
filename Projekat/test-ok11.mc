//OPIS: jedna deklaracija sa tri promenljive, inkrementacija , primer loop
//RETURN: 7
int main() {
    unsigned a,b,c,d;
    int g;
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
    loop ( g, 2, 6, 1 ){
    	
    }
    return g;
}
