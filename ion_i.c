#include <string.h>
#include <stdio.h>
#include "ion.h"
#include "y.tab.h"
#define CHAR_BIT 8
float ex_float(nodeType *p);
char* ex_char(conNodeType p);


conNodeType anidar(nodeType *p) {
    conNodeType retorno;
    conNodeType rp1;
    conNodeType rp2;
    char* r1;
    int condicion = 0;
    switch(p->type) {
        case typeCon:
            retorno.tipo    = p->val.tipo;
            retorno.entero  = p->val.entero;
            retorno.decimal = p->val.decimal;
            retorno.cadena  = p->val.cadena;
        break;

        case typeId:
            retorno.tipo = 1;
            retorno.entero = ex_int(p);
        break;

        case typeOpr:
            switch(p->opr.oper) {
                case WHILE:
                    while(ex_int(p->opr.op[0]))
                        anidar(p->opr.op[1]);
                break;

                case IF:
                    rp1 = anidar(p->opr.op[0]);
                    if(rp1.tipo == 1){
                        if(rp1.entero > 0){
                            condicion = 1;
                        }
                    } else if(rp1.tipo == 2){
                        if(rp1.decimal > 0){
                            condicion = 1;
                        }
                    } else if(rp1.tipo == 3){
                        if(sizeof(rp1.cadena)/sizeof(char) > 0){
                            condicion = 1;
                        }
                    }
                    if(condicion == 1)
                        anidar(p->opr.op[1]);
                    else if (p->opr.nops > 2)
                        anidar(p->opr.op[2]);
                break;

                case PRINT:
                    //printf(" ==>  S: >%s<\n", ex_char(p->opr.op[0]));
                    rp1  = anidar(p->opr.op[0]);
                    if(rp1.tipo == 1){
                        printf("%d", rp1.entero);
                        //printf("================ string1: %d\n", rp1.entero);
                    } else if(rp1.tipo == 2){
                        printf("%f", rp1.decimal);
                        //printf("================ string2: %f\n", rp1.decimal);
                    } else if(rp1.tipo == 3){
                        printf("%s", rp1.cadena);
                        //printf("================ string3: >%s<\n", rp1.cadena);
                    } else {
                        printf("================  TIPO DESCONOCIDO!\n");
                    }
                break;

                case ';':
                    anidar(p->opr.op[0]);
                    retorno = anidar(p->opr.op[1]);
                break;

                case '=':
                    retorno.tipo = 1;
                    retorno.entero = sym[p->opr.op[0]->id.i] = ex_int(p->opr.op[1]); /* TODO */
                break;

                case UMINUS:
                    retorno.tipo = 2;
                    retorno.decimal = -ex_float(p->opr.op[0]);
                break;

                case '+':
                    rp1  = anidar(p->opr.op[0]);
                    rp2  = anidar(p->opr.op[1]);
                    //printf("tipo1: %d , tipo2: %d\n", rp1.tipo, rp2.tipo);
                    if(rp1.tipo == 3 || rp2.tipo == 3){
                        retorno.tipo = 3;
                        r1 = strcat(ex_char(rp1), ex_char(rp2));
                        retorno.cadena = r1;
                    } else {
                        retorno.tipo = 2;
                        retorno.decimal = ex_float(p->opr.op[0]) + ex_float(p->opr.op[1]);
                    }
                break;

                case '-':
                    retorno.tipo = 2;
                    retorno.decimal = ex_float(p->opr.op[0]) - ex_float(p->opr.op[1]);
                break;
                
                case '*':
                    retorno.tipo = 2;
                    retorno.decimal = ex_float(p->opr.op[0]) * ex_float(p->opr.op[1]);
                break;
                
                case '/':
                    retorno.tipo = 2;
                    retorno.decimal = ex_float(p->opr.op[0]) / ex_float(p->opr.op[1]);
                break;
                
                case '<':
                    retorno.tipo = 1;
                    retorno.entero = ex_float(p->opr.op[0]) < ex_float(p->opr.op[1]);
                break;

                case '>':
                    retorno.tipo = 1;
                    retorno.entero = ex_float(p->opr.op[0]) > ex_float(p->opr.op[1]);
                break;
                
                case GE:
                    retorno.tipo = 1;
                    retorno.entero = ex_float(p->opr.op[0]) >= ex_float(p->opr.op[1]);
                break;
                
                case LE:
                    retorno.tipo = 1;
                    retorno.entero = ex_float(p->opr.op[0]) <= ex_float(p->opr.op[1]);
                break;
                
                case NE:
                    retorno.tipo = 1;
                    retorno.entero = ex_float(p->opr.op[0]) != ex_float(p->opr.op[1]);
                break;
                
                case EQ:
                    retorno.tipo = 1;
                    retorno.entero = ex_float(p->opr.op[0]) == ex_float(p->opr.op[1]);
                break;

                default:
                    printf("DESCONICIDO opr.oper\n");
                break;
        }
        break;
        default:
            printf("DESCONICIDO anidar\n");
        break;
    }
    return retorno;
}
int ex_int(nodeType *p){
    conNodeType rp;
    switch(p->type) {
        case typeCon:
            return p->val.tipo == 2 ? p->val.decimal : p->val.entero;
        break;
        case typeId:
            return sym[p->id.i];
        break;
        case typeOpr:
            rp = anidar(p);
            if(rp.tipo == 1){
                return rp.entero;
            } else if(rp.tipo == 2){
                return (int) rp.decimal;
            } else {
                return 0;
            }
            printf("DESCONICIDO ex_int/anidar: %d\n", rp.tipo);
        break;
        default: 
            printf("DESCONICIDO ex_int: %d\n", p->type);
        break;
    }
    return 0;
}
float ex_float(nodeType *p){
    switch(p->type) {
        case typeCon:
            return p->val.tipo == 2 ? p->val.decimal : p->val.entero;
        break;
        case typeId:
            return sym[p->id.i];
        break;
        default:
            printf("DESCONICIDO ex_float: %d, %d\n", p->type, typeCon);
        break;
    }
    return 0;
}
char* ex_char(conNodeType p){
    char* str = "";
    char buffer [(((sizeof p.entero) * CHAR_BIT) + 2)/3 + 2];
    int n;

    if(p.tipo == 1){
        sprintf(buffer, "%d", p.entero);
        str = strdup(buffer);
        return str;
    } else if(p.tipo == 2){
        sprintf(buffer, "%f", p.decimal);
        str = strdup(buffer);
        return str;
    } else if(p.tipo == 3){
        return p.cadena;
    } else {
        printf("DESCONICIDO ex_char: %d\n", p.tipo);
        return str;
    }
}
void ex(nodeType *p) {
    switch(p->type) {
        case typeId:
            ex_int(p);
        break;
        
        case typeOpr:
            anidar(p);
        break;
        
        default:
            printf("DESCONOCIDO!!\n");
        break;
    }
}
