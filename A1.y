/*          Bison file for Macrojava-Minijava Compiler     -      "A1.y"        */

%{
    #include <stdio.h>
    #include <stdlib.h>
    #include <string.h>

    void yyerror(const char*);
    int yylex(void);

    //Node of the linked list.
    struct Node
    {
        char* val;
        struct Node* next;
    };

    //Linked list.
    struct List
    {
        struct Node* head;
        struct Node* tail;
    };

    //Macro structure.
    struct macro
    {
        struct List* id;
        struct List* replace;
        struct List* args;
        int narg;
        int type;

        struct macro* next;
    };

    //Linked list for macros.
    struct macro* h=NULL;
    struct macro* t=NULL;

    //Function to count the number of arguments of arguments linked list.
    int countargs(struct List* arg)
    {
        struct Node* node=arg->head;
        if(node==NULL) return 0;
        int count=0;

        while(node!=NULL)
        {
            if(strcmp(node->val,",")==0) count++; 
            node=node->next;
        }

        return count+1;
    }

    //Function to add macros.
    void addmacro(struct List* iden , struct List* arg , struct List* rep , int ty)
    {
        struct macro* newmacro=(struct macro*) malloc(sizeof(struct macro));
        newmacro->id=iden;
        newmacro->replace=rep;
        newmacro->args=arg;
        newmacro->narg=countargs(arg);
        newmacro->type=ty;
        newmacro->next=NULL;

        if(h==NULL)
        {
            h=newmacro;
            t=newmacro;
        }
        else
        {
            t->next=newmacro;
            t=newmacro;
        }

        return;
    }

    //Function to check whether a macro is present in the list or not.
    int check(struct List* iden , struct List* expr)
    {
        int earg=countargs(expr);
        struct macro* ptr=h;

        while(ptr!=NULL)
        { 
            struct Node* ptr2=ptr->id->head;

            //Checking the match of the given identifier and the identifier in the macro.
            if(strcmp(ptr2->val,iden->head->val)==0)
            {
                //Checking for the match of the number of arguments.
                if(ptr->narg==earg)
                {
                    return 1;
                }
            }

            if(ptr==t) break;
            ptr=ptr->next;
        }

        return 0;
    }

    //Function to create a replica of the given expression.
    struct List* newexpr(struct Node* node , struct List* expr)
    {
        
        struct Node* prev=NULL;
        struct List* l=(struct List*) malloc(sizeof(struct List));

        //Creating node-by-node.
        while(node!=NULL)
        {
            struct Node* new=(struct Node*) malloc(sizeof(struct Node));
            new->val=node->val;
            new->next=NULL;

            if(prev==NULL) l->head=new;
            if(node==expr->tail || strcmp(node->next->val,",")==0) l->tail=new;

            if(prev!=NULL) prev->next=new;
            prev=new;

            if(node==expr->tail || strcmp(node->next->val,",")==0) break;
            node=node->next;
        }
        
        return l;
    }

    //Function to find and replace the given node if it matches with the macro identifier.
    struct List* findandreplace(struct List* args , struct Node* node , struct List* expr)
    {
        struct Node* ptr1=args->head;
        int com=0,f=0;

        //Finding the number of commas before an argument is found.
        while(ptr1!=NULL)
        {
            if(strcmp(ptr1->val,",")==0) com++;
            else if(strcmp(ptr1->val,node->val)==0)
            {
                f=1;
                break;
            }

            if(ptr1==args->tail) break;
            ptr1=ptr1->next;
        }
        
        if(f==0) return NULL;

        
        struct Node* ptr2=expr->head;
        
        //Traversing through the expression list till the same number of commas have been visited.
        while(com>0)
        {
            
            if(strcmp(ptr2->val,",")==0) com--;
            
            ptr2=ptr2->next;
        }

        struct List* nexpr=newexpr(ptr2,expr);

        return nexpr;
    }

    //Function to create a replica of the given replacement list.
    struct List* newrep(struct List* args , struct List* rep , struct List* expr)
    {
        struct Node* node=rep->head;
        struct Node* prev=NULL;
        struct List* l=(struct List*) malloc(sizeof(struct List));

        while(node!=NULL)
        {
            struct List* l1=(struct List*) malloc(sizeof(struct List));
            
            l1=findandreplace(args,node,expr);
            
            if(l1!=NULL)
            {
                
                if(node==rep->head)
                {
                    l->head=l1->head;
                }
                
                if(node==rep->tail) l->tail=l1->tail;
                
                if(prev!=NULL) prev->next=l1->head;
                prev=l1->tail;
            }
            else
            {
                
                struct Node* new=(struct Node*) malloc(sizeof(struct Node));
                new->val=node->val;
                new->next=NULL;
                
                if(node==rep->head) l->head=new;
                if(node==rep->tail) l->tail=new;
                
                if(prev!=NULL) prev->next=new;
                prev=new;
            }

            if(node==rep->tail) break;
            node=node->next;
        }

        return l;
    }

    //Function to replace the macros.
    struct List* replace(struct List* iden , struct List* expr)
    {
        int earg=countargs(expr);
        struct macro* ptr=h;
        struct List* rep;
        struct List* l;

        while(ptr!=NULL)
        { 
            struct Node* ptr2=ptr->id->head;
            if(strcmp(ptr2->val,iden->head->val)==0)
            {
                if(ptr->narg==earg)
                {
                    if(earg!=0) rep=newrep(ptr->args,ptr->replace,expr);
                    else rep=ptr->replace;

                    break;
                }
            }

            ptr=ptr->next;
        }

        return rep;
    }
%}

