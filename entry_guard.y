%{
#include <stdio.h>
//#include "return_code_p_lexer.h"

void yyerror(struct node **start, const char*);
int yyparse(struct node **start);

struct node {
	char *id;
	char *name;
	struct *node child;
};
%}

%union {
	char *sval;
}

%token <sval> ID;
%token <sval> NAME;
%token EOL

%parse-param {struct node **head}
%%

entry_guard:
	ID NAME;

%%

void insert(char *id, char *name) {

	struct node *i;

	struct node *to_insert = malloc(sizeof node);
	to_insert->id = id;
	to_insert->name = name;
	to_insert->child = NULL;

	if (*head) {

		/* Traverse down to the end of the list. */
		/* TODO: store tail. */
		for(i = *head; i->child; i = i->child);

		i->child = to_insert;
	} else {

		*head = to_insert;
	}
}

void yyerror(char **id, char **name, const char *s) {
	printf("Email me teh errors %s\n", s);
}

