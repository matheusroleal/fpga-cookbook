----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    14:06:34 04/26/2020 
-- Design Name: 
-- Module Name:    ps2_keybord - Behavioral 
-- Project Name: 
-- Target Devices: 
-- Tool versions: 
-- Description: 
--
-- Dependencies: 
--
-- Revision: 
-- Revision 0.01 - File Created
-- Additional Comments: 
--
----------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

-- arithmetic functions with Signed or Unsigned values
use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx primitives in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity ps2_keybord is
	port(
		clk : IN std_logic;
		ps2_clk : IN std_logic;
		data : IN std_logic;
		leds : OUT std_logic_vector(7 downto 0)
	);
end ps2_keybord;

architecture Behavioral of ps2_keybord is
	type estado is (idle,start,s1);
	
	signal ps, ns : estado;
	signal data_reg : std_logic_vector(7 downto 0);
	signal contador : integer := 0;
	constant N: integer := 4;
	
	signal sclk : unsigned(N-1 downto 0);
	signal sclk_next : unsigned(N-1 downto 0);
	
	signal par_bit, start_bit, stop_bit : std_logic;
begin

	proc1 : process(ps2_clk, ns) is
	begin
		if (falling_edge(ps2_clk)) then
			ps <= ns;
		end if;
	end process proc1;
	
	proc2 : process(ps, data, ps2_clk, sclk) is
	begin
		if (falling_edge(ps2_clk)) then
			case ns is
			when idle =>
				sclk <= "0000";
				if (data = '0') then
					ns <= s1;
					sclk <= "0001";
				end if;
			when s1 =>
				sclk <= sclk + 1;
				case sclk is
				when "0001" => 
					data_reg(0) <= data;
				when "0010" =>
					data_reg(1) <= data;
				when "0011" => 
					data_reg(2) <= data;
				when "0100" =>
					data_reg(3) <= data;
				when "0101" =>
					data_reg(4) <= data;
				when "0110" => 
					data_reg(5) <= data;
				when "0111" =>
					data_reg(6) <= data;
				when "1000"	=> 
					data_reg(7) <= data;
				when "1001" => 
					par_bit <= data;
				when others =>
					stop_bit <= data;
					ns <= idle;
					sclk <= "0000";
				end case;
			when others => 
				ns <= idle;
			end case;
		end if;
	end process proc2;
	
	leds <= data_reg;

end Behavioral;
