//OPIS: jedna deklaracija sa dve promenljive, branch statement
//RETURN: 4

int main() {
    int a,b,c;
    a = 2;
    b = 3;
    c = 0;
    branch [ c -> 1 -> 2 -> 3]
    	one -> a = a + 1;
    	two -> a = a + 2;
    	three -> b = b + 3;
    	other -> a = a + 2;
    return a;
}
