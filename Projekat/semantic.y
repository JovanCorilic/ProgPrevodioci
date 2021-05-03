%{
  #include <stdio.h>
  #include <stdlib.h>
  #include "defs.h"
  #include "symtab.h"
  #include <string.h>

  int yyparse(void);
  int yylex(void);
  int yyerror(char *s);
  void warning(char *s);

  extern int yylineno;
  char char_buffer[CHAR_BUFFER_LENGTH];
  int error_count = 0;
  int warning_count = 0;
  int var_num = 0;
  int fun_idx = -1;
  int fcall_idx = -1;
  int returnCall=0;
  int type = -1;
  int returnKoriscen = 0;
  int pocetakBloka=-1;
  unsigned nivoBloka=0;
  unsigned tipZaSelect;
  int lista[SYMBOL_TABLE_LENGTH][SYMBOL_TABLE_LENGTH];
  int brojFunkcije=-1;
  int brojPromenljive=-1;
  
%}

%union {
  int i;
  char *s;
}

%token <i> _TYPE
%token _IF
%token _ELSE
%token _RETURN
%token <s> _ID
%token <s> _INT_NUMBER
%token <s> _UINT_NUMBER
%token _LPAREN
%token _RPAREN
%token _LBRACKET
%token _RBRACKET
%token _ASSIGN
%token _SEMICOLON
%token <i> _AROP
%token <i> _RELOP
%token _COMMA
%token <i> _POSTINCREMENT
%token _WHILE
%token _LOGICOPER
%token _LOOP
%token _BRANCH
%token _LSQUAREBRACKET
%token _RSQUAREBRACKET
%token _ARROW
%token _ONE
%token _TWO
%token _THREE
%token _OTHER
%token _SELECT
%token _FROM
%token _WHERE

%type <i> num_exp exp literal function_call argument rel_exp

%nonassoc ONLY_IF
%nonassoc _ELSE

%%

program
  : function_list
      {  
        if(lookup_symbol("main", FUN) == NO_INDEX)
          err("undefined reference to 'main'");
       }
  ;

function_list
  : function
  | function_list function
  | function_list global_variable
  ;
  
global_variable
	: _TYPE _ID _SEMICOLON
		{
				int temp = strlen($2);
				if(temp>1)
					err("Identifaer must have one simbol to be identifaed with");
        if(lookup_symbol($2, VAR|PAR) == NO_INDEX || get_atr2(lookup_symbol($2, VAR|PAR))!=nivoBloka){
           insert_symbol($2, VAR, $1, ++var_num,nivoBloka);
           }
        else 
           err("redefinition of '%s'", $2);
  	}

function
  : _TYPE _ID
      {
        fun_idx = lookup_symbol($2, FUN);
        if(fun_idx == NO_INDEX)
          fun_idx = insert_symbol($2, FUN, $1, NO_ATR, NO_ATR);
        else 
          err("redefinition of function '%s'", $2);
        brojFunkcije +=1;
        brojPromenljive = -1;
        //printf("%d",fun_idx);
       
      }
    _LPAREN sabezParametara _RPAREN body
      {
      	if(($1!=VOID) && (returnKoriscen==0))
          warn("Function %s isnt VOID but doesnt have return statement!",$2);
        returnKoriscen=0;
        clear_symbols(fun_idx + 1);
        var_num = 0;
        
      }
  ;
  
sabezParametara
	: /* empty */
      { set_atr1(fun_idx, 0); }
  | parameters
  ;
  
parameters
	:	parameter
	| parameters _COMMA parameter
	;

parameter
  : _TYPE _ID
      {
      	if($1==VOID)
      		err("Type is void!");
      	
		    insert_symbol($2, PAR, $1, 1, NO_ATR);
		    set_atr1(fun_idx, get_atr1(fun_idx)+1);
		    
		    brojPromenljive +=1;
		    if(get_atr2(fun_idx)==NO_TYPE){
		    	lista[brojFunkcije][brojPromenljive]=fun_idx;
		    	brojPromenljive +=1;
		    	lista[brojFunkcije][brojPromenljive]=$1;
		    	set_atr2(fun_idx, $1);
		    }else{
		    	if(brojPromenljive==SYMBOL_TABLE_LENGTH){
		    		err("63 parameters are allowed to be in brackets of function");
		    	}
		    	lista[brojFunkcije][brojPromenljive]=$1;
		    }
		    
      }
  ;

