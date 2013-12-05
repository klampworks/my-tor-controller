%{
#include <stdlib.h>
#include <string.h>
//#include "return_code_p.tab.h"
%}

%%
$[0-9A-Z]{40}	    	{ yyval = strdup(yytext); return ID; }
[=]		    	{ BEGIN(NAME); }
<NAME>=[a-zA-Z0-9]+ 	{ BEGIN(0); yyval = strdup(yytext); return NAME; }
.			;
%%
