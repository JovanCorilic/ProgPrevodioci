//OPIS: uslovni izraz semanticka greska

int function(int a){
	return a;
}

void main() {
    int a,b;
    unsigned g;
    
    b = ( a < g ) ? 7 : 4;
}

