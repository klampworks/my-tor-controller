#include <string.h>
#include <stdio.h>
#include "comm.h"
#include <stdlib.h>
#include <alloca.h>

#define MAXDATASIZE 1024

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

struct circuitt {
	struct or_info *or;
	struct circuitt *next;
};

char * find_2(const char* t, char s1, char s2) {

	char *st1 = NULL, *st2 = NULL;
	if (((st1 = strchr(t, s1)) && (st2 = strchr(t, s2)))) 
		return st1 < st2? st1 : st2;
	else
		return st1? st1 : st2? st2 : NULL;
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
	int new_circuit = 0, dump_entry = 0, dump_exit = 0;

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

		puts(buf);

		parse_entry_guards(buf);
		exit(1);


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

	//TODO reused code.
	if (dump_exit) {

		my_send(s, "getinfo circuit-status\n");
		my_recv(s, buf);


		char *i = buf;
		char *tmp = i;

		struct circuitt *cir = NULL;
		

		for (;;) {

			char *lf = strchr(tmp, '\n');

			if (!lf)
				break;

			unsigned size = lf - tmp;
			char *line = alloca(size);
			strncpy(line, tmp, size-1);
			line[size-1] = '\0';

			char *id[] = {NULL, NULL, NULL}, *name[] = {NULL, NULL, NULL};
			for (unsigned i = 0; i < 3; i++) {
				id[i] = NULL;
				name[i] = NULL;
			}

			char *t = line;

			for (unsigned i = 0; i < 3; i++) {
				
				if ((t = strchr(t, '$'))) {
					id[i] = malloc(42);
					strncpy(id[i], t, 41);
					id[i][41] = '\0';
				} else {
					break;
				}

				char *tt = find_2(t, '=', '~');
				if (!tt) break;

				char *end = find_2(tt, ' ', ',');
				if (!end) break;
					
				tt++;
				unsigned size = end - tt;
				name[i] = alloca(size);
				strncpy(name[i], tt, size);
				name[i][size] = '\0';;
				t = end + 1;
			}

			for (unsigned i = 0; i < 3; i++) {
			
				if (id[i] && name[i]) {
					printf("Id = %s and name = %s\n", id[i], name[i]);
				}

			}

			puts("");
			tmp = lf+1;
			continue;

			/*
			if (!(tmp = strchr(tmp, '$'))) 
				break;

			if (lf < tmp)
				printf("\n\n");
	
			char id[42];
			strncpy(id, tmp, 41);
			id[41] = '\0';

			puts(id);
			i = ++tmp;
			continue;
			*/
		}
	}

	return 0;
}