body
  : _LBRACKET 
  	{
  		nivoBloka+=1;
  	}
  	variable_list statement_list _RBRACKET
  	{
  		nivoBloka-=1;
  	}
  ;

variable_list
  : /* empty */
  | variable_list variable
  ;

variable
  : _TYPE {type=$1;} vars _SEMICOLON
      {
      	if($1==VOID)
      		err("Type is void!");
      	
      }
  ;
  
vars
	: _ID
		{
				//printf("%zu\n",strlen($1));
				int temp = strlen($1);
				
				if(temp>1)
					err("Identifaer must have one simbol to be identifaed with");
				
				
        if(lookup_symbol($1, VAR|PAR) == NO_INDEX || get_atr2(lookup_symbol($1, VAR|PAR))!=nivoBloka){
           insert_symbol($1, VAR, type, ++var_num,nivoBloka);
           //printf("%s\n%d\n%d\n",$1,get_atr2(lookup_symbol($1, VAR|PAR)),nivoBloka);
           }
        else 
           err("redefinition of '%s'", $1);
  	}
	| vars _COMMA _ID
	{
				int temp = strlen($3);
				if(temp>1)
					err("Identifaer must have one simbol to be identifaed with");
        if(lookup_symbol($3, VAR|PAR) == NO_INDEX || get_atr2(lookup_symbol($3, VAR|PAR))!=nivoBloka)
        	{
           insert_symbol($3, VAR, type, ++var_num,nivoBloka);
           
           }
        else 
           err("redefinition of '%s'", $3);
  	}
	;

statement_list
  : /* empty */
  | statement_list statement
  ;

statement
  : compound_statement
  | assignment_statement
  | if_statement
  | return_statement
  | postincrement_statement
  | while_statement
  | loop_statement
  | branch_statement
  | function_statement
  | select_statement
  ;
  
select_statement
	:	_SELECT multi_vars _FROM _ID
	{
		int idx = lookup_symbol($4, VAR|PAR);
		if(idx == NO_INDEX)
          err("Parameter '%s' not declared!", $4);
   	if(tipZaSelect != get_type(idx)){
   		err("Parameters and '%s' are not the same type!",$4);
   	}
	}
		_WHERE _LPAREN logic_rel_exp _RPAREN _SEMICOLON
	;
	
multi_vars
	:	_ID
	{
		int idx = lookup_symbol($1, VAR|PAR);
		if(idx == NO_INDEX)
          err("Parameter '%s' not declared!", $1);
    tipZaSelect = get_type(idx);
    
	}
	| multi_vars _COMMA _ID
	{
		int idx = lookup_symbol($3, VAR|PAR);
		if(idx == NO_INDEX)
          err("Parameter '%s' not declared!", $3);
   	if(tipZaSelect != get_type(idx)){
   		err("Parameters are not the same type!");
   	}
	}
	;
  
branch_statement
	: _BRANCH _LSQUAREBRACKET _ID _ARROW literal _ARROW literal _ARROW literal _RSQUAREBRACKET
	{
		int idx = lookup_symbol($3, VAR|PAR);
		if(idx == NO_INDEX)
          err("Parameter '%s' not declared!", $3);
    int temp = lookup_symbol($3, VAR|PAR);
   
    if(get_type(temp) != get_type($5) || get_type(temp) != get_type($7) || get_type(temp) != get_type($9))
          err("Parameter and konstant are not the same type");
	}
		_ONE _ARROW statement _TWO _ARROW statement _THREE _ARROW statement _OTHER _ARROW statement
	;
  
loop_statement
	:	_LOOP _LPAREN _ID _COMMA literal _COMMA literal _COMMA literal _RPAREN 
	{
		int idx = lookup_symbol($3, VAR|PAR);
		if(idx == NO_INDEX)
          err("Parameter '%s' not declared!", $3);
    int temp = lookup_symbol($3, VAR|PAR);
   
    if(get_type(temp) != get_type($5) || get_type(temp) != get_type($7) || get_type(temp) != get_type($9))
          err("Parameter and literal are not the same type");
	}
	statement
	;
  
postincrement_statement
	:	_ID _POSTINCREMENT _SEMICOLON
	{
        int idx = lookup_symbol($1, VAR|PAR);
        if(idx == NO_INDEX)
          err("Parameter '%s' not declared!", $1);
      }
	;

compound_statement
  : _LBRACKET
  {
  	pocetakBloka = get_last_element()+1;
  	nivoBloka +=1;
  }
   variable_list statement_list _RBRACKET
   {
   	clear_symbols(pocetakBloka);
   	nivoBloka -=1;
   }
  ;

