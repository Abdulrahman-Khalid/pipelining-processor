
LIBRARY IEEE;
USE IEEE.std_logic_1164.all;

ENTITY flag_reg IS
PORT( Clk,Reset, Enable : IN std_logic;

	    d_flags : IN std_logic_vector(2 DOWNTO 0);
	    q_flags : OUT std_logic_vector(2 DOWNTO 0)
);
	
END flag_reg;

ARCHITECTURE flag_reg1 OF flag_reg IS
BEGIN
PROCESS (Clk, Reset, Enable)
BEGIN
IF Reset = '1' THEN
	q_flags <= (OTHERS=>'0');

ELSIF (rising_edge(Clk)) THEN
	IF Enable = '1' THEN
		q_flags <= d_flags;
	END IF;
END IF;
END PROCESS;
END flag_reg1;
