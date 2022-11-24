#include "module.h"
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <stdbool.h>
#define char_long 150
bool memory1 = false;
      bool memory2 = false;
      bool memory3 = false;

void Inputs(Mcom input)
{
 for(int i = 0; i < input.inputsNumR; i++ )
 {
  printf("\n\t%s ", (char*)input.inputs[i][0]);
  if(input.inputsNum[i]==0)
  {printf(":in std_logic");}
  else if(input.inputsNum[i] != 0)
  {printf(":in std_logic_vector(%d downto 0)", input.inputsNum[i]-1);}
  if(i < input.inputsNumR+input.outputsNumR-1)
  {printf(";");}
 }
}
void Outputs(Mcom output)
{
 for(int i = 0; i < output.outputsNumR; i++ )
 {
  printf("\n\t%s ", (char*)output.outputs[i][0]);
  if(output.outputsNum[i]==0)
  {printf(":out std_logic");}
  else if(output.outputsNum[i] != 0)
  {printf(":out std_logic_vector(%d downto 0)", output.outputsNum[i] -1);}
  if(i+output.inputsNumR < output.inputsNumR+output.outputsNumR-1)
  {printf(";");}
 }
 
}
void externalUnits(Mcom exinput)
{
  for(int i = 0; i < exinput.exinputsNumR;i++)
  {
    int col=0;
    int num = 0;
    if(exinput.exinputs[i][0][1] == (char*)'0')
    {
     printf("\n%s: entity work.%s\n", (char*)exinput.exinputs[i][col][0],(char*)exinput.exinputs[i][col][0]);col++;
     if(((exinput.exinputsStore[i])) > 3){
     num = ((exinput.exinputsStore[i])/2)+2;}
     else
     {num = 1;}
     }
    else
    {printf("\n%s: entity work.%s\n", (char*)exinput.exinputs[i][col][0],(char*)exinput.exinputs[i][col+1][0]);col+=2;
     num = ((exinput.exinputsStore[i])-2/2)-1;}
    
    printf("port map(\n");
    for(col; col <= num ;col++)
    {printf("\t%s => %s ", (char*)exinput.exinputs[i][col][0],(char*)exinput.exinputs[i][col+1][0]);
    	    /*******************/
 if(exinput.exinputsNumT[i][col+1][0]!=-1 && exinput.exinputsNumT[i][col+1][1]==-1 && exinput.exinputsNumT[i][col+1][2]==-1 && exinput.exinputsNumT[i][col+1][3]==-1)
    	    {printf("(%d)",exinput.exinputsNumT[i][col+1][0]);}
 if(exinput.exinputsNumT[i][col+1][0]!=-1 && exinput.exinputsNumT[i][col+1][1]==-1 && exinput.exinputsNumT[i][col+1][2] !=-1 && exinput.exinputsNumT[i][col+1][3]==-1)
    	    {printf("(%d)(%d)",exinput.exinputsNumT[i][col+1][0],exinput.exinputsNumT[i][col+1][2]);}
 if(exinput.exinputsNumT[i][col+1][0]!=-1 && exinput.exinputsNumT[i][col+1][1]!=-1 && exinput.exinputsNumT[i][col+1][2]==-1 && exinput.exinputsNumT[i][col+1][3]==-1)
    	    {printf("(%d downto %d)",exinput.exinputsNumT[i][col+1][0],exinput.exinputsNumT[i][col+1][1]);}
 if(exinput.exinputsNumT[i][col+1][0]!=-1 && exinput.exinputsNumT[i][col+1][1]!=-1 && exinput.exinputsNumT[i][col+1][2]!=-1 && exinput.exinputsNumT[i][col+1][3]==-1)
    	    {printf("(%d downto %d)(%d)",exinput.exinputsNumT[i][col+1][0],exinput.exinputsNumT[i][col+1][1],exinput.exinputsNumT[i][col+1][2]);}
 if(exinput.exinputsNumT[i][col+1][0]!=-1 && exinput.exinputsNumT[i][col+1][1]==-1 && exinput.exinputsNumT[i][col+1][2]!=-1 && exinput.exinputsNumT[i][col+1][3]!=-1)
    	    {printf("(%d)(%d downto %d)",exinput.exinputsNumT[i][col+1][0],exinput.exinputsNumT[i][col+1][2],exinput.exinputsNumT[i][col+1][3]);}
    	    /*******************/
	    if(col < num){printf(",\n");}
	    else{printf("\n");}
	    col++;
    }
    printf("\n\t);\n\n");
    
  }
}
void Buses(Mcom buses)
{
  
  for(int i =0;i < buses.busesNumR;i++)
  {
   if(i == 0)
   {printf("\n");}
    if(buses.busesNum[i][1]!= 0 && buses.busesNum[i][2]!=0)
  {printf("type n%s is array (%d downto 0) of std_logic_vector(%d downto 0);", buses.buses[i][0],buses.busesNum[i][1], buses.busesNum[i][2]);
   printf("\nsignal %s:n%s", buses.buses[i][0],buses.buses[i][0]);}
   else
   {printf("signal %s", buses.buses[i][0]);} 
    if(buses.busesNum[i][1]!= 0 && buses.busesNum[i][2]==0)
  {printf(" :std_logic_vector(%d downto 0)", buses.busesNum[i][1]-1);}
    if(buses.busesNum[i][1]== 0 && buses.busesNum[i][2]==0)
  {printf(" :std_logic");}
  
  printf(";\n");
  }
  
}

