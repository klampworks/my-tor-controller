%{
#include <stdio.h>
#include "comm.h"
#include "desc_info.lexer.h"
#include <assert.h>

void dscerror(struct circuit **start, const char*);
int dscparse(struct circuit **head);

%}

%union {
	char  *sval;
}

%parse-param {struct circuit **head}

%%


%%

void dscerror(struct circuit **head, const char *s) {
	printf("Emaill me teh errors %s\n", s);
}

