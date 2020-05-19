----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    21:14:21 05/10/2020 
-- Design Name: 
-- Module Name:    rs232_rx - Behavioral 
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

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx primitives in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity rs232_rx is
	port(
		CLOCK		: in STD_LOGIC;
		BIT_IN		: in STD_LOGIC;
		BAUD_RATE	: in STD_LOGIC_VECTOR(12 downto 0);
		WORD_OUT	: out STD_LOGIC_VECTOR(7 downto 0);
		RX_DONE		: out STD_LOGIC
	);
end rs232_rx;

architecture Behavioral of rs232_rx is

	signal COUNTER           : UNSIGNED(12 downto 0):=(others=>'0');
	signal SHIFT_FLAG        : STD_LOGIC:='0';
	signal RECEIVING         : STD_LOGIC:='0';

	signal BAUD_RATE_R1      : STD_LOGIC_VECTOR(12 downto 0):= (others=>'1');

	signal BIT_COUNTER       : UNSIGNED(3 downto 0):= (others=>'0');
	constant BIT_LIMIT       : UNSIGNED(3 downto 0):= to_unsigned(9,BIT_COUNTER'length);

	signal MESSAGE           : STD_LOGIC_VECTOR(9 downto 0):= (others=>'1');

	signal WORD_OUT_REG      : STD_LOGIC_VECTOR(7 downto 0):= (others=>'0');
	signal RX_DONE_REG       : STD_LOGIC := '0';

	signal FINISH_FLAG       : STD_LOGIC := '0';
	type fsm_t is(idle, startbit, rxing, done);
	signal STATE             : fsm_t := idle;

begin

	process(CLOCK)
	begin
		if(CLOCK'event and CLOCK ='1') then
			 if(RECEIVING ='1')then
				  if(SHIFT_FLAG ='1')then 
					COUNTER <=(others=>'0');
				  else
					COUNTER <= COUNTER +1;
				  end if;
			 else
				COUNTER <= (others=>'0');
			 end if;
		end if;
	end process;

	SHIFT_FLAG   <='1' when COUNTER = (unsigned(BAUD_RATE_R1)-1) else '0';
	BAUD_RATE_R1 <='0' & BAUD_RATE (12 downto 1) when BIT_COUNTER ="0000" else BAUD_RATE;

	process(CLOCK) 
	begin
		 if(CLOCK'event and CLOCK ='1')then
			  RX_DONE_REG <= '0';
			  case STATE is
			  when idle =>
					if(BIT_IN ='0')then
						RECEIVING    <= '1';
						STATE        <= startbit;
					end if;
			  when startbit =>
					if(SHIFT_FLAG ='1')then
						BIT_COUNTER <= BIT_COUNTER +1;
						MESSAGE     <= BIT_IN &MESSAGE(9 downto 1);
						STATE       <= rxing;
					end if;
			  when rxing =>
					if(SHIFT_FLAG ='1')then
						 BIT_COUNTER <= BIT_COUNTER + 1;
						 MESSAGE     <= BIT_IN & MESSAGE(9 downto 1);
						 if(FINISH_FLAG ='1')then
							BIT_COUNTER  <= (others=>'0');
							STATE        <= done;
						 end if;
					end if;
			  when done => 
					WORD_OUT_REG <= MESSAGE(8 downto 1);
					RX_DONE_REG  <= '1';
					RECEIVING    <= '0';
					STATE        <= idle;
			  when others =>
					state <= idle;
			  end case;
			  end if;
		 end process;

		 FINISH_FLAG <='1'
		 
		 when BIT_COUNTER = BIT_LIMIT else '0';
		 WORD_OUT <= WORD_OUT_REG;
		 RX_DONE  <= RX_DONE_REG;
end Behavioral;