void CombLogicUnits(Mcom clunit)
{
  for(int i = 0; i < clunit.ClunitsNumR; i++)
  {
	  for (int j = 0; j < clunit.ClunitsStore[i] ; j++)
	  {
	   
      if((char*)clunit.Clunits[i][j][0] != (char*)'!'&& (char*)clunit.Clunits[i][j][0] != (char*)'*'&& (char*)clunit.Clunits[i][j][0] != (char*)'"'&&(char*)clunit.Clunits[i][j][0] != (char*)'{'&&(char*)clunit.Clunits[i][j][0] != (char*)'+')
      {
	         printf("%s ",(char*)clunit.Clunits[i][j][0]);
		   
 if((char*)clunit.Clunits[i][j][1] != (char*)'0' && (char*)clunit.Clunits[i][j][2] == (char*)'0'&& (char*)clunit.Clunits[i][j][3] == (char*)'0'&& (char*)clunit.Clunits[i][j][4] == (char*)'0' && j != 0)
	   	   {printf("(%s) ",(char*)clunit.Clunits[i][j][1]);}
 else if((char*)clunit.Clunits[i][j][1] != (char*)'0' && (char*)clunit.Clunits[i][j][2] == (char*)'0'&& (char*)clunit.Clunits[i][j][3] != (char*)'0'&& (char*)clunit.Clunits[i][j][4] == (char*)'0' && j != 0)
	   	   {printf("(%s)(%s) ",(char*)clunit.Clunits[i][j][1],(char*)clunit.Clunits[i][j][3]);}
 else if((char*)clunit.Clunits[i][j][1] != (char*)'0' && (char*)clunit.Clunits[i][j][2] == (char*)'0'&& (char*)clunit.Clunits[i][j][3] != (char*)'0'&& (char*)clunit.Clunits[i][j][4] != (char*)'0' && j != 0)
	   	   {printf("(%s)(%s downto %s) ",(char*)clunit.Clunits[i][j][1],(char*)clunit.Clunits[i][j][3],(char*)clunit.Clunits[i][j][4]);}
 else if((char*)clunit.Clunits[i][j][1] != (char*)'0'&& (char*)clunit.Clunits[i][j][2] != (char*)'0'&& (char*)clunit.Clunits[i][j][3] == (char*)'0'&& (char*)clunit.Clunits[i][j][4] == (char*)'0' &&j != 0)
	   	   {printf("(%s downto %s) ",(char*)clunit.Clunits[i][j][1],(char*)clunit.Clunits[i][j][2]);}
 else if((char*)clunit.Clunits[i][j][1] != (char*)'0'&& (char*)clunit.Clunits[i][j][2] != (char*)'0'&& (char*)clunit.Clunits[i][j][3] != (char*)'0'&& (char*)clunit.Clunits[i][j][4] == (char*)'0' &&j != 0)
	   	   {printf("(%s downto %s)(%s) ",(char*)clunit.Clunits[i][j][1],(char*)clunit.Clunits[i][j][2],(char*)clunit.Clunits[i][j][3]);}
 else if((char*)clunit.Clunits[i][j][1] != (char*)'0'&& (char*)clunit.Clunits[i][j][2] != (char*)'0'&& (char*)clunit.Clunits[i][j][3] != (char*)'0'&& (char*)clunit.Clunits[i][j][4] != (char*)'0' &&j != 0)
	   	   {printf("(%s downto %s)(%s downto %s) ",(char*)clunit.Clunits[i][j][1],(char*)clunit.Clunits[i][j][2],(char*)clunit.Clunits[i][j][3],(char*)clunit.Clunits[i][j][4]);}
	   	    
		   if (j == 0)
		   {
		    if((char*)clunit.Clunits[i][j][1] != (char*)'0' && (char*)clunit.Clunits[i][j][2] == (char*)'0')
	   	   {
	   	    printf("(%s)",(char*)clunit.Clunits[i][j][1]);
	   	   }
	   	   if((char*)clunit.Clunits[i][j][1] != (char*)'0' && (char*)clunit.Clunits[i][j][2] != (char*)'0')
	   	   {
	   	    printf("(%s downto %s)",(char*)clunit.Clunits[i][j][1],(char*)clunit.Clunits[i][j][2]);
	   	   }
		    printf(" <= ");
		   }
	      }
	      else if((char*)clunit.Clunits[i][j][0] == (char*)'!')
	      {printf("std_logic_vector(to_unsigned(%s,%s)) ",(char*)clunit.Clunits[i][j][2],(char*)clunit.Clunits[i][j][1]);}
	       else if((char*)clunit.Clunits[i][j][0] == (char*)'*' || (char*)clunit.Clunits[i][j][0] == (char*)'"')
	       {printf("%s ", (char*)clunit.Clunits[i][j][1]);}
	       else if((char*)clunit.Clunits[i][j][0] == (char*)'+')
	       { 
	        printf("std_logic_vector(");
	        /*-------------------------------------------------------------------------------------------------*/
	        if((char*)clunit.Arith[i][0] != (char*)'0')
	        {
	         if((char*)clunit.Arith[i][1] == (char*)'0' && (char*)clunit.Arith[i][2] == (char*)'0')
	         {printf("unsigned(%s) ",(char*)clunit.Arith[i][0]);}
	         else if((char*)clunit.Arith[i][1] != (char*)'0' && (char*)clunit.Arith[i][2] == (char*)'0')
	         {printf("unsigned(%s(%s)) ",(char*)clunit.Arith[i][0],(char*)clunit.Arith[i][1]);}
	         else if((char*)clunit.Arith[i][1] != (char*)'0' && (char*)clunit.Arith[i][2] != (char*)'0')
	         {printf("unsigned(%s(%s downto %s)) ",(char*)clunit.Arith[i][0],(char*)clunit.Arith[i][1],(char*)clunit.Arith[i][2]);}
	        }
	        else{printf("to_unsigned(%s,%s) ",clunit.Arith[i][2],clunit.Arith[i][1]);}
	        /*---------------------------------------------------------------------------------------------------*/
	        if(clunit.Clunits[i][j][1] == (char*)'0')
	        {printf("+ ");}
	        else
	        {printf("- ");}
	        
	        /*-------------------------------------------------------------------------------------------------*/
	        if((char*)clunit.Arith[i][3] != (char*)'0')
	        {
	         if((char*)clunit.Arith[i][4] == (char*)'0' && (char*)clunit.Arith[i][5] == (char*)'0')
	         {printf("unsigned(%s) ",(char*)clunit.Arith[i][3]);}
	         else if((char*)clunit.Arith[i][4] != (char*)'0' && (char*)clunit.Arith[i][5] == (char*)'0')
	         {printf("unsigned(%s(%s)) ",(char*)clunit.Arith[i][3],(char*)clunit.Arith[i][4]);}
	         else if((char*)clunit.Arith[i][4] != (char*)'0' && (char*)clunit.Arith[i][5] != (char*)'0')
	         {printf("unsigned(%s(%s downto %s)) ",(char*)clunit.Arith[i][3],(char*)clunit.Arith[i][4],(char*)clunit.Arith[i][5]);}
	        }
	        else{printf("to_unsigned(%s,%s) ",clunit.Arith[i][5],clunit.Arith[i][4]);}
	        /*---------------------------------------------------------------------------------------------------*/
	        printf(") "); 
	       }
	 
		   if (j == clunit.ClunitsStore[i] -1)
		   { printf(";\n");}
	
		
	    	  
  	   }
  }
}

