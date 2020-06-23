# Central Process Unit 
This project demonstrates the VHDL encoding of an 8-bit Central Process Unit(CPU)

This example was tested on a Spartan-3E Board.

## Contemplated Instructions:

Symbol | Operating | Operation 
| --- | --- | --- | 
MOV_A_END | address | MOV A END 
MOV_END_A | address | MOV END A 
MOV_A_B   | address | MOV A B   
MOV_B_A   | address | MOV B A   
ADD_A_B   | address | ADD A B   
SUB_A_B   | address | SUB A B   
A_AND_B   | address | A AND B   
A_OR_B    | address | A OR B    
A_XOR_B   | address | A XOR B   
NOT_A     | address | NOT A     
A_NAND_B  | address | A NAND B  
JZ        | none | JZ        
JN        | none | JN        
HALT      | none | HALT      
JMP       | none | JMP       
INCA      | none | INCA      
INCB      | none | INCB      
DECA      | none | DECA      
DECB      | none | DECB      

## How to Test

You can use XILINX ISE PROJECT NAVIGATOR to test your projects. To install it, access the ISE at [XILINX](https://www.xilinx.com/support/download/index.html/content/xilinx/en/downloadNav/vivado-design-tools/archive-ise.html)
