library IEEE;
use IEEE.STD_LOGIC_1164.ALL; 
use IEEE.NUMERIC_STD.ALL;

entity Dac is
	PORT(	CLK_50MHZ : IN STD_LOGIC; 
			SPI_MOSI : OUT STD_LOGIC; 
			SPI_SCK : OUT STD_LOGIC; 
			DAC_CS : OUT STD_LOGIC; 
			DAC_CLR : OUT STD_LOGIC);
end Dac;

architecture Behavioral of Dac is
	type state_type is (start1, start2, start3, start4, data1, data2, data3, data4, data5, data6, data7, data8, data9, data10, data11, data12, comm1, comm2, comm3, comm4, comm5, comm6, comm7, comm8, stop1, stop2, stop3, stop4, stop5, stop6, stop7, stop8, idle);

	signal pst : state_type := idle;
	signal count_clk : INTEGER := 0;
	signal direction_clk : STD_LOGIC := '1';
	signal dados : unsigned(11 downto 0) := "000000000000";
	signal debug_spi : STD_LOGIC := '0';
begin
	DAC_CLR<= '1'; 
	
	process (CLK_50MHZ)
	begin
		if (CLK_50MHZ'event and CLK_50MHZ = '1') then
			if (count_clk < 3 and direction_clk = '1') then 
				debug_spi <='0';
				count_clk <= count_clk + 1;
			elsif (count_clk < 6 and direction_clk = '1') then 
				debug_spi <= '1';
				count_clk <= count_clk + 1;
			else
				count_clk <= 0;
			end if;
			SPI_SCK <= debug_spi; 
		end if;
	end process;

	process (debug_spi) begin
		if(debug_spi'event and debug_spi = '1') then 
			case pst is
			when idle => 
				pst <= start1; 
				DAC_CS <= '1';
			when start1 => 
				SPI_MOSI <= '0'; 
				DAC_CS <= '0'; pst <=start2;
			when start2 => 
				SPI_MOSI <= '0'; 
				pst <=start3;
			when start3 => 
				SPI_MOSI <= '0'; 
				pst <=start4; --DC
			when start4 => 
				SPI_MOSI <= '0'; 
				pst <=comm1; --DC
			when comm1 => 
				SPI_MOSI<= '0'; 
				pst <=comm2; --DC
			when comm2 => 
				SPI_MOSI<= '0'; 
				pst <=comm3; --DC
			when comm3 => 
				SPI_MOSI<= '0'; 
				pst <=comm4; --DC
			when comm4 => 
				SPI_MOSI<= '0'; 
				pst <=comm5; --DC
			when comm5 => 
				SPI_MOSI<= '0'; 
				pst <=comm6; --COMANDO 
			when comm6 => 
				SPI_MOSI<= '0'; 
				pst <=comm7; --COMANDO 
			when comm7 => 
				SPI_MOSI <= '1'; 
				pst <=comm8; --COMANDO 
			when comm8 => 
				SPI_MOSI <= '1'; 
				pst <=data1; --COMANDO
			when data1 => 
				SPI_MOSI <= '1';
				pst <= data2; --ENDEREÇO 
			when data2 => 
				SPI_MOSI <= '1';
				pst <= data3; --ENDEREÇO 
			when data3 => 
				SPI_MOSI <= '1';
				pst <= data4; --ENDEREÇO 
			when data4 => 
				SPI_MOSI <= '1';
				pst <= data5; --ENDEREÇO 
			when data5 => 
				SPI_MOSI <= dados(11);
				pst <= data6; --DADO 
			when data6 => 
				SPI_MOSI <= dados(10);
				pst <= data7; --DADO 
			when data7 => 
				SPI_MOSI <= dados(9);
				pst <= data8; --DADO 
			when data8 => 
				SPI_MOSI <= dados(8);
				pst <= data9; --DADO 
			when data9 => 
				SPI_MOSI <= dados(7);
				pst <= data10; --DADO 
			when data10 => 
				SPI_MOSI <= dados(6);
				pst <= data11; --DADO 
			when data11 => 
				SPI_MOSI <= dados(5);
				pst <= data12; --DADO 
			when data12 => 
				SPI_MOSI <= dados(4);
				pst <= stop1; --DADO
			when stop1 => 
				SPI_MOSI <= dados(3); 
				pst <=stop2; --DADO
			when stop2 => 
				SPI_MOSI <= dados(2); 
				pst <=stop3; --DADO
			when stop3 => 
				SPI_MOSI <= dados(1); 
				pst <=stop4; --DADO
			when stop4 => 
				SPI_MOSI <= dados(0); 
				pst <=stop5; --DADO
			when stop5 => 
				SPI_MOSI <= '0'; 
				pst <=stop6; --DC
			when stop6 => 
				SPI_MOSI <= '0'; 
				pst <=stop7; --DC
			when stop7 => 
				SPI_MOSI <= '0'; 
				pst <=stop8; --DC
			when stop8 => 
				SPI_MOSI<= '0'; --DC
				dados <= dados +1; -- INCREMENTA CONTADOR 
				pst <= idle; --DC
			end case;
		end if;
	end process;
end Behavioral;