# Compiler_Design
This is an assignment of Subject Compiler Design CS541-001 (University of Kentucky)
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
## 🧪 Examples

### ✅ Valid Regular Expressions
These patterns follow the formal grammar and will result in an `accepts` output:

| Category | Example |
| :--- | :--- |
| **Simple Literal** | `/"this is a literal"/` |
| **Unicode & Repeat** | `/"unicode literal" "🌶"*/` |
| **Escaped Hex** | `/"%x7;%x0;"/` |
| **Character Class** | `/"h"[aeiou]+/` |
| **Grouping & Alt** | `/[+-]? ("0" \| [1-9][0-9]+)/` |
| **Substitution** | `/[+-]? ("0" \| ${NonZeroDigit}${Digit}+)/` |
| **Boolean & Wild** | `/${Filename} & .+ ".txt"/` |
| **Definition** | `const s_re = /[a-z]/` |



### ❌ Invalid Expressions
These patterns will trigger a syntax error and exit with status 1:

| Example | Reason for Failure |
| :--- | :--- |
| `/"abc/` | Missing close quote |
| `/abc/` | Literals must be enclosed in double quotes |
| `/("ok) )/` | Unbalanced parentheses |
| `/[abc]^/` | Unexpected `^` character |
| `/!("abc" & [a-z])/` | Cannot nest `&` inside `!` (Boolean constraint) |