//yylval is of type struct List*.
%union
{
    struct List* list;
}

//Declaring the terminals(tokens).
%token <list> CLASS PUBLIC STATIC MAIN VOID STRING PRINT EXTENDS RETURN INT INTS BOOL IF ELSE WHILE LENGTH TRUE FALSE THIS NEW OB CB SOB SCB COB CCB EQ ADD SUB MUL DIV SEMICOL COMMA QUES EXCL DOT AND OR NEQ LEQ DFS DFS0 DFS1 DFS2 DFE DFE0 DFE1 DFE2 ID INTEGER

//Declaring the non-terminals.
%type <list> Goal
%type <list> MacroDefinitions
%type <list> MacroDefinition
%type <list> MainClass
%type <list> TypeDeclarations
%type <list> TypeDeclaration
%type <list> TypeIdentifierSCs
%type <list> TypeIdentifierSC
%type <list> Identifier
%type <list> Expression
%type <list> Type
%type <list> MethodDeclarations
%type <list> MethodDeclaration
%type <list> CTypeIdentifiers
%type <list> CTypeIdentifier
%type <list> Statements
%type <list> Statement
%type <list> PrimaryExpression
%type <list> CExpressions
%type <list> CExpression
%type <list> MacroDefExpression
%type <list> MacroDefStatement
%type <list> CIdentifiers
%type <list> CIdentifier

%%

//Grammar Productions.

Goal: MacroDefinitions MainClass TypeDeclarations       {
                                                            //Linked the linked lists on right side and forming another linked list $$.
                                                            $2->tail->next=$3->head;
                                                            $$=(struct List*) malloc(sizeof(struct List));
                                                            $$->head=$2->head; $$->tail=$3->tail;

                                                            //Priting the final program(linked list).
                                                            struct Node* ptr=$$->head;
                                                            while(ptr!=NULL)
                                                            {
                                                                if(strcmp(ptr->val,"}")==0) printf("\n\t");
                                                                if(strcmp(ptr->val,"{")==0) printf("\n\t");
                                                                printf("%s ",ptr->val);
                                                                if(strcmp(ptr->val,"}")==0) printf("\n\t\t");
                                                                if(strcmp(ptr->val,"{")==0) printf("\n\t\t");
                                                                
                                                                ptr=ptr->next;
                                                            }
                                                            printf("\n");
                                                        }
;

MacroDefinitions: MacroDefinitions MacroDefinition      {
                                                            //Linked the linked lists on right side and forming another linked list $$.
                                                            $1->tail->next=$2->head;
                                                            $$=(struct List*) malloc(sizeof(struct List));
                                                            $$->head=$1->head; $$->tail=$2->tail;
                                                        }
                        |       {
                                    //Linked the linked lists on right side and forming another linked list $$.
                                    struct Node* ptr=(struct Node*) malloc(sizeof(struct Node)); ptr->val=""; ptr->next=NULL;
                                    $$=(struct List*) malloc(sizeof(struct List));
                                    $$->head=ptr; $$->tail=ptr;
                                }
;

TypeDeclarations: TypeDeclaration TypeDeclarations      {
                                                            //Linked the linked lists on right side and forming another linked list $$.
                                                            $1->tail->next=$2->head;
                                                            $$=(struct List*) malloc(sizeof(struct List));
                                                            $$->head=$1->head; $$->tail=$2->tail;
                                                        }
                        |       {
                                    //Linked the linked lists on right side and forming another linked list $$.
                                    struct Node* ptr=(struct Node*) malloc(sizeof(struct Node)); ptr->val=""; ptr->next=NULL;
                                    $$=(struct List*) malloc(sizeof(struct List));
                                    $$->head=ptr; $$->tail=ptr;
                                }
;

