%{
    #include <stdio.h>
    #include <stdlib.h>
    #include <string.h>
    #include <stdbool.h>
    #include "module.h"
    #define charl 150 /*define el numero maximo de declaraciones que puedo tener por modulo*/
    
    
    int n = 0;
    int ns = 0;
    int module = 1;                   /*halla el numero de modulos*/
    char *idVal;
    char *clVal;
    char*  numVal;
    char*  relac;
    Mcom Module ={0}; /* estructura que se modifica acorde al archivo que se este leyendo*/
    Mcom Module1 = {0};
    void yyerror(char *s);
    int lineno = 1;
    
    /******************************************************/
    /* estructura que define las banderas de las entradas*/
   
    
    /*----------------------------------------------------*/
    
    int row = 0;
    int col = 0;
    
    /******************************************************/

%}
/* ?????????? */
%token id          /* id */
%token EOF_STMT    /* end of file */
%token ERROR_STMT  /* error */
%token NUMBER	   /* integer */
%token HEX	   /* hex number */
/* end of ??????????*/

/* keywords */
%token AHPLMODULE
%token INPUTS
%token EXINPUTS
%token BUSES
%token EXBUSES
%token OUTPUTS
%token MEMORY
%token LABELS
%token CLUNITS
%token BODY
%token NULLSTMT 
%token NODELAY
%token DEADEND
%token ENDSEQUENCE
%token CONTROLRESET
%token END

%token ENDMODULE

%token OPTION
%token CLOCKLIMIT
%token INITIALIZE
%token EXLINES
%token SUPPRESS
%token DUMP
%token ALL
%token REPEAT
%token ADD
%token ADDC
%token SUB

%token RES

%token INC 
%token MEMFN
%token DCD
%token DEC
%token CMP
%token ASSOC
/* end of keywords */ 

/* operator */
%left NOT	   /* not */
%left AND	   /* and */
%left NAND        /* nand */
%left OR          /* or */
%left NOR         /* nor */
%left XOR         /* xor */
%left XNOR        /* xnor */
%left ANDCR       /* and col reduction */
%left NANDCR      /* nand col reduction */
%left ORCR        /* or col reduction */
%left NORCR       /* nor col reduction */
%left XORCR       /* xor col reduction */
%left XNORCR      /* xnor col reduction */
%left ANDRR	   /* and row reduction */
%left NANDRR	   /* nand row reduction */
%left ORRR	   /* or row reduction */
%left NORRR	   /* nor row reduction */
%left XORRR	   /* xor row reduction */
%left XNORRR	   /* xnor row reduction */

%token COLCAT	   /* colum catenation */
%token CONDITION   /* condition */
%token SLASH	   /* slash */
%token JUMP	   /* jump */
%token EQUAL	   /* equal */
%token TRANSFER    /* transfer */

%token GEQTHAN     /*greater or equal than*/

%left RPARENTESIS /* right parentesis */
%left LPARENTESIS /* left parentesis */

%left LABRACKET   /* left angle bracket */
%left RABRACKET   /* right angle bracket */


%left LSQBRACKET  /* left square bracket */
%left RSQBRACKET  /* right square bracket */

%token LCBRACE     /* left curly brace */
%token RCBRACE     /* right curly brace */
%token SEMICOLON   /* semicolon */
%token ENCODE      /* encode */
%token PERIOD  	   /* period */
%token COLON	   /* colon */
%token BSLASH 	   /* back slash */
%token option	   /* option "!" */
%token MTIMES	   /* multiple times */
%token ONE         /* one '1' */
%token ZERO        /* zero '0' */
%token BINARY
%token BINARYC
%token APOSTROPHE
/* end of operators*/	

/* test tokens */

//%token module
%token comsec

//%token mheader
//%token mdclr
//%token mbody 
//%token mend

//%token inputs
//%token exinputs
//%token outputs
//%token buses
%token exbuses
//%token memory
%token clunits
/*%token aid
%token clkseq1
%token synop
%token srcexpr
%token destexpr1


%token constant
%token encode 
%token add
%token addc
%token inc
%token dec
%token dcd
%token busfn
%token assoc
%token compare
%token idrange*/
/* end of test tokens*/

%%

/*line 1 : <system> ::= <module> {<module>} <comsec> * mediante la consola de comandos se puede 
						     * hacer que el sistema funcione para varios modulos
          define la estructura del sistema           */
system : module 
       ;
       
/* end of line 1 ------------------------------------*/

/*line 2 : <module> ::= <mheader> <mdclr> <mbody> <mend> *
           define el formato de un modulo                */
module : mheader mdclr mbody module1
       | mheader       mbody module1
       ;
module1: mend {Module.moduleNum += 1;}
       ;
/* end of line 2 ----------------------------------------*/           

/*line 3 : <mheader> ::= AHPLMODULE: id     *     
          define el formato de un encabezado*/
mheader : AHPLMODULE COLON id PERIOD {Module.moduleName = idVal;}
	;
/* end of line 3 ----------------------------------------*/

/*line 4 : <mdclr> ::= {<inputs> | <exinputs> | <outputs> |
			<buses>  | <exbuses>  | <memory>  | clunits } *
  se encarga de definir el formato de declaracion de un modulo        */
mdclr	: mdclrx
	| mdclr mdclrx
	;

mdclrx	: inputs   
	| exinputs /*!!determinar el numero de veces que aparece alguno de estos items !!*/
	| outputs
	| buses
	| memory
	| clunits
	;
/* end of line 4 -----------------------------------------------------*/

/*line 5 : <inputs> ::= INPUTS: <aid> {;aid}.     *
  se encarga de definir el formato de una entrada */
inputs	: INPUTS COLON inaid inputsx PERIOD 
	| INPUTS COLON inaid         PERIOD
	;
inputsx : SEMICOLON inaid         
	| inputsx SEMICOLON inaid 
	;
inaid	: id                           {Module.inputs[Module.inputsNumR][0] = idVal;
					Module.inputs[Module.inputsNumR][1] = "0";
					Module.inputsNum[Module.inputsNumR] = atoi(Module.inputs[Module.inputsNumR][1]);
					Module.inputsNumR++;}
	| id LABRACKET NUMBER RABRACKET{Module.inputs[Module.inputsNumR][0] = idVal;
					Module.inputs[Module.inputsNumR][1] = numVal;
					Module.inputsNum[Module.inputsNumR] = atoi(Module.inputs[Module.inputsNumR][1]);
					Module.inputsNumR++;}
	;
/*end of line 5 ----------------------------------*/

/*line 6 : <exinputs> ::= EXINPUTS: <exaid> {; <exaid>}.*
  en caso de ser un arreglo bidimensional solo será     *
  necesario introducir el numero de filas               */
exinputs : EXINPUTS COLON exiaid exinputsx exinputsz 
	 | EXINPUTS COLON exiaid           exinputsz
	 ;
exinputsz: PERIOD {Module.exinputsNumR++;}
	 ;
exinputsx: exaids exiaid            
	 | exinputsx exaids exiaid
	 ;
exiaid	 : nikname COLON exname LSQBRACKET exiaid1 exiaid2 RSQBRACKET      {/*Nname:id[...;...;...]*/}
	 | nikname COLON exname LSQBRACKET exiaid1         RSQBRACKET      {/*Nname:id[{...,...}]*/  }
	 |               exname LSQBRACKET exiaid1 exiaid2      RSQBRACKET {/*      id[...;...;...]*/}
	 |               exname LSQBRACKET exiaid1              RSQBRACKET {/*      id[{...,...}]*/  }
	 ;
exname	 : id{/*Nname*/
                Module.exinputs[Module.exinputsNumR][Module.exinputsNumC][0] = idVal;
                Module.exinputs[Module.exinputsNumR][Module.exinputsNumC][1] = (char*)'0';//x
   	        Module.exinputs[Module.exinputsNumR][Module.exinputsNumC][2] = (char*)'0';//n1
	        Module.exinputs[Module.exinputsNumR][Module.exinputsNumC][3] = (char*)'0';//n2
	        Module.exinputs[Module.exinputsNumR][Module.exinputsNumC][4] = (char*)'0';//n3
	        Module.exinputs[Module.exinputsNumR][Module.exinputsNumC][5] = (char*)'0';//n4
                Module.exinputsNumC ++;				       
	        Module.exinputsStore[Module.exinputsNumR]++;}
	 ;
nikname  : id {/*Nname*/
                Module.exinputs[Module.exinputsNumR][Module.exinputsNumC][0] = idVal;
                Module.exinputs[Module.exinputsNumR][Module.exinputsNumC][1] = (char*)'1';//x (se etiquetan los apodos)
   	        Module.exinputs[Module.exinputsNumR][Module.exinputsNumC][2] = (char*)'0';//n1
	        Module.exinputs[Module.exinputsNumR][Module.exinputsNumC][3] = (char*)'0';//n2
	        Module.exinputs[Module.exinputsNumR][Module.exinputsNumC][4] = (char*)'0';//n3
	        Module.exinputs[Module.exinputsNumR][Module.exinputsNumC][5] = (char*)'0';//n4
                Module.exinputsNumC ++;				       
	        Module.exinputsStore[Module.exinputsNumR]++;						
               }
	 ;
