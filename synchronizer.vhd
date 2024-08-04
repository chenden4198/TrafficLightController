
-- Jeffrey Jiang and Dennis Chen


library ieee;
use ieee.std_logic_1164.all;


entity synchronizer is port (

			clk			: in std_logic;
			reset			: in std_logic;
			din			: in std_logic;
			dout			: out std_logic
  );
 end synchronizer;
 
 
architecture circuit of synchronizer is

	Signal sreg				: std_logic_vector(1 downto 0);

BEGIN
		
	process(clk) is
	begin
		if (rising_edge(clk)) then -- Only activate on rising edge of clock
			if (reset = '1') then   -- Reset input if 'reset' is enabled
				sreg <= "00";
			else 
				sreg <= din & sreg(1); -- Left shift input
			end if;
		end if;
		
		dout <= sreg(0); -- It will take two rising clock edges for the input to be given as output in sync with rising clock edge
		
	end process;


end;