%{
#include <stdio.h>
%}

%union {
	int ival;
	char *sval;
}

%token RETURN_250;
%token RETURN_OK;;
%token <ival> RETURN_CODE;
%token <sval> RETURN_TEXT;
%token EOL

%parse-param {int *return_code} 
%parse-param {char **return_text}
%%

error_code:
	two_fifty_ok | other_error

two_fifty_ok:
	RETURN_250 RETURN_OK EOL{ *return_code = 250; *return_text = NULL; }

other_error:
	RETURN_CODE RETURN_TEXT EOL { *return_code = $1; **return_text = $2 }

%%

void yyerror(const char *s, int *return_code, char **return_text) {
	//printf("Email me teh errors %s\n", s);
}