MainClass: CLASS Identifier COB PUBLIC STATIC VOID MAIN OB STRING SOB SCB Identifier CB COB PRINT OB Expression CB SEMICOL CCB CCB      {
                                                                                                                                            //Linked the linked lists on right side and forming another linked list $$.
                                                                                                                                            $1->tail->next=$2->head; $2->tail->next=$3->head; $3->tail->next=$4->head; $4->tail->next=$5->head; $5->tail->next=$6->head; $6->tail->next=$7->head; $7->tail->next=$8->head; $8->tail->next=$9->head; $9->tail->next=$10->head; $10->tail->next=$11->head; $11->tail->next=$12->head; $12->tail->next=$13->head; $13->tail->next=$14->head; $14->tail->next=$15->head; $15->tail->next=$16->head; $16->tail->next=$17->head; $17->tail->next=$18->head; $18->tail->next=$19->head; $19->tail->next=$20->head; $20->tail->next=$21->head; 
                                                                                                                                            $$=(struct List*) malloc(sizeof(struct List));
                                                                                                                                            $$->head=$1->head; $$->tail=$21->tail;
                                                                                                                                        }
;

TypeDeclaration: CLASS Identifier COB TypeIdentifierSCs MethodDeclarations CCB          {
                                                                                            //Linked the linked lists on right side and forming another linked list $$.
                                                                                            $1->tail->next=$2->head; $2->tail->next=$3->head; $3->tail->next=$4->head; $4->tail->next=$5->head; $5->tail->next=$6->head; 
                                                                                            $$=(struct List*) malloc(sizeof(struct List));
                                                                                            $$->head=$1->head; $$->tail=$6->tail;
                                                                                        }
                        | CLASS Identifier EXTENDS Identifier COB TypeIdentifierSCs MethodDeclarations CCB          {
                                                                                                                        //Linked the linked lists on right side and forming another linked list $$.
                                                                                                                        $1->tail->next=$2->head; $2->tail->next=$3->head; $3->tail->next=$4->head; $4->tail->next=$5->head; $5->tail->next=$6->head; $6->tail->next=$7->head; $7->tail->next=$8->head; 
                                                                                                                        $$=(struct List*) malloc(sizeof(struct List));
                                                                                                                        $$->head=$1->head; $$->tail=$8->tail;
                                                                                                                    }

TypeIdentifierSCs: TypeIdentifierSCs TypeIdentifierSC       {
                                                                //Linked the linked lists on right side and forming another linked list $$.
                                                                $1->tail->next=$2->head;
                                                                $$=(struct List*) malloc(sizeof(struct List));
                                                                $$->head=$1->head; $$->tail=$2->tail;
                                                            }
                        |       {
                                    //Linked the linked lists on right side and forming another linked list $$.
                                    struct Node* ptr=(struct Node*) malloc(sizeof(struct Node)); ptr->val=""; ptr->next=NULL;
                                    $$=(struct List*) malloc(sizeof(struct List));
                                    $$->head=ptr; $$->tail=ptr;
                                }
;

TypeIdentifierSC: Type Identifier SEMICOL       {
                                                    //Linked the linked lists on right side and forming another linked list $$.
                                                    $1->tail->next=$2->head; $2->tail->next=$3->head;
                                                    $$=(struct List*) malloc(sizeof(struct List));
                                                    $$->head=$1->head; $$->tail=$3->tail;
                                                }
;

MethodDeclarations: MethodDeclaration MethodDeclarations        {
                                                                    //Linked the linked lists on right side and forming another linked list $$.
                                                                    $1->tail->next=$2->head;
                                                                    $$=(struct List*) malloc(sizeof(struct List));
                                                                    $$->head=$1->head; $$->tail=$2->tail;
                                                                }
                        |       {
                                    //Linked the linked lists on right side and forming another linked list $$.
                                    struct Node* ptr=(struct Node*) malloc(sizeof(struct Node)); ptr->val=""; ptr->next=NULL;
                                    $$=(struct List*) malloc(sizeof(struct List));
                                    $$->head=ptr; $$->tail=ptr;
                                }
;

MethodDeclaration: PUBLIC Type Identifier OB CB COB TypeIdentifierSCs Statements RETURN Expression SEMICOL CCB          {
                                                                                                                            //Linked the linked lists on right side and forming another linked list $$.
                                                                                                                            $1->tail->next=$2->head; $2->tail->next=$3->head; $3->tail->next=$4->head; $4->tail->next=$5->head; $5->tail->next=$6->head; $6->tail->next=$7->head; $7->tail->next=$8->head; $8->tail->next=$9->head; $9->tail->next=$10->head; $10->tail->next=$11->head; $11->tail->next=$12->head; 
                                                                                                                            $$=(struct List*) malloc(sizeof(struct List));
                                                                                                                            $$->head=$1->head; $$->tail=$12->tail;
                                                                                                                        }
                        | PUBLIC Type Identifier OB Type Identifier CTypeIdentifiers CB COB TypeIdentifierSCs Statements RETURN Expression SEMICOL CCB          {
                                                                                                                                                                    //Linked the linked lists on right side and forming another linked list $$.
                                                                                                                                                                    $1->tail->next=$2->head; $2->tail->next=$3->head; $3->tail->next=$4->head; $4->tail->next=$5->head; $5->tail->next=$6->head; $6->tail->next=$7->head; $7->tail->next=$8->head; $8->tail->next=$9->head; $9->tail->next=$10->head; $10->tail->next=$11->head; $11->tail->next=$12->head; $12->tail->next=$13->head; $13->tail->next=$14->head; $14->tail->next=$15->head; 
                                                                                                                                                                    $$=(struct List*) malloc(sizeof(struct List));
                                                                                                                                                                    $$->head=$1->head; $$->tail=$15->tail;
                                                                                                                                                                }
