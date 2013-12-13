#include <string.h>
#include <stdio.h>
#include "comm.h"
#include <stdlib.h>
#include <alloca.h>
#include <assert.h>
#include <sys/types.h>
#include <unistd.h>

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

char* send_buffer(const char *command, const char *msg) {

	int command_len = strlen(command);
	int total_len = command_len + strlen(msg) + 3;

	char *to = alloca(total_len);
	strcpy(to, command);

	strcpy(to+command_len, msg);
	strcpy(to+total_len - 3, "\r\n");

	/* Send the query to the control port. */
	my_send(s, to);
	my_recv(s, buf);

	return buf;
}

char* get_country(const char *ip) {

	if (!ip) return NULL;

	char *res = send_buffer("getinfo ip-to-country/", ip);

	char *st = strrchr(res, '=');
	if (!st++) return NULL;

	char *country = malloc(3);
	strncpy(country, st, 2);
	country[2] = '\0';

	return country;
}

struct desc* get_desc(struct node *node) {

	assert(strlen(node->id) == 41);

	/* Buf is global. */
	char *buf = send_buffer("getinfo desc/id/", node->id);

	/* Parse out the desc data. */
	struct desc *desc =  parse_desc(buf);

	desc->country = get_country(desc->ip_address);
	
	return desc;
}

void print_desc(struct node *node) {

	struct desc *m_desc = get_desc(node);

	If (!m_desc)
		return;

	if (m_desc->ip_address)
		printf("IP = %s\n", m_desc->ip_address);

	if (m_desc->platform)
		printf("Platform = %s\n", m_desc->platform);


	printf("Uptime = %d\n", m_desc->uptime);
	printf("Bandwidth:\n\tmin = %d\n\tmax = %d\n\tavg = %d\n", 
		m_desc->bw_min, m_desc->bw_max, m_desc->bw_avg);

	if (m_desc->onion_key)
		printf("Onion key = %s\n", m_desc->onion_key);

	if (m_desc->onion_key)
		printf("Signing key = %s\n", m_desc->signing_key);

	release_desc(m_desc);
}

void print_country(struct node *node) {

	struct desc *m_desc = get_desc(node);

	if (m_desc && m_desc->ip_address)
			get_country(m_desc->ip_address);

	release_desc(m_desc);

}

void print_ip(struct node *node) {

	struct desc *m_desc = get_desc(node);

	if (m_desc && m_desc->ip_address)
			printf("%s\n", m_desc->ip_address);

	release_desc(m_desc);

}

void print_exit(struct node *node) {

	/* Check that this is the last in the chain.
	 * TODO: This won't work for single hop circuits. */
	if (!node->child) {
		print_info(node);
	}
}

void print_info(struct node *node) {

	printf("%s -- %s\n", node->id, node->name);
	print_desc(node);
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

void drop_privileges() {

	if (getuid())
		/* We are not root. */	
		return;

	setgid(1000);
	setuid(1000);

	if (setuid(0)) {
		puts("Managed to regain root.");
	} else {
		printf("Now running as %d\n", getuid());
	}
}

int main(int argc, char *argv[]) {
	
	if (argc < 2) {
		printf("Usage: %s -p <control port> -a <password> (-n|-d)\n"
			"-n New Tor circuit.\n"
			"-d dump Entry guard ip addresses.\n", argv[0]);
		exit(1);
	}

	short port = -1;
	char *password = NULL;
	int new_circuit = 0, dump_entry = 0, dump_exit = 0, dump_full = 0, dump_country = 0;
	char *filename = NULL;

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
			case 'P':
				filename = ++i < argc ? argv[i] : (char*)error("Not enough arguments.");
				continue;
			case 'c':
				dump_country = 1;
				continue;
			}

		} else {
			error("Error unrecognised option.");
		}

	}

	drop_privileges();

	if (filename) {

		//Get username and password from file.

		FILE *fd = fopen(filename, "r");
		assert(fd);

		/* A pointer to a value inside main's stack frame is
		 * effectivly global. */
		password = alloca(66);

		fscanf(fd, "%d", &port);
		fscanf(fd, "%66s", password);
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

	if (dump_country) {
		process_nodes("getinfo circuit-status\n", &print_country);
	}


	return 0;
}

