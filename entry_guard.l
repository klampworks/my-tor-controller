%{
#include <stdlib.h>
#include <string.h>
#include "entry_guard.tab.h"
%}

%option noyywrap
%x EQ NM
%%
$[0-9A-Z]{40}	    	{ entlval.sval = strdup(enttext); BEGIN(EQ); return ID; }
<EQ>[=]		    	{ BEGIN(NM); return EQUALS; }
<NM>[a-zA-Z0-9]+	{ printf("NAME %s\n", enttext); entlval.sval = strdup(enttext); return NAME; }
<NM>[ ].*			;
.			{ }
<NM>\n			{ BEGIN(0); return LF; }
\n			{ BEGIN(0); }
^250[ ]OK		{return END; }
%%
