library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity memoria is
	PORT(
		clk : IN STD_LOGIC; 
		reset, r_w : IN STD_LOGIC;
		endereco : IN integer range 0 to 31;
		leitura : OUT STD_LOGIC_VECTOR(4 downto 0);
		escrita : IN STD_LOGIC_VECTOR(4 downto 0); 
		dado_30 : OUT STD_LOGIC_VECTOR (4 downto 0)
	);
end memoria;

architecture Behavioral of memoria is

	constant tam_mem: integer := 31;
	type ram_type is array(0 to tam_mem) of STD_LOGIC_VECTOR(4 downto 0);

	signal ram : ram_type := (
		0 => "ZZZZZ", 
		1 => "ZZZZZ", 
		2 => "ZZZZZ",
		others => "ZZZZZ"
	);
	signal leitura_r : std_logic_vector (4 downto 0) := (others => '0');

begin

dado_30 <= ram(30)(4 downto 0);

	process(clk, reset, r_w)
		begin
			if (rising_edge(clk)) then
				if reset = '1' then
					ram <= (0 => 	"00001", -- MOV A, [END]
							1 => 	"10011", -- 19
							2 => 	"00100", -- MOV B, A
							3 => 	"00001", -- MOV A, [END]
							4 => 	"10010", -- 18
							5 => 	"00110", -- SUB A, B
							6 => 	"00010", -- MOV end, A
							7 => 	"10010", -- 18
							8 => 	"01101", -- JN
							9 => 	"10001", -- 17
							10 => 	"00001", -- MOV A, [END] 
							11 => 	"11110", -- 30
							12 => 	"10000",	--	INC A					
							13 => 	"00010", -- MOV end, A
							14 => 	"11110", -- 30
							15 => 	"01111", -- JMP
							16 => 	"00011", -- 3
							17 => 	"01110", -- HALT
							18 => 	"01010",	-- 10						
							19 => 	"00010", -- 2
							20 => 	"01110",
							21 => 	"01101",
							22 => 	"11110",
							23 => 	"10010",
							24 => 	"10010",
							25 => 	"10010",
							26 => 	"10010",
							27 => 	"10010",
							28 => 	"10010",
							29 => 	"11111",
							30 => 	"00000", -- 0
							31 => 	"11111");
				elsif (r_w = '1') then
					leitura_r <= ram(endereco);
				else 
					ram(endereco) <= escrita;
				end if;
			end if;
		end process;
	leitura <= leitura_r;
end Behavioral;