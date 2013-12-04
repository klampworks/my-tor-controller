%{
#include <stdio.h>
#include "return_code_p_lexer.h"

void yyerror(int*, char**, const char*);
int yyparse(int *, char **);
%}

%union {
	int ival;
	char *sval;
}

%token RETURN_250;
%token RETURN_OK;
%token <ival> RETURN_CODE;
%token <sval> RETURN_TEXT;
%token EOL

%parse-param {int *return_code} 
%parse-param {char **return_text}
%%

error_code:
	other_error | two_fifty_ok ;

two_fifty_ok:
	RETURN_250 RETURN_OK EOL { *return_code = 250; *return_text = NULL; }

other_error:
	RETURN_CODE RETURN_TEXT EOL { *return_code = $1; *return_text = $2; }

%%

void yyerror(int *return_code, char **return_text, const char *s) {
	printf("Email me teh errors %s\n", s);
}

