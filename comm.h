#ifndef COMM_H
#define COMM_H

	int my_send(int s, const char *msg);
	void newnym(int s);
	int my_recv(int s, char* j);
	int create_socket(const char*, short);
	int check_250(const char*);
	int auth(int, const char*);
	char* parse_ip(const char*);
	char** parse_ids(const char *buf, int *num);

#endif
