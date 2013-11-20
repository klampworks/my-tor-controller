#include <string.h>
#include <stdio.h>
#include "comm.h"
#include <stdlib.h>

#define MAXDATASIZE 1024

void scrub_password(char *password) {
	memset(password, '0', strlen(password));
}

long error(const char *message) {

	printf("Error: %s\n", message);
	exit(1);
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
	int new_circuit = 0, dump_entry = 0;

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
			}

		} else {
			error("Error unrecognised option.");
		}

	}

	int s = create_socket("127.0.0.1", port);

	auth(s, password);

	char buf[MAXDATASIZE];
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

		my_send(s, "getinfo entry-guards\n");
		my_recv(s, buf);

		int num = 0;
		char **ids = parse_ids(buf, &num);

		char togo[17+41+2];
		char *togo_i = togo+16;
		strncpy(togo, "getinfo desc/id/", 16);
		togo_i[41] = '\n';
		togo_i[41+1] = '\0';

		for (int i = 0; i < num; i++) {

			//This requires UseMicrodescriptors 0 in torrc
			strncpy(togo_i, ids[i], 41);

			my_send(s, togo);
			my_recv(s, buf);

			char *ip = parse_ip(buf);
			if (ip) { 
				printf("%s\n", ip);
				free(ip);
			}
			free(ids[i]);
		}


	}
	return 0;
}
