
LIBRARY IEEE;
USE IEEE.std_logic_1164.all;

ENTITY FD_buffer IS
PORT( Clk,Reset, Enable, Flush : IN std_logic;
	    d_instruction : IN std_logic_vector(15 DOWNTO 0);
	    q_instruction : OUT std_logic_vector(15 DOWNTO 0);

	    d_not_taken_address : IN std_logic_vector(31 DOWNTO 0);
	    q_not_taken_address : OUT std_logic_vector(31 DOWNTO 0);

	    d_predicted_state : IN std_logic_vector(1 DOWNTO 0);
	    q_predicted_state : OUT std_logic_vector(1 DOWNTO 0);

	    d_state_address : IN std_logic_vector(1 DOWNTO 0);
	    q_state_address : OUT std_logic_vector(1 DOWNTO 0)
);
	
END FD_buffer;

ARCHITECTURE FD_buffer1 OF FD_buffer IS
BEGIN
PROCESS (Clk, Reset, Enable, Flush)
BEGIN
IF Reset = '1' THEN
	q_instruction <= (OTHERS=>'0');
	q_not_taken_address <= (OTHERS=>'0');
	q_predicted_state <= (OTHERS=>'0');
	q_state_address <= (OTHERS=>'0');

ELSIF (rising_edge(Clk)) THEN
	IF Enable = '1' THEN
		IF Flush = '1' THEN
			q_instruction <= (OTHERS=>'0');
			q_not_taken_address <= (OTHERS=>'0');
			q_predicted_state <= (OTHERS=>'0');
			q_state_address <= (OTHERS=>'0');
		ELSE
			q_instruction <= d_instruction;
			q_not_taken_address <= d_not_taken_address;
			q_predicted_state <= d_predicted_state;
			q_state_address <= d_state_address;
		END IF;
	END IF;
END IF;
END PROCESS;
END FD_buffer1;