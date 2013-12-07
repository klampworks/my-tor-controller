%{
#include <stdio.h>
#include "comm.h"
#include "entry_guard_lexer.h"

void enterror(struct node ***start, const char*);
int entparse(struct node ***head);
void insert(struct node ***, int, char *, char *);
entdebug = 1;
int head_i = 0;

%}

%union {
	char  *sval;
}

%token <sval> ID;
%token <sval> NAME;
%token END EQUALS LF;

%parse-param {struct node ***head}
%%

start:
	circuit | start circuit | END

circuit:
	entry_guard {	
	
	} | circuit entry_guard | LF { 


		printf("Extending head %d\n", head_i);
		head_i++;
		/* TODO: If this realloc fails, bad things happen. */
		*head = realloc(*head, (sizeof *head) * (head_i + 1));
		head[head_i] = malloc(sizeof *head);
		head[head_i][0] = NULL;
	};

entry_guard:
	ID EQUALS NAME { insert(head, head_i, $1, $3); }

%%

void insert(struct node ***headhead, int head_i, char *id, char *name) {

	struct node *head = headhead[0][head_i];
	struct node *i;

	struct node *to_insert = malloc(sizeof *to_insert);
	to_insert->id = id;
	to_insert->name = name;
	to_insert->child = NULL;

	if (head) {

		/* Traverse down to the end of the list. */
		/* TODO: store tail. */
		for(i = head; i->child; i = i->child);

		i->child = to_insert;
	} else {

		printf("Inserting %s into slot %d\n", name, head_i);
		head = to_insert;
	}

	printf("%p\n", headhead[0][0]);
	printf("%s\n", headhead[0][0]->name);

/*
	for (struct node **j = headhead[0]; *j; j++) {
		for (struct node *i = *j; i; i = i->child) {
			printf("%s --> %s\n", i->id, i->name);
		}
		puts("end loop");
	} 
	*/

}

void enterror(struct node ***head, const char *s) {
	printf("Emaill me teh errors %s\n", s);
}

