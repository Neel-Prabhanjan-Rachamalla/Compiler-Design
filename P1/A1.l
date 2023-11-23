/*          Flex file for Macrojava-Minijava Compiler   -   "A1.l"      */

%{
    #include <unistd.h>

    //Function to create a node and filling its value and then returning it as a linked list.
    void create(char* value)
    {
        struct Node* node=(struct Node*) malloc(sizeof(struct Node));
        node->val=strdup(yytext);
        node->next=NULL; 

        struct List* l=(struct List*) malloc(sizeof(struct List)); 
        l->head=node; 
        l->tail=node; 

        yylval.list=l;
    }

%}

/*Regular expressions for some tokens.*/
DIGIT [0-9]
INTEGER {DIGIT}+
IDENTIFIER [a-zA-Z_][a-zA-Z0-9_]*

%%

[ \t\n\r]               { }     // Ignore white spaces.
"//".*                  { }     // Ignore single line comments.
"/*"[^*]*|[*]*"*/"      { }     // Ignore multi-line comments.

"class"                 { create(strdup(yytext)); return CLASS; }       
"public"                { create(strdup(yytext)); return PUBLIC; }
"static"                { create(strdup(yytext)); return STATIC; }
"void"                  { create(strdup(yytext)); return VOID; }
"main"                  { create(strdup(yytext)); return MAIN; }
"String"                { create(strdup(yytext)); return STRING; }
"System.out.println"    { create(strdup(yytext)); return PRINT; }
"extends"               { create(strdup(yytext)); return EXTENDS; }
"return"                { create(strdup(yytext)); return RETURN; }
"int"                   { create(strdup(yytext)); return INT; }
"int[]"                 { create(strdup(yytext)); return INTS; }
"boolean"               { create(strdup(yytext)); return BOOL; }
"if"                    { create(strdup(yytext)); return IF; }
"else"                  { create(strdup(yytext)); return ELSE; }
"while"                 { create(strdup(yytext)); return WHILE; }
"length"                { create(strdup(yytext)); return LENGTH; }
"true"                  { create(strdup(yytext)); return TRUE; }
"false"                 { create(strdup(yytext)); return FALSE; }
"this"                  { create(strdup(yytext)); return THIS; }
"new"                   { create(strdup(yytext)); return NEW; }
"#defineStmt"           { create(strdup(yytext)); return DFS; }
"#defineStmt0"          { create(strdup(yytext)); return DFS0; }
"#defineStmt1"          { create(strdup(yytext)); return DFS1; }
"#defineStmt2"          { create(strdup(yytext)); return DFS2; }
"#defineExpr"           { create(strdup(yytext)); return DFE; }
"#defineExpr0"          { create(strdup(yytext)); return DFE0; }
"#defineExpr1"          { create(strdup(yytext)); return DFE1; }
"#defineExpr2"          { create(strdup(yytext)); return DFE2; }

"("     { create(strdup(yytext)); return OB; }
")"     { create(strdup(yytext)); return CB; }
"["     { create(strdup(yytext)); return SOB; }
"]"     { create(strdup(yytext)); return SCB; }
"{"     { create(strdup(yytext)); return COB; }
"}"     { create(strdup(yytext)); return CCB; }
"="     { create(strdup(yytext)); return EQ; }
"+"     { create(strdup(yytext)); return ADD; }
"-"     { create(strdup(yytext)); return SUB; }
"*"     { create(strdup(yytext)); return MUL; }
"/"     { create(strdup(yytext)); return DIV; }
";"     { create(strdup(yytext)); return SEMICOL; }
","     { create(strdup(yytext)); return COMMA; }
"."     { create(strdup(yytext)); return DOT; }
"!"     { create(strdup(yytext)); return EXCL; }
"?"     { create(strdup(yytext)); return QUES; }
"&&"    { create(strdup(yytext)); return AND; }
"||"    { create(strdup(yytext)); return OR; }
"!="    { create(strdup(yytext)); return NEQ; }
"<="    { create(strdup(yytext)); return LEQ; }

{INTEGER}       { create(strdup(yytext)); return INTEGER; }
{IDENTIFIER}    { create(strdup(yytext)); return ID; }

.       { printf("Failed to parse the code.\n"); exit(1); }     // If anything out of these tokens appears then output error message.
