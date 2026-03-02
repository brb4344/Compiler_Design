%{
#include "../parser/parser.tab.h"
#include <string.h>
#include <stdio.h>
%}

%option noyywrap

%%

"const"                 { printf ("I am const %s\n", yytext); return CONST;}
"="                     { printf ("I am = %s \n", yytext); return EQUALS;}
"/"                     { printf ("I am slash %s\n", yytext); return SLASH; }
"&"                     { return AND; }
"!"                     { return NOT; }
"|"                     { return OR; }
"*"                     { return STAR; }
"+"                     { return PLUS; }
"?"                     { return QUESTION; }
"("                     { return LPAREN; }
")"                     { return RPAREN; }
"["                     { return LBRACK; }
"]"                     { return RBRACK; }
"^"                     { return CARET; }
"."                     { return WILD; }
"$\{"                   { return SUB_START; }
"}"                     { return SUB_END; }

"//".*                  { }
[ \t\n\r]+              { }


\[(%x[0-9A-Fa-f]+;|[^%\]])*\] {     yylval.sval = strdup(yytext);   printf ("I am range %s\n",yytext);  return RANGE; }

\"(%x[0-9A-Fa-f]+;|[^\"%])*\" { yylval.sval = strdup(yytext); printf ("I am literal %s\n", yytext); return LITERAL;
}


[a-zA-Z0-9_]+                   { yylval.sval = strdup(yytext); printf ("I am ID %s\n", yytext); return ID; }





.   { fprintf(stderr,"Invalid char: %s\n",yytext); exit(1); }

<<EOF>> {     
    return 0;
}
%%