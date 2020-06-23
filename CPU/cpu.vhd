library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity cpu is
	PORT(
		clk 				: IN std_logic;
		reset 				: IN std_logic;
		zero_flag_led	 	: OUT std_logic := '0';
		negative_flag_led 	: OUT std_logic := '0';
		clk_2s_led			: OUT std_logic;
		mem30_led			: OUT std_logic_vector ( 4 downto 0);
		lcd_e_out			: OUT std_logic;
		lcd_rs_out	 		: OUT std_logic;
		lcd_rw_out			: OUT std_logic;
		sf_d_out			: OUT STD_LOGIC_VECTOR(11 downto 8);
		sf_ce0				: OUT std_logic := '0'
	);
end cpu;

architecture Behavioral of cpu is
		
	component memoria
		port (clk 			: IN std_logic;
			  reset, r_w	: IN std_logic;
			  endereco 		: IN integer range 0 to 31;
			  leitura 		: OUT std_logic_vector ( 4 downto 0);
			  escrita 		: IN std_logic_vector ( 4 downto 0);
			  dado_30 		: OUT std_logic_vector ( 4 downto 0));
	end component;

	component ula
		port (clk  				: IN  std_logic;
			  operando1 		: IN std_logic_vector( 4 downto 0);
			  operando2 		: IN std_logic_vector( 4 downto 0);
			  opcode 			: IN std_logic_vector( 4 downto 0);
			  start				: IN std_logic;
			  result 			: OUT std_logic_vector( 4 downto 0);
			  done 				: OUT std_logic;
			  zero_flag 		: OUT std_logic := '0';
			  negative_flag 	: OUT std_logic := '0');
	end component;

	component lcd
		port(clk    		 : IN STD_LOGIC;
			 opcode 		 : IN std_logic_vector ( 4 downto 0);
			 endereco_jmp 	 : IN integer range 0 to 31;
			 endereco_mv  	 : IN integer range 0 to 31;
			 lcd_rw 		 : OUT STD_LOGIC;
			 lcd_rs 		 : OUT STD_LOGIC;
			 lcd_e  		 : OUT STD_LOGIC;
			 sf_d   		 : OUT STD_LOGIC_VECTOR(11 downto 8));
	end component;

	-- Constantes com as instrues do processador
	constant MOV_A_END : STD_LOGIC_VECTOR(4 DOWNTO 0):="00001";
	constant MOV_END_A : STD_LOGIC_VECTOR(4 DOWNTO 0):="00010";
	constant MOV_A_B   : STD_LOGIC_VECTOR(4 DOWNTO 0):="00011";
	constant MOV_B_A   : STD_LOGIC_VECTOR(4 DOWNTO 0):="00100";
	constant ADD_A_B   : STD_LOGIC_VECTOR(4 DOWNTO 0):="00101";
	constant SUB_A_B   : STD_LOGIC_VECTOR(4 DOWNTO 0):="00110";
	constant A_AND_B   : STD_LOGIC_VECTOR(4 DOWNTO 0):="00111";
	constant A_OR_B    : STD_LOGIC_VECTOR(4 DOWNTO 0):="01000";
	constant A_XOR_B   : STD_LOGIC_VECTOR(4 DOWNTO 0):="01001";
	constant NOT_A     : STD_LOGIC_VECTOR(4 DOWNTO 0):="01010";
	constant A_NAND_B  : STD_LOGIC_VECTOR(4 DOWNTO 0):="01011";
	constant JZ        : STD_LOGIC_VECTOR(4 DOWNTO 0):="01100";
	constant JN        : STD_LOGIC_VECTOR(4 DOWNTO 0):="01101";
	constant HALT      : STD_LOGIC_VECTOR(4 DOWNTO 0):="01110";
	constant JMP       : STD_LOGIC_VECTOR(4 DOWNTO 0):="01111";
	constant INCA      : STD_LOGIC_VECTOR(4 DOWNTO 0):="10000";
	constant INCB      : STD_LOGIC_VECTOR(4 DOWNTO 0):="10001";
	constant DECA      : STD_LOGIC_VECTOR(4 DOWNTO 0):="10010";
	constant DECB      : STD_LOGIC_VECTOR(4 DOWNTO 0):="10011";

	--SINAIS RAM
	SIGNAL r_w 			: std_logic;
	SIGNAL endereco 	: integer range 0 to 31;
	SIGNAL escrita 		: std_logic_vector ( 4 downto 0);
	SIGNAL leitura 		: std_logic_vector ( 4 downto 0);
	SIGNAL mem30		: std_logic_vector ( 4 downto 0);

	--SINAIS ALU
	SIGNAL opcode			: std_logic_vector ( 4 downto 0);
	SIGNAL result 			: std_logic_vector ( 4 downto 0);
	SIGNAL start_ALU	 	: std_logic;
	SIGNAL done_ALU 		: std_logic;
	SIGNAL zero_flag 		: std_logic := '0';
	SIGNAL negative_flag 	: std_logic := '0';

	--SINAIS LCD
	SIGNAL sf_d				: std_logic_vector ( 11 downto 8);
	SIGNAL lcd_e 			: std_logic;
	SIGNAL lcd_rs		 	: std_logic;
	SIGNAL lcd_rw 			: std_logic;

	--SINAIS CONTROL UNIT
	SIGNAL halt_bool		: std_logic;
	SIGNAL mv_position		: integer range 0 to 31 := 0;
	SIGNAL jmp_position		: integer range 0 to 31 := 0;
	SIGNAL position 		: integer range 0 to 31 := 0;
	SIGNAL rA 	 			: std_logic_vector ( 4 downto 0);
	SIGNAL rB				: std_logic_vector ( 4 downto 0);
	SIGNAL command			: std_logic_vector ( 4 downto 0):= "00000";
	SIGNAL zero_flag_uc	 	: std_logic := '0';
	SIGNAL negative_flag_uc : std_logic := '0';

	-- CONTROLE DO CLOCK
	SIGNAL clk_2seg : std_logic;
	SIGNAL count_clk : integer := 0;
	SIGNAL direction_clk : std_logic := '1';

	-- ESTADOS DE EXECUCAO
	TYPE state_type IS (idle, reading, fecthing, pre_fetching_mv, fetching_mv, pre_processing_mv, processing_mv, pos_processing_mv, pre_fetching_jmp, fetching_jmp, pre_processing_jmp, processing_jmp, pos_processing_jmp, processing, processing_ALU, finishing, halt);
	SIGNAL pst_uc	: 	state_type := idle;

