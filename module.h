#ifndef MODULE_H
#define MODULE_H

#define char_long 150
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <stdbool.h>


typedef struct Module_Composition /*se encarga de copiar */
    { int   moduleNum;
      char *moduleName;          /**/
      
      int  inputsNumR;
      int  inputsNum[char_long];
      char *inputs[char_long][2];
      
      int  exinputsNumR;
      int  exinputsNumC;
      int  exinputsNumT[char_long][char_long][4];
      int  exinputsStore[char_long];    /* cada fila indica el numero de variables que  *
                                           se almacenan dentro de un arreglo de exinputs*/
                                              
      char *exinputs[char_long][char_long][6];/* almacena los nombres de cada entrada externa * 
                                               * y lo de cada uno de sus miembros             *
                                               * a                                            *
	                                       * a<num>                                       *
	                                       * a<num>[num]                                  *
	                                       * a<num:num>                                   *
	                                       * id:id[{a<num>,a<num:num>[num]}]              *
	                                       * a<num>[num:num]                              */
	                                    
      int outputsNumR;
      int  outputsNum[char_long];
      char *outputs[char_long][2];
      
      int busesNumR;
      int busesNum[char_long][3];
      char *buses[char_long][3];
      
      int memoryNumR;
      int  memoryNum[char_long][3];
      char *memory[char_long][3];
      bool memory1;
      bool memory2;
      bool memory3;
      
      int   ClunitsNumR;
      int   ClunitsNumC;
      int   ClunitsStore[char_long];
      char* Clunits[char_long][char_long][5];
      
      char* Arith[char_long][6];
      char* Arithx[char_long][6];
    /*  int   ArithNumR;
      int   ArithNumC;
      char* ArithOperation[char_long][char_long];
      */
      //--FSM
      //--hay que cambiar el metodo como se hace eso
      //int fsmNum;
      //int fsmStateNum[char_long];//almacena el numero del estado en el que estoy
      //int fsmTransOpNum[char_long];//almacena el numero de operaciones realizadas para solicitar una transicion
      
      //int fsmTransNum[char_long];	  			  /*almacena el numero de transiciones que se tengan en cada estado*/ 
      //int fsmTransC[char_long][char_long];			  /*almacena el estado al que se quiere mover con dicha operacion
      //					    			    filas para estados y columnas para posiciones individuales*/
      //int fsmTransCondNum[char_long];     			  /*almacena el numero de condiciones para que se de una transicion*/
      //int fsmTransCharCondNum[char_long];
      //char *fsmTransCondition[char_long][char_long][char_long][5];/*almacena las condiciones individualmente segun el estado
      //					         	    char *fsmTransCondition[estado][transiciones][id][numero asociado]*/
     }Mcom;

void AHPL_translate(Mcom input);
//void ModuleDclr(Mcom input, char *array[]);
void Inputs(Mcom input);
void Outputs(Mcom output);
void externalUnits(Mcom exinput);

void memoryDclr(Mcom memory);//declaracion de la memoria
void memoryStr(Mcom memory); //modifica los segistros segun su declaracion
void Generic_memory(Mcom memory);// crea las memorias genericas en caso de tener un circuito que necesite memorias

void CombLogicUnits(Mcom clunit);
void Buses(Mcom buses);
char *copyArray(char *array, Mcom* Module, int row, int col, char *idVal);

void fsmControl(Mcom fsm);
void fsmExt(Mcom fsm);       //genera el modulo externo que se conecta con la máquina de estados 

//-- funciones de prueba hasta que componga esta vaina---- 
void fsmclkInit(Mcom memory); //de existir una memoria o maquina de estados se crea un reloj y un boton de rst
			      //evita errores de codigo

#endif