exiaid1  : LCBRACE exaidx1 COLCAT exaidx2 RCBRACE   {} 
	 ;
exiaid2	 : SEMICOLON exiaid1
	 | exiaid2 SEMICOLON exiaid1
	 ;
exaids   :SEMICOLON{Module.exinputsNumR ++;/*!!!!!!!!!!!!!!!!!!!!!!esto esta mal!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!*/
		    Module.exinputsNumC = 0;}
	 ;	
exaidx1  : id                                 {Module.exinputs[Module.exinputsNumR][Module.exinputsNumC][0] = idVal;
					       Module.exinputs[Module.exinputsNumR][Module.exinputsNumC][1] = (char*)'0';//x
				   	       Module.exinputs[Module.exinputsNumR][Module.exinputsNumC][2] = (char*)'0';//n1
					       Module.exinputs[Module.exinputsNumR][Module.exinputsNumC][3] = (char*)'0';//n2
					       Module.exinputs[Module.exinputsNumR][Module.exinputsNumC][4] = (char*)'0';//n3
					       Module.exinputs[Module.exinputsNumR][Module.exinputsNumC][5] = (char*)'0';//n4
					       
				 Module.exinputsNumT[Module.exinputsNumR][Module.exinputsNumC][0] = 0 ;
				 Module.exinputsNumT[Module.exinputsNumR][Module.exinputsNumC][1] = 0;//n1
				 Module.exinputsNumT[Module.exinputsNumR][Module.exinputsNumC][2] = 0;//n2
				 Module.exinputsNumT[Module.exinputsNumR][Module.exinputsNumC][3] = 0;//n3
				 Module.exinputsNumT[Module.exinputsNumR][Module.exinputsNumC][4] = 0;//n4
					       
         				       Module.exinputsNumC ++;			       
      					       Module.exinputsStore[Module.exinputsNumR]++;}
	 | id LABRACKET exiaidn1 RABRACKET {Module.exinputs[Module.exinputsNumR][Module.exinputsNumC][0] = idVal;
					    Module.exinputs[Module.exinputsNumR][Module.exinputsNumC][1] = numVal;
					    Module.exinputs[Module.exinputsNumR][Module.exinputsNumC][2] = (char*)'0';//n1
					    Module.exinputs[Module.exinputsNumR][Module.exinputsNumC][3] = (char*)'0';//n2
					    Module.exinputs[Module.exinputsNumR][Module.exinputsNumC][4] = (char*)'0';//n3
					    Module.exinputs[Module.exinputsNumR][Module.exinputsNumC][5] = (char*)'0';//n4
				
				Module.exinputsNumT[Module.exinputsNumR][Module.exinputsNumC][0] = atoi(numVal);//n1
				Module.exinputsNumT[Module.exinputsNumR][Module.exinputsNumC][1] = -1;//n2
				Module.exinputsNumT[Module.exinputsNumR][Module.exinputsNumC][2] = -1;//n3
				Module.exinputsNumT[Module.exinputsNumR][Module.exinputsNumC][3] = -1;
					    
					    Module.exinputsNumC ++;		
					    Module.exinputsStore[Module.exinputsNumR]++;}
	 ;
exaidx2	 : id                                                                                  {/*a*/
												Module.exinputs[Module.exinputsNumR][Module.exinputsNumC][0] = idVal;
											        Module.exinputs[Module.exinputsNumR][Module.exinputsNumC][1] = (char*)'0';//x
										   	        Module.exinputs[Module.exinputsNumR][Module.exinputsNumC][2] = (char*)'0';//n1
												Module.exinputs[Module.exinputsNumR][Module.exinputsNumC][3] = (char*)'0';//n2
												Module.exinputs[Module.exinputsNumR][Module.exinputsNumC][4] = (char*)'0';//n3
												Module.exinputs[Module.exinputsNumR][Module.exinputsNumC][5] = (char*)'0';//n4
												
												Module.exinputsNumT[Module.exinputsNumR][Module.exinputsNumC][0] = -1;//n1
												Module.exinputsNumT[Module.exinputsNumR][Module.exinputsNumC][1] = -1;//n2
												Module.exinputsNumT[Module.exinputsNumR][Module.exinputsNumC][2] = -1;//n3
												Module.exinputsNumT[Module.exinputsNumR][Module.exinputsNumC][3] = -1;//n4
												
												Module.exinputsStore[Module.exinputsNumR]++;
                										Module.exinputsNumC ++;}
	 | id LABRACKET exiaidn1                RABRACKET                                       {/*a<num>*/
												 Module.exinputs[Module.exinputsNumR][Module.exinputsNumC][0] = idVal;
        											 Module.exinputs[Module.exinputsNumR][Module.exinputsNumC][1] = (char*)'0';//x
        											 Module.exinputs[Module.exinputsNumR][Module.exinputsNumC][3] = (char*)'0';//n2
        											 Module.exinputs[Module.exinputsNumR][Module.exinputsNumC][4] = (char*)'0';//n3
        											 Module.exinputs[Module.exinputsNumR][Module.exinputsNumC][5] = (char*)'0';//n4
        											
        											
												 Module.exinputsNumT[Module.exinputsNumR][Module.exinputsNumC][1] = -1;//n2
												 Module.exinputsNumT[Module.exinputsNumR][Module.exinputsNumC][2] = -1;//n3
												 Module.exinputsNumT[Module.exinputsNumR][Module.exinputsNumC][3] = -1;//n4
        											 
        											 Module.exinputsStore[Module.exinputsNumR]++;
        											 Module.exinputsNumC ++;}
	 | id LABRACKET exiaidn1 RABRACKET LSQBRACKET exiaidn3  RSQBRACKET                     {/*a<num>[num]*/
												 Module.exinputs[Module.exinputsNumR][Module.exinputsNumC][0] = idVal;
        											 Module.exinputs[Module.exinputsNumR][Module.exinputsNumC][1] = (char*)'0';//x
        											 Module.exinputs[Module.exinputsNumR][Module.exinputsNumC][3] = (char*)'0';//n2
        											 Module.exinputs[Module.exinputsNumR][Module.exinputsNumC][5] = (char*)'0';//n4
        											
												 Module.exinputsNumT[Module.exinputsNumR][Module.exinputsNumC][1] = -1;//n2
												 Module.exinputsNumT[Module.exinputsNumR][Module.exinputsNumC][3] = -1;//n4
        											 
        											 Module.exinputsStore[Module.exinputsNumR]++;
        											 Module.exinputsNumC ++;}
         | id LABRACKET exiaidn1 COLON exiaidn2 RABRACKET                                      {/*a<num:num>*/
												 Module.exinputs[Module.exinputsNumR][Module.exinputsNumC][0] = idVal;
        											 Module.exinputs[Module.exinputsNumR][Module.exinputsNumC][1] = (char*)'0';//x
        											 Module.exinputs[Module.exinputsNumR][Module.exinputsNumC][4] = (char*)'0';//n3
        											 Module.exinputs[Module.exinputsNumR][Module.exinputsNumC][5] = (char*)'0';//n4
        											 
        											 
												 Module.exinputsNumT[Module.exinputsNumR][Module.exinputsNumC][2] = -1;//n3
												 Module.exinputsNumT[Module.exinputsNumR][Module.exinputsNumC][3] = -1;//n4
        											 
        											 Module.exinputsStore[Module.exinputsNumR]++;
        											 Module.exinputsNumC ++;}
	 | id LABRACKET exiaidn1 COLON exiaidn2 RABRACKET LSQBRACKET exiaidn3 RSQBRACKET       {/*a<num:num>[num]*/
												 Module.exinputs[Module.exinputsNumR][Module.exinputsNumC][0] = idVal;
        											 Module.exinputs[Module.exinputsNumR][Module.exinputsNumC][1] = (char*)'0';//x
        											 Module.exinputs[Module.exinputsNumR][Module.exinputsNumC][5] = (char*)'0';//n4
        											 
												 Module.exinputsNumT[Module.exinputsNumR][Module.exinputsNumC][3] = -1;//n4
        											 
        											 Module.exinputsStore[Module.exinputsNumR]++;
        											 Module.exinputsNumC ++;}
	 | id LABRACKET exiaidn1 RABRACKET LSQBRACKET exiaidn3 COLON exiaidn4 RSQBRACKET       {/*a<num>[num:num]*/
												 Module.exinputs[Module.exinputsNumR][Module.exinputsNumC][0] = idVal;
        											 Module.exinputs[Module.exinputsNumR][Module.exinputsNumC][1] = (char*)'0';//x
        											 Module.exinputs[Module.exinputsNumR][Module.exinputsNumC][3] = (char*)'0';//n2
        											 
												 Module.exinputsNumT[Module.exinputsNumR][Module.exinputsNumC][1] = -1;//n2
        											 
        											 Module.exinputsStore[Module.exinputsNumR]++;
        											 Module.exinputsNumC ++;}
	 ;
