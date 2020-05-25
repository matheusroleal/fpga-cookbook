LIBRARY ieee;
USE ieee.std_logic_1164.ALL;

ENTITY dac_controller_tb IS 
END dac_controller_tb;

ARCHITECTURE behavior OF dac_controller_tb IS
    
-- Component Declaration for the Unit Under Test (UUT)
    COMPONENT Dac 
        PORT(   CLK_50MHZ : IN std_logic; 
                SPI_MOSI:OUT std_logic; 
                SPI_SCK : OUT std_logic; 
                DAC_CS:OUT std_logic; 
                DAC_CLR : OUT std_logic
        );
    END COMPONENT;
    
    --Inputs
    signal CLK_50MHZ : std_logic := '0';

    --Outputs
    signal SPI_MOSI : std_logic;
    signal SPI_SCK : std_logic; signal DAC_CS : std_logic; signal DAC_CLR : std_logic;

    -- Clock period definitions
    constant CLK_50MHZ_period : time := 10 ns;
BEGIN
    -- Instantiate the Unit Under Test (UUT) 
    uut: Dac PORT MAP ( CLK_50MHZ => CLK_50MHZ, 
                        SPI_MOSI => SPI_MOSI, 
                        SPI_SCK => SPI_SCK, 
                        DAC_CS => DAC_CS, 
                        DAC_CLR => DAC_CLR
                    );

    -- Clock process definitions 
    CLK_50MHZ_process: process 
    begin
        CLK_50MHZ <= '0';
        wait for CLK_50MHZ_period/2; 
        CLK_50MHZ <= '1';
        wait for CLK_50MHZ_period/2;
    end process;

    -- Stimulus process 
    stim_proc: process 
    begin
        -- hold reset state for 100 ns. 
        wait for 100 ns;
        wait for CLK_50MHZ_period*10;
        
        -- insert stimulus here

    wait;
    end process;
END;