assignment_statement
  : _ID _ASSIGN num_exp _SEMICOLON
      {
        int idx = lookup_symbol($1, VAR|PAR);
        if(idx == NO_INDEX)
          err("invalid lvalue '%s' in assignment", $1);
        else
          if(get_type(idx) != get_type($3))
            err("incompatible types in assignment");
      }
  ;

num_exp
  : exp
  | num_exp _AROP exp
      {
        if(get_type($1) != get_type($3))
          err("invalid operands: arithmetic operation");
      }
  //| num_exp _COMMA _ID
  ;

exp
  : literal
  | _ID
      {
        $$ = lookup_symbol($1, VAR|PAR);
        if($$ == NO_INDEX)
          err("'%s' undeclared", $1);
      }
  | function_call
  | _LPAREN num_exp _RPAREN
      { $$ = $2; }
  | _ID _POSTINCREMENT
  {
        $$ = lookup_symbol($1, VAR|PAR);
        if($$ == NO_INDEX)
          err("'%s' undeclared", $1);
  }
  ;

literal
  : _INT_NUMBER
      { $$ = insert_literal($1, INT); }

  | _UINT_NUMBER
      { $$ = insert_literal($1, UINT); }
  ;
  
function_statement
	:	function_call _SEMICOLON
	;

function_call
  : _ID 
      {
        fcall_idx = lookup_symbol($1, FUN);
        if(fcall_idx == NO_INDEX)
          err("'%s' is not a function", $1);
      }
    _LPAREN argument _RPAREN
      {

        if(get_atr1(fcall_idx) != $4)
          err("wrong number of args to function '%s'", 
              get_name(fcall_idx));
        set_type(FUN_REG, get_type(fcall_idx));
        $$ = FUN_REG;
      }
  ;

argument
  : /* empty */
    { $$ = 0; }

  | num_exp
    { 
    	
    	brojPromenljive = 1;
      int i;
    	for(i = 0;i<SYMBOL_TABLE_LENGTH;i++){
    		if(lista[i][0]==fcall_idx){
    			brojFunkcije = i;
    			break;
    		}
    	}
    	
		  if(lista[brojFunkcije][1] != get_type($1))
		    err("incompatible type for argument in '%s'",
		        get_name(fcall_idx));
      $$ = 1;
    }
  | argument _COMMA num_exp
  {
    	brojPromenljive += 1;
		  if(lista[brojFunkcije][brojPromenljive] != get_type($3))
		    err("incompatible type for argument in '%s'",
		        get_name(fcall_idx));
  		$$ = $$ +1;
  }
  ;

if_statement
  : if_part %prec ONLY_IF
  | if_part _ELSE statement
  ;

if_part
  : _IF _LPAREN logic_rel_exp _RPAREN statement
  ;
  
logic_rel_exp
	: rel_exp
	| logic_rel_exp _LOGICOPER rel_exp
	;

rel_exp
  : num_exp _RELOP num_exp
      {
        if(get_type($1) != get_type($3))
          err("invalid operands: relational operator");
      }
  ;
  
while_statement
	: _WHILE _LPAREN logic_rel_exp _RPAREN statement
	;

return_statement
  : _RETURN num_exp _SEMICOLON
      {
      	if(get_type(fun_idx)==VOID)
      		err("Return type is VOID");
        else if(get_type(fun_idx) != get_type($2))
          err("incompatible types in return");
        returnKoriscen++;
        if(returnKoriscen>1)
        	err("Multiple return statements");
      }
	| _RETURN _SEMICOLON
			{
				if(get_type(fun_idx) != VOID)
					warn("Return type is not VOID!");
				returnKoriscen++;
				if(returnKoriscen>1)
					err("Multiple return statements");
			}
  ;

%%

int yyerror(char *s) {
  fprintf(stderr, "\nline %d: ERROR: %s", yylineno, s);
  error_count++;
  return 0;
}

void warning(char *s) {
  fprintf(stderr, "\nline %d: WARNING: %s", yylineno, s);
  warning_count++;
}

int main() {
  int synerr;
  init_symtab();

  synerr = yyparse();

  clear_symtab();
  
  if(warning_count)
    printf("\n%d warning(s).\n", warning_count);

  if(error_count)
    printf("\n%d error(s).\n", error_count);

  if(synerr)
    return -1; //syntax error
  else
    return error_count; //semantic errors
}

