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
<NM>[a-zA-Z0-9]+	{ BEGIN(0); entlval.sval = strdup(enttext); return NAME; }
.			{ BEGIN(0);}
\n			{ BEGIN(0); }
^250[ ]OK		{return END; }
%%
