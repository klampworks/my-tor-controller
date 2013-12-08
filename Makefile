
all: entry_guard_lexer.c entry_guard.tab.c lex.yy.c return_code_p.tab.c desc_info.lexer.c desc_info.tab.c
	gcc main.c comm.c lex.yy.c return_code_p.tab.c entry_guard.tab.c entry_guard_lexer.c desc_info.lexer.c desc_info.tab.c -lfl -pg -fno-pie -std=gnu99

desc_info.tab.c desc_info.tab.h: desc_info.y
	bison -t -d desc_info.y -p dsc

desc_info.lexer.h desc_info.lexer.c: desc_info.l
	flex --header-file="desc_info.lexer.h" --outfile="desc_info.lexer.c" --prefix="dsc" desc_info.l

return_code_p.tab.c return_code_p.tab.h: return_code_p.y
	bison -d return_code_p.y

lex.yy.c: return_code_p.l return_code_p.tab.h
	flex return_code_p.l

entry_guard.tab.c entry_guard.tab.h: entry_guard.y
	bison -t -d entry_guard.y -p ent

entry_guard_lexer.h entry_guard_lexer.c: entry_guard.l
	flex --header-file="entry_guard_lexer.h" --outfile="entry_guard_lexer.c" --prefix="ent" entry_guard.l



