/* A node structure is defined here. A node has its name, may have value: for leaf nodes only, children either to left or right*/
typedef struct ASTNode {
    char *type; 
    char *value; 
    struct ASTNode *left; 
    struct ASTNode *right; 

} ASTNode;

/*Function to create an AST node. It will take the tree paramaters as an arguments. Then allocate the size for the node, allocate value and will point to new nodes*/

ASTNode* createNode(char *type, char *value, ASTNode *left, ASTNode *right) {
    ASTNode *node = (ASTNode *)malloc(sizeof(ASTNode)); 
    node->type = strdup(type); 
    node->value = value ? strdup(value): NULL;
    node->left = left; 
    node->right = right; 
    return node;
}

/*This printAST is Recursive function that print AST in a tree format as hierarchy visualization. The left and right children are printed in recursive manner and finally all memory will be free*/ 
void printAST(ASTNode *node, int depth) {
    if (node == NULL)
        return;
        
    for (int i = 0; i < depth; i++)
        printf("  ");

    printf("|-%s", node->type);
    if (node->value)
        printf(" -%s", node->value);
    printf("\n");

    
    printAST(node->left, depth + 1);
    printAST(node->right, depth + 1);
}

void freeAST(ASTNode *node) {
    if (node == NULL)
        return;
   
    freeAST(node->left); 
    freeAST(node->right); 

    if(node->type != NULL){ 
        free(node->type);
        node->type=NULL;
    }
    if(node->value != NULL){ 
        free(node->value);
        node->value=NULL;
    }
    free(node); 
    node=NULL; 
}