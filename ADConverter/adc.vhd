library IEEE;
use IEEE.STD_LOGIC_1164.ALL; 
use IEEE.NUMERIC_STD.ALL;
-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values 
--use IEEE.NUMERIC_STD.ALL;
-- Uncomment the following library declaration if instantiating -- any Xilinx primitives in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity adc is
    Port (  CLK_50MHZ : IN STD_LOGIC;
            SPI_MOSI : OUT STD_LOGIC;
            SPI_MISO : IN STD_LOGIC;
            SPI_SCK : OUT STD_LOGIC;
            AMP_CS : OUT STD_LOGIC;
            AD_CONV : OUT STD_LOGIC;
            LED: OUT STD_LOGIC_VECTOR (7 DOWNTO 0)
        );
end adc;

architecture Behavioral of adc is

    -- Divisão do Clock
    SIGNAL count_clk : INTEGER := 0;
    SIGNAL direction_clk : STD_LOGIC := '1';
    SIGNAL debug_spi : STD_LOGIC := '0';

    -- Estados do adc
    TYPE state_type IS (idle, pre_amp, recebendo);
    SIGNAL pst : state_type := idle;

    -- Contadores dos estados
    SIGNAL cont_pre_amp : INTEGER := 0;
    SIGNAL cont_recebendo : INTEGER := 0;

    -- Vetor que recebe os dados
    SIGNAL data_amp : unsigned(13 DOWNTO 0) := "00000000000000";
