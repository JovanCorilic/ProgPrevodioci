//OPIS: jedna globalna promenljiva
//RETURN: 4

int f(int a, int r, int d, int e, int t){
	int c;
	
	c = r;
	a++;
	r++;
	d++;
	e++;
	t++;
	return c;
}

int main() {
  int a;
  int x;
  int y;
  
	x = 5;
	a = 5;
	if ( a >= 6 ){
		x = 4;
	}
	y = f(20,6,30,7,10);

  return y;
}