;

CTypeIdentifiers: CTypeIdentifiers CTypeIdentifier      {
                                                            //Linked the linked lists on right side and forming another linked list $$.
                                                            $1->tail->next=$2->head;
                                                            $$=(struct List*) malloc(sizeof(struct List));
                                                            $$->head=$1->head; $$->tail=$2->tail;
                                                        }
                        |       {
                                    //Linked the linked lists on right side and forming another linked list $$.
                                    struct Node* ptr=(struct Node*) malloc(sizeof(struct Node)); ptr->val=""; ptr->next=NULL;
                                    $$=(struct List*) malloc(sizeof(struct List));
                                    $$->head=ptr; $$->tail=ptr;
                                }
;

CTypeIdentifier: COMMA Type Identifier      {
                                                //Linked the linked lists on right side and forming another linked list $$.
                                                $1->tail->next=$2->head; $2->tail->next=$3->head;
                                                $$=(struct List*) malloc(sizeof(struct List));
                                                $$->head=$1->head; $$->tail=$3->tail;
                                            }
;

Statements: Statement Statements        {
                                            //Linked the linked lists on right side and forming another linked list $$.
                                            $1->tail->next=$2->head;
                                            $$=(struct List*) malloc(sizeof(struct List));
                                            $$->head=$1->head; $$->tail=$2->tail;
                                        }
                |               {
                                    //Linked the linked lists on right side and forming another linked list $$.
                                    struct Node* ptr=(struct Node*) malloc(sizeof(struct Node)); ptr->val=""; ptr->next=NULL;
                                    $$=(struct List*) malloc(sizeof(struct List));
                                    $$->head=ptr; $$->tail=ptr;
                                }
;

Type: INTS              {
                            $$->head=$1->head; $$->tail=$1->tail;
                        }
        | BOOL          {
                            $$->head=$1->head; $$->tail=$1->tail;
                        }
        | INT           {
                            $$->head=$1->head; $$->tail=$1->tail;
                        }
        | Identifier    {
                            $$->head=$1->head; $$->tail=$1->tail;
                        }
;

Statement: COB Statements CCB       {
                                        //Linked the linked lists on right side and forming another linked list $$.
                                        $1->tail->next=$2->head; $2->tail->next=$3->head;
                                        $$=(struct List*) malloc(sizeof(struct List));
                                        $$->head=$1->head; $$->tail=$3->tail;
                                    }
                | PRINT OB Expression CB SEMICOL        {
                                                            //Linked the linked lists on right side and forming another linked list $$.
                                                            $1->tail->next=$2->head; $2->tail->next=$3->head; $3->tail->next=$4->head; $4->tail->next=$5->head; 
                                                            $$=(struct List*) malloc(sizeof(struct List));
                                                            $$->head=$1->head; $$->tail=$5->tail;
                                                        }
                | Identifier EQ Expression SEMICOL      {
                                                            //Linked the linked lists on right side and forming another linked list $$.
                                                            $1->tail->next=$2->head; $2->tail->next=$3->head; $3->tail->next=$4->head; 
                                                            $$=(struct List*) malloc(sizeof(struct List));
                                                            $$->head=$1->head; $$->tail=$4->tail;
                                                        }
                | Identifier SOB Expression SCB EQ Expression SEMICOL       {
                                                                                //Linked the linked lists on right side and forming another linked list $$.
                                                                                $1->tail->next=$2->head; $2->tail->next=$3->head; $3->tail->next=$4->head; $4->tail->next=$5->head; $5->tail->next=$6->head; $6->tail->next=$7->head; 
                                                                                $$=(struct List*) malloc(sizeof(struct List));
                                                                                $$->head=$1->head; $$->tail=$7->tail;
                                                                            }
                | IF OB Expression CB Statement         {
                                                            //Linked the linked lists on right side and forming another linked list $$.
                                                            $1->tail->next=$2->head; $2->tail->next=$3->head; $3->tail->next=$4->head; $4->tail->next=$5->head; 
                                                            $$=(struct List*) malloc(sizeof(struct List));
                                                            $$->head=$1->head; $$->tail=$5->tail;
                                                        }
                | IF OB Expression CB Statement ELSE Statement              {
                                                                                //Linked the linked lists on right side and forming another linked list $$.
                                                                                $1->tail->next=$2->head; $2->tail->next=$3->head; $3->tail->next=$4->head; $4->tail->next=$5->head; $5->tail->next=$6->head; $6->tail->next=$7->head; 
                                                                                $$=(struct List*) malloc(sizeof(struct List));
                                                                                $$->head=$1->head; $$->tail=$7->tail;
                                                                            }
                | WHILE OB Expression CB Statement      {
                                                            //Linked the linked lists on right side and forming another linked list $$.
                                                            $1->tail->next=$2->head; $2->tail->next=$3->head; $3->tail->next=$4->head; $4->tail->next=$5->head; 
                                                            $$=(struct List*) malloc(sizeof(struct List));
                                                            $$->head=$1->head; $$->tail=$5->tail;
                                                        }
                | Identifier OB CB SEMICOL              {
                                                            //Linked the linked lists on right side and forming another linked list $$.
                                                            $1->tail->next=$2->head; $2->tail->next=$3->head; $3->tail->next=$4->head;
                                                            $$=(struct List*) malloc(sizeof(struct List));
                                                            $$->head=$1->head; $$->tail=$4->tail;

                                                            struct List* l=(struct List*) malloc(sizeof(struct List));
                                                            l->head=NULL; l->tail=NULL;
                                                            if(check($1,l)) $$=replace($1,l);
                                                        }
                | Identifier OB Expression CExpressions CB SEMICOL      {
                                                                            //Linked the linked lists on right side and forming another linked list $$.
                                                                            $1->tail->next=$2->head; $2->tail->next=$3->head; $3->tail->next=$4->head; $4->tail->next=$5->head; $5->tail->next=$6->head; 
                                                                            $$=(struct List*) malloc(sizeof(struct List));
                                                                            $$->head=$1->head; $$->tail=$6->tail;

                                                                            struct List* l=(struct List*) malloc(sizeof(struct List));
                                                                            l->head=$3->head; l->tail=$4->tail;
                                                                            if(check($1,l)) $$=replace($1,l);
                                                                        }
