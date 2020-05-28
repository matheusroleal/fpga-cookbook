--------------------------------------------------------------------------------
-- Company: 
-- Engineer:
--
-- Create Date:   09:03:03 05/26/2020
-- Design Name:   
-- Module Name:   /home/matheus/Documents/PUC-RIO/ComputacaoDigital/lab7/LCDdisplay_tb.vhd
-- Project Name:  lab7
-- Target Device:  
-- Tool versions:  
-- Description:   
-- 
-- VHDL Test Bench Created by ISE for module: LCDdisplay
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
 
ENTITY LCDdisplay_tb IS
END LCDdisplay_tb;
 
ARCHITECTURE behavior OF LCDdisplay_tb IS 
 
    -- Component Declaration for the Unit Under Test (UUT)
 
    COMPONENT LCDdisplay
    PORT(
         clk_50MHZ : IN  std_logic;
         lcd_rw : OUT  std_logic;
         lcd_rs : OUT  std_logic;
         lcd_e : OUT  std_logic;
         sf_d : OUT  std_logic_vector(11 downto 8);
         led_1 : OUT  std_logic;
         led_2 : OUT  std_logic;
         led_3 : OUT  std_logic
        );
    END COMPONENT;
    

   --Inputs
   signal clk_50MHZ : std_logic := '0';

 	--Outputs
   signal lcd_rw : std_logic;
   signal lcd_rs : std_logic;
   signal lcd_e : std_logic;
   signal sf_d : std_logic_vector(11 downto 8);
   signal led_1 : std_logic;
   signal led_2 : std_logic;
   signal led_3 : std_logic;

   -- Clock period definitions
   constant clk_50MHZ_period : time := 20 ns;
 
BEGIN
 
	-- Instantiate the Unit Under Test (UUT)
   uut: LCDdisplay PORT MAP (
          clk_50MHZ => clk_50MHZ,
          lcd_rw => lcd_rw,
          lcd_rs => lcd_rs,
          lcd_e => lcd_e,
          sf_d => sf_d,
          led_1 => led_1,
          led_2 => led_2,
          led_3 => led_3
        );

   -- Clock process definitions
   clk_50MHZ_process :process
   begin
		clk_50MHZ <= '0';
		wait for clk_50MHZ_period/2;
		clk_50MHZ <= '1';
		wait for clk_50MHZ_period/2;
   end process;
 

   -- Stimulus process
   stim_proc: process
   begin		
      -- hold reset state for 100 ns.
      wait for 100 ns;	

      wait for clk_50MHZ_period*10;

      -- insert stimulus here 

      wait;
   end process;

END;
