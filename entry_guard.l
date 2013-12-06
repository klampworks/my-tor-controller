%{
#include <stdlib.h>
#include <string.h>
#include "entry_guard.tab.h"
%}

%option noyywrap
%x EQ NM
%%
$[0-9A-Z]{40}	    	{ puts("Match id"); entlval.sval = strdup(enttext); BEGIN(EQ); return ID; }
<EQ>[=]		    	{ puts("Match ="); BEGIN(NM); return EQUALS; }
<NM>[a-zA-Z0-9]+	{ puts("Match name");  BEGIN(0); entlval.sval = strdup(enttext); return NAME; }
.			{ puts("SKip period."); BEGIN(0);}
\n			{ puts("SKip \\n."); BEGIN(0); }
^250[ ]OK			{ puts("FOund end"); return END; }
%%
