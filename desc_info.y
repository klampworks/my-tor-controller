%{
#include <stdio.h>
#include "comm.h"
#include "desc_info.lexer.h"

void dscerror(struct desc *desc, const char*);
int dscparse(struct desc  *m_desc);

//dscdebug = 1;
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
	ip platform uptime

ip:
	IP { m_desc->ip_address = $1;  }

	
platform:
	PLATFORM { m_desc->platform = $1; }

	
uptime:
	UPTIME { m_desc->uptime = $1; }
	

%%

void dscerror(struct desc *desc, const char *s) {
	//printf("Email me teh errors %s\n", s);
}