void clkInit(Mcom memory)
{
  if (memory.memoryNumR >= 1)
  {
    if(memory.inputsNumR+memory.outputsNumR >= 1)
    {
   printf("\tclk :in std_logic := '0';\n");
   printf("\trst :in std_logic := '1';");}
   else
   {printf("\tclk :in std_logic;\n");
    printf("\trst :in std_logic");}
  }
}

/*---------------------------------------------------------------------*/
void memoryDclr(Mcom memory)
{  for(int i =0;i < memory.memoryNumR;i++)
  {
   if(i == 0)
   {printf("\n");}
    if(memory.memoryNum[i][1]!= 0 && memory.memoryNum[i][2]!=0)
  {printf("\nsignal d%s,%s: std_logic_vector(%d downto 0);\n", memory.memory[i][0],memory.memory[i][0],memory.memoryNum[i][2]-1);//se crea un "data" con el prefijo 'd'+nombre para escribir el registro
   printf("signal en%s :std_logic;\n", memory.memory[i][0]);
   printf("signal r_addr%s,w_addr%s :std_logic_vector(%d downto 0);\n",memory.memory[i][0],memory.memory[i][0],memory.memoryNum[i][1]-1);
   memory3 = true;}
   else
   {printf("signal d%s,%s",memory.memory[i][0],memory.memory[i][0]);} 
    if(memory.memoryNum[i][1]!= 0 && memory.memoryNum[i][2]==0)
  {printf(" :std_logic_vector(%d downto 0);\n", memory.memoryNum[i][1]-1);
   printf("signal en%s :std_logic;\n", memory.memory[i][0]);
   memory2 = true;}
    if(memory.memoryNum[i][1]== 0 && memory.memoryNum[i][2]==0)
  {printf(",en%s :std_logic;\n", memory.memory[i][0]);
   memory1 = true;}
  
  //printf(";\n");
  }
}
void memoryStr(Mcom memory)
{ 
  for(int i = 0;i < memory.memoryNumR;i++)
  {
   if(memory.memoryNum[i][1]== 0 && memory.memoryNum[i][2]==0)
   {
     printf("mem%s: entity work.ff\n",memory.memory[i][0]);
     printf("port map(\n");
     printf("\tclk => clk,\n");
     printf("\trst => rst,\n");
     printf("\ten => en%s,\n",memory.memory[i][0]);
     printf("\td => d%s,\n",memory.memory[i][0]);
     printf("\tq => %s\n",memory.memory[i][0]);
     printf("\t);\n");
  }
  if(memory.memoryNum[i][1]!= 0 && memory.memoryNum[i][2]==0)
  {
     printf("mem%s: entity work.reg\n",memory.memory[i][0]);
     printf("generic map(reg_size => %d)\n", memory.memoryNum[i][1]);
     printf("port map(\n");
     printf("\tclk => clk,\n");
     printf("\trst => rst,\n");
     printf("\ten => en%s,\n",memory.memory[i][0]);
     printf("\td => d%s,\n",memory.memory[i][0]);
     printf("\tq => %s\n",memory.memory[i][0]);
     printf("\t);\n");  
  }
   if(memory.memoryNum[i][1]!= 0 && memory.memoryNum[i][2]!=0)
   {
    printf("mem%s: entity work.ram\n",memory.memory[i][0]);
    printf("generic map(DATA_WIDTH => %d,\n\t  ADDR_WIDTH => %d)\n", memory.memoryNum[i][2],memory.memoryNum[i][1]);
    printf("port map(\n");
    printf("\tclk => clk,\n");	
    printf("\trst => rst,\n");			 
    printf("\twr_en => en%s,\n",memory.memory[i][0]);	
    printf("\tw_addr => w_addr%s,\n",memory.memory[i][0]);		
    printf("\tr_addr => r_addr%s,\n",memory.memory[i][0]);		
    printf("\tw_data => d%s,\n",memory.memory[i][0]);		
    printf("\tr_data => %s \n",memory.memory[i][0]);
    printf("\t);\n");	
   }
  }
}

