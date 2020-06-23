----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    14:06:34 05/14/2020 
-- Design Name: 
-- Module Name:    lcd - Behavioral 
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

entity lcd is
    PORT(
        clk_50MHZ : IN STD_LOGIC; -- System Clock
        lcd_rw : OUT STD_LOGIC; -- Read & Write
        lcd_rs : OUT STD_LOGIC; -- Setup/Data
        lcd_e  : OUT STD_LOGIC; -- Enable for LCD
        sf_d : OUT STD_LOGIC_VECTOR(11 downto 0); --data vector
        led_1, led_2, led_3 : out std_logic
    );
end lcd;

architecture Behavioral of lcd is

    signal clk_500HZ : STD_LOGIC;
    signal count_clk : INTEGER := 0;
    signal direction_clk : STD_LOGIC := '1';

    -- LCD steps
    type state_type is (initialization_st_1, initialization_st_2, initialization_st_3, initialization_st_4, initialization_st_5, initialization_st_6, initialization_st_7, initialization_st_8, initialization_st_9, configuration_st_1, configuration_st_2, configuration_st_3, configuration_st_4, configuration_st_5, configuration_st_6, configuration_st_7, configuration_st_8, configuration_st_9, configuration_st_10, configuration_st_11, configuration_st_12, configuration_st_13, configuration_st_14, configuration_st_15, configuration_st_16, write_st_1, write_st_2, write_st_3, write_st_4, write_st_5, write_st_6, write_st_7,write_st_8,write_st_9, write_st_10, write_st_11, write_st_12, write_st_13, write_st_14, write_st_15, write_st_16, write_st_17, write_st_18, write_st_19, finish);
    signal pst : state_type := initialization_st_1;
    
    -- Initialization signals
    signal count_initialization : INTEGER := 0;
    
