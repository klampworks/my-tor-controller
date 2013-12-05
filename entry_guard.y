%{
#include <stdio.h>
#include "comm.h"
#include "entry_guard_lexer.h"

void yyerror(struct node **start, const char*);
int yyparse(struct node **head);
void insert(struct node **, char *, char *);

%}

%union {
	char *sval;
}

%token <sval> ID;
%token <sval> NAME;

%parse-param {struct node **head}
%%

entry_guard:
	ID NAME { insert(head, $1, $2); }

%%

void insert(struct node **head, char *id, char *name) {

	struct node *i;

	struct node *to_insert = malloc(sizeof to_insert);
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

void yyerror(struct node **head, const char *s) {
	printf("Email me teh errors %s\n", s);
}

