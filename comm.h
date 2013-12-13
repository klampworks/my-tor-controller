#ifndef COMM_H
#define COMM_H

	struct desc {

		char *ip_address;
		char *platform;
		int uptime;
		int bw_min, bw_max, bw_avg;
		char *onion_key;
		char *signing_key;
		char *country;

	};

	int my_send(int s, const char *msg);
	void newnym(int s);
	int my_recv(int s, char* j);
	int create_socket(const char*, short);
	int check_250(const char*);
	int auth(int, const char*);
	char* parse_ip(const char*);
	struct desc* parse_desc(const char *buf);
	char** parse_ids(const char *buf, int *num);
	void release_desc(struct desc*);

	struct circuit * parse_entry_guards(const char *msg);


	struct node {
		char *id;
		char *name;
		struct node *child;
	};

	struct circuit {

		/* Head of a linked list of nodes */
		struct node *head;
		struct circuit *child;

	};

#endif