void Generic_memory(Mcom memory)
{
  if(memory1 == true)
   {
printf("\n-- single flip flop--------------------------------------------\n");
printf("library ieee;\n");
printf("use ieee.std_logic_1164.all;\n\n");

printf("entity ff is\n");
printf("port(	clk :in std_logic;\n");
printf("	rst :in std_logic;\n");
printf("	en	 :in std_logic;\n");
printf("	d 	 :in std_logic;\n");
printf("	q	 :out std_logic);\n");
printf("end entity ff;\n\n");

printf("architecture rtl of ff is\n");
printf("begin\n\n");

printf("dff: PROCESS(clk, rst,d)\n");
printf("	  BEGIN\n");
printf("	IF (rst = '1') THEN\n");
printf("			q <= '0';\n");
printf("		ELSIF (rising_edge(clk)) THEN\n");
printf("			IF en = '1' THEN\n");
printf("				q <= d;\n");
printf("			END IF;\n");
printf("		END IF;\n");
printf("	  END PROCESS dff;\n");

printf("end architecture rtl;\n");
}
  if(memory2 == true)
   {
printf("\n--single register-----------------------------------------------\n");
printf("LIBRARY IEEE;\n");
printf("USE IEEE.STD_LOGIC_1164.ALL;\n");

printf("ENTITY reg IS\n");
printf("GENERIC(reg_size :integer := 3);\n");
printf("PORT( clk	:in std_logic;\n");
printf("		rst	:in std_logic;\n");
printf("		en		:in std_logic;\n");
printf("		d		:in std_logic_vector(reg_size-1 downto 0);\n");
printf("		q		:out std_logic_vector(reg_size-1 downto 0));\n");
printf("END ENTITY reg;\n");

printf("ARCHITECTURE rtl OF reg IS\n");
printf("BEGIN\n");

printf("myreg: PROCESS(clk, rst, d)\n");
printf("		 BEGIN\n");
printf("			IF (rst = '1') THEN\n");
printf("				q <= (others => '0');\n");
printf("			ELSIF (rising_edge(clk)) THEN\n");
printf("					IF (en = '1') THEN\n");
printf("						q <= d;\n");
printf("					END IF;\n");
printf("				END IF;\n");
printf("		 END PROCESS myreg;\n");

printf("END ARCHITECTURE rtl;\n");
}

  if(memory3 == true)
   {
printf("\n--single generic ram block--------------------------------------------------------------------\n");
printf("LIBRARY IEEE;\n");
printf("USE IEEE.STD_LOGIC_1164.ALL;\n");
printf("USE IEEE.NUMERIC_STD.ALL;\n");
printf("ENTITY ram IS\n");
printf("GENERIC(DATA_WIDTH :	integer := 8;\n");
printf("		  ADDR_WIDTH :	integer := 3);\n");
printf("PORT(	  clk			 : in  std_logic;\n");
printf("		  rst			 : in  std_logic;--\n");
printf("		  wr_en		 :	in  std_logic;\n");
printf("		  w_addr		 : in  std_logic_vector(ADDR_WIDTH-1 DOWNTO 0);\n");
printf("		  r_addr		 : in  std_logic_vector(ADDR_WIDTH-1 DOWNTO 0);\n");
printf("		  w_data		 : in  std_logic_vector(DATA_WIDTH-1 DOWNTO 0);\n");
printf("		  r_data		 : OUT std_logic_vector(DATA_WIDTH-1 DOWNTO 0));\n");
printf("END ENTITY ram;\n");

printf("ARCHITECTURE rtl OF ram IS\n");
printf("	TYPE mem_type IS ARRAY (0 TO 2**ADDR_WIDTH-1) OF STD_LOGIC_VECTOR(DATA_WIDTH-1 DOWNTO 0);\n");
printf("	SIGNAL array_reg: mem_type;\n");
printf("BEGIN\n");
printf("	proceso: PROCESS(clk)\n");
printf("				BEGIN\n");
printf("					IF (rst = '1') THEN\n");
printf("						array_reg <= (OTHERS => (OTHERS => '0'));\n");
printf("					ELSIF (rising_edge(clk)) THEN\n");
printf("						IF (wr_en = '1') THEN\n");
printf("							array_reg(to_integer(unsigned(w_addr))) <= w_data;\n");
printf("						END IF;\n");
printf("					END IF;\n");
printf("				END PROCESS proceso;\n");
printf("	--READ\n");
printf("	r_data <= (array_reg(to_integer(unsigned(r_addr))));\n");
	
printf("END ARCHITECTURE rtl;\n");
	}
};
//--------------------------------------------------------------------------------------------------------------------------------------------------------
/*void fsmControl(Mcom fsm)
{
 	printf("\n\nlibrary ieee;\n");
	printf("use ieee.std_logic_1164.all;\n");
	printf("\nentity fsm_%s is\n", fsm.moduleName);
	/*inicio de entradas y salidas*/
