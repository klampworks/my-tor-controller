%{
#include <stdlib.h>
#include <string.h>
#include "return_code_p.tab.h"
%}

%%
^250[ ]		{ puts("macthed 250"); return RETURN_250; }
^[0-9]+		{ printf("Matced %s\n", yytext); yylval.ival = atoi(yytext); return RETURN_CODE; }
[ ]+		{ puts("matched space"); }
OK		{ puts("Matched ok"); return RETURN_OK; }
[a-zA-Z :]+	{ puts("Matched misc text"); yylval.sval = strdup(yytext); return RETURN_TEXT; }
\r\n		{ puts("Matched EOL"); return EOL;		}
%%