exiaidn1 : NUMBER {Module.exinputs[Module.exinputsNumR][Module.exinputsNumC][2] = numVal;
		   Module.exinputsNumT[Module.exinputsNumR][Module.exinputsNumC][0] = atoi(numVal) ;//n1
		   }
	 ;
exiaidn2 : NUMBER {Module.exinputs[Module.exinputsNumR][Module.exinputsNumC][3] = numVal;
		   Module.exinputsNumT[Module.exinputsNumR][Module.exinputsNumC][1] = atoi(numVal);//n2
		   }
	 ;
exiaidn3 : NUMBER {Module.exinputs[Module.exinputsNumR][Module.exinputsNumC][4] = numVal;
		   Module.exinputsNumT[Module.exinputsNumR][Module.exinputsNumC][2] = atoi(numVal);//n3
		   }
	 ;
exiaidn4 : NUMBER {Module.exinputs[Module.exinputsNumR][Module.exinputsNumC][5] = numVal;
		   Module.exinputsNumT[Module.exinputsNumR][Module.exinputsNumC][3] = atoi(numVal);//n4
		   }
	 ;

/*end of line 6 ----------------------------------------*/

/*line 7 : <outputs> ::= OUTPUTS: <aid> {; <aid>} *
  define el formato de una salida                 */
outputs	: OUTPUTS COLON oaid outputsx PERIOD 
	| OUTPUTS COLON oaid          PERIOD 
	;
outputsx : SEMICOLON oaid        
	| outputsx SEMICOLON oaid 
	;
oaid	: id 			 {Module.outputs[Module.outputsNumR][0] = idVal;
			          Module.outputs[Module.outputsNumR][1] = "0";
				  Module.outputsNum[Module.outputsNumR] = atoi(Module.outputs[Module.outputsNumR][1]);
				  Module.outputsNumR++;}
	| id LABRACKET NUMBER RABRACKET {Module.outputs[Module.outputsNumR][0] = idVal;
			          Module.outputs[Module.outputsNumR][1] = numVal;
				  Module.outputsNum[Module.outputsNumR] = atoi(Module.outputs[Module.outputsNumR][1]);
				  Module.outputsNumR++;}
	;

/*end of line 7 ----------------------------------*/

/*line 8 : <buses>    ::= BUSES:   <aid> {; <aid>}.  *
  se encarga de definir el formato de un bus de datos*/
buses   : BUSES COLON baid busesx PERIOD
	| BUSES COLON baid        PERIOD
	;
busesx  : SEMICOLON baid        
	| busesx SEMICOLON baid 
	;
baid:     id           {Module.buses[Module.busesNumR][0]=idVal;
			Module.buses[Module.busesNumR][1]="0";
			Module.buses[Module.busesNumR][2]="0";
			Module.busesNum[Module.busesNumR][1] = atoi(Module.buses[Module.busesNumR][1]);
			Module.busesNum[Module.busesNumR][2] = atoi(Module.buses[Module.busesNumR][2]);
			Module.busesNumR ++;}
      	| id LABRACKET baidn1 RABRACKET      {Module.buses[Module.busesNumR][0]=idVal;
					      Module.buses[Module.busesNumR][2]="0";
					      Module.busesNum[Module.busesNumR][2] = atoi(Module.buses[Module.busesNumR][2]);
					      Module.busesNumR ++;}
	| id LABRACKET baidn1 RABRACKET LSQBRACKET baidn2 RSQBRACKET  {Module.buses[Module.busesNumR][0]=idVal;
								      Module.busesNumR ++;}
	;
baidn1	: NUMBER {Module.buses[Module.busesNumR][1]=numVal;
	          Module.busesNum[Module.busesNumR][1] = atoi(Module.buses[Module.busesNumR][1]);
	          }
	;
baidn2	: NUMBER {Module.buses[Module.busesNumR][2]=numVal;
	          Module.busesNum[Module.busesNumR][2] = atoi(Module.buses[Module.busesNumR][2]);
	          }
	;
/*end of line 8 -------------------------------------*/
/*line 10 : <memory> ::= MEMORY: <aid> {; aid} !!!!!!!!!!!!!!!!!!!!!editar!!!!!!!!!!!!!!!!!!!!*/
memory	: MEMORY COLON mid memoryx PERIOD 
	| MEMORY COLON mid         PERIOD 
	;
memoryx : SEMICOLON mid        
	| memoryx SEMICOLON mid 
	;
mid     : id		       {Module.memory[Module.memoryNumR][0]=idVal;
				Module.memory[Module.memoryNumR][1]="0";
				Module.memory[Module.memoryNumR][2]="0";
				Module.memoryNum[Module.memoryNumR][1] = atoi(Module.memory[Module.memoryNumR][1]);
				Module.memoryNum[Module.memoryNumR][2] = atoi(Module.memory[Module.memoryNumR][2]);
				Module.memoryNumR ++;}
	| id LABRACKET mid1 RABRACKET {Module.memory[Module.memoryNumR][0]=idVal;
				       Module.memory[Module.memoryNumR][2]="0";
				       Module.memoryNum[Module.memoryNumR][2] = atoi(Module.memory[Module.memoryNumR][2]);
				       Module.memoryNumR ++;}
	| id LABRACKET mid1 RABRACKET LSQBRACKET mid2 RSQBRACKET {Module.memory[Module.memoryNumR][0]=idVal;
								  Module.memoryNumR ++;}
	;
mid1	: NUMBER{Module.memory[Module.memoryNumR][1]=numVal;
	          Module.memoryNum[Module.memoryNumR][1] = atoi(Module.memory[Module.memoryNumR][1]);}
	;
mid2	: NUMBER{Module.memory[Module.memoryNumR][2]=numVal;
	          Module.memoryNum[Module.memoryNumR][2] = atoi(Module.memory[Module.memoryNumR][2]);}
	;
/*end of line 10 -----------------------------!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!*/

/*line 12 : <aid> ::= id ['<' num '>']['[' num ']'] *
  se encarga de definir el formato en el que se     *
  escibe una variable                               */
/*aid:      id           {}
      //| id    aidy  /*(parece ser que es un arreglo de solo columnas) !! no se ve correcto !!*
	| id aidx       /* variable en forma de arrego (BUS) *
	| id aidx aidy  /* variable en forma de matriz *
	;
aidx	: LABRACKET NUMBER RABRACKET   {}
	;
aidy	: LSQBRACKET NUMBER RSQBRACKET {}
	;	
/*end of line 12 -----------------------------------*/

/*mbody	: BODY fsm logic END  //se define la estructrura del cuerpo del codigo
	| BODY     logic END
	;*/
mbody	: BODY     logic //se define la estructrura del cuerpo del codigo 
	;
	
logic	: logic1
	| logic logic1
	;
	
logic1	: logic1y EQUAL logic2b logic1x
	;
logic1x : PERIOD { Module.ClunitsNumR ++ ;
		   Module.ClunitsNumC = 0;}
	;
	
logic1y : id     { Module.Clunits[Module.ClunitsNumR][Module.ClunitsNumC][0] = idVal;
		   Module.Clunits[Module.ClunitsNumR][Module.ClunitsNumC][1] = (char*)'0';
		   Module.Clunits[Module.ClunitsNumR][Module.ClunitsNumC][2] = (char*)'0';
		   Module.Clunits[Module.ClunitsNumR][Module.ClunitsNumC][3] = (char*)'0';
		   Module.Clunits[Module.ClunitsNumR][Module.ClunitsNumC][4] = (char*)'0';
		   Module.ClunitsNumC ++;
		   Module.ClunitsStore[Module.ClunitsNumR] ++;
		    }
         |id LABRACKET logic1yn1 RABRACKET { /**/
		   Module.Clunits[Module.ClunitsNumR][Module.ClunitsNumC][0] = idVal;
		  // Module.Clunits[Module.ClunitsNumR][Module.ClunitsNumC][1] = numVal;
		   Module.Clunits[Module.ClunitsNumR][Module.ClunitsNumC][2] = (char*)'0';
		   Module.Clunits[Module.ClunitsNumR][Module.ClunitsNumC][3] = (char*)'0';
		   Module.Clunits[Module.ClunitsNumR][Module.ClunitsNumC][4] = (char*)'0';
		   Module.ClunitsNumC ++;
		   Module.ClunitsStore[Module.ClunitsNumR] ++;}
        | id LABRACKET logic1yn1 COLON logic1yn2 RABRACKET {/*a<num:num>*/
		   Module.Clunits[Module.ClunitsNumR][Module.ClunitsNumC][0] = idVal;
		   Module.Clunits[Module.ClunitsNumR][Module.ClunitsNumC][3] = (char*)'0';
		   Module.Clunits[Module.ClunitsNumR][Module.ClunitsNumC][4] = (char*)'0';
		   Module.ClunitsNumC ++;
		   Module.ClunitsStore[Module.ClunitsNumR] ++;}
	;