/*	printf("port(");
	/*entradas*/
	/*-----------activa reloj y reset-------------*/
/*	  if (fsm.memoryNumR >= 1)
	  {
	    if(fsm.inputsNumR+fsm.outputsNumR >= 1)
	    {
	   printf("\tclk :in std_logic;\n");
	   printf("\trst :in std_logic;");}
	   else
	   {printf("\tclk :in std_logic;\n");
	    printf("\trst :in std_logic");}
	  }	
	/*--------------------------------------------*/
	
	/*---------------Inputs(fsm);-----------------*/
/*	 for(int i = 0; i < fsm.inputsNumR; i++ )
	 {
	  printf("\n\t%s ", (char*)fsm.inputs[i][0]);
	  if(fsm.inputsNum[i]==0)
	  {printf(":in std_logic");}
	  else if(fsm.inputsNum[i] != 0)
	  {printf(":in std_logic_vector(%d downto 0)", fsm.inputsNum[i]-1);}
	  if(i < fsm.inputsNumR+fsm.outputsNumR-1)
	  {printf(";");}
	 }	
	/*--------------Outputs(fsm);-----------------*/
/*	 for(int i = 0; i < fsm.outputsNumR; i++ )
	 {
	  printf("\n\t%s ", (char*)fsm.outputs[i][0]);
	  if(fsm.outputsNum[i]==0)
	  {printf(":out std_logic");}
	  else if(fsm.outputsNum[i] != 0)
	  {printf(":out std_logic_vector(%d downto 0)", fsm.outputsNum[i] -1);}
	  if(i+fsm.inputsNumR < fsm.inputsNumR+fsm.outputsNumR-1)
	  {printf(";");}
	 }
	/*fin de entradas*/
