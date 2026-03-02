%{
#include <stdio.h>
#include <stdlib.h>

void yyerror(const char *s);
extern int yylex();
extern FILE *yyin;

%}

%union {
    char* sval;
}

%token <sval> ID LITERAL RANGE CONST WILD
%token <sval> EQUALS SLASH AND NOT OR STAR PLUS QUESTION 
%token <sval> LPAREN RPAREN LBRACK RBRACK CARET DOT SUB_START SUB_END


%type <sval> System Definition RootRegex rrg Seq Regex Term Alt Repeat Substitute;

%left AND NOT
%left OR
%left STAR PLUS QUESTION


%start mystart
%%


mystart: System
    | mystart System
    | error { 
        yyerror("Syntax error"); 
        yyerrok; 
        return 1; // returns 1 to report error to main
    }
    ;
System: 
    SLASH RootRegex SLASH 
    | Definition System
    ;

Definition: CONST ID EQUALS SLASH Alt SLASH
    ;

RootRegex: RootRegex AND RootRegex
    | NOT Regex  
    | Regex               
    ;

Regex: Alt;

Alt: Seq
    |Alt OR Seq
    ;

Seq: rrg
    | Seq rrg
    ;

rrg: Term
    | Repeat
    | LPAREN Alt RPAREN
    ;

Repeat: rrg STAR
    | rrg PLUS
    | rrg QUESTION
    ;

Term: LITERAL
    | RANGE
    | WILD
    | Substitute
    ;

Substitute: SUB_START ID SUB_END ;

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
    if(yyparse()==0){ 
        printf("accepts\n");
        exit(0);
    }
    else{
        printf("Exiting due to error.\n");
        exit(1);
    }
    return 0;
}