%{
    #include <stdio.h>
    #include <string.h>
    #include <stdlib.h>
    #include <stdbool.h>
    int yylex();
    
    
    #include "y.tab.c"
    


%}
id       [a-zA-Z]+[0-9]*
integer  [0-9]+
hex	 "'"[A-F]?[0-9A-F]+			
bin	[\"][0-1]+[\"]
binc	[\'][0-1][\']
%%
EOF       {return EOF_STMT;}      /* end of file */
na        {return ERROR_STMT;}    /* error */
{binc}	  {numVal = strdup(yytext);
	   return BINARYC;} /*binary constant*/
{bin}	  {numVal = strdup(yytext);
	   return BINARY;}
{integer} {numVal = strdup(yytext);
	   return NUMBER;}	/* string of digits */
{hex}     {return HEX;}		/* !! Revisar los HEX !!*/

 /* keywords */
AHPLMODULE   {return AHPLMODULE;}
INPUTS       {return INPUTS;}
EXINPUTS     {return EXINPUTS;}
BUSES        {return BUSES;}
EXBUSES      {return EXBUSES;}
OUTPUTS      {return OUTPUTS;}
MEMORY       {return MEMORY;}
LABELS       {return LABELS;}
CLUNITS      {return CLUNITS;}
BODY         {return BODY;}
NULL         {return NULLSTMT;}
NODELAY      {return NODELAY;}
DEADEND      {return DEADEND;}
ENDSEQUENCE  {return ENDSEQUENCE;}
CONTROLRESET {return CONTROLRESET;}
END          {return END;}

ENDMODULE    {return ENDMODULE;}

OPTION       {return OPTION;}
CLOCKLIMIT   {return CLOCKLIMIT;}
INITIALIZE   {return INITIALIZE;}
EXLINES      {return EXLINES;}
SUPPRESS     {return SUPPRESS;}
DUMP         {return DUMP;}
ALL          {return ALL;}
REPEAT       {return REPEAT;}
ADD          {return ADD;}
ADDC         {return ADDC;}
SUB	     {return SUB;}

INC          {return INC;}
MEMFN        {return MEMFN;}
DCD          {return DCD;}
DEC          {return DEC;}
CMP          {return CMP;}
ASSOC        {return ASSOC;}
 /* end of keywords */



 /* test keywords */
clunits  {return clunits;}
comsec	     {return comsec;}
 /* end of test keywords*/

 /* operators */
"^"       {clVal = strdup(yytext);
           return NOT;}		/* inverter */
"&"    	  {clVal = strdup(yytext);
           return AND;}		/* and */
"^&"      {clVal = strdup(yytext);
           return NAND;}	/* nand */
"+"	  {clVal = strdup(yytext);
           return OR;}		/* or */
"^+"	  {clVal = strdup(yytext);
           return NOR;}		/* nor */
"@" 	  {clVal = strdup(yytext);
           return XOR;}  	/* xor */
"^@"	  {clVal = strdup(yytext);
           return XNOR;}	/* xnor */
                    
"&/"	  {return ANDCR;}	/* and col reduction */
"^&/"	  {return NANDCR;}	/* nand col reduction */
"+/" 	  {return ORCR;}	/* or col reduction */
"^+/"	  {return NORCR;}       /* nor col reduction */
"@/"      {return XORCR;}	/* xor col reduction */
"^@/"	  {return XNORCR;}	/* xnor col reduction */
"&//"	  {return ANDRR;}	/* and row reduction */
"^&//"	  {return NANDRR;}      /* nand row reduction */
"+//"	  {return ORRR;}	/* or row reduction */
"^+//"    {return NORRR;}	/* nor row reduction */

"@//"	  {return XORRR;} 	/* xor row reduction */
"^@//"	  {return XNORRR;} 	/* xnor row reduction */
","       {return COLCAT;}      /* colum catenation */
"*" 	  {return CONDITION;}	/* condition */
"/"	  {return SLASH;}	/* slash */
"=>"	  {return JUMP;}	/* jump */
"="       {return EQUAL;}	/* equal */
"<="      {relac = strdup(yytext);
	   return TRANSFER;}	/* transfer */

">="	  {relac = strdup(yytext);
	   return GEQTHAN;}

"("       {return LPARENTESIS;} /* left parentesis */
")"	  {return RPARENTESIS;} /* right parentesis */
"[" 	  {return LSQBRACKET;}  /* left square bracket */
"]"	  {return RSQBRACKET;}  /* right square bracket */
"<"	  {relac = strdup(yytext);
	   return LABRACKET;}   /* left angle bracket */
">"	  {relac = strdup(yytext);
	   return RABRACKET;}   /* right angle bracket */
"{" 	  {return LCBRACE;}     /* left curly brace */
"}"	  {return RCBRACE;}     /* right curly brace */
";"	  {return SEMICOLON;}	/* semicolon */
"$"	  {return ENCODE;}	/* encode */ 
"."	  {return PERIOD;}	/* period */ 
":"	  {return COLON;}	/* colon */
"\\"	  {return BSLASH;}	/* back slash */ 
"!"	  {return option;}	/* option */
"#"	  {return MTIMES;}	/* multiple times */
[\"]       {return APOSTROPHE;}
 /* end of operators */
 
{id}    {idVal = strdup(yytext);
         return id;}            /* string of chars */

 /* white spaces */
\n      lineno++;
[ \t\r]+ ;                      /* ignore whitespaces */
 /* end of white spaces*/

 /* anything else */
.                    yyerror("invalid character");

%%
char **fileList;
unsigned currentFile = 0;
int main(int argc, char **argv)
{
  int i = 1;
  bool mem1 = false;
  bool mem2 = false;
  bool mem3 = false;
	while(i < argc){   
		  if(argc > 1 && (yyin = fopen(argv[i], "r")) == NULL)
		  {
		  	perror(argv[i]);
		  	exit(1);
		  }
		  
		 
		  if(!yyparse())
		  {
		  	
		  	
		  	printf("\n--AHPL parse Worked------------------\n");
		  	
		  	mem1 = Module.memory1; /*pregunta si existe alguna memoria en algun archivo*/
		  	mem2 = Module.memory2;
		  	mem3 = Module.memory3;
		  	
		  	AHPL_translate(Module);

		  	Module = Module1;

		  	Module.memory1 = mem1;
		  	Module.memory2 = mem2;
		  	Module.memory3 = mem3;
		  	lineno = 1;
		  	/*if (argc ==)
		  	system("./bnfr %s");*/
		  	//system("clear");
		  }
		  else
		  { 
		  	printf("\nAHPL parse failed at:%s\n", argv[i]);
		  }
		  
		  i++;
	  }
Generic_memory(Module);
} /*main*/