;

CExpressions: CExpressions CExpression      {
                                                //Linked the linked lists on right side and forming another linked list $$.
                                                $1->tail->next=$2->head;
                                                $$=(struct List*) malloc(sizeof(struct List));
                                                $$->head=$1->head; $$->tail=$2->tail;
                                            }
                |               {
                                    struct Node* ptr=(struct Node*) malloc(sizeof(struct Node)); ptr->val=""; ptr->next=NULL;
                                    $$=(struct List*) malloc(sizeof(struct List));
                                    $$->head=ptr; $$->tail=ptr;
                                }
;

CExpression: COMMA Expression       {
                                        //Linked the linked lists on right side and forming another linked list $$.
                                        $1->tail->next=$2->head;
                                        $$=(struct List*) malloc(sizeof(struct List));
                                        $$->head=$1->head; $$->tail=$2->tail;
                                    }
;

Expression: PrimaryExpression AND PrimaryExpression         {
                                                                //Linked the linked lists on right side and forming another linked list $$.
                                                                $1->tail->next=$2->head; $2->tail->next=$3->head;
                                                                $$=(struct List*) malloc(sizeof(struct List));
                                                                $$->head=$1->head; $$->tail=$3->tail;
                                                            }
                | PrimaryExpression OR PrimaryExpression    {
                                                                //Linked the linked lists on right side and forming another linked list $$.
                                                                $1->tail->next=$2->head; $2->tail->next=$3->head;
                                                                $$=(struct List*) malloc(sizeof(struct List));
                                                                $$->head=$1->head; $$->tail=$3->tail;
                                                            }
                | PrimaryExpression NEQ PrimaryExpression   {
                                                                //Linked the linked lists on right side and forming another linked list $$.
                                                                $1->tail->next=$2->head; $2->tail->next=$3->head;
                                                                $$=(struct List*) malloc(sizeof(struct List));
                                                                $$->head=$1->head; $$->tail=$3->tail;
                                                            }
                | PrimaryExpression LEQ PrimaryExpression   {
                                                                //Linked the linked lists on right side and forming another linked list $$.
                                                                $1->tail->next=$2->head; $2->tail->next=$3->head;
                                                                $$=(struct List*) malloc(sizeof(struct List));
                                                                $$->head=$1->head; $$->tail=$3->tail;
                                                            }
                | PrimaryExpression ADD PrimaryExpression   {
                                                                //Linked the linked lists on right side and forming another linked list $$.
                                                                $1->tail->next=$2->head; $2->tail->next=$3->head;
                                                                $$=(struct List*) malloc(sizeof(struct List));
                                                                $$->head=$1->head; $$->tail=$3->tail;
                                                            }
                | PrimaryExpression SUB PrimaryExpression   {
                                                                //Linked the linked lists on right side and forming another linked list $$.
                                                                $1->tail->next=$2->head; $2->tail->next=$3->head;
                                                                $$=(struct List*) malloc(sizeof(struct List));
                                                                $$->head=$1->head; $$->tail=$3->tail;
                                                            }
                | PrimaryExpression MUL PrimaryExpression   {
                                                                //Linked the linked lists on right side and forming another linked list $$.
                                                                $1->tail->next=$2->head; $2->tail->next=$3->head;
                                                                $$=(struct List*) malloc(sizeof(struct List));
                                                                $$->head=$1->head; $$->tail=$3->tail;
                                                            }
                | PrimaryExpression DIV PrimaryExpression   {
                                                                //Linked the linked lists on right side and forming another linked list $$.
                                                                $1->tail->next=$2->head; $2->tail->next=$3->head;
                                                                $$=(struct List*) malloc(sizeof(struct List));
                                                                $$->head=$1->head; $$->tail=$3->tail;
                                                            }
                | PrimaryExpression SOB PrimaryExpression SCB       {
                                                                        //Linked the linked lists on right side and forming another linked list $$.
                                                                        $1->tail->next=$2->head; $2->tail->next=$3->head; $3->tail->next=$4->head; 
                                                                        $$=(struct List*) malloc(sizeof(struct List));
                                                                        $$->head=$1->head; $$->tail=$4->tail;
                                                                    }
                | PrimaryExpression DOT LENGTH              {
                                                                //Linked the linked lists on right side and forming another linked list $$.
                                                                $1->tail->next=$2->head; $2->tail->next=$3->head;
                                                                $$=(struct List*) malloc(sizeof(struct List));
                                                                $$->head=$1->head; $$->tail=$3->tail;
                                                            }
                | PrimaryExpression         {
                                                $$->head=$1->head; $$->tail=$1->tail;
                                            }
                | PrimaryExpression DOT Identifier OB CB    {
                                                                //Linked the linked lists on right side and forming another linked list $$.
                                                                $1->tail->next=$2->head; $2->tail->next=$3->head; $3->tail->next=$4->head; $4->tail->next=$5->head; 
                                                                $$=(struct List*) malloc(sizeof(struct List));
                                                                $$->head=$1->head; $$->tail=$5->tail;
                                                            }
                | PrimaryExpression DOT Identifier OB Expression CExpressions CB        {
                                                                                            //Linked the linked lists on right side and forming another linked list $$.
                                                                                            $1->tail->next=$2->head; $2->tail->next=$3->head; $3->tail->next=$4->head; $4->tail->next=$5->head; $5->tail->next=$6->head; $6->tail->next=$7->head; 
                                                                                            $$=(struct List*) malloc(sizeof(struct List));
                                                                                            $$->head=$1->head; $$->tail=$7->tail;
                                                                                        }
                | Identifier OB CB      {
                                            //Linked the linked lists on right side and forming another linked list $$.
                                            $1->tail->next=$2->head; $2->tail->next=$3->head;
                                            $$=(struct List*) malloc(sizeof(struct List));
                                            $$->head=$1->head; $$->tail=$3->tail;

                                            
                                            struct List* l=(struct List*) malloc(sizeof(struct List));
                                            l->head=NULL; l->tail=NULL;
                                            if(check($1,l)) $$=replace($1,l);
                                        }
                | Identifier OB Expression CExpressions CB  {
                                                                //Linked the linked lists on right side and forming another linked list $$.
                                                                $1->tail->next=$2->head; $2->tail->next=$3->head; $3->tail->next=$4->head; $4->tail->next=$5->head; 
                                                                $$=(struct List*) malloc(sizeof(struct List));
                                                                $$->head=$1->head; $$->tail=$5->tail;

                                                                struct List* l=(struct List*) malloc(sizeof(struct List));
                                                                l->head=$3->head; l->tail=$4->tail;
                                                                if(check($1,l)) $$=replace($1,l);
                                                            }
