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

%parse-param {int *test}

%%

error_code:
	two_fifty_ok | other_error

two_fifty_ok:
	RETURN_250 RETURN_OK EOL{ /*return 250 ok*/ }

other_error:
	RETURN_CODE RETURN_TEXT EOL { /*return some error*/ }

%%

void yyerror(const char *s) {

	printf("Email me teh errors %s\n", s);
}

