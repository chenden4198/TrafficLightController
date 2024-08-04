
-- Jeffrey Jiang and Dennis Chen


library ieee;
use ieee.std_logic_1164.all;


entity holding_register is port (

			clk					: in std_logic;
			reset					: in std_logic;
			register_clr		: in std_logic;
			din					: in std_logic;
			dout					: out std_logic
  );
 end holding_register;
 
 architecture circuit of holding_register is

	Signal sreg				: std_logic;


BEGIN

	process(clk) is
	begin
		if (rising_edge(clk)) then 								-- Run only at rising clock edge
			if (reset = '1' OR register_clr = '1') then 		-- Reset to 0 if requested
				sreg <= '0';
			else
				sreg <= (sreg OR din); 								-- Latch sreg, if din is ever 1 then sreg will stay as 1 until cleared
			end if;
		end if;
		
		dout <= sreg;
		
	end process;

end;