begin
    -- Processo que gera o clock mais lento 
    process (CLK_50MHZ)
    begin
        if (CLK_50MHZ'event and CLK_50MHZ = '1') then
            if (count_clk < 16 and direction_clk = '1') then 
                debug_spi <='0';
                count_clk <= count_clk + 1; 
            elsif (count_clk < 32 and direction_clk = '1') then
                debug_spi <= '1';
                count_clk <= count_clk + 1;
            else
                count_clk <= 0;
            end if;
            SPI_SCK <= debug_spi; end if;
    end process;

    -- Processo responsável pelos estados 
    process (debug_spi)
    begin
        if(debug_spi'event and debug_spi = '1') then
            case pst is
                when idle =>
                    AMP_CS <= '1'; 
                    AD_CONV <= '1'; 
                    pst <= pre_amp;
                when pre_amp => 
                    AMP_CS <= '0';
                    cont_recebendo <= 0; 

                    case cont_pre_amp is
                        when 0 => 
                            SPI_MOSI <= '0'; 
                        when 1 => 
                            SPI_MOSI <= '0'; 
                        when 2 => 
                            SPI_MOSI <= '0'; 
                        when 3 => 
                            SPI_MOSI <= '1'; 
                        when 4 => 
                            SPI_MOSI <= '0'; 
                        when 5 => 
                            SPI_MOSI <= '0'; 
                        when 6 => 
                            SPI_MOSI <= '0'; 
                        when 7 => 
                            SPI_MOSI <= '1';
                            pst <= recebendo; 
                            AMP_CS <= '1';
                        when others => 
                            cont_pre_amp <= 0; 
                    end case;
                    cont_pre_amp <= cont_pre_amp + 1; 
                when recebendo =>
                    cont_pre_amp <= 0; 

                    case cont_recebendo is
                        when 0 => 
                            AD_CONV <= '1';
                            cont_recebendo <= cont_recebendo + 1;
                        when 1 => 
                            AD_CONV <= '0';
                            cont_recebendo <= cont_recebendo + 1;
                        when 2 => 
                            data_amp(13) <= SPI_MISO;
                            cont_recebendo <= cont_recebendo + 1;
                        when 3 => 
                            data_amp(12) <= SPI_MISO;
                            cont_recebendo <= cont_recebendo + 1;
                        when 4 => 
                            data_amp(11) <= SPI_MISO;
                            cont_recebendo <= cont_recebendo + 1;
                        when 5 => 
                            data_amp(10) <= SPI_MISO;
                            cont_recebendo <= cont_recebendo + 1;
                        when 6 => 
                            data_amp(9) <= SPI_MISO;
                            cont_recebendo <= cont_recebendo + 1;
                        when 7 => 
                            data_amp(8) <= SPI_MISO;
                            cont_recebendo <= cont_recebendo + 1;
                        when 8 => 
                            data_amp(7) <= SPI_MISO;
                            cont_recebendo <= cont_recebendo + 1;
                        when 9 => 
                            data_amp(6) <= SPI_MISO;
                            cont_recebendo <= cont_recebendo + 1;
                        when 10 => 
                            data_amp(5) <= SPI_MISO;
                            cont_recebendo <= cont_recebendo + 1;
                        when 11 => 
                            data_amp(4) <= SPI_MISO;
                            cont_recebendo <= cont_recebendo + 1;
                        when 12 => 
                            data_amp(3) <= SPI_MISO;
                            cont_recebendo <= cont_recebendo + 1;
                        when 13 => 
                            data_amp(2) <= SPI_MISO;
                            cont_recebendo <= cont_recebendo + 1;
                        when 14 => 
                            data_amp(1) <= SPI_MISO;
                            cont_recebendo <= cont_recebendo + 1;
                        when 15 => 
                            data_amp(0) <= SPI_MISO;
                            cont_recebendo <= cont_recebendo + 1;
                        when 33 =>
								    cont_recebendo <= 0;
                        when others => 
                            AD_CONV <= '0';
                            cont_recebendo <= cont_recebendo + 1;
                    end case;
            end case;
        end if;
    end process;

    process(data_amp)
    begin
        if (data_amp < 2048) then 
            led(0) <= '1'; 
            led(1) <= '0'; 
            led(2) <= '0'; 
            led(3) <= '0'; 
            led(4) <= '0'; 
            led(5) <= '0'; 
            led(6) <= '0'; 
            led(7) <= '0';
        elsif(data_amp < 4096) then 
            led(0) <= '1'; 
            led(1) <= '1'; 
            led(2) <= '0'; 
            led(3) <= '0'; 
            led(4) <= '0'; 
            led(5) <= '0'; 
            led(6) <= '0'; 
            led(7) <= '0';
        elsif(data_amp < 6144) then 
            led(0) <= '1'; 
            led(1) <= '1'; 
            led(2) <= '1'; 
            led(3) <= '0'; 
            led(4) <= '0'; 
            led(5) <= '0'; 
            led(6) <= '0'; 
            led(7) <= '0';
        elsif(data_amp < 8192) then 
            led(0) <= '1'; 
            led(1) <= '1'; 
            led(2) <= '1'; 
            led(3) <= '1'; 
            led(4) <= '0'; 
            led(5) <= '0'; 
            led(6) <= '0'; 
            led(7) <= '0';
        elsif(data_amp < 10240) then 
            led(0) <= '1';
            led(1) <= '1'; 
            led(2) <= '1'; 
            led(3) <= '1'; 
            led(4) <= '1'; 
            led(5) <= '0'; 
            led(6) <= '0'; 
            led(7) <= '0';
        elsif(data_amp < 12288) then 
            led(0) <= '1';
            led(1) <= '1'; 
            led(2) <= '1'; 
            led(3) <= '1'; 
            led(4) <= '1'; 
            led(5) <= '1'; 
            led(6) <= '0'; 
            led(7) <= '0';
        elsif(data_amp < 14336) then 
            led(0) <= '1';
            led(1) <= '1'; 
            led(2) <= '1'; 
            led(3) <= '1'; 
            led(4) <= '1'; 
            led(5) <= '1'; 
            led(6) <= '1'; 
            led(7) <= '0';
        else
            led(0) <= '1'; 
            led(1) <= '1'; 
            led(2) <= '1'; 
            led(3) <= '1'; 
            led(4) <= '1'; 
            led(5) <= '1'; 
            led(6) <= '1'; 
            led(7) <= '1';
        end if;
	  end process;
end Behavioral;