begin
    
    -- Processo que transforma o clock de 50MHZ em 500HZ
    process (clk_50MHZ)
    begin
        if (CLK_50MHZ'event and CLK_50MHZ = '1') then
            if (count_clk < 250000 and direction_clk = '1') then
                clk_500HZ <= '0';
                count_clk <= count_clk + 1;
            elsif (count_clk < 500000 and direction_clk = '1') then
                clk_500HZ <= '1';
                count_clk <= count_clk + 1;
            else
                count_clk <= 0;
            end if;
        end if;
    end process;

    -- Processo FMS
    process (clk_500HZ)
    begin
        if (CLK_500HZ'event and CLK_500HZ = '1') then
            case pst is
                -- Casos de inicialização
                when initialization_st_1 => 
                    pst <= initialization_st_2; 
                    lcd_rs <= '0' ; 
                    lcd_rw <= '0';
                    lcd_e <= '1'; 
                when initialization_st_2 => 
                    lcd_e <= '0'; 
                    sf_d(11 downto 8) <= "0011"; 
                    pst <= initialization_st_3;
                when initialization_st_3 => 
                    lcd_e <= '1'; 
                    pst <= initialization_st_4;
                when initialization_st_4 => 
                    lcd_e <= '0';
                    sf_d(11 downto 8) <= "0011"; 
                    pst <= initialization_st_5;
                when initialization_st_5 => 
                    lcd_e <= '1'; 
                    pst <= initialization_st_6;
                when initialization_st_6 => 
                    lcd_e <= '0'; 
                    sf_d(11 downto 8) <= "0011"; 
                    pst <= initialization_st_7;
                when initialization_st_7 => 
                    lcd_e <= '1'; 
                    pst <= initialization_st_8;
                when initialization_st_8 => 
                    lcd_e <= '0'; 
                    sf_d(11 downto 8) <= "0010"; 
                    pst <= initialization_st_9;
                when initialization_st_9 => lcd_e <= '1'; pst <= configuration_st_1; led_1 <= '1';
                -- Casos de configuração
                when configuration_st_1 => 
                    lcd_e <= '0'; 
                    sf_d(11 downto 8) <= "0010"; 
                    pst <= configuration_st_2;
                when configuration_st_2 => 
                    lcd_e <= '1'; 
                    pst <= configuration_st_3;
                when configuration_st_3 => 
                    lcd_e <= '0'; 
                    sf_d(11 downto 8) <= "1000"; 
                    pst <= configuration_st_4;
                when configuration_st_4 => 
                    lcd_e <= '1'; 
                    pst <= configuration_st_5;
                when configuration_st_5 => 
                    lcd_e <= '0'; 
                    sf_d(11 downto 8) <= "0000"; 
                    pst <= configuration_st_6;
                when configuration_st_6 => 
                    lcd_e <= '1'; 
                    pst <= configuration_st_7;
                when configuration_st_7 => 
                    lcd_e <= '0'; 
                    sf_d(11 downto 8) <= "0110"; 
                    pst <= configuration_st_8;
                when configuration_st_8 => 
                    lcd_e <= '1'; 
                    pst <= configuration_st_9;
                when configuration_st_9 => 
                    lcd_e <= '0'; 
                    sf_d(11 downto 8) <= "0000"; 
                    pst <= configuration_st_10;
                when configuration_st_10 => 
                    lcd_e <= '1'; 
                    pst <= configuration_st_11;
                when configuration_st_11 => 
                    lcd_e <= '0'; 
                    sf_d(11 downto 8) <= "1100"; 
                    pst <= configuration_st_12;
                when configuration_st_12 => 
                    lcd_e <= '1'; 
                    pst <= configuration_st_13;
                when configuration_st_13 => 
                    lcd_e <= '0'; 
                    sf_d(11 downto 8) <= "0000"; 
                    pst <= configuration_st_14;
                when configuration_st_14 => 
                    lcd_e <= '1'; 
                    pst <= configuration_st_15;
                when configuration_st_15 => 
                    lcd_e <= '0'; 
                    sf_d(11 downto 8) <= "0001"; 
                    pst <= configuration_st_16;
                when configuration_st_16 => 
                    lcd_e <= '1'; 
                    pst <= write_st_1; 
                    led_2 <= '1';
                -- Casos de escrita
                when write_st_1 => 
                    lcd_e <= '0'; 
                    lcd_rs <= '1'; 
                    lcd_rw <= '0'; 
                    pst <= write_st_2;
                when write_st_2 =>
                    lcd_e <= '0';
                    pst <= write_st_3;
                when write_st_3 =>
                    lcd_e <= '0';
                    sf_d (11 downto 8) <= "0100";
                    pst <= write_st_4;
                when write_st_4 =>
                    lcd_e <= '1';
                    pst <= write_st_5;
                when write_st_5 =>
                    lcd_e <= '0';
                    sf_d (11 downto 8) <= "1111";
                    pst <= write_st_6;
                when write_st_6 =>
                    lcd_e <= '1';
                    pst <= write_st_7;
                when write_st_7 =>
                    lcd_e <= '0';
                    sf_d (11 downto 8) <= "0100";
                    pst <= write_st_8;
                when write_st_8 =>
                    lcd_e <= '1';
                    pst <= write_st_9;
                when write_st_9 =>
                    lcd_e <= '0';
                    sf_d (11 downto 8) <= "1100";
                    pst <= write_st_10;
                when write_st_10 =>
                    lcd_e <= '1';
                    pst <= write_st_11;
                when write_st_11 =>
                    lcd_e <= '0';
                    sf_d (11 downto 8) <= "0100";
                    pst <= write_st_12;
                when write_st_12 =>
                    lcd_e <= '1';
                    pst <= write_st_13;
                when write_st_13 =>
                    lcd_e <= '0';
                    sf_d (11 downto 8) <= "0001";
                    pst <= write_st_14;
                when write_st_14 =>
                    lcd_e <= '1';
                    pst <= write_st_15;
                when write_st_15 =>
                    lcd_e <= '0';
                    sf_d (11 downto 8) <= "0010";
                    pst <= write_st_16;
                when write_st_16 =>
                    lcd_e <= '1';
                    pst <= write_st_17;
                when write_st_17 =>
                    lcd_e <= '0';
                    sf_d (11 downto 8) <= "0001";
                    pst <= write_st_18;
                when write_st_18 =>
                    lcd_e <= '1';
                    led_1 <= '1'; 
                    led_2 <= '0'; 
                    led_3 <= '1'; 
                    pst <= write_st_19;
                when write_st_19 =>
                    lcd_e <= '0';
                    led_1 <= '1'; 
                    led_2 <= '0';
                    led_3 <= '1'; 
                    pst <= finish;
                when finish => 
                    led_1 <= '1';
                    led_2 <= '0';
                    led_3 <= '1';
                when others =>
                    pst <= initialization_st_1;
            end case;
        end if;
    end process;
end Behavioral;