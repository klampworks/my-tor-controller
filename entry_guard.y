%{
#include <stdio.h>
#include "comm.h"
#include "entry_guard_lexer.h"

void enterror(struct node **start, const char*);
int entparse(struct node **head);
void insert(struct node **, char *, char *);
entdebug = 1;

%}

%union {
	char  *sval;
}

%token <sval> ID;
%token <sval> NAME;
%token END EQUALS;

%parse-param {struct node **head}
%%

start:
	entry_guard
entry_guard:
	ID EQUALS NAME { insert(head, $1, $3); }

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

void enterror(struct node **head, const char *s) {
	printf("Emaill me teh errors %s\n", s);
}