logic1yn1: NUMBER {Module.Clunits[Module.ClunitsNumR][Module.ClunitsNumC][1] = numVal;}
	;
logic1yn2: NUMBER {Module.Clunits[Module.ClunitsNumR][Module.ClunitsNumC][2] = numVal;}
	;

logic2b : logic2c
	| logic2b logic2c
	;
logic2c : id      {Module.Clunits[Module.ClunitsNumR][Module.ClunitsNumC][0] = idVal;
		   Module.Clunits[Module.ClunitsNumR][Module.ClunitsNumC][1] = (char*)'0';
		   Module.Clunits[Module.ClunitsNumR][Module.ClunitsNumC][2] = (char*)'0';
		   Module.Clunits[Module.ClunitsNumR][Module.ClunitsNumC][3] = (char*)'0';
		   Module.Clunits[Module.ClunitsNumR][Module.ClunitsNumC][4] = (char*)'0';
		   Module.ClunitsNumC ++;
		   Module.ClunitsStore[Module.ClunitsNumR] ++; }
	  |id LABRACKET logic2n1 RABRACKET { //a<num>
		   Module.Clunits[Module.ClunitsNumR][Module.ClunitsNumC][0] = idVal;
		   Module.Clunits[Module.ClunitsNumR][Module.ClunitsNumC][2] = (char*)'0';
		   Module.Clunits[Module.ClunitsNumR][Module.ClunitsNumC][3] = (char*)'0';
		   Module.Clunits[Module.ClunitsNumR][Module.ClunitsNumC][4] = (char*)'0';
		   Module.ClunitsNumC ++;
		   Module.ClunitsStore[Module.ClunitsNumR] ++;}
	  |id LABRACKET logic2n1 RABRACKET LSQBRACKET logic2n3 RSQBRACKET { //a<num>[num]
		   Module.Clunits[Module.ClunitsNumR][Module.ClunitsNumC][0] = idVal;
		   Module.Clunits[Module.ClunitsNumR][Module.ClunitsNumC][2] = (char*)'0';
		   Module.Clunits[Module.ClunitsNumR][Module.ClunitsNumC][4] = (char*)'0';
		   Module.ClunitsNumC ++;
		   Module.ClunitsStore[Module.ClunitsNumR] ++;}
	  |id LABRACKET logic2n1 RABRACKET LSQBRACKET logic2n3 COLON logic2n4 RSQBRACKET { //a<num>[num:num]
		   Module.Clunits[Module.ClunitsNumR][Module.ClunitsNumC][0] = idVal;
		   Module.Clunits[Module.ClunitsNumR][Module.ClunitsNumC][2] = (char*)'0';
		   Module.ClunitsNumC ++;
		   Module.ClunitsStore[Module.ClunitsNumR] ++;}
	  |id LABRACKET logic2n1 COLON logic2n2 RABRACKET { //a<num:num>
		   Module.Clunits[Module.ClunitsNumR][Module.ClunitsNumC][0] = idVal;
		   Module.Clunits[Module.ClunitsNumR][Module.ClunitsNumC][3] = (char*)'0';
		   Module.Clunits[Module.ClunitsNumR][Module.ClunitsNumC][4] = (char*)'0';
		   Module.ClunitsNumC ++;
		   Module.ClunitsStore[Module.ClunitsNumR] ++;}
          |id LABRACKET logic2n1 COLON logic2n2 RABRACKET LSQBRACKET logic2n3 RSQBRACKET { //a<num:num>[num]
		   Module.Clunits[Module.ClunitsNumR][Module.ClunitsNumC][0] = idVal;
		   Module.Clunits[Module.ClunitsNumR][Module.ClunitsNumC][4] = (char*)'0';
		   Module.ClunitsNumC ++;
		   Module.ClunitsStore[Module.ClunitsNumR] ++;}
	  |id LABRACKET logic2n1 COLON logic2n2 RABRACKET LSQBRACKET logic2n3 COLON logic2n4 RSQBRACKET { //a<num:num>[num:num]
		   Module.Clunits[Module.ClunitsNumR][Module.ClunitsNumC][0] = idVal;
		   Module.ClunitsNumC ++;
		   Module.ClunitsStore[Module.ClunitsNumR] ++;}
	| NOT { Module.Clunits[Module.ClunitsNumR][Module.ClunitsNumC][0] = "not";
		   Module.Clunits[Module.ClunitsNumR][Module.ClunitsNumC][1] = (char*)'0';
		   Module.Clunits[Module.ClunitsNumR][Module.ClunitsNumC][2] = (char*)'0';
		   Module.Clunits[Module.ClunitsNumR][Module.ClunitsNumC][3] = (char*)'0';
		   Module.Clunits[Module.ClunitsNumR][Module.ClunitsNumC][4] = (char*)'0';
		Module.ClunitsNumC ++;
		Module.ClunitsStore[Module.ClunitsNumR] ++; }
	| AND { Module.Clunits[Module.ClunitsNumR][Module.ClunitsNumC][0] = "and";
		   Module.Clunits[Module.ClunitsNumR][Module.ClunitsNumC][1] = (char*)'0';
		   Module.Clunits[Module.ClunitsNumR][Module.ClunitsNumC][2] = (char*)'0';
		   Module.Clunits[Module.ClunitsNumR][Module.ClunitsNumC][3] = (char*)'0';
		   Module.Clunits[Module.ClunitsNumR][Module.ClunitsNumC][4] = (char*)'0';
		Module.ClunitsNumC ++;
		Module.ClunitsStore[Module.ClunitsNumR] ++; }
	| NAND{ Module.Clunits[Module.ClunitsNumR][Module.ClunitsNumC][0] = "nand";
		   Module.Clunits[Module.ClunitsNumR][Module.ClunitsNumC][1] = (char*)'0';
		   Module.Clunits[Module.ClunitsNumR][Module.ClunitsNumC][2] = (char*)'0';
		   Module.Clunits[Module.ClunitsNumR][Module.ClunitsNumC][3] = (char*)'0';
		   Module.Clunits[Module.ClunitsNumR][Module.ClunitsNumC][4] = (char*)'0';
		Module.ClunitsNumC ++;
		Module.ClunitsStore[Module.ClunitsNumR] ++; }
	| OR  { Module.Clunits[Module.ClunitsNumR][Module.ClunitsNumC][0] = "or";
		   Module.Clunits[Module.ClunitsNumR][Module.ClunitsNumC][1] = (char*)'0';
		   Module.Clunits[Module.ClunitsNumR][Module.ClunitsNumC][2] = (char*)'0';
		   Module.Clunits[Module.ClunitsNumR][Module.ClunitsNumC][3] = (char*)'0';
		   Module.Clunits[Module.ClunitsNumR][Module.ClunitsNumC][4] = (char*)'0';
		Module.ClunitsNumC ++; 
		Module.ClunitsStore[Module.ClunitsNumR] ++;}
	| NOR { Module.Clunits[Module.ClunitsNumR][Module.ClunitsNumC][0] = "nor";
		   Module.Clunits[Module.ClunitsNumR][Module.ClunitsNumC][1] = (char*)'0';
		   Module.Clunits[Module.ClunitsNumR][Module.ClunitsNumC][2] = (char*)'0';
		   Module.Clunits[Module.ClunitsNumR][Module.ClunitsNumC][3] = (char*)'0';
		   Module.Clunits[Module.ClunitsNumR][Module.ClunitsNumC][4] = (char*)'0';
		Module.ClunitsNumC ++; 
		Module.ClunitsStore[Module.ClunitsNumR] ++;}
	| XOR { Module.Clunits[Module.ClunitsNumR][Module.ClunitsNumC][0] = "xor";
		   Module.Clunits[Module.ClunitsNumR][Module.ClunitsNumC][1] = (char*)'0';
		   Module.Clunits[Module.ClunitsNumR][Module.ClunitsNumC][2] = (char*)'0';
		   Module.Clunits[Module.ClunitsNumR][Module.ClunitsNumC][3] = (char*)'0';
		   Module.Clunits[Module.ClunitsNumR][Module.ClunitsNumC][4] = (char*)'0';
		Module.ClunitsNumC ++; 
		Module.ClunitsStore[Module.ClunitsNumR] ++;}
	| XNOR { Module.Clunits[Module.ClunitsNumR][Module.ClunitsNumC][0] = "xnor";
		   Module.Clunits[Module.ClunitsNumR][Module.ClunitsNumC][1] = (char*)'0';
		   Module.Clunits[Module.ClunitsNumR][Module.ClunitsNumC][2] = (char*)'0';
		   Module.Clunits[Module.ClunitsNumR][Module.ClunitsNumC][3] = (char*)'0';
		   Module.Clunits[Module.ClunitsNumR][Module.ClunitsNumC][4] = (char*)'0';
		Module.ClunitsNumC ++; 
		Module.ClunitsStore[Module.ClunitsNumR] ++;}
	| COLCAT{Module.Clunits[Module.ClunitsNumR][Module.ClunitsNumC][0] = "&";
		   Module.Clunits[Module.ClunitsNumR][Module.ClunitsNumC][1] = (char*)'0';
		   Module.Clunits[Module.ClunitsNumR][Module.ClunitsNumC][2] = (char*)'0';
		   Module.Clunits[Module.ClunitsNumR][Module.ClunitsNumC][3] = (char*)'0';
		   Module.Clunits[Module.ClunitsNumR][Module.ClunitsNumC][4] = (char*)'0';
		   Module.ClunitsNumC ++;
		   Module.ClunitsStore[Module.ClunitsNumR] ++;}
	|  RPARENTESIS {Module.Clunits[Module.ClunitsNumR][Module.ClunitsNumC][0] = ")";
		   Module.Clunits[Module.ClunitsNumR][Module.ClunitsNumC][1] = (char*)'0';
		   Module.Clunits[Module.ClunitsNumR][Module.ClunitsNumC][2] = (char*)'0';
		   Module.Clunits[Module.ClunitsNumR][Module.ClunitsNumC][3] = (char*)'0';
		   Module.Clunits[Module.ClunitsNumR][Module.ClunitsNumC][4] = (char*)'0';
		   Module.ClunitsNumC ++;
		   Module.ClunitsStore[Module.ClunitsNumR] ++; }
	| LPARENTESIS {Module.Clunits[Module.ClunitsNumR][Module.ClunitsNumC][0] = "(";
		   Module.Clunits[Module.ClunitsNumR][Module.ClunitsNumC][1] = (char*)'0';
		   Module.Clunits[Module.ClunitsNumR][Module.ClunitsNumC][2] = (char*)'0';
		   Module.Clunits[Module.ClunitsNumR][Module.ClunitsNumC][3] = (char*)'0';
		   Module.Clunits[Module.ClunitsNumR][Module.ClunitsNumC][4] = (char*)'0';
		   Module.ClunitsNumC ++;
		   Module.ClunitsStore[Module.ClunitsNumR] ++; } 
	
	| LPARENTESIS logic2n1 ENCODE logic2n2 RPARENTESIS{/*'('num '$' num ')' define la codificacion de un numero*/
							   Module.Clunits[Module.ClunitsNumR][Module.ClunitsNumC][0] = (char*)'!';
							   Module.Clunits[Module.ClunitsNumR][Module.ClunitsNumC][3] = (char*)'0';
							   Module.Clunits[Module.ClunitsNumR][Module.ClunitsNumC][4] = (char*)'0';
							   Module.ClunitsNumC ++;
							   Module.ClunitsStore[Module.ClunitsNumR] ++;}
							
	| BINARYC					  {Module.Clunits[Module.ClunitsNumR][Module.ClunitsNumC][0] = (char*)'*';
							   Module.Clunits[Module.ClunitsNumR][Module.ClunitsNumC][1] = numVal;
							   Module.Clunits[Module.ClunitsNumR][Module.ClunitsNumC][2] = (char*)'0';
							   Module.Clunits[Module.ClunitsNumR][Module.ClunitsNumC][3] = (char*)'0';
							   Module.Clunits[Module.ClunitsNumR][Module.ClunitsNumC][4] = (char*)'0';
							   Module.ClunitsNumC ++;
							   Module.ClunitsStore[Module.ClunitsNumR] ++; } 
	| BINARY					  {Module.Clunits[Module.ClunitsNumR][Module.ClunitsNumC][0] = (char*)'"';
							   Module.Clunits[Module.ClunitsNumR][Module.ClunitsNumC][1] = numVal;
							   Module.Clunits[Module.ClunitsNumR][Module.ClunitsNumC][2] = (char*)'0';
							   Module.Clunits[Module.ClunitsNumR][Module.ClunitsNumC][3] = (char*)'0';
							   Module.Clunits[Module.ClunitsNumR][Module.ClunitsNumC][4] = (char*)'0';
							   Module.ClunitsNumC ++;
							   Module.ClunitsStore[Module.ClunitsNumR] ++; } 
	| op  LPARENTESIS oper1 COLCAT oper2 RPARENTESIS { 
							   Module.Clunits[Module.ClunitsNumR][Module.ClunitsNumC][2] = (char*)'0';
							   Module.Clunits[Module.ClunitsNumR][Module.ClunitsNumC][3] = (char*)'0';
							   Module.Clunits[Module.ClunitsNumR][Module.ClunitsNumC][4] = (char*)'0';
							   Module.ClunitsNumC ++;
							   Module.ClunitsStore[Module.ClunitsNumR] ++; } 
	;

