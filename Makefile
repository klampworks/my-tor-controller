all: entry_guard_lexer.c entry_guard.tab.c lex.yy.c return_code_p.tab.c
	gcc main.c comm.c lex.yy.c return_code_p.tab.c entry_guard.tab.c entry_guard_lexer.c -lfl -std=gnu99

return_code_p.tab.c return_code_p.tab.h: return_code_p.y
	bison -d return_code_p.y

lex.yy.c: return_code_p.l return_code_p.tab.h
	flex return_code_p.l

entry_guard.tab.c entry_guard.tab.h: entry_guard.y
	 bison -d entry_guard.y -p ent

entry_guard_lexer.h entry_guard_lexer.c: entry_guard.l
	flex --header-file="entry_guard_lexer.h" --outfile="entry_guard_lexer.c" --prefix="ent" entry_guard.l


