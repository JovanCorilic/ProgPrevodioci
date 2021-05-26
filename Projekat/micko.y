%{
  #include <stdio.h>
  #include <stdlib.h>
  #include "defs.h"
  #include "codegen.h"
  #include "symtab.h"
  #include <string.h>


  int yyparse(void);
  int yylex(void);
  int yyerror(char *s);
  void warning(char *s);

  extern int yylineno;
  int out_lin = 0;
  char char_buffer[CHAR_BUFFER_LENGTH];
  int error_count = 0;
  int warning_count = 0;
  int var_num = 0;
  int fun_idx = -1;
  int fcall_idx = -1;
  int lab_num = -1;
  FILE *output;
  int returnCall=0;
  int type = -1;
  int returnKoriscen = 0;
  int pocetakBloka=-1;
  unsigned nivoBloka=0;
  unsigned tipZaSelect;
  int lista[SYMBOL_TABLE_LENGTH][SYMBOL_TABLE_LENGTH];
  int brojFunkcije=-1;
  int brojPromenljive=-1;
  int ifPartRel_Exp=-1;
  int ifPartPrenos=-1;
  int komparacijaTemp = -1;
  int tempPrenosNumExp = -1;
  int viseLabela = -1;
  int unosLista[SYMBOL_TABLE_LENGTH];
  
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
%token _QUESTIONMARK
%token _TWODOTS

%type <i> num_exp exp literal custom_num_exp custom_exp 
%type <i> function_call argument rel_exp if_part

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
  : /* empty */
  | function_list function
  | function_list global_variable
  ;
  
global_variable
	: _TYPE _ID _SEMICOLON
		{
				int temp = strlen($2);
				if(temp>1)
					err("Identifaer must have one simbol to be identifaed with");
        if(lookup_symbol($2, GVAR) == NO_INDEX || get_atr2(lookup_symbol($2, GVAR))!=nivoBloka){
           insert_symbol($2, GVAR, $1, NO_ATR,nivoBloka);
           code("\n%s:\n\t\tWORD\t1", $2);
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
        code("\n%s:", $2);
        code("\n\t\tPUSH\t%%14");
        code("\n\t\tMOV \t%%15,%%14");
        //printf("%d",fun_idx);
       
      }
    _LPAREN sabezParametara _RPAREN body
      {
      	if(($1!=VOID) && (returnKoriscen==0))
          warn("Function %s isnt VOID but doesnt have return statement!",$2);
        returnKoriscen=0;
        clear_symbols(fun_idx + 1);
        var_num = 0;
        code("\n@%s_exit:", $2);
        code("\n\t\tMOV \t%%14,%%15");
        code("\n\t\tPOP \t%%14");
        code("\n\t\tRET");
        
        
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
      	
		    insert_symbol($2, PAR, $1, get_atr1(fun_idx)+1, NO_ATR);
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
  	variable_list 
  	{
  		if(var_num)
          code("\n\t\tSUBS\t%%15,$%d,%%15", 4*var_num);
        code("\n@%s_body:", get_name(fun_idx));
  	}
  	statement_list _RBRACKET
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
		if(idx == NO_INDEX){
					idx = lookup_symbol($4, GVAR);
					if(idx == NO_INDEX)
          	err("Parameter '%s' not declared!", $4);
    }
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
			{
          idx = lookup_symbol($1, GVAR);
					if(idx == NO_INDEX)
          	err("Parameter '%s' not declared!", $1);
      }
    tipZaSelect = get_type(idx);
    
	}
	| multi_vars _COMMA _ID
	{
		int idx = lookup_symbol($3, VAR|PAR);
		if(idx == NO_INDEX)
      {
          idx = lookup_symbol($3, GVAR);
					if(idx == NO_INDEX)
          	err("Parameter '%s' not declared!", $3);
      }
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
          {
          idx = lookup_symbol($3, GVAR);
					if(idx == NO_INDEX)
          	err("Parameter '%s' not declared!", $3);
      }
    int temp = idx;
   
    if(get_type(temp) != get_type($5) || get_type(temp) != get_type($7) || get_type(temp) != get_type($9))
          err("Parameter and konstant are not the same type");
    ifPartPrenos = ++lab_num;
    code("\n@branch%d:", lab_num);
    int nesto = 4 + ((get_type(idx) - 1) * RELOP_NUMBER);
    gen_cmp(idx,$5);
    code("\n\t\t%s\t@one%d", jumps[nesto], ifPartPrenos);
    gen_cmp(idx,$7);
    code("\n\t\t%s\t@two%d", jumps[nesto], ifPartPrenos); 
    gen_cmp(idx,$9);
    code("\n\t\t%s\t@three%d", jumps[nesto], ifPartPrenos);
    code("\n\t\tJMP \t@other%d", ifPartPrenos); 
	}
	
		_ONE
		{ code("\n@one%d:", ifPartPrenos); }
		 _ARROW statement
		{ code("\n\t\tJMP \t@exit%d", ifPartPrenos); } 
		  _TWO
		{ code("\n@two%d:", ifPartPrenos); }  
		 _ARROW statement
		{ code("\n\t\tJMP \t@exit%d", ifPartPrenos); }
		 _THREE
		{ code("\n@three%d:", ifPartPrenos); }
		 _ARROW statement
		{ code("\n\t\tJMP \t@exit%d", ifPartPrenos); } 
		 _OTHER
		{ code("\n@other%d:", ifPartPrenos); } 
		 _ARROW statement
		{ code("\n\t\tJMP \t@exit%d", ifPartPrenos); 
			code("\n@exit%d:", ifPartPrenos);
			ifPartPrenos--;
		} 
	;
  
loop_statement
	:	_LOOP _LPAREN _ID _COMMA literal _COMMA literal _COMMA literal _RPAREN 
	{
		int idx = lookup_symbol($3, VAR|PAR);
		if(idx == NO_INDEX)
        {
        idx = lookup_symbol($3, GVAR);
				if(idx == NO_INDEX)
        	err("Parameter '%s' not declared!", $3);
    }
    
   
    if(get_type(idx) != get_type($5) || get_type(idx) != get_type($7) || get_type(idx) != get_type($9))
          err("Parameter and literal are not the same type");
    gen_mov($5,idx);
    ifPartPrenos = ++lab_num;
		code("\n@loop%d:", lab_num);
		int temp = -1;
		char* drugi = get_name($7);
		int drugii =strtol(drugi,NULL,10);

		char* prvi = get_name($5);
		int prvii =strtol(prvi,NULL,10);
		if(drugii>=prvii){
			
			temp = 2+((get_type(idx) - 1) * RELOP_NUMBER);
		}else if(drugii<prvii){
			
			temp = 1+((get_type(idx) - 1) * RELOP_NUMBER);
		}
		gen_cmp(idx,$7);
    code("\n\t\t%s\t@exit%d", opp_jumps[temp], ifPartPrenos); 
		code("\n@true%d:", ifPartPrenos);
	}
	statement
	{
		int idx = lookup_symbol($3, VAR|PAR);
		if(idx == NO_INDEX)
        {
        idx = lookup_symbol($3, GVAR);
        }
    char* drugi = get_name($7);
		int drugii =strtol(drugi,NULL,10);
		char* prvi = get_name($5);
		int prvii =strtol(prvi,NULL,10);
    if(drugii>=prvii){
			code("\n\t\tADDU\t");
		}else if(drugii<prvii){
			code("\n\t\tSUBU\t");
		}
		gen_sym_name(idx);
		code(",");
		gen_sym_name($9);
		code(",");
		int nesto = take_reg();
		gen_sym_name(nesto);
		gen_mov(nesto,idx);
		code("\n\t\tJMP \t@loop%d", ifPartPrenos);
		code("\n@exit%d:", ifPartPrenos);
		ifPartPrenos--;
	}
	;
  
postincrement_statement
	:	_ID _POSTINCREMENT _SEMICOLON
	{
        int idx = lookup_symbol($1, VAR|PAR);
        if(idx == NO_INDEX){
        	idx = lookup_symbol($1, GVAR);
        	if (idx == NO_INDEX) 
          	err("'%s' undeclared", $1);
          else{
          	code("\n\t\tADDS\t%s,$1,%s",$1,$1);
          }
       	}else{
       		code("\n\t\tADDS\t");
       		gen_sym_name(idx);
       		code(",");
       		code("$1,");
       		gen_sym_name(idx);

       	}
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
        if(idx == NO_INDEX){
          idx = lookup_symbol($1, GVAR);
          if (idx == NO_INDEX)
          	err("invalid lvalue '%s' in assignment", $1);
        }
        else
          if(get_type(idx) != get_type($3))
            err("incompatible types in assignment");
        gen_mov($3, idx);
      }
  ;

num_exp
  : exp
  | num_exp _AROP exp
      {
        if(get_type($1) != get_type($3))
          err("invalid operands: arithmetic operation");
        int t1 = get_type($1);    
        code("\n\t\t%s\t", ar_instructions[$2 + (t1 - 1) * AROP_NUMBER]);
        gen_sym_name($1);
        code(",");
        gen_sym_name($3);
        code(",");
        free_if_reg($3);
        free_if_reg($1);
        $$ = take_reg();
        gen_sym_name($$);
        set_type($$, t1);
      }
  ;

exp
  : literal
  | _ID
      {
        $$ = lookup_symbol($1, VAR|PAR);
        if($$ == NO_INDEX){
        	$$ = lookup_symbol($1, GVAR);
        	if ($$ == NO_INDEX)
          	err("'%s' undeclared", $1);
        }
      }
  | function_call
		{
		      $$ = take_reg();
		      gen_mov(FUN_REG, $$);
		}
		
  | _LPAREN num_exp
  	{
  	tempPrenosNumExp = $2;
  	}
   ekstenzija_exp
      { 
      $$ = tempPrenosNumExp;
      
     	}
  | _ID _POSTINCREMENT
  {
        $$ = lookup_symbol($1, VAR|PAR);
        if($$ == NO_INDEX){
        	$$ = lookup_symbol($1, GVAR);
        	if ($$ == NO_INDEX) 
          	err("'%s' undeclared", $1);
          else{
          	code("\n\t\tADDS\t%s,$1,%s",$1,$1);
          }
       	}else{
       		code("\n\t\tADDS\t");
       		gen_sym_name($$);
       		code(",");
       		code("$1,");
       		gen_sym_name($$);
       	}
  }
  ;
  
ekstenzija_exp
	:	_RPAREN
	| _RELOP num_exp _RPAREN _QUESTIONMARK
	{
		komparacijaTemp = take_reg();
		ifPartPrenos = ++lab_num;
		code("\n@if%d:", lab_num);
		if(get_type(tempPrenosNumExp) != get_type($2))
			err("invalid operands: relational operator");
		int temp = $1 + ((get_type(tempPrenosNumExp) - 1) * RELOP_NUMBER);
		gen_cmp(tempPrenosNumExp, $2);
		code("\n\t\t%s\t@false%d", opp_jumps[temp], ifPartPrenos); 
    code("\n@true%d:", ifPartPrenos);
	}
	 custom_num_exp
	 {
	 	gen_mov($6, komparacijaTemp);
	 	code("\n\t\tJMP \t@exit%d", ifPartPrenos);
		code("\n@false%d:", ifPartPrenos);
	 }
	  _TWODOTS custom_num_exp
	  {
	  	gen_mov($9, komparacijaTemp);
			code("\n\t\tJMP \t@exit%d", ifPartPrenos);
			code("\n@exit%d:", ifPartPrenos);
			ifPartPrenos--;
			tempPrenosNumExp = komparacijaTemp;
	  }
	;	
	
custom_num_exp
	:	custom_exp
	| _LPAREN custom_num_exp _AROP custom_exp _RPAREN
	{
        if(get_type($2) != get_type($4))
          err("invalid operands: arithmetic operation");
        int t1 = get_type($2);    
        code("\n\t\t%s\t", ar_instructions[$3 + (t1 - 1) * AROP_NUMBER]);
        gen_sym_name($2);
        code(",");
        gen_sym_name($4);
        code(",");
        free_if_reg($4);
        free_if_reg($2);
        $$ = take_reg();
        gen_sym_name($$);
        set_type($$, t1);
      }
	;

custom_exp
	: literal
  | _ID
      {
        $$ = lookup_symbol($1, VAR|PAR);
        if($$ == NO_INDEX){
        	$$ = lookup_symbol($1, GVAR);
        	if ($$ == NO_INDEX)
          	err("'%s' undeclared", $1);
        }
      }
  | _ID _POSTINCREMENT
  {
        $$ = lookup_symbol($1, VAR|PAR);
        if($$ == NO_INDEX){
        	$$ = lookup_symbol($1, GVAR);
        	if ($$ == NO_INDEX) 
          	err("'%s' undeclared", $1);
          else{
          	code("\n\t\tADDS\t%s,$1,%s",$1,$1);
          }
       	}else{
       		code("\n\t\tADDS\t");
       		gen_sym_name($$);
       		code(",");
       		code("$1,");
       		gen_sym_name($$);
       	}
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
        int i;
        for(i=brojPromenljive-1;i>-1;i--){
        	free_if_reg(unosLista[i]);
        	code("\n\t\t\tPUSH\t");
        	gen_sym_name(unosLista[i]);
        }
        code("\n\t\t\tCALL\t%s", get_name(fcall_idx));
        if($4 > 0)
          code("\n\t\t\tADDS\t%%15,$%d,%%15", $4 * 4);
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
      unosLista[0] = $1;
      
      $$ = 1;
    }
  | argument _COMMA num_exp
  {
    	brojPromenljive += 1;
		  if(lista[brojFunkcije][brojPromenljive] != get_type($3))
		    err("incompatible type for argument in '%s'",
		        get_name(fcall_idx));
      
      unosLista[brojPromenljive-1]=$3;
  		$$ = $$ +1;
  }
  ;

if_statement
  : if_part %prec ONLY_IF
  { code("\n@exit%d:", $1); 
  	ifPartPrenos--;
  }
  | if_part _ELSE statement
  { code("\n@exit%d:", $1); 
  	ifPartPrenos--;
  }
  ;

if_part
  : _IF _LPAREN 
  {
    
    ifPartPrenos = ++lab_num;
    code("\n@if%d:", lab_num);
    viseLabela = 0;
  }
  logic_rel_exp _RPAREN statement
  {
    code("\n\t\tJMP \t@exit%d", ifPartPrenos);
    code("\n@false%d:", ifPartPrenos);
    $$ = ifPartPrenos;
  }
  ;
  
logic_rel_exp
	: rel_exp
	{
		ifPartRel_Exp = $1;
    code("\n\t\t%s\t@false%d", opp_jumps[$1], ifPartPrenos); 
    code("\n@true%d:", ifPartPrenos);
  }
	| logic_rel_exp _LOGICOPER rel_exp
	{
		ifPartRel_Exp = $3;
		viseLabela++;
		
    code("\n\t\t%s\t@false%d", opp_jumps[$3], ifPartPrenos); 
    
    code("\n@true%d%d:", ifPartPrenos,viseLabela);
    
  }
	;

rel_exp
  : num_exp _RELOP num_exp
      {
        if(get_type($1) != get_type($3))
          err("invalid operands: relational operator");
        $$ = $2 + ((get_type($1) - 1) * RELOP_NUMBER);

        gen_cmp($1, $3);
      }
  ;
  
while_statement
	: _WHILE _LPAREN
	{
		ifPartPrenos = ++lab_num;
    code("\n@while%d:", lab_num);
	}
	 logic_rel_exp _RPAREN statement
	 {
	 	code("\n\t\tJMP \t@while%d", ifPartPrenos);
    code("\n@false%d:", ifPartPrenos);
    code("\n\t\tJMP \t@exit%d", ifPartPrenos);
    code("\n@exit%d:", ifPartPrenos); 
    ifPartPrenos--;
	 }
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
       	gen_mov($2, FUN_REG);
        code("\n\t\tJMP \t@%s_exit", get_name(fun_idx)); 
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
  output = fopen("output.asm", "w+");

  synerr = yyparse();

  clear_symtab();
  fclose(output);
  
  if(warning_count)
    printf("\n%d warning(s).\n", warning_count);

  if(error_count) {
    remove("output.asm");
    printf("\n%d error(s).\n", error_count);
  }

  if(synerr)
    return -1;  //syntax error
  else if(error_count)
    return error_count & 127; //semantic errors
  else if(warning_count)
    return (warning_count & 127) + 127; //warnings
  else
    return 0; //OK
}