op	: ADD {Module.Clunits[Module.ClunitsNumR][Module.ClunitsNumC][0] = (char*)'+';
	       Module.Clunits[Module.ClunitsNumR][Module.ClunitsNumC][1] = (char*)'0';}

	| SUB {Module.Clunits[Module.ClunitsNumR][Module.ClunitsNumC][0] = (char*)'+';
	       Module.Clunits[Module.ClunitsNumR][Module.ClunitsNumC][1] = (char*)'1';}
	;
/*listnum	: oper 
	| oper cnumber
	;
*/
/*cnumber : COLCAT oper 
	| cnumber COLCAT oper
	;*/
oper1 	: LPARENTESIS opern1 ENCODE opern2 RPARENTESIS     {Module.Arith[Module.ClunitsNumR][0] = (char*)'0';/*nombre*/}
							 
	| id						   {Module.Arith[Module.ClunitsNumR][0] = idVal;/*nombre*/
							    Module.Arith[Module.ClunitsNumR][1] = (char*)'0';
							    Module.Arith[Module.ClunitsNumR][2] = (char*)'0';}
							    
	| id LABRACKET opern1 RABRACKET		           {Module.Arith[Module.ClunitsNumR][0] = idVal;/*nombre*/
							    Module.Arith[Module.ClunitsNumR][2] = (char*)'0';}
							    
	| id LABRACKET opern1 COLON opern2 RABRACKET       {Module.Arith[Module.ClunitsNumR][0] = idVal;/*nombre*/}
	;

oper2 	: LPARENTESIS opern3 ENCODE opern4 RPARENTESIS     {Module.Arith[Module.ClunitsNumR][3] = (char*)'0';/*nombre*/}

	| id						   {Module.Arith[Module.ClunitsNumR][3] = idVal;/*nombre*/
							    Module.Arith[Module.ClunitsNumR][4] = (char*)'0';
							    Module.Arith[Module.ClunitsNumR][5] = (char*)'0';}
							    
	| id LABRACKET opern3 RABRACKET	         	   {Module.Arith[Module.ClunitsNumR][3] = idVal;/*nombre*/
							    Module.Arith[Module.ClunitsNumR][4] = (char*)'0';}
							    
	| id LABRACKET opern3 COLON opern4 RABRACKET    {Module.Arith[Module.ClunitsNumR][3] = idVal;/*nombre*/}
	;

opern1	: NUMBER {Module.Arith[Module.ClunitsNumR][1] = numVal;}
	;

opern2	: NUMBER {Module.Arith[Module.ClunitsNumR][2] = numVal;}
	;
	
opern3	: NUMBER {Module.Arith[Module.ClunitsNumR][4] = numVal;}
	;

opern4	: NUMBER {Module.Arith[Module.ClunitsNumR][5] = numVal;}
	;
	