/*	printf(");");
	/*fin de entradas y salidas*/
/*	printf("\nend entity fsm_%s;\n",fsm.moduleName);
	
	/*arquitectura*/
/*	printf("\narchitecture ARC_fsm_%s of fsm_%s is\n",fsm.moduleName,fsm.moduleName);
	/*señales o estados*/
				/*Buses(input);*/        /*en las maquinas de estados no pueden haber buses que se controlen*/
				/*memoryDclr(input);*/   /*las memorias hay que declararlas diferentes 
							   (como entradas o salidas de un sitema que controla)*/
	
	/*--creacion de los estados posibles--*/
/*	printf("TYPE state IS (");
	for(int i = 0; i < fsm.fsmNum; i++)
	{
	 printf("S%d",fsm.fsmStateNum[i]);
	 if( i != fsm.fsmNum-1)
	 {printf(",");}
	}
	printf(");\n");
	printf("SIGNAL pr_state, nx_state: state;\n");
	/*fin de señales o estados*/
/*	printf("\nbegin\n\n");
	/* maquinas de estado */
/*	printf("--sequential section----------------------");
	printf("\nPROCESS (rst, clk)\n");
	printf("BEGIN\n");
	printf("\tIF (rst = '1') THEN\n");
	printf("\t   pr_state <= S%d\n", fsm.fsmStateNum[0]);
	printf("\tELSIF (rising_edge(clk)) THEN\n");
	printf("\t   pr_state <= nx_state;\n");
	printf("\tEND IF;\n");
	printf("END PROCESS;\n\n");
	
	printf("--combinatonal section--");
	printf("\nPROCESS ((falta poner las entradas),rst, clk, pr_state)\n");
	printf("BEGIN\n");
	printf("\tCASE pr_state IS\n");
	for(int i = 0; i < fsm.fsmNum; i++)
	{
	printf("\t-------------------------\n");
	printf("\t   WHEN S%d => \n",fsm.fsmStateNum[i]);
	 //if (fsm.fsmTransNum[i] >= 1)
	 //{
	   for(int j = 0; j< fsm.fsmTransNum[i];j++)
	   {
	    if(j == 0)
	    {printf("\t\tIF(");}
	    else
	    {printf("\t\tELSIF(");}
	    for(int k = 0;k < fsm.fsmTransCharCondNum[i];k++)
	    { printf(" %s",fsm.fsmTransCondition[i][j][k][0]);}
	    printf(" = '1') THEN\n");
	    printf("\t\t   nx_state <= S%d;\n",fsm.fsmTransC[i][j]);
	   }	
	   printf("\t\tEND IF;\n");
	 //}
	 // else /*if (fsm.fsmTransNum[i] == 1)*/
	 //{printf("\t\t   nx_state <= S%d\n",fsm.fsmStateNum[i]+1);}
