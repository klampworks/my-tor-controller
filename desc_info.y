%{
#include <stdio.h>
#include "comm.h"
#include "desc_info.lexer.h"
#include <assert.h>

void dscerror(struct desc *desc, const char*);
int dscparse(struct desc  *m_desc);

char *rsa_index;

//dscdebug = 1;
%}

%union {
	char  *sval;
	int  ival;
}

%token <sval> IP;
%token <sval> PLATFORM;
%token <sval> ONION_KEY;
%token <ival> UPTIME;
%token <ival> BANDWIDTH;

%parse-param {struct desc *m_desc}

%%

start:
	ip platform uptime bandwidth onion_key

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

onion_key:
	ONION_KEY { 
		m_desc->onion_key = malloc(189);
		int len = strlen($1);
		strncpy(m_desc->onion_key, $1, len);
		rsa_index = m_desc->onion_key + len;

		/* TODO find out why this does not always work, 
			is index 188 being clobbered later?
			it shouldn't be... */
		rsa_index[188] = '\0';
		}

	| onion_key ONION_KEY {
		
		int len = strlen($2);

		/* Most likely an attack. */
		assert((rsa_index - m_desc->onion_key) + len < 189); 

		strncpy(rsa_index, $2, len);
		rsa_index += len;

		/* Should not be needed. */
		*rsa_index = '\0';
	
		}
%%

void dscerror(struct desc *desc, const char *s) {
	//printf("Email me teh errors %s\n", s);
}

