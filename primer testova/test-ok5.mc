//OPIS: jedna deklaracija sa tri promenljive, blokovi unutar
int main() {
    unsigned a,b,c;
    a = 2u;
    b = 3u;
    c = 4u;
    
    {
    	unsigned a;
    	a = a + b;
    }
}
