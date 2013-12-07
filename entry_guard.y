%{
#include <stdio.h>
#include "comm.h"
#include "entry_guard_lexer.h"
#include <assert.h>

void enterror(struct circuit **start, const char*);
int entparse(struct circuit **head);
void insert(struct circuit **, int, char *, char *);
entdebug = 1;
int head_i = 0;

%}

%union {
	char  *sval;
}

%token <sval> ID;
%token <sval> NAME;
%token END EQUALS LF;

%parse-param {struct circuit **head}

%%

start:
	circuit | start circuit | END

circuit:
	entry_guard {	
	
	} | circuit entry_guard | LF { 


		/* TODO: If this realloc fails, bad things happen. */

		/* TODO: Refactor common code. */
		struct circuit *circur = *head;
		for (int i = 0; i++ < head_i; circur = circur->child);
		
		/* Assuming that head_i always points to the end of the list. */
		assert(!circur->child);

		circur->child = malloc(sizeof *(circur->child));

		circur = circur->child;

		circur->child = NULL;
		circur->head = NULL;

		head_i++;
	};

entry_guard:
	ID EQUALS NAME { insert(head, head_i, $1, $3); }

%%

void insert(struct circuit **head, int head_i, char *id, char *name) {

	struct circuit *circur = *head;

	/* Traverse down the linked list until we find the correct node */
	for (int i = 0; i++ < head_i; circur = circur->child);

	/* circur now points to the desired circuit. */

	/* Create the new node to insert. */
	struct node *to_insert = malloc(sizeof *to_insert);
	to_insert->id = id;
	to_insert->name = name;
	to_insert->child = NULL;

	struct node *nodecur = circur->head;

	if (nodecur) {

		/* Traverse down to the end of the list. */
		/* TODO: store tail. */
		for(; nodecur->child; nodecur = nodecur->child);

		nodecur->child = to_insert;
	} else {

		circur->head = to_insert;
	}


/*
	for (struct circuit **j = headhead[0]; *j; j++) {
		for (struct circuit *i = *j; i; i = i->child) {
			printf("%s --> %s\n", i->id, i->name);
		}
		puts("end loop");
	} 
	*/

}

void enterror(struct circuit **head, const char *s) {
	printf("Emaill me teh errors %s\n", s);
}

