%{
#include <stdio.h>
#include <stdlib.h>
#include <string.h> 
#include "../Library/AST.h"

void yyerror(const char *s);
extern int yylex();
extern FILE *yyin;

%}

%union {
    char* sval;
    struct ASTNode *node;
}

%token <sval> ID LITERAL RANGE CONST WILD
%token <sval> EQUALS SLASH AND NOT OR STAR PLUS QUESTION 
%token <sval> LPAREN RPAREN LBRACK RBRACK CARET DOT SUB_START SUB_END

// FIX 1: All rules that return ASTNode* must be <node>, not <sval>
%type <node> mystart System Definition RootRegex rrg Seq Regex Term Alt Repeat Substitute;

%left AND NOT
%left OR
%left STAR PLUS QUESTION

%start mystart
%%

// FIX 2: mystart properly typed, print/free on every completed System
mystart: System                 { $$ = $1; printAST($1, 0); freeAST($1); }
    | mystart System            { $$ = $2; printAST($2, 0); freeAST($2); }
    | error { 
        yyerror("Syntax error"); 
        yyerrok; 
        return 1;
    }
    ;

System: 
    SLASH RootRegex SLASH       { $$ = createNode("System", NULL, $2, NULL); }
    | Definition System         { $$ = createNode("System", NULL, $1, $2); }
    ;

Definition: CONST ID EQUALS SLASH Alt SLASH 
                                { $$ = createNode("Definition", $2, $5, NULL); }
    ;

RootRegex: RootRegex AND RootRegex  { $$ = createNode("AND", NULL, $1, $3); }
    | NOT Regex                     { $$ = createNode("NOT", NULL, $2, NULL); }
    | Regex                         { $$ = $1; }
    ;

Regex: Alt                      { $$ = $1; }
    ;

Alt: Seq                        { $$ = $1; }
    | Alt OR Seq                { $$ = createNode("OR", NULL, $1, $3); }
    ;

Seq: rrg                        { $$ = $1; }
    | Seq rrg                   { $$ = createNode("Seq", NULL, $1, $2); }
    ;

rrg: Term                       { $$ = $1; }
    | Repeat                    { $$ = $1; }
    | LPAREN Alt RPAREN         { $$ = createNode("Group", NULL, $2, NULL); }
    ;

Repeat: rrg STAR                { $$ = createNode("STAR", NULL, $1, NULL); }
    | rrg PLUS                  { $$ = createNode("PLUS", NULL, $1, NULL); }
    | rrg QUESTION              { $$ = createNode("QUESTION", NULL, $1, NULL); }
    ;

Term: LITERAL                   { $$ = createNode("Literal", $1, NULL, NULL); }
    | RANGE                     { $$ = createNode("Range", $1, NULL, NULL); }
    | WILD                      { $$ = createNode("Wild", $1, NULL, NULL); }
    | Substitute                { $$ = $1; }
    ;

Substitute: SUB_START ID SUB_END  { $$ = createNode("Substitute", $2, NULL, NULL); }
    ;

%%

void yyerror(const char *s) {
    fprintf(stderr, "rejects\n");
    exit(1);
}

int main(int argc, char **argv) {
    if (argc < 2) {
        fprintf(stderr, "Usage: %s <filename>\n", argv[0]);
        return 1;
    }
    FILE *f = fopen(argv[1], "r");
    if (!f) {
        perror("File error");
        return 1;
    }
    yyin = f;
    if (yyparse() == 0) {
        printf("accepts\n");
        exit(0);
    } else {
        printf("Exiting due to error.\n");
        exit(1);
    }
    return 0;
}