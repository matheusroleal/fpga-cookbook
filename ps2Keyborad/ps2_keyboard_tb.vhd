--------------------------------------------------------------------------------
-- Company: 
-- Engineer:
--
-- Create Date:   12:18:06 04/28/2020
-- Design Name:   
-- Module Name:   C:/Users/Edneia/Desktop/matheus/Lab 5/ps2_keybord/ps2_keyboard_tb.vhd
-- Project Name:  ps2_keybord
-- Target Device:  
-- Tool versions:  
-- Description:   
-- 
-- VHDL Test Bench Created by ISE for module: ps2_keybord
-- 
-- Dependencies:
-- 
-- Revision:
-- Revision 0.01 - File Created
-- Additional Comments:
--
-- Notes: 
-- This testbench has been automatically generated using types std_logic and
-- std_logic_vector for the ports of the unit under test.  Xilinx recommends
-- that these types always be used for the top-level I/O of a design in order
-- to guarantee that the testbench will bind correctly to the post-implementation 
-- simulation model.
--------------------------------------------------------------------------------
LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
 
-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--USE ieee.numeric_std.ALL;
 
ENTITY ps2_keyboard_tb IS
END ps2_keyboard_tb;
 
ARCHITECTURE behavior OF ps2_keyboard_tb IS 
 
    -- Component Declaration for the Unit Under Test (UUT)
 
    COMPONENT ps2_keybord
    PORT(
         clk : IN  std_logic;
         ps2_clk : IN  std_logic;
         data : IN  std_logic;
         leds : OUT  std_logic_vector(7 downto 0)
        );
    END COMPONENT;
    

   --Inputs
   signal clk : std_logic := '0';
   signal ps2_clk : std_logic := '0';
   signal data : std_logic := '0';

 	--Outputs
   signal leds : std_logic_vector(7 downto 0);

   -- Clock period definitions
   constant clk_period : time := 10 ns;
   constant ps2_clk_period : time := 10 ns;
 
BEGIN
 
	-- Instantiate the Unit Under Test (UUT)
   uut: ps2_keybord PORT MAP (
          clk => clk,
          ps2_clk => ps2_clk,
          data => data,
          leds => leds
        );

   -- Clock process definitions
   clk_process :process
   begin
		clk <= '0';
		wait for clk_period/2;
		clk <= '1';
		wait for clk_period/2;
   end process;
 
   ps2_clk_process :process
   begin
		ps2_clk <= '0';
		wait for ps2_clk_period/2;
		ps2_clk <= '1';
		wait for ps2_clk_period/2;
   end process;
 

   -- Stimulus process
   stim_proc: process
   begin		
      -- hold reset state for 100 ns.
      wait for 100 ns;	

      wait for clk_period*10;

      -- insert stimulus here 
		 
    DATA <= '0'; --start
    PS2_CLK <= '0';
    wait for ps2_clk_period;
    PS2_CLK <= '1';
    wait for ps2_clk_period;
    
    DATA <= '1';
    PS2_CLK <= '0';
    wait for ps2_clk_period;
    PS2_CLK <= '1';
    wait for ps2_clk_period;
    
    DATA <= '0';
    PS2_CLK <= '0';
    wait for ps2_clk_period;
    PS2_CLK <= '1';
    wait for ps2_clk_period;
    
    
    DATA <= '1';
    PS2_CLK <= '0';
    wait for ps2_clk_period;
    PS2_CLK <= '1';
    wait for ps2_clk_period;
    
    DATA <= '1'; 
    PS2_CLK <= '0';
    wait for ps2_clk_period;
    PS2_CLK <= '1';
    wait for ps2_clk_period;
    
    DATA <= '0';
    PS2_CLK <= '0';
    wait for ps2_clk_period;
    PS2_CLK <= '1';
    wait for ps2_clk_period;
    
    DATA <= '0';
    PS2_CLK <= '0';
    wait for ps2_clk_period;
    PS2_CLK <= '1';
    wait for ps2_clk_period;
    
    DATA <= '1';
    PS2_CLK <= '0';
    wait for ps2_clk_period;
    PS2_CLK <= '1';
    wait for ps2_clk_period;
    
    DATA <= '1';
    PS2_CLK <= '0';
    wait for ps2_clk_period;
    PS2_CLK <= '1';
    wait for ps2_clk_period;
    
    DATA <= '0'; -- odd parity
    PS2_CLK <= '0';
    wait for ps2_clk_period;
    PS2_CLK <= '1';
    wait for ps2_clk_period;
    
    DATA <= '1'; -- stop
    PS2_CLK <= '0';
    wait for ps2_clk_period;
    PS2_CLK <= '1';
    wait for ps2_clk_period;

      wait;
   end process;

END;
