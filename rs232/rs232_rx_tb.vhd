--------------------------------------------------------------------------------
-- Company: 
-- Engineer:
--
-- Create Date:   10:23:19 05/11/2020
-- Design Name:   
-- Module Name:   C:/Users/Edneia/Desktop/matheus/Lab 6/rs232_rx/rs232_rx_tb.vhd
-- Project Name:  rs232_rx
-- Target Device:  
-- Tool versions:  
-- Description:   
-- 
-- VHDL Test Bench Created by ISE for module: rs232_rx
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
USE ieee.numeric_std.ALL;
 
ENTITY rs232_rx_tb IS
END rs232_rx_tb;
 
ARCHITECTURE behavior OF rs232_rx_tb IS 
 
    -- Component Declaration for the Unit Under Test (UUT)
 
    COMPONENT rs232_rx
    PORT(
         CLOCK : IN  std_logic;
         BIT_IN : IN  std_logic;
         BAUD_RATE : IN  std_logic_vector(12 downto 0);
         WORD_OUT : OUT  std_logic_vector(7 downto 0);
         RX_DONE : OUT  std_logic
        );
    END COMPONENT;
    

   --Inputs
   signal CLOCK : std_logic := '0';
   signal BIT_IN : std_logic := '0';
   signal BAUD_RATE : std_logic_vector(12 downto 0);

 	--Outputs
   signal WORD_OUT : std_logic_vector(7 downto 0);
   signal RX_DONE : std_logic;

   -- Clock period definitions
   constant CLOCK_period : time := 10 ns;
 
BEGIN
 
	-- Instantiate the Unit Under Test (UUT)
   uut: rs232_rx PORT MAP (
          CLOCK => CLOCK,
          BIT_IN => BIT_IN,
          BAUD_RATE => BAUD_RATE,
          WORD_OUT => WORD_OUT,
          RX_DONE => RX_DONE
        );

   -- Clock process definitions
   CLOCK_process :process
   begin
		CLOCK <= '0';
		wait for CLOCK_period/2;
		CLOCK <= '1';
		wait for CLOCK_period/2;
   end process;
 

	-- Stimulus process
	stim_proc: process
	  variable K : natural;
	begin
	  K := 50;
	  
	  wait for CLOCK_period*9;
	  BAUD_RATE <= std_logic_vector(to_unsigned(K, BAUD_RATE'length));
	  wait for CLOCK_period*11;
	  
	  -- START BIT
	  report "START BIT" severity note;
	  BIT_IN <= '0';
	  wait for CLOCK_period*K;

	  -- "11001101"
	  report "BIT 0" severity note;
	  BIT_IN <= '1';
	  wait for CLOCK_period*K;

	  report "BIT 1" severity note;
	  BIT_IN <= '0';
	  wait for CLOCK_period*K;

	  report "BIT 2" severity note;
	  BIT_IN <= '1';
	  wait for CLOCK_period*K;
	  
	  report "BIT 3" severity note;
	  BIT_IN <= '1';
	  wait for CLOCK_period*K;

	  report "BIT 4" severity note;
	  BIT_IN <= '0';
	  wait for CLOCK_period*K;
	  
	  report "BIT 5" severity note;
	  BIT_IN <= '0';
	  wait for CLOCK_period*K;
	  
	  report "BIT 6" severity note;
	  BIT_IN <= '1';
	  wait for CLOCK_period*K;
	  
	  report "BIT 7" severity note;
	  BIT_IN <= '1';
	  wait for CLOCK_period*K;
	  
	  -- parity
	  report "PARITY" severity note;
	  BIT_IN <= '0';
	  wait for CLOCK_period*K;
	  
	  -- stop
	  report "STOP BIT" severity note;
	  BIT_IN <= '1';
	  wait for CLOCK_period*K;
	  
	  wait;
	end process;
END;