/*|||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||*/
/*oper1x 	: LPARENTESIS opern1x ENCODE opern2x RPARENTESIS     {Module.Arithx[Module.ClunitsNumR][0] = (char*)'0';/*nombre}
							 
	| id						   {Module.Arithx[Module.ClunitsNumR][0] = idVal;/*nombre
							    Module.Arithx[Module.ClunitsNumR][1] = (char*)'0';
							    Module.Arithx[Module.ClunitsNumR][2] = (char*)'0';}
							    
	| id LABRACKET opern1x RABRACKET		           {Module.Arithx[Module.ClunitsNumR][0] = idVal;/*nombre
							    Module.Arithx[Module.ClunitsNumR][2] = (char*)'0';}
							    
	| id LABRACKET opern1x COLON opern2x RABRACKET       {Module.Arithx[Module.ClunitsNumR][0] = idVal;/*nombre}
	;

oper2x 	: LPARENTESIS opern3x ENCODE opern4x RPARENTESIS     {Module.Arithx[Module.ClunitsNumR][3] = (char*)'0';/*nombre}

	| id						   {Module.Arithx[Module.ClunitsNumR][3] = idVal;/*nombre
							    Module.Arithx[Module.ClunitsNumR][4] = (char*)'0';
							    Module.Arithx[Module.ClunitsNumR][5] = (char*)'0';}
							    
	| id LABRACKET opern3x RABRACKET	         	   {Module.Arithx[Module.ClunitsNumR][3] = idVal;/*nombre
							    Module.Arithx[Module.ClunitsNumR][4] = (char*)'0';}
							    
	| id LABRACKET opern3x COLON opern4x RABRACKET    {Module.Arithx[Module.ClunitsNumR][3] = idVal;/*nombre}
	;

opern1x	: NUMBER {Module.Arithx[Module.ClunitsNumR][1] = numVal;}
	;

opern2x	: NUMBER {Module.Arithx[Module.ClunitsNumR][2] = numVal;}
	;
	
opern3x	: NUMBER {Module.Arithx[Module.ClunitsNumR][4] = numVal;}
	;

opern4x	: NUMBER {Module.Arithx[Module.ClunitsNumR][5] = numVal;}
	;
/*------------------------------------fsm---------------------------------------------------------------------------------------------------------------------------*/
/*fsm	: fsm1 ENDSEQUENCE
	;
fsm1	: fsm2
	| fsm1 fsm2
	;                                      
							    /*operaciones validas en fsm 
						 	     (cuando no se especifica la transicion se va al siguiente estado)*/                 
/*fsm2	: stateNum PERIOD operate PERIOD cond  statend	    /*num. operacion. 
						              => condition*/
/*	| stateNum PERIOD                cond  statend 	    /*num. 
						              => condition*/
/*	| stateNum PERIOD operate  	       statend      /*num. operation. */
	;
/*statend : PERIOD {Module.fsmNum ++;
		  //Module.fsmTransCharCondNum[Module.fsmNum] = 0;}
	;*/
/*stateNum: NUMBER {Module.fsmStateNum[Module.fsmNum] = atoi(numVal);}
	;
operate : operate2 
	| operate2 operate1
	; 
////////////////////////////////////////////////////////////////////////////////////////////////////////	
cond	: JUMP LSQBRACKET logicv cond1 RSQBRACKET SLASH LSQBRACKET transN tran RSQBRACKET
	| JUMP LSQBRACKET logicv       RSQBRACKET SLASH LSQBRACKET transN      RSQBRACKET
	| JUMP LSQBRACKET transN RSQBRACKET
	;
	
cond1	: cond1x logicv2
	| cond1 cond1x logicv2
	;
cond1x  : SEMICOLON {Module.fsmTransCondNum[Module.fsmNum]++;}
	;
tran	: COLCAT transN
	| tran COLCAT transN
	;
transN	: NUMBER {Module.fsmTransC[Module.fsmNum][Module.fsmTransNum[Module.fsmNum]] = atoi(numVal);
		  Module.fsmTransNum[Module.fsmNum]++;}/*permite detectar la transcion a cualquier otro estado*/
	;
/////////////////////////////////////////////////////////////////////////////////////////////////////////	
/*operate1: SEMICOLON operate2
	| operate1 SEMICOLON operate2
	;
operate2: log1 EQUAL logicv /*se definen las operaciones*/
/*	| log2 TRANSFER logicv
/*	;
/*log1	: id 											   /*a*/
/*	| id LABRACKET NUMBER RABRACKET								   /*a<num>*/
/*	| id LABRACKET NUMBER RABRACKET LSQBRACKET NUMBER RSQBRACKET 			           /*a<num>[num]*/
/*	| id LABRACKET NUMBER COLON NUMBER RABRACKET			 			   /*a <num:num>*/
/*	| id LABRACKET NUMBER COLON NUMBER RABRACKET LSQBRACKET NUMBER COLON NUMBER RSQBRACKET     /*a<num:num>[num:num]*/
/*	;
log2	: id 											   /*a*/
/*	| id LABRACKET NUMBER RABRACKET								   /*a<num>*/
/*	| id LABRACKET NUMBER RABRACKET LSQBRACKET NUMBER RSQBRACKET			           /*a<num>[num]*/
/*	| id LABRACKET NUMBER RABRACKET LSQBRACKET NUMBER COLON NUMBER RSQBRACKET	           /*a<num>[num:num]*/
/*	| id LABRACKET NUMBER RABRACKET LSQBRACKET 'x' RSQBRACKET  			   	   /*a<num>[x] operacion creada para transferir
												    registros sin afectar su tamaño */
/*	;
logicv	: logicv1
	| logicv logicv1
	;
logicv1	: id      
	| id LABRACKET logic2n1 RABRACKET 
	| id LABRACKET logic2n1 RABRACKET LSQBRACKET logic2n3 RSQBRACKET 
	| id LABRACKET logic2n1 RABRACKET LSQBRACKET logic2n3 COLON logic2n4 RSQBRACKET 
	| id LABRACKET logic2n1 COLON logic2n2 RABRACKET 
        | id LABRACKET logic2n1 COLON logic2n2 RABRACKET LSQBRACKET logic2n3 RSQBRACKET 
	| id LABRACKET logic2n1 COLON logic2n2 RABRACKET LSQBRACKET logic2n3 COLON logic2n4 RSQBRACKET 
	| NOT 
	| AND 
	| NAND
	| OR  
	| NOR 
	| XOR
	| XNOR 
	| COLCAT
	| RPARENTESIS 
	| LPARENTESIS 
	| LPARENTESIS NUMBER ENCODE NUMBER RPARENTESIS/*'('num '$' num ')' define la codificacion de un numero*/
