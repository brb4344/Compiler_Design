# Compiler_Design
This is an assignment of Subject Compiler Design CS541-001.
In this part of the assignment we will extend the regex compiler with an AST and semantic checker.
The interface will be the same as for the lexer/parser but we will expect the compiler to now:
* Ensure that all names are bound -- specifically the ${ID} expansions must match a declaration const ID = ...;
* In the string and range expressions we must ensure that the %x...; escapes are well formed and valid (less that unicode max codepoint)
If not already done we also need to build an AST so that we are ready for interpreting the regex operations in part #3.

As before for grading purposes your main application will simply:
1. Take a single file argument from the command line
2. Read in this file
3. Output "accepts" and exits(0) if the file contains a syntactically (and semantically) valid regular expression and outputs any errors and exits(1) otherwise. 
The project should provide a Makefile at the top-level of the directory that when run by default produces an executable (also at the top-level) called "parse".

---

# 📜 Regex Lexer & Parser
A robust lexical analyzer and syntax parser designed for a custom Regular Expression grammar. This project is built using Flex and Bison and is optimized for Ubuntu 24.04.

The lexer is responsible for tokenizing and validating the content inside tokens. For LITERAL tokens, it ensures quotes are balanced, " and % are properly escaped, and any %x...; escape has only digits 0-9, a closing semicolon, and a codepoint strictly less than the unicode maximum. For RANGE tokens, it additionally ensures ^ only appears at the start, and that any start-end pair has start codepoint less than or equal to end codepoint. Any character that does not match any rule hits the catch-all and is rejected immediately. Whitespace and line comments starting with // are silently discarded.

In Parser, I have implemented two pass compiler for the compilation. The first pass runs during yyparse(). The lexer validates escapes and ranges immediately. The parser builds the AST and inserts every const name into the symbol table. 
Substitution nodes ${X} are just stored in the AST without checking yet. During second pass Pass 2 runs after yyparse() completes. It walks the entire AST and checks every ${X} node against the symbol table. If any name is not found, it rejects. 

---
# 🌲 Abstract Tree & Sumbol Table
The AST is a binary tree where every node has a type, an optional value, and left and right children. The parser builds it bottom-up as grammar rules are reduced — leaf nodes like Literal, Range, and Wild store their string value, while internal nodes like Seq, OR, AND, STAR, and Substitute connect their children. The root is stored in rootAST and represents the entire parsed program. After Pass 2 validates all substitutions, the tree is printed with printAST and then freed with freeAST which recursively walks and frees every node.

The symbol table is a linked list that tracks all const identifier names defined in the file. When the parser sees const X = /.../ , it calls insertSymbol to register the name. If the same name is inserted twice it is rejected as a duplicate. After the full parse completes, checkSymbol is used in Pass 2 to verify every ${X} substitution has a matching definition. The table persists across multiple Systems in the same file so forward references work correctly, and is freed once in main after everything is done.

---


## 📘 Project Overview
This project is part of a compiler design course focused on implementing a simple regular-expression compiler. This phase includes the implementation of a lexer, parser, and parse-tree data structure.

* **Target Platform**: Ubuntu 24.04.
* **Tools**: Flex (Lexical Analyzer) and Bison (Parser Generator).
* **Standard Behavior**: 
    * Takes a single file argument from the command line.
    * Outputs `accepts` and exits with code 0 if the file contains a syntactically valid regular expression.
    * Outputs errors and exits with code 1 otherwise.

---

## 📂 Project Structure
As shown in the workspace, the project is organized as follows:

* **`lexer/`**: Contains `lexar.l`, the Flex source file for tokenization.
* **`parser/`**: Contains `parse.y`, the Bison grammar rules and logic.
* **`txts/`**: A collection of sample regex files for testing.
* **`Makefile`**: Build automation script located at the top-level directory.
* **`parse`**: The final executable generated at the top-level.

---
## 🛠️ Requirements
To build and run this project on Ubuntu 24.04, ensure you have the following tools installed:
```bash
sudo apt update
sudo apt install flex bison build-essential
```
---
## 🚀 Getting Started
### 1. Compilation
Run the Makefile at the top-level directory to produce the parse executable:

```bash
make
```
### 2. Running the Parser
The application takes a single file argument from the command line. It outputs accepts and exits with code 0 if the file contains a syntactically valid regular expression; otherwise, it outputs errors and exits with code 1.

To run the single test file
```bash
./parse test.txt
```
To run test files under folder test:
```bash
./ test.sh
```
### Cleaning Up (Needed when remove old parse and want to make new parse)
To remove generated C files and the executable for a fresh build:
```bash
make clean
```
---
## 📐 Regex Grammar Specification
The parser validates input based on the following formal grammar:

```text
System     := Definition* '/' RootRegex '/'
Definition := 'const' ID '=' '/' Regex '/'
RootRegex  := RootRegex '&' RootRegex | '!' Regex | Regex
Regex      := Seq | Alt | Repeat | Term | '(' Regex ')'
Seq        := Regex+
Alt        := Regex '|' Regex
Repeat     := Regex'*' | Regex'+' | Regex'?'
Term       := Literal | Range | Wild | Substitute
Literal    := '"' escaped unicode '"' 
Range      := '[' '^'? unicode char ranges ']'
Wild       := '.'
Substitute := '${' ID '}'
ID         := [a-zA-Z0-9_]+
```
---

### 🔑 Key Technical Notes

* **Escaping**: The `"` and `%` characters must be escaped using the format `%x[0-9]+;` (for example, `%x34;` for a double quote).
* **Comments**: Line comments are supported; they begin with `//` and continue until the end of the line, at which point they are discarded by the lexer.
* **Precedence**:
    * **Repeat operators** (`*`, `+`, `?`) hold the highest precedence.
    * **Sequencing** (concatenation) has higher precedence than alternation.
    * **Alternation** (`|`) has the lowest precedence among the standard regex operators.
---