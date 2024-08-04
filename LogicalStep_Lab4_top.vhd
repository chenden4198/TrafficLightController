
-- Jeffrey Jiang and Dennis Chen

LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.numeric_std.ALL;

ENTITY LogicalStep_Lab4_top IS
   PORT
	(
   clkin_50	   : in	std_logic;							-- The 50 MHz FPGA Clockinput
	rst_n			: in	std_logic;							-- The RESET input (ACTIVE LOW)
	pb_n			: in	std_logic_vector(3 downto 0); -- The push-button inputs (ACTIVE LOW)
 	sw   			: in  	std_logic_vector(7 downto 0); -- The switch inputs
   leds			: out 	std_logic_vector(7 downto 0);	-- for displaying the the lab4 project details
	-------------------------------------------------------------
	-- you can add temporary output ports here if you need to debug your design 
	-- or to add internal signals for your simulations
	-------------------------------------------------------------
	
   seg7_data 	: out 	std_logic_vector(6 downto 0); -- 7-bit outputs to a 7-segment
	seg7_char1  : out	std_logic;							-- seg7 digi selectors
	seg7_char2  : out	std_logic							-- seg7 digi selectors
	
	-- ANALYSIS 
	--sm_clken_temp, blink_sig_temp							: out std_logic;
	--NS_L_temp, EW_L_temp	: out std_logic_vector(6 downto 0)
	);
END LogicalStep_Lab4_top;

ARCHITECTURE SimpleCircuit OF LogicalStep_Lab4_top IS
   component segment7_mux port (
          clk        	: in  	std_logic := '0';
			 DIN2 			: in  	std_logic_vector(6 downto 0);	--bits 6 to 0 represent segments G,F,E,D,C,B,A
			 DIN1 			: in  	std_logic_vector(6 downto 0); --bits 6 to 0 represent segments G,F,E,D,C,B,A
			 DOUT				: out	std_logic_vector(6 downto 0);
			 DIG2				: out	std_logic;
			 DIG1				: out	std_logic
   );
   end component;

   component clock_generator port (
			sim_mode			: in boolean;
			reset				: in std_logic;
         clkin       	: in  std_logic;
			sm_clken			: out	std_logic;
			blink		  		: out std_logic
  );
   end component;

    component pb_filters port (
			clkin					 : in std_logic;
			rst_n					 : in std_logic;
			rst_n_filtered	    : out std_logic;
			pb_n					 : in  std_logic_vector (3 downto 0);
			pb_n_filtered	    : out	std_logic_vector(3 downto 0)							 
 );
   end component;

	component pb_inverters port (
			rst_n				: in  std_logic;
			rst				    : out	std_logic;							 
			pb_n_filtered	    : in  std_logic_vector (3 downto 0);
			pb					: out	std_logic_vector(3 downto 0)							 
  );
   end component;
	
   component synchronizer port(
			clk					: in std_logic;
			reset					: in std_logic;
			din					: in std_logic;
			dout					: out std_logic
	);
	end component; 
  
   component holding_register port (
			clk					: in std_logic;
			reset					: in std_logic;
			register_clr		: in std_logic;
			din					: in std_logic;
			dout					: out std_logic
   );
   end component;			
	
	component Traffic_Light_Controller port(
		clk_input, clk_en, reset, blink_sig			: IN std_logic;
		hold_reg_ew, hold_reg_ns						: IN std_logic;
		lights_output										: OUT std_logic_vector(5 downto 0); -- (NS: green 5/amber 4/red 3 EW:green 2/amber 1/red 0)
		state													: OUT std_logic_vector(3 downto 0);
		reg_clear_ew, reg_clear_ns						: out std_logic;
		NS_CROSSING_DISPLAY, EW_CROSSING_DISPLAY  : out std_logic
	);
	end component;
----------------------------------------------------------------------------------------------------
	CONSTANT	sim_mode										: boolean := false;  -- set to FALSE for LogicalStep board downloads																						-- set to TRUE for SIMULATIONS
	SIGNAL rst, rst_n_filtered, synch_rst			: std_logic;
	SIGNAL sm_clken, blink_sig							: std_logic; 
	SIGNAL pb_n_filtered, pb							: std_logic_vector(3 downto 0); 
	
	SIGNAL sync_out0, sync_out1 	: std_logic;
	SIGNAL GL_ns, AL_ns, RL_ns 	: std_logic; 
	SIGNAL NS_CROSSING_DISPLAY 	: std_logic;
	SIGNAL EW_CROSSING_DISPLAY 	: std_logic;
	SIGNAL NS_L							: std_logic_vector(6 downto 0);
	SIGNAL EW_L							: std_logic_vector(6 downto 0);
	SIGNAL TLC_output 				: std_logic_vector(5 downto 0);
	SIGNAL CURRENT_STATE 			: std_logic_vector(3 downto 0);
	
	SIGNAL HOLD_REG_ns, HOLD_REG_ew 					: std_logic;
	SIGNAL CLEAR_HOLD_REG_ns, CLEAR_HOLD_REG_ew  : std_logic;
	
BEGIN
----------------------------------------------------------------------------------------------------

-- Concatenation of state machine outputs for 7seg mux
NS_L <= TLC_output(4) & "00" & TLC_output(5) & "00" & TLC_output(3);
EW_L <= TLC_output(1) & "00" & TLC_output(2) & "00" & TLC_output(0);

-- Assignments of outputs to LEDs
leds(2) <= EW_CROSSING_DISPLAY;
leds(0) <= NS_CROSSING_DISPLAY;

leds(3) <= HOLD_REG_ew;
leds(1) <= HOLD_REG_ns;
leds(7 downto 4) <= CURRENT_STATE;

-- Temp ports for simulations
--sm_clken_temp <= sm_clken;
--blink_sig_temp <= blink_sig; 
--NS _L_temp <= NS_L;
--EW_L_temp <= EW_L;

INST0: clock_generator 	port map (sim_mode, synch_rst, clkin_50, sm_clken, blink_sig);
INST1: pb_filters		port map (clkin_50, rst_n, rst_n_filtered, pb_n, pb_n_filtered);
INST2: pb_inverters		port map (rst_n_filtered, rst, pb_n_filtered, pb);

INST3: synchronizer     port map (clkin_50, '0', rst, synch_rst);	-- the synchronizer is also reset by synch_rst.
INST4: synchronizer     port map (clkin_50, synch_rst, pb(1), sync_out1);	-- EW cross request sync
INST5: synchronizer     port map (clkin_50, synch_rst, pb(0), sync_out0);	-- NS cross request sync

INST6: holding_register port map (clkin_50, synch_rst, CLEAR_HOLD_REG_ew, sync_out1, HOLD_REG_ew); -- Takes synchronized input and holds it until cleared by state machine
INST7: holding_register port map (clkin_50, synch_rst, CLEAR_HOLD_REG_ns, sync_out0, HOLD_REG_ns);	-- Same as above but for the other direction

INST8: Traffic_Light_Controller port map(clkin_50, sm_clken, synch_rst, blink_sig, HOLD_REG_ew, HOLD_REG_ns, TLC_output, CURRENT_STATE, 
CLEAR_HOLD_REG_ew, CLEAR_HOLD_REG_ns, NS_CROSSING_DISPLAY, EW_CROSSING_DISPLAY); -- Mealy state machine

INST9: segment7_mux port map(clkin_50, NS_L, EW_L, seg7_data, seg7_char2, seg7_char1); -- Mapping the concatenated state machine outputs to the 7segment display


END SimpleCircuit;

