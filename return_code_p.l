%{
#include <stdlib.h>
#include <string.h>
#include "return_code_p.tab.h"
%}

%%
^250[ ]		{ return RETURN_250; }
^[0-9]+		{ yylval.ival = atoi(yytext); return RETURN_CODE; }
[ ]+		;
OK		{ return RETURN_OK; }
[a-zA-Z :]+	{ yylval.sval = strdup(yytext); return RETURN_TEXT; }
\r\n		{ return EOL;		}
%%
