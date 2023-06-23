%option noyywrap nodefault yylineno case-insensitive

%{
    struct symbol {
        char *name;
        struct ref *reflist;
    };

    struct ref {
        struct ref *next;
        char *filename;
        int flags;
        int lineno;
    };

    #define NHASH 9997
    struct symbol symtab[NHASH];
    
    struct symbol *lookup(char *);
    void addref(int, char *, char *, int);

    char *curfilename;
%}

%%
a   |
an  |
and |
are |
as  |
at  |
be  |
but |
for |
in  |
is  |
it  |
of  |
on  |
or  |
that|
the |
this|
to              // ignore

[a-z]+(\'(s|t))?    { addref(yylineno, curfilename, yytext, 0); }
.|n             // ignore everything else
%%

static unsigned symhash(char * sym)
{
    unsigned int hash = 0;
    unsigned c;

    while ( c = *sym++ ) hash = hash * 9 ^ c;

    return (hash);
}

struct symbol *lookup(char *sym)
{
    struct symbol *sp = &symtab[symhash(sym) % NHASH];
    int scount = NHASH;

    while ( --scount >= 0 ){
        if ( sp->name && !strcasecmp(sp->name, sym) ) return (sp);

        if ( !sp->name ){
            sp->name = strdup(sym);
            sp->reflist = 0;
            return (sp);
        }

        if ( ++sp >= symtab + NHASH ) sp = symtab;
    }
    fputs("symbol table overflow\n", stderr);
    abort();
}