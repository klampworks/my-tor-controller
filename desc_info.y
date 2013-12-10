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
%token <ival> bandwidth;

%parse-param {struct desc *m_desc}

%%

start:
	ip platform uptime bandwidth

ip:
	IP { m_desc->ip_address = $1;  }

	
platform:
	PLATFORM { m_desc->platform = $1; }

	
uptime:
	UPTIME { m_desc->uptime = $1; }
	
bandwidth:
	BANDWIDTH BANDWIDTH BANDWIDTH { m_desc->bw_min = $1; 
					m_desc->bw_max = $2;
					m_desc->bw_avg = $3;
					}

%%

void dscerror(struct desc *desc, const char *s) {
	//printf("Email me teh errors %s\n", s);
}

