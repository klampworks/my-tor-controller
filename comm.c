#include <string.h>
#include <malloc.h>
#include <arpa/inet.h>
#include <netinet/in.h>
#include <alloca.h>
#include <fcntl.h>
#include <unistd.h>

#define MAXDATASIZE 1024

void clear_socket(int s) {

	int opts;
	opts = fcntl(s,F_GETFL);
	opts = (opts | O_NONBLOCK);
	fcntl(s, F_SETFL, opts);

	int numbytes = 10;
	char j[2048];

	while (numbytes > 0) {
		numbytes = recv(s, j, 2048, 0);
	}


	opts = opts & (~O_NONBLOCK);
	fcntl(s, F_SETFL, opts);
}

int my_send(int s, const char *msg) {

	clear_socket(s);

	int len = strlen(msg);
	int r;

	if (msg[len-1] != '\n') {
		
		char *msg2 = alloca(len + 1);
		strncpy(msg2, msg, len);
		msg2[len] = '\n';
		msg2[len+1] = '\0';

		r = send(s, msg2, strlen(msg2), 0);
	} else {
	
		r = send(s, msg, strlen(msg), 0);
	}

	return r;
}

int auth(int s, const char *pass) {

	//static const char *txt = "authenticate \"";
	static const int txt_len = 14;

	int len = strlen(pass);

	char *msg = alloca((txt_len + len + 3) * sizeof *msg);

	sprintf(msg, "authenticate \"%s\"\n", pass);

	return my_send(s, msg);
}


void newnym(int s) {
	my_send(s, "signal NEWNYM\n");
}


int my_recv(int s, char* j) {

	sleep(1);
	int numbytes = recv(s, j, MAXDATASIZE-1, 0);
	j[numbytes] = '\0';
	clear_socket(s);
	return numbytes;
}

int create_socket(const char *address, const short port) {

	struct sockaddr_in serv_addr;
	int s;
	s = socket(AF_INET, SOCK_STREAM, 0);

	//zero fill memory of serv_addr
	memset(&serv_addr, '0', sizeof serv_addr);

	serv_addr.sin_family = AF_INET;
	serv_addr.sin_port= htons(port);
	serv_addr.sin_family = AF_INET;
	serv_addr.sin_addr.s_addr = inet_addr(address);

	connect(s, (struct sockaddr *)&serv_addr, sizeof serv_addr);
	return s;
}

#include "return_code_p_lexer.h"
#include "return_code_p.tab.h"
//Check for the 250 OK message.
int check_250(const char *message) {

	YY_BUFFER_STATE i = yy_scan_string(message);
	int code = 0;
	char **text;
	text = malloc(sizeof(char*));

	yyparse(&code, text);
	yy_delete_buffer(i);

	if (code == 250) {

		//*text is not allocated with code i 250.
		free(text);
		return 1;
	} else {

		printf("Error %d %s\n", code, *text);
		free(*text);
		free(text);
		return 0;
	}

}

#include "entry_guard_lexer.h"
#include "entry_guard.tab.h"
#include "comm.h"

struct circuit* parse_entry_guards(const char *message) {

	YY_BUFFER_STATE i = ent_scan_string(message);

	struct circuit **head;
	head = malloc((sizeof *head));
	*head = NULL;

	entparse(head);
	ent_delete_buffer(i);

	return *head;
}

/* Unused. */
char** parse_ids(const char *buf, int *num) {

	//Having more than 3 or 4 entry guards is just plain dumb.
	int max = 4;
	char **ids = malloc(max * sizeof(char*));

	int count = 0;

	for (const char *st = buf; (st = strchr(st, '$')); count++) {

		//If some Einstein has set more than 3 entry guards...
		if (count > max) {

			max *= 2;
			ids = realloc(ids, max * sizeof(char*));
			//if (!*ids) exit(1);
		}

		ids[count] = malloc(42 * sizeof(char*));
		//if (!*ids[count]) exit(1);

		strncpy(ids[count], st, 41);
		ids[count][41] = '\0';
		st +=42;
	}

	*num = count;
	return ids;
}

#include "entry_guard_lexer.h"
#include "entry_guard.tab.h"

struct desc* parse_desc(const char *buf) {

	struct desc *m_desc = malloc(sizeof *m_desc);

	YY_BUFFER_STATE i = dsc_scan_string(buf);
	dscparse(m_desc);
	dsc_delete_buffer(i);

	return m_desc;
}

char* parse_ip(const char *buf) {

	struct desc *m_desc = parse_desc(buf);

	free(m_desc->platform);
	char *ret = m_desc->ip_address;
	free(m_desc);

	return ret;
}