begin
	RAM_UC: memoria port map (clk=>clk, reset=>reset, r_w=>r_w, endereco=>endereco, leitura=>leitura, escrita=>escrita, dado_30=>mem30);
	ALU_UC: ula port map (clk=>clk, opcode=>command, operando1=>rA, operando2=>rB, result=>result, start=>start_ALU, done=>done_ALU, zero_flag=>zero_flag, negative_flag => negative_flag);
	LCD_UC: lcd port map (clk=>clk, opcode=>command, endereco_mv=>mv_position, endereco_jmp=>jmp_position, lcd_rw=>lcd_rw, lcd_rs=>lcd_rs, lcd_e=>lcd_e, sf_d=>sf_d);

	zero_flag_led <= zero_flag_uc;
	negative_flag_led <= negative_flag_uc;
	clk_2s_led <= clk_2seg;
	mem30_led <= mem30;
	lcd_e_out <= lcd_e;
	lcd_rs_out <= lcd_rs;
	lcd_rw_out <= lcd_rw;
	sf_d_out <= sf_d;
	sf_ce0 <= '0';

	-- Processo que transforma o clock de 50MHZ em 0,5HZ
	process (clk)
	begin
		if (clk'event and clk = '1') then
			if (count_clk < 3125000 and direction_clk = '1') then
					clk_2seg <= '0';
					count_clk <= count_clk + 1;
			elsif (count_clk < 6250000 and direction_clk = '1') then
					clk_2seg <= '1';
					count_clk <= count_clk + 1;
			else 
					count_clk <= 0;
			end if;
		end if;
	end process;

	-- Processo que troca estado a cada subida do clock de 2 segundos
	process (clk)
	begin
		if (clk'event and clk = '1') then
			if (reset = '1') then
				position <= 0;
				rA <= "00000";
				rB <= "00000";
				pst_uc <= idle;
				start_ALU <= '0';
				zero_flag_uc <= '0';
				negative_flag_uc <= '0';
				halt_bool <= '0';
				r_w <= '1';
			else
				case pst_uc is
					when idle =>
						start_ALU <= '0';
						r_w <= '1'; -- set leitura 
						endereco <= position;
						pst_uc <= reading;
					when reading =>
						r_w <= '1'; -- set leitura
						pst_uc <= fecthing;
					when fecthing => 
						command <= leitura;
						pst_uc <= processing;
					when pre_fetching_mv =>
						r_w <= '1';
						pst_uc <= fetching_mv;
					when fetching_mv =>
						mv_position <= to_integer(unsigned(leitura));
						pst_uc <= pre_processing_mv;
					when pre_processing_mv =>
						endereco <= mv_position;
						pst_uc <= processing_mv;
					when processing_mv =>
						if (command = "00010") then
							escrita <= rA;
						else
							r_w <= '1';
						end if;
						pst_uc <= pos_processing_mv;
					when pos_processing_mv =>
						if (command = "00010") then
							r_w <= '0';
						else
							rA <= leitura;
						end if;
						pst_uc <= finishing;
					when pre_fetching_jmp =>
						r_w <= '1';
						pst_uc <= fetching_jmp;
					when fetching_jmp =>
						jmp_position <= to_integer(unsigned(leitura));
						pst_uc <= pre_processing_jmp;
					when pre_processing_jmp =>
						endereco <= jmp_position;
						pst_uc <= processing_jmp;
					when processing_jmp =>
						position <= endereco;
						pst_uc <= idle;
					when processing =>
							case command is 
								when MOV_A_END => -- MOV A, end
									endereco <= position + 1;
									position <=  position + 1;
									pst_uc <= pre_fetching_mv;
								when MOV_END_A => -- MOV end, A
									endereco <= position + 1;
									position <=  position + 1;
									r_w <= '1';
									pst_uc <= pre_fetching_mv;
								when MOV_A_B => -- MOV A, B
									rA <= rB;
									pst_uc <= finishing;	
								when MOV_B_A => -- MOV B, A
									rB <= rA;
									pst_uc <= finishing;
								when ADD_A_B => -- ADD A, B
									start_ALU <= '1';
									pst_uc <= processing_ALU;
								when SUB_A_B => -- SUB A, B
									start_ALU <= '1';
									pst_uc <= processing_ALU;	
								when A_AND_B => -- A AND B
									start_ALU <= '1';
									pst_uc <= processing_ALU;
								when A_OR_B => -- A OR B
									start_ALU <= '1';
									pst_uc <= processing_ALU;	
								when A_XOR_B => -- A XOR B
									start_ALU <= '1';
									pst_uc <= processing_ALU;	
								when NOT_A => -- NOT A
									start_ALU <= '1';
									pst_uc <= processing_ALU;
								when A_NAND_B => -- A NAND B
									start_ALU <= '1';
									pst_uc <= processing_ALU;
								when JZ => -- JZ
									if(zero_flag_uc = '0') then
										endereco <= position + 1;
										pst_uc <= pre_fetching_jmp;
									else
										position <= position + 1;
										pst_uc <= finishing;
									end if;						
								when JN => -- JN
									if(negative_flag_uc = '1') then
										endereco <= position + 1;
										pst_uc <= pre_fetching_jmp;
									else
										position <= position + 1;
										pst_uc <= finishing;
									end if;	
								when HALT => -- HALT
									pst_uc <= halt;
								when JMP => -- JMP
									endereco <= position + 1;
									pst_uc <= pre_fetching_jmp;
								when INC_A => -- INC A
									start_ALU <= '1';
									pst_uc <= processing_ALU;	
								when INC_B => -- INC B
									start_ALU <= '1';
									pst_uc <= processing_ALU;	
								when DEC_A => -- DEC A
									start_ALU <= '1';
									pst_uc <= processing_ALU;	
								when DEC_B => -- DEC B
									start_ALU <= '1';
									pst_uc <= processing_ALU;
								when others => 
									start_ALU <= '0';
									r_w <= '1';
									pst_uc <= finishing;
							end case;
						when processing_ALU =>
							zero_flag_uc <= zero_flag;
							negative_flag_uc <= negative_flag;
							if (done_ALU = '1') then
										pst_uc <= finishing;
										if (command = "10011" or command = "10001") then
											rB <= result;
										else
											rA <= result;
										end if;
							end if;							
						when halt =>
							halt_bool <= '1';
							pst_uc <= finishing;
						when finishing =>
							if (position < 31 and halt_bool = '0') then
									position <= position + 1;
									pst_uc <= idle;
							end if;
							--printar no LCD que acabou
						when others =>
							pst_uc <= idle;
				end case;
			end if;
		end if;
	end process;

end Behavioral;