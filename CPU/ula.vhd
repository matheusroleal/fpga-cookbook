library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.all;
use IEEE.STD_LOGIC_SIGNED.all;

entity ula is
	port (	clk  			: IN  std_logic;
			operando1 		: IN std_logic_vector(4 downto 0);
			operando2 		: IN std_logic_vector(4 downto 0);
			opcode 			: IN std_logic_vector(4 downto 0); -- opcode do comando atual a ser executado
			start			: IN std_logic;
			result 			: OUT std_logic_vector(4 downto 0); -- resultado da operacao
			done 			: OUT std_logic;
			zero_flag 		: OUT std_logic := '0';
			negative_flag 	: OUT std_logic := '0');
end ula;


architecture Behavioral of ula is

TYPE state_type IS (idle, processing, finish, set);
SIGNAL pst : state_type := idle;
SIGNAL temp_result : std_logic_vector (4 downto 0);

begin
	process(clk, start, pst, opcode, operando1, operando2) 
		begin
			if (rising_edge(clk)) then 
				case pst is
					when idle => 
						if(start = '1') then
							pst <= processing;
							negative_flag <= '0';
						end if;
					when processing =>
						case opcode is
							when "00101" => temp_result <= (signed(operando1) + signed(operando2));		--A + B 
									
							when "00110" => temp_result <= (signed(operando1) - signed(operando2));		-- A - B
							
							when "00111" => temp_result <= operando1 AND operando2;						 	-- A AND B

							when "01000" => temp_result <= operando1 OR operando2;						 	-- A OR B

							when "01001" => temp_result <= operando1 XOR operando2;							-- A XOR B

							when "01010" => temp_result <= NOT operando1;										-- NOT A

							when "01011" => temp_result <= operando1 NAND operando2;							-- A NAND B

							when "10000" => temp_result <= (signed(operando1) + 1);							-- INC A

							when "10001" => temp_result <= (signed(operando2) + 1);							-- INC B

							when "10010" => temp_result <= (signed(operando1) - 1);							-- DEC A

							when "10011" => temp_result <= (signed(operando2) - 1);							-- DEC B

							when others => temp_result <= "00000";
						end case;
						pst <= finish;

					when finish =>
						result <= temp_result;
						done <= '1';
						pst <= set;
						negative_flag <= temp_result(4);
						if (signed(temp_result) = 0) then
							zero_flag <= '1';
						else
							zero_flag <= '0';
						end if;
						
					when set =>
						done <= '0';
						pst <= idle;
					
					when others =>
						pst <= idle;
				end case;
			end if;
		end process;
end Behavioral;