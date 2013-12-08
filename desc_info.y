%{
#include <stdio.h>
#include "comm.h"
#include "desc_info.lexer.h"

void dscerror(struct desc *desc, const char*);
int dscparse(struct desc  *m_desc);

%}

%union {
	char  *sval;
}

%token <sval> IP;

%parse-param {struct desc *m_desc}

%%

start:
	IP { m_desc->ip_address = $1; }
	

%%

void dscerror(struct desc *desc, const char *s) {
	//printf("Email me teh errors %s\n", s);
}

