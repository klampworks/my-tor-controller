%{
#include <stdlib.h>
#include <string.h>
#include "entry_guard.tab.h"
%}

%option noyywrap
%x NAME
%%
$[0-9A-Z]{40}	    	{ entlval.sval = strdup(enttext); return ID; }
[=]		    	{ BEGIN(NAME); }
<NAME>=[a-zA-Z0-9]+ 	{ BEGIN(0); entlval.sval = strdup(enttext); return NAME; }
.			;
%%
