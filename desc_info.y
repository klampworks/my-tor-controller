%{
#include <stdio.h>
#include "comm.h"
#include "desc_info.lexer.h"
#include <assert.h>

void dscerror(struct desc *desc, const char*);
int dscparse(struct desc  *m_desc);
char* append_buffer(char *, const char *, const char*);

char *rsa_index;

//dscdebug = 1;
%}

%union {
	char  *sval;
	int  ival;
}

%token <sval> IP;
%token <sval> PLATFORM;
%token <sval> KEY;
%token <ival> UPTIME;
%token <ival> BANDWIDTH;
%token ONION_KEY;

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
	ONION_KEY KEY { 
		m_desc->onion_key = malloc(189);
		m_desc->onion_key[188] = '\0';
		rsa_index = m_desc->onion_key;

		rsa_index = append_buffer(rsa_index, $2, m_desc->onion_key);

		}

	| onion_key KEY {
		
		rsa_index = append_buffer(rsa_index, $2, m_desc->onion_key);
	
		}
%%

char* append_buffer(char *buffer, const char *data, const char *buffer_start) {

	int len = strlen(data);

	/* Prevent buffer overflow. */
	assert((rsa_index - buffer_start) + len < 189); 

	strncpy(buffer, data, len);
	return buffer + len;
}

void dscerror(struct desc *desc, const char *s) {
	//printf("Email me teh errors %s\n", s);
}


