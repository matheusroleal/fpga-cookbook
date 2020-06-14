LIBRARY ieee ;
USE ieee.std_logic_1164.all ;
USE ieee.std_logic_unsigned.all ;

ENTITY cpu IS
	PORT
	(
		-- Barramento de endereos (8 bits)
		-- Address bus (8 bits)
		address_bus	: OUT STD_LOGIC_VECTOR(7 DOWNTO 0);
		-- Barramentos de dados unidirecionais (DATA_IN e DATA_OUT) de 8 bits
		-- Unidirectional Data buses (DATA_IN and DATA_OUT) (8 bits)
		data_in		: IN STD_LOGIC_VECTOR(7 DOWNTO 0);
		data_out	: OUT STD_LOGIC_VECTOR(7 DOWNTO 0);
		mem_write	: OUT std_logic;	-- Sinal de escrita na memria (memory write signal)
		clk			: IN std_logic;		-- Clock principal (main clock)
		reset		: IN std_logic;		-- Reset da CPU (CPU reset)
		ERROR		: OUT STD_LOGIC;	-- Error (opcode ilegal) (illegal opcode error)
		-- Barramentos de dados para interface com a ULA
		-- ALU interfacing data buses
		OPERACAO 	: OUT STD_LOGIC_VECTOR (3 DOWNTO 0);	-- Seleo da operao da ULA (ULA's operation select)
		OPER_A		: OUT STD_LOGIC_VECTOR(7 DOWNTO 0);		-- operando A (operand A)
		OPER_B		: OUT STD_LOGIC_VECTOR(7 DOWNTO 0);		-- operando B (operand B)
		RESULT		: IN STD_LOGIC_VECTOR(7 DOWNTO 0);		-- resultado (result)
		Cout		: OUT STD_LOGIC;						-- Sada de Carry (Carry out)
		N,Z,C,B,V 	: IN STD_LOGIC							-- flags da ALU (ALU's flags)
	);
END cpu;

ARCHITECTURE Behavioral OF cpu IS
	-- Constantes com as instrues do processador
	-- Processor's instruction-constants
	constant NOP : STD_LOGIC_VECTOR(7 DOWNTO 0):="00000000";
	constant STA : STD_LOGIC_VECTOR(7 DOWNTO 0):="00010000";
	constant LDA : STD_LOGIC_VECTOR(7 DOWNTO 0):="00100000";
	constant ADD : STD_LOGIC_VECTOR(7 DOWNTO 0):="00110000";
	constant IOR : STD_LOGIC_VECTOR(7 DOWNTO 0):="01000000";
	constant IAND: STD_LOGIC_VECTOR(7 DOWNTO 0):="01010000";
	constant INOT: STD_LOGIC_VECTOR(7 DOWNTO 0):="01100000";
	constant SUB : STD_LOGIC_VECTOR(7 DOWNTO 0):="01110000";
	constant JMP : STD_LOGIC_VECTOR(7 DOWNTO 0):="10000000";
	constant JN  : STD_LOGIC_VECTOR(7 DOWNTO 0):="10010000";
	constant JP  : STD_LOGIC_VECTOR(7 DOWNTO 0):="10010100";
	constant JV  : STD_LOGIC_VECTOR(7 DOWNTO 0):="10011000";
	constant JNV : STD_LOGIC_VECTOR(7 DOWNTO 0):="10011100";
	constant JZ  : STD_LOGIC_VECTOR(7 DOWNTO 0):="10100000";
	constant JNZ : STD_LOGIC_VECTOR(7 DOWNTO 0):="10100100";
	constant JC  : STD_LOGIC_VECTOR(7 DOWNTO 0):="10110000";
	constant JNC : STD_LOGIC_VECTOR(7 DOWNTO 0):="10110100";
	constant JB  : STD_LOGIC_VECTOR(7 DOWNTO 0):="10111000";
	constant JNB : STD_LOGIC_VECTOR(7 DOWNTO 0):="10111100";
	constant SHR : STD_LOGIC_VECTOR(7 DOWNTO 0):="11100000";
	constant SHL : STD_LOGIC_VECTOR(7 DOWNTO 0):="11100001";
	constant IROR: STD_LOGIC_VECTOR(7 DOWNTO 0):="11100010";
	constant IROL: STD_LOGIC_VECTOR(7 DOWNTO 0):="11100011";
	constant HLT : STD_LOGIC_VECTOR(7 DOWNTO 0):="11110000";

	-- Constantes que definem as operaes da ULA
	-- ALU operation's constants
	constant ULA_ADD : STD_LOGIC_VECTOR(3 DOWNTO 0):="0001";
	constant ULA_SUB : STD_LOGIC_VECTOR(3 DOWNTO 0):="0010";
	constant ULA_OU  : STD_LOGIC_VECTOR(3 DOWNTO 0):="0011";
	constant ULA_E   : STD_LOGIC_VECTOR(3 DOWNTO 0):="0100";
	constant ULA_NAO : STD_LOGIC_VECTOR(3 DOWNTO 0):="0101";
	constant ULA_DLE : STD_LOGIC_VECTOR(3 DOWNTO 0):="0110";
	constant ULA_DLD : STD_LOGIC_VECTOR(3 DOWNTO 0):="0111";
	constant ULA_DAE : STD_LOGIC_VECTOR(3 DOWNTO 0):="1000";
	constant ULA_DAD : STD_LOGIC_VECTOR(3 DOWNTO 0):="1001";
BEGIN
	-- sensibilidade nas bordas do sinal de clock e reset
	-- sensibility on clk and reset edges
	process (clk,reset)
	variable PC : STD_LOGIC_VECTOR(7 DOWNTO 0);	-- Contador de programa (program counter)
	variable AC : STD_LOGIC_VECTOR(7 DOWNTO 0);	-- Acumulador (accumulator)
	VARIABLE TEMP: STD_LOGIC_VECTOR(7 DOWNTO 0);	-- registrador temporrio (temporary register)
	VARIABLE INSTR: STD_LOGIC_VECTOR(7 DOWNTO 0);	-- instruo atual (current instruction)
	-- Mquina de estados da CPU (CPU state machine)
	type Tcpu_state is (
		BUSCA, BUSCA1, DECOD,  -- estados bsicos de busca e decodificao (basic fetch and decode states)
		DECOD_STA1, DECOD_STA2, DECOD_STA3, DECOD_STA4,		-- decodificao da instruo STA (STA decode)
		DECOD_LDA1, DECOD_LDA2, DECOD_LDA3,					-- decodificao da instruo LDA (LDA decode)
		DECOD_ADD1, DECOD_ADD2, DECOD_ADD3,					-- decodificao da instruo ADD (ADD decode)
		DECOD_SUB1, DECOD_SUB2, DECOD_SUB3, 				-- decodificao da instruo SUB (SUB decode)
		DECOD_IOR1, DECOD_IOR2, DECOD_IOR3, 				-- decodificao da instruo OR (OR decode)
		DECOD_IAND1, DECOD_IAND2, DECOD_IAND3, 				-- decodificao da instruo AND (AND decode)
		DECOD_JMP,											-- decodificao da instruo JMP (JMP decode)
		DECOD_SHR1,  										-- decodificao da instruo SHR (SHR decode)
		DECOD_SHL1,  										-- decodificao da instruo SHL (SHL decode)
		DECOD_IROR1, 										-- decodificao da instruo IROR (IROR decode)
		DECOD_IROL1, 										-- decodificao da instruo IROL (IROL decode)
		DECOD_STORE						
		);
	VARIABLE CPU_STATE : TCPU_STATE;  -- varivel de estado da CPU (CPU state variable)
	begin
		if (reset='1') then
			-- Operaes em caso de reset (reset operations)
			CPU_STATE := BUSCA;	-- configura a mquina de estados para BUSCA (set CPU state machine to fetch)
			PC := "00000000";	-- Inicializa o PC em zero (set PC to zero)
			MEM_WRITE <= '0';	-- desativa a linha de escrita na memria (disable memory write signal)
			ADDRESS_BUS <= "00000000";	-- coloca zero no barramento de endereos (set the address bus to zero)
			DATA_OUT <= "00000000";		-- coloca zero no barramento de dados (set the DATA_OUT bus to zero)
			OPERACAO <= "0000";			-- nenhuma operao na ULA (no operation on ALU)
		ELSIF ((clk'event and clk='1')) THEN	-- se for uma borda de subida do clock (if it's a clock rising edge)
			CASE CPU_STATE IS	-- verifica o estado atual da mquina de estados (select the current state of the CPU's state machine)
				WHEN BUSCA =>	-- primeiro ciclo da busca de instruo (first fetch cycle)
					ADDRESS_BUS <= PC;		-- carrega o barramento de endereos com o PC (load address bus with the PC content)
					ERROR <= '0';			-- fora a sada de erros para zero (disable the error output)
					CPU_STATE := BUSCA1;	-- avana para o estado BUSCA1 (next state = BUSCA1)
				WHEN BUSCA1 =>	-- segundo ciclo da busca de instruo (second fetch cycle)
					INSTR := DATA_IN;		-- l a instruo e armazena em INSTR (read the instruction and store into INSTR)
					CPU_STATE := DECOD;		-- avana para o prximo estgio (next state = DECOD)
				WHEN DECOD =>	-- incio da decodificao de instruo (now we will start decoding the instruction)
					CASE INSTR IS			-- decod the INSTR content
						-- NOP - no faz nada, apenas avana o PC
						-- NOP - no operation, only increment PC
						WHEN NOP =>						
							PC := PC + 1;				-- soma 1 ao PC	(add 1 to PC)
							CPU_STATE := BUSCA;			-- retorna a mquina de estados ao incio (restart instruction fetch)
						-- STA - armazena o AC no endereo especificado pelo operando
						-- STA - store the AC into the specified memory
						WHEN STA =>						
							ADDRESS_BUS <= PC + 1;		-- incrementa o endereo (para apontar para o operando) (fetch the operand)
							CPU_STATE := DECOD_STA1;	-- segue para a decodificao da STA (proceed on STA decoding)
						-- LDA - carrega o acumulador com o contedo do endereo especificado pelo operando
						-- LDA - load AC with the contents of the specified memory address
						WHEN LDA =>						
							ADDRESS_BUS <= PC + 1;		-- incrementa o endereo (para apontar para o operando) (fetch the operand)
							CPU_STATE := DECOD_LDA1;	-- segue para a decodificao da LDA (proceed on LDA decoding)
						-- ADD - soma o acumulador com o contedo do endereo especificado pelo operando
						-- ADD - add the contents of the specified memory address to the accumulator (AC)
						WHEN ADD =>						
							ADDRESS_BUS <= PC + 1;		-- incrementa o endereo (para apontar para o operando) (fetch the operand)
							CPU_STATE := DECOD_ADD1;	-- segue para a decodificao da ADD (proceed on ADD decoding)
						-- SUB - subtrai o contedo do endereo especificado do contedo do acumulador
						-- SUB - subtract the contents of the specified address from the current content of the accumulator
						WHEN SUB =>						
							ADDRESS_BUS <= PC + 1;		-- incrementa o endereo (para apontar para o operando) (fetch the operand)
							CPU_STATE := DECOD_SUB1;	-- avana para a decodificao da SUB (proceed on SUB decoding)
						-- OR - operao lgica OU entre o acumulador e o contedo do endereo especificado pelo operando
						-- OR - logic OR operation between the accumulator and the content of the specified address
						WHEN IOR =>						
							ADDRESS_BUS <= PC + 1;		-- incrementa o endereo (para apontar para o operando) (fetch the operand)
							CPU_STATE := DECOD_IOR1;	-- avana para a decodificao da OR (proceed on OR decoding)
						-- AND - operao lgica E entre o acumulador e o contedo do endereo especificado pelo operando 
						-- AND - logic AND operation between the accumulator and the content of the specified address
						WHEN IAND =>				
							ADDRESS_BUS <= PC + 1;		-- incrementa o endereo (para apontar para o operando) (fetch the operand)
							CPU_STATE := DECOD_IAND1;	-- avana para a decodificao da AND (proceed on AND decoding)
						-- NOT - operao lgica NO do acumulador
						-- NOT - logic NOT operation of the accumulator
						WHEN INOT =>					
							OPER_A <= AC;				-- carrega o acumulador no OPER_A da ULA (load ALU's input OPER_A with the accumulator)
							OPERACAO <= ULA_NAO;		-- seleciona a operao NO na ULA (selects the ALU's NOT operation)
							PC := PC + 1;				-- incrementa o PC (increments PC)
							CPU_STATE := DECOD_STORE;	-- avana para a decodificao da NOT (proceed on NOT decoding)
						-- JMP - desvia para o endereo indicado aps a instruo	
						-- JMP - jumps to the specified address
						WHEN JMP =>						
							ADDRESS_BUS <= PC + 1;		-- aponta para o operando da instruo (fetch the operand)
							CPU_STATE := DECOD_JMP;		-- avana para a decodificao de JMP (proceed on JMP decoding)
						-- JN - desvia para o endereo se N=1
						-- JN - jump to the address if N = 1
						WHEN JN =>						
							IF (N='1') THEN
								-- se N=1 (if N=1)
								ADDRESS_BUS <= PC + 1;	-- aponta para o operando da instruo (fetch the operand)
								CPU_STATE := DECOD_JMP;	-- prossegue como um JMP (proceed as with JMP)									
							ELSE
								-- se N=0 (if N=0)
								PC := PC + 2;			-- avana o PC (add two to the PC so it points the next instruction) 
								CPU_STATE := BUSCA;		-- retorna ao estado de busca (restart instruction fetch)
							END IF;
						-- JP - desvia para o endereo se N=0
						-- JP - jump to the address if N=0
						WHEN JP =>						
							IF (N='0') THEN
								-- se N=0 (if N=0)
								ADDRESS_BUS <= PC + 1;	-- aponta para o operando da instruo (fetch the operand)
								CPU_STATE := DECOD_JMP;	-- prossegue como um JMP (proceed as with JMP)
							ELSE
								-- se N=1 (if N=1)
								PC := PC + 2;			-- avana o PC (add two to the PC so it points the next instruction) 
								CPU_STATE := BUSCA;		-- retorna ao estado de busca (restart instruction fetch)
							END IF;
						-- JV - desvia para o endereo se V=1
						-- JV - jump to the address if V=1
						WHEN JV =>						
							IF (V='1') THEN
								-- se V=1 (if V=1)
								ADDRESS_BUS <= PC + 1;	-- aponta para o operando da instruo (fetch the operand)
								CPU_STATE := DECOD_JMP;	-- prossegue como um JMP (proceed as a JMP)
							ELSE
								-- se V=0 (if V=0)
								PC := PC + 2;			-- avana o PC (add two to the PC so it points the next instruction) 
								CPU_STATE := BUSCA;		-- retorna ao estado de busca (restart instruction fetch)
							END IF;
						-- JNV - desvia para o endereo se V=0
						-- JNV - jump to the address if V=0
						WHEN JNV =>						
							IF (V='0') THEN
								-- se V=0 (if V=0)
								ADDRESS_BUS <= PC + 1;	-- aponta para o operando da instruo (fetch the operand)
								CPU_STATE := DECOD_JMP;	-- prossegue como um JMP (proceed as a JMP)
							ELSE
								-- se V=1 (if V=1)
								PC := PC + 2;			-- avana o PC (add 2 to the PC)
								CPU_STATE := BUSCA;		-- retorna ao estado de busca (restart instruction fetch)
							END IF;
						WHEN JZ =>						-- desvia para o endereo se Z=1 (jump if zero)
							IF (Z='1') THEN
								-- se Z=1 (if Z=1)
								ADDRESS_BUS <= PC + 1;	-- aponta para o operando da instruo (fetch the operand)
								CPU_STATE := DECOD_JMP;	-- prossegue como um JMP (proceed as a JMP)
							ELSE
								-- se Z=0 (if Z=0)
								PC := PC + 2;			-- avana o PC (add 2 to the PC)
								CPU_STATE := BUSCA;		-- retorna ao estado de busca (restart instruction fetch)
							END IF;
						WHEN JNZ =>						-- desvia para o endereo se Z=0 (jump if not zero)
							IF (Z='0') THEN
								-- se Z=0 (if Z=0)
								ADDRESS_BUS <= PC + 1;	-- aponta para o operando da instruo (fetch the operand)
								CPU_STATE := DECOD_JMP;	-- prossegue como um JMP (proceed as a JMP)
							ELSE
								-- se Z=1 (if Z=1)
								PC := PC + 2;			-- avana o PC (add 2 to the PC)
								CPU_STATE := BUSCA;		-- retorna ao estado de busca (restart instruction fetch)
							END IF;
						WHEN JC =>						-- desvia para o endereo se C=1 (jump if carry)
							IF (C='1') THEN
								-- se C=1 (if C=1)
								ADDRESS_BUS <= PC + 1;	-- aponta para o operando da instruo (fetch the operand)
								CPU_STATE := DECOD_JMP;	-- prossegue como um JMP (proceed as a JMP)
							ELSE
								-- se C=0
								PC := PC + 2;			-- avana o PC (add 2 to the PC)
								CPU_STATE := BUSCA;		-- retorna ao estado de busca (restart instruction fetch)
							END IF;
						WHEN JNC =>						-- desvia para o endereo se C=0 (jump if not carry)
							IF (C='0') THEN
								-- se C=0 (if C=0)
								ADDRESS_BUS <= PC + 1;	-- aponta para o operando da instruo (fetch the operand)
								CPU_STATE := DECOD_JMP;	-- prossegue como um JMP (proceed as a JMP)
							ELSE
								-- se C=1 (if C=1)
								PC := PC + 2;			-- avana o PC (add 2 to the PC)
								CPU_STATE := BUSCA;		-- retorna ao estado de busca (restart instruction fetch)
							END IF;
						WHEN JB =>						-- desvia para o endereo se B=1 (jump if borrow)
							IF (B='1') THEN
								-- se B=1 (if B=1)
								ADDRESS_BUS <= PC + 1;	-- aponta para o operando da instruo (fetch the operand)
								CPU_STATE := DECOD_JMP;	-- prossegue como um JMP (proceed as a JMP)
							ELSE
								-- se B=0 (if B=0)
								PC := PC + 2;			-- avana o PC (Add 2 to the PC)
								CPU_STATE := BUSCA;		-- retorna ao estado de busca (restart instruction fetch)
							END IF;
						WHEN JNB =>						-- desvia para o endereo se B=0 (jump if not borrow)
							IF (B='0') THEN
								-- se B=0 (if B=0)
								ADDRESS_BUS <= PC + 1;	-- aponta para o operando da instruo (fetch the operand)
								CPU_STATE := DECOD_JMP;	-- prossegue como um JMP (proceed as a JMP)
							ELSE
								-- se B=1 (if B=1)
								PC := PC + 2;			-- avana o PC (add 2 to the PC)
								CPU_STATE := BUSCA;		-- retorna ao estado de busca (restart instruction fetch)
							END IF;
						WHEN SHR =>						-- SHR - deslocamento para a direita (shift right)
							CPU_STATE := DECOD_SHR1;	-- avana para a decodificao da SHR (proceed with SHR decoding)
						WHEN SHL =>						-- SHL - deslocamento para a esquerda (shift left)
							CPU_STATE := DECOD_SHL1;	-- avana para a decodificao da SHL (proceed with SHL decoding)
						WHEN IROR =>					-- IROR - rotao para a direita (immediate rotate to right)
							Cout <= C;
							CPU_STATE := DECOD_IROR1;	-- avana para a decodificao da IROR (proceed with IROR decoding)
						WHEN IROL =>					-- IROL - rotao para a esquerda (immediate rotate to left)
							Cout <= C;
							CPU_STATE := DECOD_IROL1;	-- avana para a decodificao da IROL (proceed with IROL decoding)
						WHEN HLT =>						-- HLT - pra o processamento e aguarda um reset (halts processing)
						WHEN OTHERS =>					-- opcode desconhecido (unkown opcode)
							PC := PC + 1;				-- avana o PC (add 1 to the PC)
							ERROR <= '1';				-- coloca ERRO em 1 (sets error output)
							CPU_STATE := BUSCA;			-- retorna ao estado de busca (restart instruction fetch)
					END CASE;
				WHEN DECOD_STA1 =>				-- decodificao da instruo STA (STA decoding)
					TEMP := DATA_IN;			-- l o operando (reads the operand)
					CPU_STATE := DECOD_STA2;	
				WHEN DECOD_STA2 =>				
					ADDRESS_BUS <= TEMP;
					DATA_OUT <= AC;				-- coloca o acumulador na sada de dados (put the accumulator on the data_out bus)
					PC := PC + 1;				-- incrementa o PC (add 1 to the PC)
					CPU_STATE := DECOD_STA3;
				WHEN DECOD_STA3 =>
					MEM_WRITE <= '1';			-- ativa a escrita na memria (write to the memory)
					PC := PC + 1;				-- incrementa o PC (agora ele aponta para a prxima instruo) (add 1 to the PC)
					CPU_STATE := DECOD_STA4;
				WHEN DECOD_STA4 =>
					MEM_WRITE <= '0';			-- desativa a escrita na memria (disable memory write signal)
					CPU_STATE := BUSCA;			-- termina a decodificao da instruo STA (restart instruction fetch)
				WHEN DECOD_LDA1 =>				-- decodificao da instruo LDA (LDA decoding)
					TEMP := DATA_IN;			-- carrega o operando (endereo) (loads operand address)
					CPU_STATE := DECOD_LDA2;
				WHEN DECOD_LDA2 =>
					ADDRESS_BUS <= TEMP;		-- coloca o endereo do operando no barramento de endereos (load the operand onto the address bus)
					PC := PC + 1;				-- incrementa o PC (add 1 to the PC)
					CPU_STATE := DECOD_LDA3;
				WHEN DECOD_LDA3 =>
					AC := DATA_IN;				-- carrega o acumulador com o dado apontado pelo barramento de endereos (load the accumulator with the data read)
					PC := PC + 1;				-- incrementa o PC (add 1 to the PC)
					CPU_STATE := BUSCA;			-- termina a decodificao da instruo LDA (restart instruction fetch)
				WHEN DECOD_ADD1 =>				-- decodificao da instruo ADD (ADD decoding)
					TEMP := DATA_IN;			-- carrega o operando (endereo) (load the operand address)
					CPU_STATE := DECOD_ADD2;
				WHEN DECOD_ADD2 =>
					ADDRESS_BUS <= TEMP;		-- coloca o endereo do operando no barramento de endereos (load the address bus with the operand address)
					CPU_STATE := DECOD_ADD3;
				WHEN DECOD_ADD3 =>
					OPER_A <= DATA_IN;			-- coloca o dado na entrada OPER_A da ULA (load ULA's OPER_A input with the data read from memory)
					OPER_B <= AC;				-- carrega a entrada OPER_B da ULA com o acumulador (load ULA's OPER_B input with the data from the accumulator)
					OPERACAO <= ULA_ADD;		-- especifica a operao ADD na ULA (select ULA's ADD operation)
					PC := PC + 1;				-- incrementa o PC (add 1 to the PC)
					CPU_STATE := DECOD_STORE;
				WHEN DECOD_SUB1 =>				-- decodificao da instruo SUB (SUB decoding)
					TEMP := DATA_IN;			-- carrega o operando (endereo) (load the operand address)
					CPU_STATE := DECOD_SUB2;
				WHEN DECOD_SUB2 =>
					ADDRESS_BUS <= TEMP;		-- coloca o endereo do operando no barramento de endereos (load the address bus with the operand address)
					CPU_STATE := DECOD_SUB3;
				WHEN DECOD_SUB3 =>
					OPER_A <= AC;				-- carrega a entrada OPER_A da ULA com o acumulador (load ULA's OPER_A input from accumulator)
					OPER_B <= DATA_IN;			-- carrega a entrada OPER_B da ULA (load ULA's OPER_B input from data input bus)
					OPERACAO <= ULA_SUB;		-- seleciona a operao SUB na ULA (select ULA's SUB operation)
					PC := PC + 1;				-- incrementa o PC (increments the PC)
					CPU_STATE := DECOD_STORE;
				WHEN DECOD_IOR1 =>				-- decodificao da instruo OR (OR decoding)
					TEMP := DATA_IN;			-- carrega o operando (endereo) (load the operand address)
					CPU_STATE := DECOD_IOR2;
				WHEN DECOD_IOR2 =>
					ADDRESS_BUS <= TEMP;		-- coloca o endereo do operando no barramento de endereos (load the address bus with the operand address)
					CPU_STATE := DECOD_IOR3;
				WHEN DECOD_IOR3 =>
					OPER_A <= AC;				-- carrega a entrada OPER_A da ULA com o acumulador (load ULA's OPER_A input from the accumulator)
					OPER_B <= DATA_IN;			-- carrega a entrada OPER_B da ULA com o dado (load ULA's OPER_B input from the data bus)
					OPERACAO <= ULA_OU;			-- seleciona a operao OU na ULA (select ULA's OR operation)
					PC := PC + 1;				-- incrementa o PC (increments the PC)
					CPU_STATE := DECOD_STORE;
				WHEN DECOD_IAND1 =>				-- decodificao da instruo AND (AND decoding)
					TEMP := DATA_IN;			-- carrega o operando (endereo) (load the operand address)
					CPU_STATE := DECOD_IAND2;
				WHEN DECOD_IAND2 =>
					ADDRESS_BUS <= TEMP;		-- coloca o endereo do operando no barramento de endereos (load the address bus with the operand address)
					CPU_STATE := DECOD_IAND3;
				WHEN DECOD_IAND3 =>
					OPER_A <= AC;				-- carrega a entrada OPER_A da ULA com o acumulador (load ULA's OPER_A input from the accumulator)
					OPER_B <= DATA_IN;			-- carrega a entrada OPER_B da ULA com o dado (load ULA's OPER_B input from the data bus)
					OPERACAO <= ULA_E;			-- seleciona a operao E na ULA (select ULA's AND operation)
					PC := PC + 1;				-- incrementa o PC (increments the PC)
					CPU_STATE := DECOD_STORE;
				WHEN DECOD_JMP =>				-- decodificao da instruo JMP (JMP decoding)
					PC := DATA_IN;				-- carrega o dado lido (operando) no PC (load PC with the operand data)
					CPU_STATE := BUSCA;			-- termina a decodificao da instruo JMP (restart instruction decoding)
				WHEN DECOD_SHR1 =>				-- decodificao da instruo SHR (SHR decoding)
					OPER_A <= AC;				-- carrega a entrada OPER_A da ULA com o acumulador (load ULA's OPER_A input from the accumulator)
					OPERACAO <= ULA_DAD;		-- seleciona a operao de deslocamento aritmtico  direita (select ULA's SHR operation)
					CPU_STATE := DECOD_STORE;
				WHEN DECOD_SHL1 =>				-- decodificao da instruo SHL (SHL decoding)
					OPER_A <= AC;				-- carrega a entrada OPER_A da ULA com o acumulador (load ULA's OPER_A input from the accumulator)
					OPERACAO <= ULA_DAD;		-- seleciona a operao de deslocamento aritmtico  esquerda (select ULA's SHL)
					CPU_STATE := DECOD_STORE;
				WHEN DECOD_IROR1 =>				-- decodificao da instruo ROR (ROR decoding)
					OPER_A <= AC;				-- carrega a entrada OPER_A da ULA com o acumulador (load ULA's OPER_A from the accumulator)
					OPERACAO <= ULA_DLD;		-- seleciona a operao de deslocamento lgico  direita (select ULA's ROR)
					CPU_STATE := DECOD_STORE;
				WHEN DECOD_IROL1 =>				-- decodificao da instruo ROL (ROL decoding)
					OPER_A <= AC;				-- carrega a entrada OPER_A da ULA com o acumulador (load ULA's OPER_A from the accumulator)
					OPERACAO <= ULA_DLE;		-- seleciona a operao de deslocamento lgico  esquerda (select ULA's ROL)
					CPU_STATE := DECOD_STORE;					
				WHEN DECOD_STORE =>
					AC := RESULT;				-- carrega o resultado da ULA no acumulador (load the accumulator from the result)
					PC := PC + 1;				-- incrementa o PC (increments the PC)
					CPU_STATE := BUSCA;			-- termina a decodificao da instruo (restart instruction decoding)
			END CASE;
		END IF;
	end process;
END Behavioral;