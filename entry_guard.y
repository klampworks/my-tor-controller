%{
#include <stdio.h>
//#include "return_code_p_lexer.h"

void yyerror(char **id, char **name, const char*);
int yyparse(char **id, char **name);
%}

%union {
	char *sval;
}

%token <sval> ID;
%token <sval> NAME;
%token EOL

%parse-param {char **id}
%parse-param {char **name}
%%

entry_guard:
	ID NAME;

%%

void yyerror(char **id, char **name, const char *s) {
	printf("Email me teh errors %s\n", s);
}

