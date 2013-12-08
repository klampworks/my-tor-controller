%{
#include <stdio.h>
#include "comm.h"
#include "desc_info.lexer.h"

void dscerror(struct desc *desc, const char*);
int dscparse(struct desc *desc);

%}

%union {
	char  *sval;
}

%parse-param {struct desc *desc}

%%

start:
	

%%

void dscerror(struct desc *desc, const char *s) {
	printf("Email me teh errors %s\n", s);
}

