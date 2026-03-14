#ifndef SYMBOL_H
#define SYMBOL_H

#include <stdio.h>
#include <stdlib.h>
#include <string.h>

//Define the symbol structure for the symbol table and each symbol has name and a pointer to the next symbol in the table (linked list)
typedef struct Symbol {
    char          *name;   
    struct Symbol *next;    
} Symbol;

// Forward declaration for initial pass of checkSymbol function
int checkSymbol(char *name, Symbol *symbolTable);

// I will insert a symbol into the symbol table & will return 1 if successful, 0 if the symbol already exists or if an error occurs
int insertSymbol(char *name, Symbol **symbolTable) {
    if (!name || !symbolTable) {
        fprintf(stderr, "Error: NULL argument passed to insertSymbol\n");
        return 0;
    }
    if (checkSymbol(name, *symbolTable)) {
        fprintf(stderr, "Error: '%s' is already defined\n", name);
        return 0;
    }
    Symbol *newSymbol = (Symbol *)malloc(sizeof(Symbol));
    if (!newSymbol) {
        fprintf(stderr, "Error: Memory allocation failed for '%s'\n", name);
        return 0;
    }
    newSymbol->name = strdup(name);
    if (!newSymbol->name) {
        fprintf(stderr, "Error: strdup failed for '%s'\n", name);
        free(newSymbol);
        return 0;
    }
    newSymbol->next = *symbolTable;
    *symbolTable    = newSymbol;
    return 1;
}

// This function checks if a symbol with the given name exists in the symbol table. It returns 1 if the symbol is found, and 0 if it is not found or if an error occurs (e.g., NULL name).
int checkSymbol(char *name, Symbol *symbolTable) {
    if (!name) {
        fprintf(stderr, "Error: NULL name passed to checkSymbol\n");
        return 0;
    }
    Symbol *current = symbolTable;
    while (current) {
        if (strcmp(current->name, name) == 0)
            return 1;
        current = current->next;
    }
    return 0;
}

// This function prints the contents of the symbol table in a formatted manner. It displays each symbol's identifier and the total number of symbols in the table. If the table is empty, it indicates that as well.
void printSymbolTable(Symbol *table) {
    printf("\nSymbol Table:\n");    
    printf("ID names \n");
    
    if (table == NULL) {
        printf("%s \n", "(empty)");         
        printf("Total: 0 symbol(s)\n");
    } else {
        int index = 1;
        Symbol *current = table;
        while (current) {
            printf(" %2d. %s \n", index++, current->name);
            current = current->next;
        }       
        printf("Total: %d symbol(s)\n", index - 1);
    }
}

// This function frees all memory allocated for the symbol table, including each symbol's name and the symbol structures themselves. It takes a pointer to the symbol table pointer, allowing it to set the original pointer to NULL after freeing the memory to prevent dangling pointers.
void freeSymbolTable(Symbol **table) {
    if (!table || !*table) return;
    Symbol *current = *table;
    while (current) {
        Symbol *next = current->next;
        if (current->name) {
            free(current->name);
            current->name = NULL;
        }
        free(current);
        current = next;
    }
    *table = NULL;
}

#endif 