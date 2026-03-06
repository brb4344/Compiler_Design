%{
#include "../parser/parser.tab.h"
#include <string.h>
#include <stdio.h>
%}

%option noyywrap

%%

"const"                 { yylval.sval = strdup(yytext); return CONST;}
"="                     { yylval.sval = strdup(yytext); return EQUALS;}
"/"                     { yylval.sval = strdup(yytext); return SLASH; }
"&"                     { yylval.sval = strdup(yytext); return AND; }
"!"                     { yylval.sval = strdup(yytext);  return NOT; }
"|"                     { yylval.sval = strdup(yytext); return OR; }
"*"                     { yylval.sval = strdup(yytext);return STAR; }
"+"                     { yylval.sval = strdup(yytext); return PLUS; }
"?"                     { yylval.sval = strdup(yytext); return QUESTION; }
"("                     { yylval.sval = strdup(yytext); return LPAREN; }
")"                     { yylval.sval = strdup(yytext); return RPAREN; }
"["                     { yylval.sval = strdup(yytext); return LBRACK; }
"]"                     { yylval.sval = strdup(yytext); return RBRACK; }
"^"                     { yylval.sval = strdup(yytext); return CARET; }
"."                     { yylval.sval = strdup(yytext); return WILD; }
"$\{"                   { yylval.sval = strdup(yytext); return SUB_START; }
"}"                     { yylval.sval = strdup(yytext); return SUB_END; }

"//".*                  { }
[ \t\n\r]+              { }


\[(%x[0-9A-Fa-f]+;|[^%\]])*\] {     yylval.sval = strdup(yytext);  return RANGE; }

\"(%x[0-9A-Fa-f]+;|[^\"%])*\" { yylval.sval = strdup(yytext);  return LITERAL;
}


[a-zA-Z0-9_]+                   { yylval.sval = strdup(yytext);  return ID; }





.   { fprintf(stderr,"Invalid char: %s\n",yytext); exit(1); }

<<EOF>> {     
    return 0;
}
%%