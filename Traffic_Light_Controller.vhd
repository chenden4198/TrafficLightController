
-- Jeffrey Jiang and Dennis Chen

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

Entity Traffic_Light_Controller IS Port
	(
		clk_input, clk_en, reset, blink_sig				: IN std_logic;  -- Basic inputs given
		hold_reg_ew, hold_reg_ns							: in std_logic;  -- Input from hold registers
		lights_output											: OUT std_logic_vector(5 downto 0); -- (NS: green 5/amber 4/red 3 EW:green 2/amber 1/red 0)
		state														: OUT std_logic_vector(3 downto 0); -- Outputs current state
		reg_clear_ew, reg_clear_ns							: out std_logic; -- Output to clear the hold register
		NS_CROSSING_DISPLAY, EW_CROSSING_DISPLAY		: out std_logic  -- Output to activate crossing LEDs
	);
END ENTITY; 

 Architecture SM of Traffic_Light_Controller is
 
 TYPE STATE_NAMES IS (S0, S1, S2, S3, S4, S5, S6, S7, S8, S9, S10, S11, S12, S13, S14, S15, S16);   -- All possible states for the controller

 
 SIGNAL current_state, next_state	:  STATE_NAMES;     	-- signals of states


 BEGIN
 
 -- Mealy State machine

 -- REGISTER LOGIC SECTION
 
Register_Section: PROCESS (clk_input)  -- The machine changes state only at the rising edge of the clock and when Clk_en is on
BEGIN
	IF(rising_edge(clk_input)) THEN
		if (clk_en = '1') then   -- If clk_en is not on, do not change state
		
			IF (reset = '1') THEN -- If reset, return to state 0
				current_state <= S0;
			ELSIF (reset = '0') THEN
				current_state <= next_state;
			END IF;
			
		end if;
	END IF;
END PROCESS;	



-- TRANSITION LOGIC SECTION

TRANSITION : process(current_state) 

BEGIN 

CASE current_state IS

        WHEN S0 =>  					-- If EW crossing is requested and NS crossing is not, skip steady green
				if (hold_reg_ew = '1' AND hold_reg_ns = '0') then
					next_state <= S6;
				else
					next_state <= S1;
				end if;
				
        WHEN S1 => 
				if (hold_reg_ew = '1' AND hold_reg_ns = '0') then
					next_state <= S6;
				else
					next_state <= S2;
				end if;
				
        WHEN S2 => 
				next_state <= S3;
		 
		  WHEN S3 => 
				next_state <= S4;
				
        WHEN S4 => 
				next_state <= S5;
				
		  WHEN S5 => 
				next_state <= S6;
				
        WHEN S6 => 
				next_state <= S7;
				
        WHEN S7 => 
				next_state <= S8;
				
        WHEN S8 => 				-- If NS crossing is requested and EW crossing is not, skip steady green
		  		if (hold_reg_ew = '0' AND hold_reg_ns = '1') then
					next_state <= S14;
				else
					next_state <= S9;
				end if;
				
		  WHEN S9 => 
		  		if (hold_reg_ew = '0' AND hold_reg_ns = '1') then
					next_state <= S14;
				else
					next_state <= S10;
				end if;
				
        WHEN S10 => 
				next_state <= S11;
				
        WHEN S11 => 
				next_state <= S12;
				
        WHEN S12 =>
				next_state <= S13;
				
        WHEN S13 => 
				next_state <= S14;
				
        WHEN S14 => 
				next_state <= S15;
				
        WHEN S15 => 	
				next_state <= S0;
				
		  WHEN OTHERS =>
				next_state <= S0;
				
	END CASE; 
END PROCESS;

-- DECODER SECTION

Decoder_Section: PROCESS (current_state) 

