/* I have implemented two pass compiler for the compilation. The first pass runs during yyparse(). 
The lexer validates escapes and ranges immediately. The parser builds the AST and inserts every const name into the symbol table. 
Substitution nodes ${X} are just stored in the AST without checking yet.
During second pass Pass 2 runs after yyparse() completes. It walks the entire AST and checks every ${X} node against the symbol table. 
If any name is not found, it rejects. */

%{
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include "../Library/AST.h"     /*Import own AST Library*/
#include "../Library/Symbol.h"  /*Import own Symbol table Library*/

void yyerror(const char *s);
extern int yylex();
extern FILE *yyin;

/*Initial symbol table and root of AST are NULL*/
Symbol  *symbolTable = NULL;
ASTNode *rootAST     = NULL;

int validateSubstitutions(ASTNode *node);
%}

/*Union is choose: it allocate single memory of maximum size suitable for same data type*/
%union {
    char* sval;
    struct ASTNode *node;
}

/*These tokens carry a char* string value stored in yylval.sval*/
%token <sval> ID LITERAL RANGE CONST WILD
%token <sval> EQUALS SLASH AND NOT OR STAR PLUS QUESTION
%token <sval> LPAREN RPAREN LBRACK RBRACK CARET DOT SUB_START SUB_END

/*These grammar rules return an ASTNode* stored in the node field of the union*/
%type <node> mystart System Definition RootRegex rrg Seq Regex Term Alt Repeat Substitute;


/* These will define the precedence and associativity of operators used*/
%left AND NOT
%left OR
%left STAR PLUS QUESTION

/*will handle multiple lines in a file*/
%start mystart
%%

mystart: System {
        $$ = $1;
        rootAST = $1;
    }
    | mystart System {
        $$ = $2;
        rootAST = createNode("Myregex", NULL, rootAST, $2);
    }
    | error {
        yyerrok;
        return 1;
    }
    ;
/* The number along with the dollor size represents positions of the nodes eg SLASH RootRegex SLASH can be
marked as SLASH (&1) RootRegex (&2) SLASH (&3) */
System:
    SLASH RootRegex SLASH       { $$ = createNode("System", NULL, $2, NULL); }
    | Definition System         { $$ = createNode("System", NULL, $1, $2); }
    ;

/* First pass happens here while bison is parsing */
Definition: CONST ID EQUALS SLASH Alt SLASH {
        if (!insertSymbol($2, &symbolTable)) {
            free($2);                          
            freeAST($5);                       
            freeAST(rootAST);                  
            rootAST = NULL;
            freeSymbolTable(&symbolTable);     
            YYERROR;
        }
        $$ = createNode("Definition", $2, $5, NULL);
        free($2);                              
    }
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

Term: LITERAL {
        $$ = createNode("Literal", $1, NULL, NULL);
        free($1);         /*free the memeory occupied by the nodes or values*/                     
    }
    | RANGE {
        $$ = createNode("Range", $1, NULL, NULL);
        free($1);                              
    }
    | WILD {
        $$ = createNode("Wild", $1, NULL, NULL);
        free($1);                              
    }
    | Substitute { $$ = $1; }
    ;

Substitute: SUB_START ID SUB_END {
        $$ = createNode("Substitute", $2, NULL, NULL);
        free($2);                             
    }
    ;

%%

void yyerror(const char *s) {
    fprintf(stderr, "rejects\n");
    freeAST(rootAST);                          
    rootAST = NULL;
    freeSymbolTable(&symbolTable);             
    if (yyin) fclose(yyin);                    
    exit(1);
}


int validateSubstitutions(ASTNode *node) {
    if (node == NULL) return 1;

    if (strcmp(node->type, "Substitute") == 0) {
        if (!checkSymbol(node->value, symbolTable)) {
            fprintf(stderr, "Error: '%s' is not defined in symbol table\n", node->value);
            return 0;
        }
    }

    if (!validateSubstitutions(node->left))  return 0;
    if (!validateSubstitutions(node->right)) return 0;

    return 1;
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
        fclose(f);
        yyin = NULL;

        /*Second pass happens here and will validate substitutions after full parse */

        if (!validateSubstitutions(rootAST)) {
            fprintf(stderr, "rejects\n");
            freeAST(rootAST);
            rootAST = NULL;
            freeSymbolTable(&symbolTable);
            exit(1);
        }

        printAST(rootAST, 0);
        printSymbolTable(symbolTable);
        freeAST(rootAST);
        rootAST = NULL;
        freeSymbolTable(&symbolTable);
        printf("accepts\n");
        exit(0);
    } else {
           exit(1);
    }
    return 0;
}