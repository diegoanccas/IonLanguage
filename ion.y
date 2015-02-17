%{
    #include <string.h>
    #include <stdio.h>
    #include <stdlib.h>
    #include <stdarg.h>
    #include "ion.h"

    nodeType *opr(int oper, int nops, ...);
    nodeType *id(int i);
    nodeType *con(int tipo, int entero, float decimal, char* cadena);
    void freeNode(nodeType *p);
    void ex(nodeType *p);
    int yylex(void);

    void yyerror(char *s);
    int sym[26];

    /* Esto es un simple comentario */

    extern char* variables_nombres[TABSIZE];
    extern int variables_valores[TABSIZE];
    extern int num_variables;
    extern int verificar_variable(char *txt);
    extern void reset();
    extern int yylineno;
    extern char* yytext;

    nodeType *ruler;
%}

%union {
    float iDecimal;
    int iEntero; 
    char iCaracter;
    char* iCadena;
    nodeType *nPtr;
};

%token <iEntero> NUM_ENTERO
%token <iDecimal> NUM_DECIMAL
%token <iCaracter> VARIABLE
%token <iCadena> CADENA
%token <iCadena> funcNAME
%token WHILE IF PRINT FUNCTION
%nonassoc IFX
%nonassoc ELSE

%left GE LE EQ NE '>' '<'
%left '+' '-'
%left '*' '/'
%nonassoc UMINUS

%type <nPtr> stmt expr stmt_list

%%

program:
        work                { exit(0); }
        ;

work:
        work stmt         { ex($2); freeNode($2); }
        | /* NULL */
        ;

stmt:
          ';'                            { $$ = opr(';', 2, NULL, NULL); }
        | expr ';'                       { $$ = $1; }
        | PRINT expr ';'                 { $$ = opr(PRINT, 1, $2); }
        | FUNCTION funcNAME ';'          { printf("Function: %s\n", strdup($2)); } /* TODO */
        | VARIABLE '=' expr ';'          { $$ = opr('=', 2, id($1), $3); }
        | WHILE '(' expr ')' stmt        { $$ = opr(WHILE, 2, $3, $5); }
        | IF '(' expr ')' stmt %prec IFX { $$ = opr(IF, 2, $3, $5); }
        | IF '(' expr ')' stmt ELSE stmt { $$ = opr(IF, 3, $3, $5, $7); }
        | '{' stmt_list '}'              { $$ = $2; }
        ;

stmt_list:
          stmt                  { $$ = $1; }
        | stmt_list stmt        { $$ = opr(';', 2, $1, $2); }
        ;

expr:
          NUM_ENTERO            { $$ = con(1, $1, 1, NULL); }
        | NUM_DECIMAL           { $$ = con(2, 1, $1, NULL); }
        | CADENA                { $$ = con(3, 1, 1, $1); }
        | VARIABLE              { $$ = id($1); }
        | '-' expr %prec UMINUS { $$ = opr(UMINUS, 1, $2); }
        | expr '+' expr         { $$ = opr('+', 2, $1, $3); } /* Concatenar */
        | expr '-' expr         { $$ = opr('-', 2, $1, $3); }
        | expr '*' expr         { $$ = opr('*', 2, $1, $3); }
        | expr '/' expr         { $$ = opr('/', 2, $1, $3); }
        | expr '<' expr         { $$ = opr('<', 2, $1, $3); }
        | expr '>' expr         { $$ = opr('>', 2, $1, $3); }
        | expr GE expr          { $$ = opr(GE, 2, $1, $3); }
        | expr LE expr          { $$ = opr(LE, 2, $1, $3); }
        | expr NE expr          { $$ = opr(NE, 2, $1, $3); }
        | expr EQ expr          { $$ = opr(EQ, 2, $1, $3); }
        | '(' expr ')'          { $$ = $2; }
        ;

%%
/* Almacenamos data */

char* limpiarCadena(char* s){

    return s;
}
char* concatenarCadenas(char* s1, char* s2){
    char* str3 ;
    str3 = strcat(s1, s2); 
    return str3;
}
nodeType *con(int tipo, int entero, float decimal, char* cadena){
    nodeType *p;
    if ((p = malloc(sizeof(nodeType))) == NULL)
        yyerror("out of memory");
    p->type = typeCon;
    p->val.tipo = tipo;
    if(tipo == 1){
        //printf("ENTERO: %d\n", entero);
        p->val.entero = entero;
    } else if(tipo == 2){
        //printf("DECIMAL: %f\n", decimal);
        p->val.decimal = decimal;
    } else if(tipo == 3){
        //printf("CADENA: %s\n", limpiarCadena(cadena));
        p->val.cadena = cadena;
    } else {
        printf("DESCONOCIDO::::::::::::::::::::::::::::::::::::::::::::::::::::::::\n");
    }
    return p;
}
nodeType *id(int i) {
    nodeType *p;

    if ((p = malloc(sizeof(nodeType))) == NULL)
        yyerror("out of memory");

    p->type = typeId;
    p->id.i = i;

    return p;
}

nodeType *opr(int oper, int nops, ...) {
    va_list ap;
    nodeType *p;
    int i;

    if ((p = malloc(sizeof(nodeType))) == NULL)
        yyerror("out of memory");
    if ((p->opr.op = malloc(nops * sizeof(nodeType *))) == NULL)
        yyerror("out of memory");

    //printf("OPERADOR: %d\n", oper);
    p->type = typeOpr;
    p->opr.oper = oper;
    p->opr.nops = nops;
    va_start(ap, nops);
    for (i = 0; i < nops; i++)
        p->opr.op[i] = va_arg(ap, nodeType*);
    va_end(ap);
    return p;
}

void freeNode(nodeType *p) {
    int i;

    if (!p) return;
    if (p->type == typeOpr) {
        for (i = 0; i < p->opr.nops; i++)
            freeNode(p->opr.op[i]);
		free (p->opr.op);
    }
    free (p);
}

void yyerror(char *s) {
    //printf("oha, %s: '%s' in line %d\n", s, yytext, yylineno);
    //fprintf(stdout, "%s\n", s);

    if(strcmp(s, "syntax error") == 0 ){
        printf("\nIon Parser error: syntax error, unexpected '%s' in  /var/www on line %d\n", strdup(yytext), yylineno); 
    } else {
        printf("\nIon error: %s, in /var/www on line %d\n", s, yylineno); 
    }
    ///printf("\n%d: %s:\n%s\n", lineno, s, linebuf);
    //printf("%*s\n",1+tokenpos, "^");
}

int main(void) {
    yyparse();
    return 0;
}
