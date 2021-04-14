//OPIS: jedna deklaracija sa dve promenljive, pozivanje funkcije sa vise promenljivih

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
}
