#include <string.h>
#include <stdio.h>
#include "comm.h"
#include <stdlib.h>
#include <alloca.h>
#include <assert.h>

#define MAXDATASIZE 1024

/* Socket file descriptor. */
static int s;

/* Socket responses. */
static char buf[MAXDATASIZE];

void scrub_password(char *password) {
	memset(password, '0', strlen(password));
}

long error(const char *message) {

	printf("Error: %s\n", message);
	exit(1);
}

struct or_info {

	char *name;
	char id[42];
	char *country;
	char *ip;
};

struct desc* get_desc(struct node *node) {

	/* Prepare template text that will not change. */
	static char togo[17+41+2];
	static char *togo_i = togo+16;

	/* Is there a way to initialise a char array with an initial value
	 * and have it still read/ write? */
	static int first = 1;
	if (first) { 
		strncpy(togo, "getinfo desc/id/", 16);
		first = 0;
	}

	/* Copy the ID into the template buffer. */
	assert(strlen(node->id) == 41);
	strcpy(togo_i, node->id);

	/* Send the query to the control port. */
	my_send(s, togo);
	my_recv(s, buf);

	/* Parse out the desc data. */
	return parse_desc(buf);
}


void print_ip(struct node *node) {

	struct desc *m_desc = get_desc(node);

	if (m_desc && m_desc->ip_address)
			printf("%s\n", m_desc->ip_address);

	release(m_desc);

}

void print_exit(struct node *node) {

	/* Check that this is the last in the chain.
	 * TODO: This won't work for single hop circuits. */
	if (!node->child) {
		print_info(node);
	}
}

void print_info(struct node *node) {

	printf("%s -- %s -- ", node->id, node->name);
	print_ip(node);
}

void process_nodes(const char *msg, void(*fn)(struct node*)) {

	my_send(s, msg);
	my_recv(s, buf);

	struct circuit *head = parse_entry_guards(buf);

	for (struct circuit *i = head; i;) {
		
		for (struct node *j = i->head; j; ) {

			fn(j);

			free(j->id);
			free(j->name);
			struct node *t = j;
			j = j->child;
			free(t);
		}

		struct circuit *t = i;
		i = i->child;
		free(t);
	}
}

int main(int argc, char *argv[]) {

	if (argc < 3) {
		printf("Usage: %s -p <control port> -a <password> (-n|-d)\n"
			"-n New Tor circuit.\n"
			"-d dump Entry guard ip addresses.\n", argv[0]);
		exit(1);
	}

	short port = -1;
	char *password = NULL;
	int new_circuit = 0, dump_entry = 0, dump_exit = 0, dump_full = 0;

	for (int i = 1; i < argc; i++) {
		
		if (strlen(argv[i]) == 2 && *argv[i] == '-') {

			switch(argv[i][1]) {

			case 'p':
				port = ++i < argc ? atoi(argv[i]) : error("Not enough arguments.");
				continue;
			case 'a':
				password = ++i < argc ? argv[i] : (char*)error("Not enough arguments.");
				continue;
			case 'n':
				new_circuit = 1;
				continue;
			case 'd':
				dump_entry = 1;
				continue;
			case 'x':
				dump_exit = 1;
				continue;
			case 'f':
				dump_full = 1;
				continue;
			}

		} else {
			error("Error unrecognised option.");
		}

	}

	s = create_socket("127.0.0.1", port);

	auth(s, password);

	my_recv(s, buf);

	scrub_password(password);

	if (!check_250(buf)) {

		printf("Something went wrong, recieved %s\n", buf);
		exit(1);
	} 

	if (new_circuit) {

		newnym(s);
		my_recv(s, buf);
		return (!check_250(buf));
	}

	if (dump_entry) {

		process_nodes("getinfo entry-guards\n", &print_ip);
	}

	if (dump_exit) {
		process_nodes("getinfo circuit-status\n", &print_exit);

	}

	if (dump_full) {
		process_nodes("getinfo circuit-status\n", &print_info);

	}
	return 0;
}

