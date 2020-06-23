LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
 
-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned vulaes
--USE ieee.numeric_std.ALL;
 
ENTITY ula_tb IS
END ula_tb;
 
ARCHITECTURE behavior OF ula_tb IS 
 
    -- Component Declaration for the Unit Under Test (UUT)
 
    COMPONENT ula
		port (
			clk  			: IN  std_logic;
			operando1 		: IN std_logic_vector(4 downto 0);
			operando2 		: IN std_logic_vector(4 downto 0);
			opcode 			: IN std_logic_vector(4 downto 0); -- opcode do comando atual a ser executado
			start			: IN std_logic;
			result 			: OUT std_logic_vector(4 downto 0); -- resultado da operacao
			done 			: OUT std_logic;
			zero_flag 		: OUT std_logic := '0';
			negative_flag 	: OUT std_logic := '0'
		);
    END COMPONENT;
    

   --Inputs
   signal clk 			: std_logic := '0';
   signal opcode 		: std_logic_vector(4 downto 0) := (others => '0');
   signal operando1 	: std_logic_vector(4 downto 0) := (others => '0');
   signal operando2 	: std_logic_vector(4 downto 0) := (others => '0');
   signal start 		: std_logic := '0';

 	--Outputs
   signal result 	: std_logic_vector(4 downto 0);
   signal done 	: std_logic;
	signal zero_flag 		:  std_logic;
	signal negative_flag 	:  std_logic;

   -- Clock period definitions
   constant clk_period : time := 10 ns;
 
BEGIN
 
	-- Instantiate the Unit Under Test (UUT)
   uut: ula PORT MAP (
		clk => clk,
		operando1 => operando1,
		operando2 => operando2,
		opcode => opcode,
		result => result,
		start => start,
		done => done,
		zero_flag => zero_flag,
		negative_flag => negative_flag
		);

   -- Clock process definitions
   clk_process :process
   begin
		clk <= '0';
		wait for clk_period/2;
		clk <= '1';
		wait for clk_period/2;
   end process;
 

   -- Stimulus process
   stim_proc: process
   begin

		operando1 <= "00001";
		operando2 <= "10000";
		
      -- hold reset state for 100 ns.
      wait for 100 ns;	
		opcode <= "10010";
		start <= '1';
		wait for clk_period;
		start <= '0';

		
		
		
		wait for clk_period*10;
		operando1 <= "00000";
		operando2 <= "00001";
		opcode <= "00110";
		start <= '1';
		wait for clk_period;
		start <= '0';
		

		wait for clk_period*10;
		operando1 <= "00000";
		operando2 <= "00001";
		opcode <= "00111";
		start <= '1';
		wait for clk_period;
		start <= '0';
		
		wait for clk_period*10;
		operando1 <= "00000";
		operando2 <= "00001";
		opcode <= "01000";
		start <= '1';
		wait for clk_period;
		start <= '0';
		
		wait for clk_period*10;
		operando1 <= "00000";
		operando2 <= "00001";
		opcode <= "01001";
		start <= '1';
		wait for clk_period;
		start <= '0';

		wait for clk_period*10;
		operando1 <= "00000";
		operando2 <= "00001";
		opcode <= "01010";
		start <= '1';
		wait for clk_period;
		start <= '0';

		wait for clk_period*10;
		operando1 <= "00000";
		operando2 <= "00001";
		opcode <= "10000";
		start <= '1';
		wait for clk_period;
		start <= '0';

		wait for clk_period*10;
		operando1 <= "00000";
		operando2 <= "00001";
		opcode <= "10001";
		start <= '1';
		wait for clk_period;
		start <= '0';

		wait for clk_period*10;
		operando1 <= "00000";
		operando2 <= "00001";
		opcode <= "10010";
		start <= '1';
		wait for clk_period;
		start <= '0';
		

      -- insert stimulus here 

      wait;
   end process;

END;
