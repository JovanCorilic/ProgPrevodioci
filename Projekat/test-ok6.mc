//OPIS: jedna deklaracija sa dve promenljive, pozivanje funkcije sa vise promenljivih
//RETURN: 5

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
    return c;
}
