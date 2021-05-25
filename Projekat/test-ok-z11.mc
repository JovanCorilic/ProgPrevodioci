//OPIS: jedna globalna promenljiva
//RETURN: 26

int y;

int main() {
  int a;
  int x;
  a = 11;
  x = 13;
  y = 12;
  y++;
  a = a + y;
  x = x + 1;
  x++;
  x = x++ + 1;
  
  x = (a + x) - 1 ;
  
  x = (a < y) ? y : 0;
		
  return 0;
}




