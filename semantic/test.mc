//OPIS: jedna deklaracija sa dve promenljive
int nesto(int a,int b){
	int c;
	
	c=2;

	return c;
	
}

void main() {
  int a,b;
  
  int x; 
	int y;
    
  a=nesto(a,b);
  
  if ( a > 5 and b < 4 or b>5)
  {
   a = 5;
  }
  
  loop ( a,2,3,4 )
  {
  
  }
  
  branch [ a -> 1 -> 3 -> 5 ]
		one -> a = a + 1;
		two -> a = a + 3;
		three -> a = a + 5;
		other -> a = a - 3;
    
  {
	int x;
	int z; 
	x = 5;
	y = x + y; 
	}
	while ( a < 10 ) 
	{ 
	a = a + 3;  
	while (b > 0) 
	b = b + 1;
	}
}
