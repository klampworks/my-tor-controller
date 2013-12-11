%{
#include <stdio.h>
#include "comm.h"
#include "desc_info.lexer.h"
#include <assert.h>

void dscerror(struct desc *desc, const char*);
int dscparse(struct desc  *m_desc);
char* append_buffer(char *, const char *, const char*);
char* begin_buffer(unsigned );

char *rsa_index;

dscdebug = 1;
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
%token ONION_KEY SIGNING_KEY;

%parse-param {struct desc *m_desc}

%%

start:
	ip platform uptime bandwidth onion_key signing_key

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
		m_desc->onion_key = begin_buffer(189);
		rsa_index = append_buffer(m_desc->onion_key, $2, m_desc->onion_key);
		}

	| onion_key KEY {
		rsa_index = append_buffer(rsa_index, $2, m_desc->onion_key);
		}

signing_key:
	SIGNING_KEY KEY { 
		m_desc->signing_key = begin_buffer(189);
		rsa_index = append_buffer(m_desc->signing_key, $2, m_desc->signing_key);
		}

	| signing_key KEY {
		rsa_index = append_buffer(rsa_index, $2, m_desc->signing_key);
		}
%%

char* begin_buffer(unsigned size) {

	char *t = malloc(size);
	t[size - 1] = '\0';
	return t;
}

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