;

PrimaryExpression: INTEGER              {
                                            $$->head=$1->head; $$->tail=$1->tail;
                                        }
                        | TRUE          {
                                            $$->head=$1->head; $$->tail=$1->tail;
                                        }
                        | FALSE         {
                                            $$->head=$1->head; $$->tail=$1->tail;
                                        }
                        | Identifier    {
                                            $$->head=$1->head; $$->tail=$1->tail;
                                        }
                        | THIS          {
                                            $$->head=$1->head; $$->tail=$1->tail;
                                        }
                        | NEW INT SOB Expression SCB        {
                                                                //Linked the linked lists on right side and forming another linked list $$.
                                                                $1->tail->next=$2->head; $2->tail->next=$3->head; $3->tail->next=$4->head; $4->tail->next=$5->head; 
                                                                $$=(struct List*) malloc(sizeof(struct List));
                                                                $$->head=$1->head; $$->tail=$5->tail;
                                                            }
                        | NEW Identifier OB CB              {
                                                                //Linked the linked lists on right side and forming another linked list $$.
                                                                $1->tail->next=$2->head; $2->tail->next=$3->head; $3->tail->next=$4->head;
                                                                $$=(struct List*) malloc(sizeof(struct List));
                                                                $$->head=$1->head; $$->tail=$4->tail;
                                                            }
                        | EXCL Expression       {
                                                    //Linked the linked lists on right side and forming another linked list $$.
                                                    $1->tail->next=$2->head;
                                                    $$=(struct List*) malloc(sizeof(struct List));
                                                    $$->head=$1->head; $$->tail=$2->tail;
                                                }
                        | OB Expression CB      {
                                                    //Linked the linked lists on right side and forming another linked list $$.
                                                    $1->tail->next=$2->head; $2->tail->next=$3->head;
                                                    $$=(struct List*) malloc(sizeof(struct List));
                                                    $$->head=$1->head; $$->tail=$3->tail;
                                                }
