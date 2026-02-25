%{
#include <stdio.h>
#include <stdlib.h>

void yyerror(const char *s);
extern int yylex();
extern FILE *yyin;
%}

%token CONST EQUALS SLASH AND NOT PIPE STAR PLUS QUESTION
%token LPAREN RPAREN LBRACK RBRACK CARET DOT SUB_START SUB_END
%token ID LITERAL RANGE

/* Precedence: Low to High */
%left PIPE
%left AND
%left SEQ_PREC
%nonassoc NOT
%nonassoc STAR PLUS QUESTION

%%

System:
    Definitions SLASH RootRegex SLASH { printf("accepts\n"); exit(0); }
    ;

Definitions:
    /* empty */
    | Definitions Definition
    ;

Definition:
    CONST ID EQUALS SLASH Regex SLASH
    ;

RootRegex:
    RootRegex AND RootRegex
    | NOT Regex
    | Regex
    ;

Regex:
    Regex PIPE Regex             /* Alternation */
    | Regex Regex %prec SEQ_PREC  /* Sequence */
    | Regex STAR
    | Regex PLUS
    | Regex QUESTION
    | Term
    | LPAREN Regex RPAREN
    ;

Term:
    LITERAL
    | RANGE
    | DOT
    | SUB_START ID SUB_END
    ;

%%

void yyerror(const char *s) {
    fprintf(stderr, "error: %s\n", s);
    exit(1);
}

int main(int argc, char **argv) {
    if (argc < 2) {
        fprintf(stderr, "Usage: %s <filename>\n", argv[0]);
        return 1;
    }
    FILE *f = fopen(argv[1], "r");
    if (!f) {
        perror(argv[1]);
        return 1;
    }
    yyin = f;
    yyparse();
    return 0;
}