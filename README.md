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
# 📜 Regex Lexer & Parser
A robust lexical analyzer and syntax parser designed for a custom Regular Expression grammar. This project is built using Flex and Bison and is optimized for Ubuntu 24.04.
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

```bash
./parse test.txt
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