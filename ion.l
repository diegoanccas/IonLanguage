%{
    #include <string.h>
    #include <stdlib.h>
    #include "ion.h"
    #include "y.tab.h"

    #define TABSIZE 1000
    #define true 1
    #define false 0
     
    char* variables_nombres[TABSIZE];
    int variables_valores[TABSIZE];
    int num_variables = 0;

    //void yyerror(char *);
    void reset(){
        int j;
        for(j = 0; j < TABSIZE; j++)
            variables_valores[j] = false;
    }
    int verificar_variable(char *txt){
        int j;
        char *s;

        if(num_variables == 0) {
            s = strdup(txt);
            variables_nombres[0] = s;
            ++num_variables;
            return 0;
        }
        for(j = 0; j < num_variables; ++j) {
            if(strcmp(txt, variables_nombres[j]) == 0) {
                return j;
            }
        }
        s = strdup(txt);
        variables_nombres[j] = s;
        ++num_variables;
        return j;
    }
%}

%option yylineno

EXPREG_NUMERO_DOUBLE   [0-9][0-9]*\.[0-9]+
EXPREG_NUMERO_INT      [0-9][0-9]*
EXPREG_VAR             "$"[a-zA-Z][a-zA-Z0-9_]*
EXPREG_FUNCION         [a-z]{1,10}
EXPREG_STRING          \"(\\.|[^\\\"])*\"
EXPREG_CARACTER        .
EXPREG_OPERADORES      [-()<>=+*/;{}."]
EXPREG_VACIO           [ \n\t]+
EXPREG_COMENTARIO      (\#[^\n]*)

%%
 
{EXPREG_COMENTARIO} {
    //printf("COMENTARIO1: %s\n", strdup(yytext));
}
{EXPREG_VACIO}  {

}

{EXPREG_VAR}    { 
    yylval.iCaracter = verificar_variable(yytext);
    return VARIABLE;
} 
{EXPREG_NUMERO_DOUBLE} {
    yylval.iDecimal = atof(yytext);
    return NUM_DECIMAL;
}
{EXPREG_NUMERO_INT} {
    yylval.iEntero = atoi(yytext);
    return NUM_ENTERO;
}
{EXPREG_OPERADORES} {
    return *yytext;
}
"while" {
    return WHILE;
}
"if"    {
    return IF;
}
"else"  {
    return ELSE;
}
"print" {
    return PRINT;
}
"function" {
    return FUNCTION;
}
">="    {
    return GE;
}
"<="    {
    return LE;
}
"=="    {
    return EQ;
}
"!="    {
    return NE;
}
{EXPREG_FUNCION} {
    yylval.iCadena = strdup(yytext);
    return funcNAME;
}
{EXPREG_STRING} {
    yylval.iCadena = strdup(yytext);
    return CADENA;
}
{EXPREG_CARACTER}  {
    yyerror("Caracter invalido");
}
%%
int yywrap(void) {
    return 1;
}
