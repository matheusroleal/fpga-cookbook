# Central Process Unit 
This project demonstrates the VHDL encoding of an 8-bit Central Process Unit(CPU)

## Contemplated Instructions:

Symbol | Operating | Operation | Affected flags
| --- | --- | --- | --- |
NOP	| none | 	none    						 | none
STA	| address | MEM(end)<-AC					 | none
LDA	| address | AC<-MEM(end)					 | N,Z
ADD	| address | AC<-AC+MEM(end)					 | N,Z,V,C
OR	| address | AC<-AC or MEM(end)				 | N,Z
AND	| address | AC<-AC and MEM(end)				 | N,Z
NOT	| none | 	AC<-NOT AC						 | N,Z
SUB	| address | AC<-AC - MEM(end)				 | N,Z,V,B
JMP	| address | PC<-address						 | none
JN	| address | if N=1 PC<-address				 | none
JP	| address | if N=0 PC<-address				 | none
JV	| address | if V=1 PC<-address 				 | none
JNV	| address | if V=0 PC<-address 				 | none
JZ	| address | if Z=1 PC<-address 				 | none
JNZ	| address | if Z=0 PC<-address 				 | none
JC	| address | if C=1 PC<-address				 | none
JNC	| address | if C=0 PC<-address 				 | none
JB	| address | if B=1 PC<-address 				 | none
JNB	| address | if B=0 PC<-address 				 | none
SHR	| none | 	C<-AC(0);AC(i-1)<-AC(i);AC(7)<-0 | N,Z,C
SHL	| none | 	C<-AC(7);AC(i)<-AC(i-1);AC(0)<-0 | N,Z,C
ROR	| none | 	C<-AC(0);AC(i-1)<-AC(i);AC(7)<-C | N,Z,C
ROL	| none | 	C<-AC(7);AC(i)<-AC(i-1);AC(0)<-C | N,Z,C
HLT	| none | 	stop processing		 | none