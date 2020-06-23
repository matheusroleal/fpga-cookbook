LIBRARY ieee;
USE ieee.std_logic_1164.ALL;

ENTITY cpu_tb IS
END cpu_tb;
 
ARCHITECTURE Behavior OF cpu_tb IS 
    -- Component Declaration for the Unit Under Test (UUT)
    COMPONENT cpu
        PORT(clk 				: IN std_logic;
             reset 				: IN std_logic;
             zero_flag_led	 	: OUT std_logic := '0';
             negative_flag_led 	: OUT std_logic := '0';
             clk_2s_led			: OUT std_logic;
             mem30_led			: OUT std_logic_vector ( 4 downto 0);
             lcd_e_out			: OUT std_logic;
             lcd_rs_out	 		: OUT std_logic;
             lcd_rw_out			: OUT std_logic;
             sf_d_out			: OUT STD_LOGIC_VECTOR(11 downto 8));
    END COMPONENT;

    --Inputs
    signal clk : std_logic := '0';
    signal reset : std_logic := '0';

    --Outputs
    signal zero_flag_led 	 : std_logic;
    signal negative_flag_led : std_logic;
    signal sf_d_out 		 : sTD_LOGIC_VECTOR(11 downto 8);
    SIGNAL lcd_e_out 		 : std_logic;
    SIGNAL lcd_rw_out		 : std_logic;
    SIGNAL lcd_rs_out 		 : std_logic;
    SIGNAL mem30_led 		 : std_logic_vector (4 downto 0);
    signal clk_2s_led 		 : std_logic;

    -- Clock period definitions
    constant clk_period : time := 20 ns;
 
BEGIN
    -- Instantiate the Unit Under Test (UUT)
    uut: cpu PORT MAP (
            clk => clk,
            reset => reset,
            zero_flag_led => zero_flag_led,
            negative_flag_led => negative_flag_led,
            lcd_e_out => lcd_e_out,
            sf_d_out => sf_d_out,
            lcd_rs_out => lcd_rs_out,
            lcd_rw_out => lcd_rw_out,
            mem30_led => mem30_led,
            clk_2s_led => clk_2s_led
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
        reset <= '1';
        -- hold reset state for 100 ns.
        wait for 100 ns;	
            reset <= '0';
        wait for clk_period*10;

        -- insert stimulus here 

        wait;
    end process;
END;