/*	}
	printf("\tEND CASE;\n");
	printf("END PROCESS;\n\n");
	//memoryStr(input); //crea los registros      
	printf("\nend architecture ARC_fsm_%s;\n", fsm.moduleName);
	printf("\n-------fin de la maquina de estados -------------\n");
}
//---------------------------------------------------------------------------------------------------------------------------------------
/*--------------------------------------------------------------------------------*/
void AHPL_translate(Mcom input)
{
	printf("\n\nlibrary ieee;\n");
	printf("use ieee.std_logic_1164.all;\n");
	printf("use ieee.numeric_std.all;");
	printf("\nentity %s is\n", input.moduleName);
	/*inicio de entradas y salidas*/
	printf("port(");
	/*entradas*/
	clkInit(input);
	Inputs(input);
	Outputs(input);
	/*fin de entradas*/
	printf(");");
	/*fin de entradas y salidas*/
	printf("\nend entity %s;\n",input.moduleName);
	
	/*arquitectura*/
	printf("\narchitecture ARC%s of %s is\n",input.moduleName,input.moduleName);
	/*señales o estados*/
	Buses(input);
	memoryDclr(input);
	/*fin de señales o estados*/
	printf("\nbegin\n\n");
	/* maquinas de estado */
	
	/*unidades logicas combinacionales*/
	CombLogicUnits(input);
	
	/* entradas externas */
	externalUnits(input);
	memoryStr(input); //crea los registros
	printf("\nend architecture ARC%s;\n", input.moduleName);
	printf("\n--------fin del modulo %s--------------------------\n",input.moduleName);
	/*fin de arquitectura*/
	/*if(input.fsmNum >= 1)
	{
	printf("\n--maquina de estados de %s---------------------------------\n",input.moduleName);
	fsmControl(input);
	}*/
	
}
