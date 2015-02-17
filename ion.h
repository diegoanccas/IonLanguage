typedef enum { typeCon, typeId, typeOpr } nodeEnum;

/* constants */
typedef struct {
    int tipo; /* 1: int, 2:float, 3:string, 4:boolean, etc */
    int entero;
    float decimal;
    char* cadena;
} conNodeType;

/* identifiers */
typedef struct {
    int i;                      /* subscript to sym array */
} idNodeType;

/* operators */
typedef struct {
    int oper;                   /* operator */
    int nops;                   /* number of operands */
    struct nodeTypeTag **op;	/* operands */
} oprNodeType;

typedef struct nodeTypeTag {
    nodeEnum type;              /* type of node */

    union {
        conNodeType val;        /* constants */
        idNodeType id;          /* identifiers */
        oprNodeType opr;        /* operators */
    };
} nodeType;

extern int sym[26];
#define TABSIZE 1000
#define true 1
#define false 0