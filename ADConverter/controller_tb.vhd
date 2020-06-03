LIBRARY ieee;
USE ieee.std_logic_1164.ALL;

-- Uncomment the following library declaration if using 
-- arithmetic functions with Signed or Unsigned values 
--USE ieee.numeric_std.ALL;
ENTITY controller_tb IS END controller_tb;
ARCHITECTURE behavior OF controller_tb IS

-- Component Declaration for the Unit Under Test (UUT)
COMPONENT controller 
    PORT(
        clk : IN std_logic;
        SPI_MOSI:OUT std_logic;
        SPI_MISO : IN std_logic;
        SPI_SCK : OUT std_logic; DAC_CS:OUT std_logic;
        DAC_CLR : OUT std_logic;
        SPI_SS_B : OUT std_logic;
        AMP_CS : OUT std_logic;
        AD_CONV : OUT std_logic; SF_CE0:OUT std_logic;
        FPGA_INIT_B : OUT std_logic;
        LED : OUT std_logic_vector(7 downto 0)
    );
END COMPONENT;

--Inputs
signal clk : std_logic := '0';
signal SPI_MISO : std_logic := '0';

--Outputs
signal SPI_MOSI : std_logic;
signal SPI_SCK : std_logic; 
signal DAC_CS : std_logic; 
signal DAC_CLR : std_logic; 
signal SPI_SS_B : std_logic; 
signal AMP_CS : std_logic; 
signal AD_CONV : std_logic; 
signal SF_CE0 : std_logic;
signal FPGA_INIT_B : std_logic;
signal LED : std_logic_vector(7 downto 0);

-- Clock period definitions
constant clk_period : time := 10 ns;

BEGIN
-- Instantiate the Unit Under Test (UUT) 

uut: controller PORT MAP (
                    clk => clk,
                    SPI_MOSI => SPI_MOSI, 
                    SPI_MISO => SPI_MISO, 
                    SPI_SCK => SPI_SCK, 
                    DAC_CS => DAC_CS, 
                    DAC_CLR => DAC_CLR, 
                    SPI_SS_B => SPI_SS_B, 
                    AMP_CS => AMP_CS, 
                    AD_CONV => AD_CONV, 
                    SF_CE0 => SF_CE0, 
                    FPGA_INIT_B => FPGA_INIT_B, 
                    LED => LED
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
    stim_proc: process begin
        -- hold reset state for 100 ns. 
        wait for 100 ns;
        
        wait for clk_period*10;
        
        SPI_MISO <= '1';
        
        wait;
    end process;
END;