;

MacroDefinition: MacroDefExpression             {
                                                    $$->head=$1->head; $$->tail=$1->tail;
                                                }
                    | MacroDefStatement         {
                                                    $$->head=$1->head; $$->tail=$1->tail;
                                                }
;

MacroDefStatement: DFS Identifier OB Identifier COMMA Identifier COMMA Identifier CIdentifiers CB COB Statements CCB        {
                                                                                                                                //Linked the linked lists on right side and forming another linked list $$.
                                                                                                                                $1->tail->next=$2->head; $2->tail->next=$3->head; $3->tail->next=$4->head; $4->tail->next=$5->head; $5->tail->next=$6->head; $6->tail->next=$7->head; $7->tail->next=$8->head; $8->tail->next=$9->head; $9->tail->next=$10->head; $10->tail->next=$11->head; $11->tail->next=$12->head;  $12->tail->next=$13->head;
                                                                                                                                $$=(struct List*) malloc(sizeof(struct List));
                                                                                                                                $$->head=$1->head; $$->tail=$13->tail;
                                                                                                                                
                                                                                                                                struct List* l=(struct List*) malloc(sizeof(struct List));
                                                                                                                                l->head=$4->head; l->tail=$9->tail;
                                                                                                                                addmacro($2,l,$12,0);
                                                                                                                            }
                        | DFS0 Identifier OB CB COB Statements CCB          {
                                                                                //Linked the linked lists on right side and forming another linked list $$.
                                                                                $1->tail->next=$2->head; $2->tail->next=$3->head; $3->tail->next=$4->head; $4->tail->next=$5->head; $5->tail->next=$6->head; $6->tail->next=$7->head; 
                                                                                $$=(struct List*) malloc(sizeof(struct List));
                                                                                $$->head=$1->head; $$->tail=$7->tail;

                                                                                struct List* l=(struct List*) malloc(sizeof(struct List));
                                                                                l->head=NULL; l->tail=NULL;
                                                                                addmacro($2,l,$6,0);
                                                                            }
                        | DFS1 Identifier OB Identifier CB COB Statements CCB       {
                                                                                        //Linked the linked lists on right side and forming another linked list $$.
                                                                                        $1->tail->next=$2->head; $2->tail->next=$3->head; $3->tail->next=$4->head; $4->tail->next=$5->head; $5->tail->next=$6->head; $6->tail->next=$7->head; $7->tail->next=$8->head; 
                                                                                        $$=(struct List*) malloc(sizeof(struct List));
                                                                                        $$->head=$1->head; $$->tail=$8->tail;

                                                                                        struct List* l=(struct List*) malloc(sizeof(struct List));
                                                                                        l->head=$4->head; l->tail=$4->tail;
                                                                                        addmacro($2,l,$7,0);
                                                                                    }
                        | DFS2 Identifier OB Identifier COMMA Identifier CB COB Statements CCB      {
                                                                                                        //Linked the linked lists on right side and forming another linked list $$.
                                                                                                        $1->tail->next=$2->head; $2->tail->next=$3->head; $3->tail->next=$4->head; $4->tail->next=$5->head; $5->tail->next=$6->head; $6->tail->next=$7->head; $7->tail->next=$8->head; $8->tail->next=$9->head; $9->tail->next=$10->head; 
                                                                                                        $$=(struct List*) malloc(sizeof(struct List));
                                                                                                        $$->head=$1->head; $$->tail=$10->tail;
                                                                                                        
                                                                                                        struct List* l=(struct List*) malloc(sizeof(struct List));
                                                                                                        l->head=$4->head; l->tail=$6->tail;
                                                                                                        addmacro($2,l,$9,0);
                                                                                                        
                                                                                                    }
;

