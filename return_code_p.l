%{
#include <stdio.h>
//#include "return_code_p.tab.h"

//250 OK\r\n\0
%}

%%
250		{ return RETURN_OK; }
[0-9]+		{ return RETURN_CODE; }
[ ]+		;
[A-Za-z]+	{ return RETURN_TEXT; }
\r\n		{ return EOL;		}
%%

