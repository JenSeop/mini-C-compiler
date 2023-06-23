%option noyywrap yylineno
%x IFILE

%{
    #define LD_PATH /usr/include/
    struct bufstack {
        struct bufstack *prev;  // prev include file pointer
        YY_BUFFER_STATE bs;     // saved buffer, used by flex
        int lineno;             // include source code line num
        char *filename;         // include file name
        FILE *f                 // File Descriptor, used by fopen file pointer
    } *curbs = 0;

    char *curfilename;          // file name

    int newfile(char *fn);      // fn is filename, new file loader
    int popfile(void);          // end of include
%}

%%
^"#"[ \t]*include[ \t]*[\"<]    { BEGIN IFILE; }

<IFILE>[^ \t\n\">]+ {
    {
        int c;
        while((c = input()) && c != '\n');
    }
    yylineno++;
    if (!newfile(yytext))
        yyterminate();          // no such file & end
    BEGIN INITIAL;
    }

<IFILE>.|\n {
    fprintf(stderr, "%4d bad include line\n", yylineno);
    yyterminate();
    }

<<EOF>>     { if (!popfile()) yyterminate(); }

^.          { fprintf(yyout, "%4d %s", yylineno, yytext); }
^\n         { fprintf(yyout, "%4d %s", yylineno++, yytext); }
\n          { ECHO; yylineno++; }
.           { ECHO; }


"auto"      {}
"break"     {}
"case"      {}
"char"      {}
"const"     {}
"continue"  {}
"default"   {}
"do"        {}
"double"    {}
"else"      {}
"enum"      {}
"extern"    {}
"float"     {}
"for"       {}
"goto"      {}
"if"        {}
"inline"    {}
"int"       {}
"long"      {}
"register"  {}
"restrict"  {}
"return"    {}
"short"     {}
"signed"    {}
"sizeof"    {}
"static"    {}
"struct"    {}
"switch"    {}
"typedef"   {}
"union"     {}
"unsigned"  {}
"void"      {}
"volatile"  {}
"while"     {}
"_Bool"     {}
"_Complex"  {}
"_Imagenary"{}

%%

int newfile(char *fn)
{
    FILE *f = fopen(fn, "r");
    struct bufstack *bs = malloc(sizeof(struct bufstack));

    if ( !f )   { perror(fn); return (0); }
    if ( !bs )  { perror("malloc"); exit(1); }

    if ( curbs ) curbs->lineno = yylineno;
    bs->prev = curbs;

    bs->bs = yy_create_buffer(f, YY_BUF_SIZE);
    bs->f = f;
    bs->filename = strdup(fn);
    yy_switch_to_buffer(bs->bs);
    curb = bs;
    yylineno = 1;
    curfilename = bs->filename;
    
    return (1);
}

int popfile(void)
{
    struct bufstack *bs = curbs;
    struct bufstack *prevbs;

    if ( !bs ) return (0);

    fclose(bs->f);
    free(bs->filename);
    yy_delete_buffer(bs->bs);

    prevbs = bs->prev;
    free(bs);

    if ( !prevbs ) return (0);

    yy_switch_to_buffer(prevbs->bs);
    curbs = prevbs;
    yylineno = curbs->lineno;
    curfilename = curbs->filename;

    return (1);
}