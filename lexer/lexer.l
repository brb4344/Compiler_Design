%{
#include "../parser/parser.tab.h" 
#include <stdio.h>
#include <string.h>
%}

%option noyywrap

%%

"const"                 { return CONST; }
"="                     { return EQUALS; }
"/"                     { return SLASH; }
"&"                     { return AND; }
"!"                     { return NOT; }
"|"                     { return PIPE; }
"*"                     { return STAR; }
"+"                     { return PLUS; }
"?"                     { return QUESTION; }
"("                     { return LPAREN; }
")"                     { return RPAREN; }
"["                     { return LBRACK; }
"]"                     { return RBRACK; }
"^"                     { return CARET; }
"."                     { return DOT; }
"$\{"                   { return SUB_START; }
"}"                     { return SUB_END; }

"//".* { /* Skip comments */ }
[ \t\n\r]+              { /* Skip whitespace */ }

\"([^\"%]|%x[0-9a-fA-F]+;)*\"   { return LITERAL; }
[a-zA-Z0-9_]+                   { return ID; }
"["\^?([^\]\\]|\\.)+"]"         { return RANGE; }

.                       { return yytext[0]; }

%%