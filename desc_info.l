%{
#include <stdlib.h>
#include <string.h>
#include "desc_info.tab.h"

/* Example text:

250+desc/id/$AA5751A6E83D901899587C74115D45E06B42D339=
router invincibleAI 80.90.43.129 41252 0 9030
platform Tor 0.2.4.18-rc-dev on Linux
protocols Link 1 2 Circuit 1
published 2013-12-07 07:29:44
fingerprint AA57 51A6 E83D 9018 9958 7C74 115D 45E0 6B42 D339
uptime 380518
bandwidth 3170304 5146624 3730123
extra-info-digest 152E9FCC9E454250509BD1A465C2080D6FEA2612
onion-key
-----BEGIN RSA PUBLIC KEY-----
MIGJAoGBAK+I/HFE9y/oh95ThfNl//OlvjJ0YqgpMK5Q3YDk+9nWpaasvs5gFWR8
rQbRZispGIal7qZbyUXLfO6084xIxJal6olI4WxgHDRGxUHLPHv12Ol0wC5AKrN/
0LCyWg7QAKmcqCIg6Mav9dZOE4KIzxpm3WqGyc0YKCcMyBnWXypHAgMBAAE=
-----END RSA PUBLIC KEY-----
signing-key
-----BEGIN RSA PUBLIC KEY-----
MIGJAoGBAMybI4hQiP5s1QYkmuEF1e51w0v8a22tgFmsqL7vpwHjttxyIvH1thxC
eMW70vA48pqUuzewYS3Wax5o7qcs5mzXyQwVK5liQQ7cvTpFs0QDhhujnLyyPw/0
tLF9Z9qUvYe1Dm/rX49H8Q/HRgZBqxDAj5ysplgu7zS0qAx1AnuLAgMBAAE=
-----END RSA PUBLIC KEY-----
hidden-service-dir
contact 0x02225522 Frenn vun der Enn (FVDE) <info AT enn DOT lu>
ntor-onion-key 467ox5E7Va

*/
%}

%option noyywrap
%x L1 L2 L3 UP JUNK1 JUNK2 JUNK3 BW OK PLAT
%%

^250\+[^\n]+	{ /* First line, contains information we already know. */ 
			BEGIN(L1);
		}

<L1>\n		{ BEGIN(L2); }
<L2>[^ ]	;
<L2>([0-9]+\.){3}[0-9]+	{ dsclval.sval = strdup(dsctext); return IP; }
<L2>[ ]		;
<L2>\r\n	{ BEGIN(L3); }
<L3>^platform[ ] {BEGIN(PLAT); }
<PLAT>[^\n]+	{ dsclval.sval = strdup(dsctext); BEGIN(JUNK1); return PLATFORM; }

<JUNK1>\n[^\n]+\n { BEGIN(JUNK2); }
<JUNK2>[^\n]+\n { BEGIN(JUNK3); }
<JUNK3>[^\n]+\n { BEGIN(0); }

^uptime[ ]	{ BEGIN(UP); }
<UP>[0-9]+	{ dsclval.ival = atoi(dsctext); BEGIN(0); return UPTIME; }

^bandwidth[ ]	{ BEGIN(BW); } 
<BW>[ ]?[0-9]+	{ dsclval.ival = atoi(dsctext); return BANDWIDTH; }
<BW>\r\n	{ BEGIN(0);}


^signing-key\r\n 	{ BEGIN(OK); return SIGNING_KEY; }
^onion-key\r\n 	{ BEGIN(OK); return ONION_KEY; }
<OK>\-\-\-\--BEGIN\ RSA\ PUBLIC\ KEY\-\-\-\-\-\r\n ;
<OK>[^-\r]+	{ dsclval.sval = strdup(dsctext); return KEY; }
<OK>\r\n	;
<OK>\-\-\-\-\-END\ RSA\ PUBLIC\ KEY\-\-\-\-\-\r\n	{ BEGIN(0); }
.		;
\n		;
%%
