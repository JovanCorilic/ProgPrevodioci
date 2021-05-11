//OPIS: jedna globalna promenljiva
//RETURN: 26



int main() {
  int a;
  int x;
  a = 11;
  x = 13;
  x = x + 1;
  x++;
  x = x++ + 1;
  if ( x < 0){
  	x++;
  }
		
  return a + x;
}