BEGIN
     CASE current_state IS
         WHEN S0 =>		
				lights_output <= blink_sig & "00001"; -- Current light situation for both intersections encoded as above: (NS: green 5/amber 4/red 3 EW:green 2/amber 1/red 0)
				state <= "0000"; 				  -- Output for current state
				NS_CROSSING_DISPLAY <= '0';
				EW_CROSSING_DISPLAY <= '0';
				reg_clear_ns <= '0';
				reg_clear_ew <= '0';
				
			WHEN S1 =>		
				lights_output <= blink_sig & "00001";	-- Green light is blinking
				state <= "0001";
				NS_CROSSING_DISPLAY <= '0';
				EW_CROSSING_DISPLAY <= '0';
				reg_clear_ns <= '0';
				reg_clear_ew <= '0';			
				
         WHEN S2 =>		
				lights_output <= "100001"; -- Steady green on NS
				state <= "0010";
				NS_CROSSING_DISPLAY <= '1'; -- Enabled when NS steady green
				EW_CROSSING_DISPLAY <= '0';
				reg_clear_ns <= '0';
				reg_clear_ew <= '0';
				
			WHEN S3 =>		
				lights_output <= "100001";
				state <= "0011";
				NS_CROSSING_DISPLAY <= '1';
				EW_CROSSING_DISPLAY <= '0';
				reg_clear_ns <= '0';
				reg_clear_ew <= '0';
				
			WHEN S4 =>		
				lights_output <= "100001";
				state <= "0100";
				NS_CROSSING_DISPLAY <= '1';
				EW_CROSSING_DISPLAY <= '0';
				reg_clear_ns <= '0';
				reg_clear_ew <= '0';
			
			WHEN S5 =>		
				lights_output <= "100001";
				state <= "0101";
				NS_CROSSING_DISPLAY <= '1';
				EW_CROSSING_DISPLAY <= '0';
				reg_clear_ns <= '0';
				reg_clear_ew <= '0';
			
         WHEN S6 =>		
				lights_output <= "010001"; -- Amber on NS
				state <= "0110";
				NS_CROSSING_DISPLAY <= '0';
				EW_CROSSING_DISPLAY <= '0';
				reg_clear_ns <= '1'; 		-- Clear NS crossing hold register
				reg_clear_ew <= '0';
			
			WHEN S7 =>		
				lights_output <= "010001";
				state <= "0111";
				NS_CROSSING_DISPLAY <= '0';
				EW_CROSSING_DISPLAY <= '0';
				reg_clear_ns <= '0';
				reg_clear_ew <= '0';
				
         WHEN S8 =>		
				lights_output <= "001" & blink_sig & "00"; -- Blinking green on SW
				state <= "1000";
				NS_CROSSING_DISPLAY <= '0';
				EW_CROSSING_DISPLAY <= '0';
				reg_clear_ns <= '0';
				reg_clear_ew <= '0';
				
			WHEN S9 =>		
				lights_output <= "001" & blink_sig & "00";
				state <= "1001";
				NS_CROSSING_DISPLAY <= '0';
				EW_CROSSING_DISPLAY <= '0';
				reg_clear_ns <= '0';
				reg_clear_ew <= '0';
				
			WHEN S10 =>		
				lights_output <= "001100";
				state <= "1010";
				NS_CROSSING_DISPLAY <= '0';
				EW_CROSSING_DISPLAY <= '1';  -- Enabled when EW steady green
				reg_clear_ns <= '0';
				reg_clear_ew <= '0';	
				
			WHEN S11 =>		
				lights_output <= "001100";
				state <= "1011";
				NS_CROSSING_DISPLAY <= '0';
				EW_CROSSING_DISPLAY <= '1';
				reg_clear_ns <= '0';
				reg_clear_ew <= '0';
				
			WHEN S12 =>		
				lights_output <= "001100";
				state <= "1100";
				NS_CROSSING_DISPLAY <= '0';
				EW_CROSSING_DISPLAY <= '1';
				reg_clear_ns <= '0';
				reg_clear_ew <= '0';		
		
			WHEN S13 =>		
				lights_output <= "001100";
				state <= "1101";
				NS_CROSSING_DISPLAY <= '0';
				EW_CROSSING_DISPLAY <= '1';	
				reg_clear_ns <= '0';
				reg_clear_ew <= '0';		
			
			WHEN S14 =>		
				lights_output <= "001010"; -- Amber on SW
				state <= "1110";
				NS_CROSSING_DISPLAY <= '0';
				EW_CROSSING_DISPLAY <= '0';
				reg_clear_ns <= '0';
				reg_clear_ew <= '1';			-- Clear EW crossing hold register
				
			WHEN S15 =>		
				lights_output <= "001010";
				state <= "1111";
				NS_CROSSING_DISPLAY <= '0';
				EW_CROSSING_DISPLAY <= '0';
				reg_clear_ns <= '0';
				reg_clear_ew <= '0';
				
			WHEN others => 						-- Reset to default if unidentified state
				lights_output <= "000000";
				state <= "0000";
				NS_CROSSING_DISPLAY <= '0';
				EW_CROSSING_DISPLAY <= '0';
				reg_clear_ns <= '0';
				reg_clear_ew <= '0';
				
	  END CASE;
 END PROCESS;

 END ARCHITECTURE SM;