MacroDefExpression: DFE Identifier OB Identifier COMMA Identifier COMMA Identifier CIdentifiers CB OB Expression CB     {
                                                                                                                            //Linked the linked lists on right side and forming another linked list $$.
                                                                                                                            $1->tail->next=$2->head; $2->tail->next=$3->head; $3->tail->next=$4->head; $4->tail->next=$5->head; $5->tail->next=$6->head; $6->tail->next=$7->head; $7->tail->next=$8->head; $8->tail->next=$9->head; $9->tail->next=$10->head; $10->tail->next=$11->head; $11->tail->next=$12->head;  $12->tail->next=$13->head;
                                                                                                                            $$=(struct List*) malloc(sizeof(struct List));
                                                                                                                            $$->head=$1->head; $$->tail=$13->tail;

                                                                                                                            struct List* l1=(struct List*) malloc(sizeof(struct List)); struct List* l2=(struct List*) malloc(sizeof(struct List));
                                                                                                                            l1->head=$4->head; l1->tail=$9->tail; l2->head=$11->head; l2->tail=$13->tail;
                                                                                                                            addmacro($2,l1,l2,1);
                                                                                                                        }
                        | DFE0 Identifier OB CB OB Expression CB        {
                                                                            //Linked the linked lists on right side and forming another linked list $$.
                                                                            $1->tail->next=$2->head; $2->tail->next=$3->head; $3->tail->next=$4->head; $4->tail->next=$5->head; $5->tail->next=$6->head; $6->tail->next=$7->head; 
                                                                            $$=(struct List*) malloc(sizeof(struct List));
                                                                            $$->head=$1->head; $$->tail=$7->tail;

                                                                            struct List* l1=(struct List*) malloc(sizeof(struct List)); struct List* l2=(struct List*) malloc(sizeof(struct List));
                                                                            l1->head=NULL; l1->tail=NULL; l2->head=$5->head; l2->tail=$7->tail;
                                                                            addmacro($2,l1,l2,1);
                                                                        }
                        | DFE1 Identifier OB Identifier CB OB Expression CB         {
                                                                                        //Linked the linked lists on right side and forming another linked list $$.
                                                                                        $1->tail->next=$2->head; $2->tail->next=$3->head; $3->tail->next=$4->head; $4->tail->next=$5->head; $5->tail->next=$6->head; $6->tail->next=$7->head; $7->tail->next=$8->head; 
                                                                                        $$=(struct List*) malloc(sizeof(struct List));
                                                                                        $$->head=$1->head; $$->tail=$8->tail;

                                                                                        struct List* l1=(struct List*) malloc(sizeof(struct List)); struct List* l2=(struct List*) malloc(sizeof(struct List));
                                                                                        l1->head=$4->head; l1->tail=$4->tail; l2->head=$6->head; l2->tail=$8->tail;
                                                                                        addmacro($2,l1,l2,1);
                                                                                    }
                        | DFE2 Identifier OB Identifier COMMA Identifier CB OB Expression CB        {
                                                                                                        //Linked the linked lists on right side and forming another linked list $$.
                                                                                                        $1->tail->next=$2->head; $2->tail->next=$3->head; $3->tail->next=$4->head; $4->tail->next=$5->head; $5->tail->next=$6->head; $6->tail->next=$7->head; $7->tail->next=$8->head; $8->tail->next=$9->head; $9->tail->next=$10->head; 
                                                                                                        $$=(struct List*) malloc(sizeof(struct List));
                                                                                                        $$->head=$1->head; $$->tail=$10->tail;
                                                                                                        
                                                                                                        struct List* l1=(struct List*) malloc(sizeof(struct List)); struct List* l2=(struct List*) malloc(sizeof(struct List));
                                                                                                        l1->head=$4->head; l1->tail=$6->tail; l2->head=$8->head; l2->tail=$10->tail;
                                                                                                        addmacro($2,l1,l2,1);
                                                                                                    }
;

CIdentifiers: CIdentifiers CIdentifier      {
                                                //Linked the linked lists on right side and forming another linked list $$.
                                                $1->tail->next=$2->head;
                                                $$=(struct List*) malloc(sizeof(struct List));
                                                $$->head=$1->head; $$->tail=$2->tail;
                                            }
                |               {
                                    //Linked the linked lists on right side and forming another linked list $$.
                                    struct Node* ptr=(struct Node*) malloc(sizeof(struct Node)); ptr->val=""; ptr->next=NULL;
                                    $$=(struct List*) malloc(sizeof(struct List));
                                    $$->head=ptr; $$->tail=ptr;
                                }
;

CIdentifier: COMMA Identifier       {
                                        //Linked the linked lists on right side and forming another linked list $$.
                                        $1->tail->next=$2->head;
                                        $$=(struct List*) malloc(sizeof(struct List));
                                        $$->head=$1->head; $$->tail=$2->tail;
                                    }
;

Identifier: ID          {
                            $$->head=$1->head; $$->tail=$1->tail;
                        }
;

%%

void yyerror(const char* s)
{
    printf("Failed to parse the code.\n");
}

int yywrap(void) { return 1; }

int main()
{
    yyparse();

    return 0;
}

#include "lex.yy.c"