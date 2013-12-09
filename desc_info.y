%{
#include <stdio.h>
#include "comm.h"
#include "desc_info.lexer.h"

void dscerror(struct desc *desc, const char*);
int dscparse(struct desc  *m_desc);

%}

%union {
	char  *sval;
	int  ival;
}

%token <sval> IP;
%token <sval> PLATFORM;
%token <ival> UPTIME;

%parse-param {struct desc *m_desc}

%%

start:
	IP { m_desc->ip_address = $1; }
	PLATFORM { m_desc->platform = $1; }
	UPTIME { m_desc->uptime = $1; }
	

%%

void dscerror(struct desc *desc, const char *s) {
	//printf("Email me teh errors %s\n", s);
}

