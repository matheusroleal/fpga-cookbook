library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values --use IEEE.NUMERIC_STD.ALL;
-- Uncomment the following library declaration if instantiating -- any Xilinx primitives in this code.
--library UNISIM;
--use UNISIM.VComponents.all;
entity controller is
    Port (  clk : in STD_LOGIC;
            SPI_MOSI : OUT STD_LOGIC;
            SPI_MISO : IN STD_LOGIC;
            SPI_SCK : OUT STD_LOGIC;
            DAC_CS : OUT STD_LOGIC;
            DAC_CLR : OUT STD_LOGIC;
            SPI_SS_B : OUT STD_LOGIC;
            AMP_CS : OUT STD_LOGIC;
            AD_CONV : OUT STD_LOGIC;
            SF_CE0 : OUT STD_LOGIC;
            FPGA_INIT_B : OUT STD_LOGIC;
            AMP_SHDN : OUT STD_LOGIC;
            LED: OUT STD_LOGIC_VECTOR (7 DOWNTO 0)
        );
end controller;

architecture Behavioral of controller is 
    component adc
        Port (  CLK_50MHZ : IN STD_LOGIC;
                SPI_MOSI : OUT STD_LOGIC;
                SPI_MISO : IN STD_LOGIC;
                SPI_SCK : OUT STD_LOGIC;
                AMP_CS : OUT STD_LOGIC;
                AD_CONV : OUT STD_LOGIC;
                LED: OUT STD_LOGIC_VECTOR (7 DOWNTO 0)
            );
    end component;

    begin
        SPI_SS_B <= '1'; 
        SF_CE0 <= '1'; 
        FPGA_INIT_B <= '1'; 
        DAC_CLR <= '1'; 
        DAC_CS <= '1';
        AMP_SHDN <= '0';

        DB: ADC port map (CLK_50MHZ=>clk, SPI_MOSI => SPI_MOSI, SPI_MISO => SPI_MISO, SPI_SCK => SPI_SCK, AMP_CS => AMP_CS, AD_CONV => AD_CONV, LED => LED);
end Behavioral;