/*	| BINARY/* '101010010110101' descripcion de un numero binario*/
/*	| BINARYC /*'1' | '0'*/
/*	;
logicv2	: logicv2x
	| logicv2 logicv2x
	;
logicv2x: id                              {//a
					   Module.fsmTransCondition[Module.fsmNum][Module.fsmTransCondNum[Module.fsmNum]][Module.fsmTransCharCondNum[Module.fsmNum]][0]= idVal;
					   Module.fsmTransCondition[Module.fsmNum][Module.fsmTransCondNum[Module.fsmNum]][Module.fsmTransCharCondNum[Module.fsmNum]][1]= (char*)'0';
					   Module.fsmTransCondition[Module.fsmNum][Module.fsmTransCondNum[Module.fsmNum]][Module.fsmTransCharCondNum[Module.fsmNum]][2]= (char*)'0';
					   Module.fsmTransCondition[Module.fsmNum][Module.fsmTransCondNum[Module.fsmNum]][Module.fsmTransCharCondNum[Module.fsmNum]][3]= (char*)'0';
					   Module.fsmTransCondition[Module.fsmNum][Module.fsmTransCondNum[Module.fsmNum]][Module.fsmTransCharCondNum[Module.fsmNum]][4]= (char*)'0';
					   Module.fsmTransCharCondNum[Module.fsmNum]++;}
	/*------------------------------------------------------------------------------------------------------------------------------------------------------------------------------*/
	/*| id LABRACKET logic2x1 RABRACKET  {//a<num>
					  Module.fsmTransCondition[Module.fsmNum][Module.fsmTransCondNum[Module.fsmNum]][Module.fsmTransCharCondNum[Module.fsmNum]][0]= idVal;
				          Module.fsmTransCondition[Module.fsmNum][Module.fsmTransCondNum[Module.fsmNum]][Module.fsmTransCharCondNum[Module.fsmNum]][1]= (char*)'0';
				          Module.fsmTransCondition[Module.fsmNum][Module.fsmTransCondNum[Module.fsmNum]][Module.fsmTransCharCondNum[Module.fsmNum]][2]= (char*)'0';
				          Module.fsmTransCondition[Module.fsmNum][Module.fsmTransCondNum[Module.fsmNum]][Module.fsmTransCharCondNum[Module.fsmNum]][3]= (char*)'0';
				          Module.fsmTransCondition[Module.fsmNum][Module.fsmTransCondNum[Module.fsmNum]][Module.fsmTransCharCondNum[Module.fsmNum]][4]= (char*)'0';
				          Module.fsmTransCharCondNum[Module.fsmNum]++;}
	| id LABRACKET logic2x1 RABRACKET LSQBRACKET logic2x3 RSQBRACKET {//a<num>[num]
								      Module.fsmTransCondition[Module.fsmNum][Module.fsmTransCondNum[Module.fsmNum]][Module.fsmTransCharCondNum[Module.fsmNum]][0]= idVal;
							              Module.fsmTransCondition[Module.fsmNum][Module.fsmTransCondNum[Module.fsmNum]][Module.fsmTransCharCondNum[Module.fsmNum]][1]= (char*)'0';
							              Module.fsmTransCondition[Module.fsmNum][Module.fsmTransCondNum[Module.fsmNum]][Module.fsmTransCharCondNum[Module.fsmNum]][2]= (char*)'0';
							              Module.fsmTransCondition[Module.fsmNum][Module.fsmTransCondNum[Module.fsmNum]][Module.fsmTransCharCondNum[Module.fsmNum]][3]= (char*)'0';
							              Module.fsmTransCondition[Module.fsmNum][Module.fsmTransCondNum[Module.fsmNum]][Module.fsmTransCharCondNum[Module.fsmNum]][4]= (char*)'0';
	       							      Module.fsmTransCharCondNum[Module.fsmNum]++;} 
	| id LABRACKET logic2x1 RABRACKET LSQBRACKET logic2x3 COLON logic2x4 RSQBRACKET{//a<num>[num:num]
								      Module.fsmTransCondition[Module.fsmNum][Module.fsmTransCondNum[Module.fsmNum]][Module.fsmTransCharCondNum[Module.fsmNum]][0]= idVal;
							              Module.fsmTransCondition[Module.fsmNum][Module.fsmTransCondNum[Module.fsmNum]][Module.fsmTransCharCondNum[Module.fsmNum]][1]= (char*)'0';
							              Module.fsmTransCondition[Module.fsmNum][Module.fsmTransCondNum[Module.fsmNum]][Module.fsmTransCharCondNum[Module.fsmNum]][2]= (char*)'0';
							              Module.fsmTransCondition[Module.fsmNum][Module.fsmTransCondNum[Module.fsmNum]][Module.fsmTransCharCondNum[Module.fsmNum]][3]= (char*)'0';
							              Module.fsmTransCondition[Module.fsmNum][Module.fsmTransCondNum[Module.fsmNum]][Module.fsmTransCharCondNum[Module.fsmNum]][4]= (char*)'0';
	       							      Module.fsmTransCharCondNum[Module.fsmNum]++;} 
	| id LABRACKET logic2x1 COLON logic2x2 RABRACKET {//a<num:num>
	      Module.fsmTransCondition[Module.fsmNum][Module.fsmTransCondNum[Module.fsmNum]][Module.fsmTransCharCondNum[Module.fsmNum]][0]= idVal;
	      Module.fsmTransCondition[Module.fsmNum][Module.fsmTransCondNum[Module.fsmNum]][Module.fsmTransCharCondNum[Module.fsmNum]][1]= (char*)'0';
	      Module.fsmTransCondition[Module.fsmNum][Module.fsmTransCondNum[Module.fsmNum]][Module.fsmTransCharCondNum[Module.fsmNum]][2]= (char*)'0';
	      Module.fsmTransCondition[Module.fsmNum][Module.fsmTransCondNum[Module.fsmNum]][Module.fsmTransCharCondNum[Module.fsmNum]][3]= (char*)'0';
	      Module.fsmTransCondition[Module.fsmNum][Module.fsmTransCondNum[Module.fsmNum]][Module.fsmTransCharCondNum[Module.fsmNum]][4]= (char*)'0';
	      Module.fsmTransCharCondNum[Module.fsmNum]++;} 
        | id LABRACKET logic2x1 COLON logic2x2 RABRACKET LSQBRACKET logic2x3 RSQBRACKET {//a<num:num>[num]
								      Module.fsmTransCondition[Module.fsmNum][Module.fsmTransCondNum[Module.fsmNum]][Module.fsmTransCharCondNum[Module.fsmNum]][0]= idVal;
							              Module.fsmTransCondition[Module.fsmNum][Module.fsmTransCondNum[Module.fsmNum]][Module.fsmTransCharCondNum[Module.fsmNum]][1]= (char*)'0';
							              Module.fsmTransCondition[Module.fsmNum][Module.fsmTransCondNum[Module.fsmNum]][Module.fsmTransCharCondNum[Module.fsmNum]][2]= (char*)'0';
							              Module.fsmTransCondition[Module.fsmNum][Module.fsmTransCondNum[Module.fsmNum]][Module.fsmTransCharCondNum[Module.fsmNum]][3]= (char*)'0';
							              Module.fsmTransCondition[Module.fsmNum][Module.fsmTransCondNum[Module.fsmNum]][Module.fsmTransCharCondNum[Module.fsmNum]][4]= (char*)'0';
	       							      Module.fsmTransCharCondNum[Module.fsmNum]++;} 
	| id LABRACKET logic2x1 COLON logic2x2 RABRACKET LSQBRACKET logic2x3 COLON logic2x4 RSQBRACKET {//a<num:num>[num:num]
								      Module.fsmTransCondition[Module.fsmNum][Module.fsmTransCondNum[Module.fsmNum]][Module.fsmTransCharCondNum[Module.fsmNum]][0]= idVal;
							              Module.fsmTransCondition[Module.fsmNum][Module.fsmTransCondNum[Module.fsmNum]][Module.fsmTransCharCondNum[Module.fsmNum]][1]= (char*)'0';
							              Module.fsmTransCondition[Module.fsmNum][Module.fsmTransCondNum[Module.fsmNum]][Module.fsmTransCharCondNum[Module.fsmNum]][2]= (char*)'0';
							              Module.fsmTransCondition[Module.fsmNum][Module.fsmTransCondNum[Module.fsmNum]][Module.fsmTransCharCondNum[Module.fsmNum]][3]= (char*)'0';
							              Module.fsmTransCondition[Module.fsmNum][Module.fsmTransCondNum[Module.fsmNum]][Module.fsmTransCharCondNum[Module.fsmNum]][4]= (char*)'0';
	       							      Module.fsmTransCharCondNum[Module.fsmNum]++;} 
	
	 /*-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------*/
	/*| NOT {Module.fsmTransCondition[Module.fsmNum][Module.fsmTransCondNum[Module.fsmNum]][Module.fsmTransCharCondNum[Module.fsmNum]][0]= "not";
	       Module.fsmTransCondition[Module.fsmNum][Module.fsmTransCondNum[Module.fsmNum]][Module.fsmTransCharCondNum[Module.fsmNum]][1]= (char*)'0';
	       Module.fsmTransCondition[Module.fsmNum][Module.fsmTransCondNum[Module.fsmNum]][Module.fsmTransCharCondNum[Module.fsmNum]][2]= (char*)'0';
	       Module.fsmTransCondition[Module.fsmNum][Module.fsmTransCondNum[Module.fsmNum]][Module.fsmTransCharCondNum[Module.fsmNum]][3]= (char*)'0';
	       Module.fsmTransCondition[Module.fsmNum][Module.fsmTransCondNum[Module.fsmNum]][Module.fsmTransCharCondNum[Module.fsmNum]][4]= (char*)'0';
	       Module.fsmTransCharCondNum[Module.fsmNum]++;}
	| AND {Module.fsmTransCondition[Module.fsmNum][Module.fsmTransCondNum[Module.fsmNum]][Module.fsmTransCharCondNum[Module.fsmNum]][0]= "and";
	       Module.fsmTransCondition[Module.fsmNum][Module.fsmTransCondNum[Module.fsmNum]][Module.fsmTransCharCondNum[Module.fsmNum]][1]= (char*)'0';
	       Module.fsmTransCondition[Module.fsmNum][Module.fsmTransCondNum[Module.fsmNum]][Module.fsmTransCharCondNum[Module.fsmNum]][2]= (char*)'0';
	       Module.fsmTransCondition[Module.fsmNum][Module.fsmTransCondNum[Module.fsmNum]][Module.fsmTransCharCondNum[Module.fsmNum]][3]= (char*)'0';
	       Module.fsmTransCondition[Module.fsmNum][Module.fsmTransCondNum[Module.fsmNum]][Module.fsmTransCharCondNum[Module.fsmNum]][4]= (char*)'0';
	       Module.fsmTransCharCondNum[Module.fsmNum]++;}
	| NAND {Module.fsmTransCondition[Module.fsmNum][Module.fsmTransCondNum[Module.fsmNum]][Module.fsmTransCharCondNum[Module.fsmNum]][0]= "nand";
	       Module.fsmTransCondition[Module.fsmNum][Module.fsmTransCondNum[Module.fsmNum]][Module.fsmTransCharCondNum[Module.fsmNum]][1]= (char*)'0';
	       Module.fsmTransCondition[Module.fsmNum][Module.fsmTransCondNum[Module.fsmNum]][Module.fsmTransCharCondNum[Module.fsmNum]][2]= (char*)'0';
	       Module.fsmTransCondition[Module.fsmNum][Module.fsmTransCondNum[Module.fsmNum]][Module.fsmTransCharCondNum[Module.fsmNum]][3]= (char*)'0';
	       Module.fsmTransCondition[Module.fsmNum][Module.fsmTransCondNum[Module.fsmNum]][Module.fsmTransCharCondNum[Module.fsmNum]][4]= (char*)'0';
	       Module.fsmTransCharCondNum[Module.fsmNum]++;}
	| OR  {Module.fsmTransCondition[Module.fsmNum][Module.fsmTransCondNum[Module.fsmNum]][Module.fsmTransCharCondNum[Module.fsmNum]][0]= "or";
	       Module.fsmTransCondition[Module.fsmNum][Module.fsmTransCondNum[Module.fsmNum]][Module.fsmTransCharCondNum[Module.fsmNum]][1]= (char*)'0';
	       Module.fsmTransCondition[Module.fsmNum][Module.fsmTransCondNum[Module.fsmNum]][Module.fsmTransCharCondNum[Module.fsmNum]][2]= (char*)'0';
	       Module.fsmTransCondition[Module.fsmNum][Module.fsmTransCondNum[Module.fsmNum]][Module.fsmTransCharCondNum[Module.fsmNum]][3]= (char*)'0';
	       Module.fsmTransCondition[Module.fsmNum][Module.fsmTransCondNum[Module.fsmNum]][Module.fsmTransCharCondNum[Module.fsmNum]][4]= (char*)'0';
	       Module.fsmTransCharCondNum[Module.fsmNum]++;}
	| NOR {Module.fsmTransCondition[Module.fsmNum][Module.fsmTransCondNum[Module.fsmNum]][Module.fsmTransCharCondNum[Module.fsmNum]][0]= "nor";
	       Module.fsmTransCondition[Module.fsmNum][Module.fsmTransCondNum[Module.fsmNum]][Module.fsmTransCharCondNum[Module.fsmNum]][1]= (char*)'0';
	       Module.fsmTransCondition[Module.fsmNum][Module.fsmTransCondNum[Module.fsmNum]][Module.fsmTransCharCondNum[Module.fsmNum]][2]= (char*)'0';
	       Module.fsmTransCondition[Module.fsmNum][Module.fsmTransCondNum[Module.fsmNum]][Module.fsmTransCharCondNum[Module.fsmNum]][3]= (char*)'0';
	       Module.fsmTransCondition[Module.fsmNum][Module.fsmTransCondNum[Module.fsmNum]][Module.fsmTransCharCondNum[Module.fsmNum]][4]= (char*)'0';
	       Module.fsmTransCharCondNum[Module.fsmNum]++;}
	| XOR {Module.fsmTransCondition[Module.fsmNum][Module.fsmTransCondNum[Module.fsmNum]][Module.fsmTransCharCondNum[Module.fsmNum]][0]= "xor";
	       Module.fsmTransCondition[Module.fsmNum][Module.fsmTransCondNum[Module.fsmNum]][Module.fsmTransCharCondNum[Module.fsmNum]][1]= (char*)'0';
	       Module.fsmTransCondition[Module.fsmNum][Module.fsmTransCondNum[Module.fsmNum]][Module.fsmTransCharCondNum[Module.fsmNum]][2]= (char*)'0';
	       Module.fsmTransCondition[Module.fsmNum][Module.fsmTransCondNum[Module.fsmNum]][Module.fsmTransCharCondNum[Module.fsmNum]][3]= (char*)'0';
	       Module.fsmTransCondition[Module.fsmNum][Module.fsmTransCondNum[Module.fsmNum]][Module.fsmTransCharCondNum[Module.fsmNum]][4]= (char*)'0';
	       Module.fsmTransCharCondNum[Module.fsmNum]++;}
	| XNOR{Module.fsmTransCondition[Module.fsmNum][Module.fsmTransCondNum[Module.fsmNum]][Module.fsmTransCharCondNum[Module.fsmNum]][0]= "xnor";
	       Module.fsmTransCondition[Module.fsmNum][Module.fsmTransCondNum[Module.fsmNum]][Module.fsmTransCharCondNum[Module.fsmNum]][1]= (char*)'0';
	       Module.fsmTransCondition[Module.fsmNum][Module.fsmTransCondNum[Module.fsmNum]][Module.fsmTransCharCondNum[Module.fsmNum]][2]= (char*)'0';
	       Module.fsmTransCondition[Module.fsmNum][Module.fsmTransCondNum[Module.fsmNum]][Module.fsmTransCharCondNum[Module.fsmNum]][3]= (char*)'0';
	       Module.fsmTransCondition[Module.fsmNum][Module.fsmTransCondNum[Module.fsmNum]][Module.fsmTransCharCondNum[Module.fsmNum]][4]= (char*)'0';
	       Module.fsmTransCharCondNum[Module.fsmNum]++;} 
	| RPARENTESIS {Module.fsmTransCondition[Module.fsmNum][Module.fsmTransCondNum[Module.fsmNum]][Module.fsmTransCharCondNum[Module.fsmNum]][0]= ")";
		       Module.fsmTransCondition[Module.fsmNum][Module.fsmTransCondNum[Module.fsmNum]][Module.fsmTransCharCondNum[Module.fsmNum]][1]= (char*)'0';
		       Module.fsmTransCondition[Module.fsmNum][Module.fsmTransCondNum[Module.fsmNum]][Module.fsmTransCharCondNum[Module.fsmNum]][2]= (char*)'0';
		       Module.fsmTransCondition[Module.fsmNum][Module.fsmTransCondNum[Module.fsmNum]][Module.fsmTransCharCondNum[Module.fsmNum]][3]= (char*)'0';
		       Module.fsmTransCondition[Module.fsmNum][Module.fsmTransCondNum[Module.fsmNum]][Module.fsmTransCharCondNum[Module.fsmNum]][4]= (char*)'0';
		       Module.fsmTransCharCondNum[Module.fsmNum]++;} 
	| LPARENTESIS {Module.fsmTransCondition[Module.fsmNum][Module.fsmTransCondNum[Module.fsmNum]][Module.fsmTransCharCondNum[Module.fsmNum]][0]= "(";
		       Module.fsmTransCondition[Module.fsmNum][Module.fsmTransCondNum[Module.fsmNum]][Module.fsmTransCharCondNum[Module.fsmNum]][1]= (char*)'0';
		       Module.fsmTransCondition[Module.fsmNum][Module.fsmTransCondNum[Module.fsmNum]][Module.fsmTransCharCondNum[Module.fsmNum]][2]= (char*)'0';
		       Module.fsmTransCondition[Module.fsmNum][Module.fsmTransCondNum[Module.fsmNum]][Module.fsmTransCharCondNum[Module.fsmNum]][3]= (char*)'0';
		       Module.fsmTransCondition[Module.fsmNum][Module.fsmTransCondNum[Module.fsmNum]][Module.fsmTransCharCondNum[Module.fsmNum]][4]= (char*)'0';
		       Module.fsmTransCharCondNum[Module.fsmNum]++;}
	;
logic2x1: NUMBER {Module.fsmTransCondition[Module.fsmNum][Module.fsmTransCondNum[Module.fsmNum]][Module.fsmTransCharCondNum[Module.fsmNum]][1]= numVal;
		  Module.fsmTransCharCondNum[Module.fsmNum]++;}
	;
logic2x2: NUMBER {Module.fsmTransCondition[Module.fsmNum][Module.fsmTransCondNum[Module.fsmNum]][Module.fsmTransCharCondNum[Module.fsmNum]][2]= numVal;
		  Module.fsmTransCharCondNum[Module.fsmNum]++;}
	;
logic2x3: NUMBER {Module.fsmTransCondition[Module.fsmNum][Module.fsmTransCondNum[Module.fsmNum]][Module.fsmTransCharCondNum[Module.fsmNum]][3]= numVal;
		  Module.fsmTransCharCondNum[Module.fsmNum]++;}
	;
logic2x4: NUMBER {Module.fsmTransCondition[Module.fsmNum][Module.fsmTransCondNum[Module.fsmNum]][Module.fsmTransCharCondNum[Module.fsmNum]][4]= numVal;
		  Module.fsmTransCharCondNum[Module.fsmNum]++;}
	;

/*------------------------------------end fsm-----------------------------------------------------------------------------------------------------------------------------*/



logic2n1: NUMBER {Module.Clunits[Module.ClunitsNumR][Module.ClunitsNumC][1] = numVal;}
	;
logic2n3: NUMBER {Module.Clunits[Module.ClunitsNumR][Module.ClunitsNumC][3] = numVal;}
	;
logic2n2: NUMBER {Module.Clunits[Module.ClunitsNumR][Module.ClunitsNumC][2] = numVal;}
	;
logic2n4: NUMBER {Module.Clunits[Module.ClunitsNumR][Module.ClunitsNumC][4] = numVal;}
	;
/*********************************************************/

/*endline :<mend> ::= ENDMODULE.*/
mend 	: ENDMODULE PERIOD
	;
/**/
%%
void yyerror(char *s )
{
	printf("\n%d: %s at %s\n", lineno, s, yytext);
} /* error */
