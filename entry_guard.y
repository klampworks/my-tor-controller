%{
#include <stdio.h>
//#include "return_code_p_lexer.h"

void yyerror(const char*);
int yyparse();
%}

%union {
	int ival;
	char *sval;
}

%token EOL

%parse-param {char **return_text}
%%


%%

void yyerror(const char *s) {
	printf("Email me teh errors %s\n", s);
}

