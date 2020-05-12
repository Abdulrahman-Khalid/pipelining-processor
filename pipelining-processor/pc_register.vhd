LIBRARY IEEE;
USE IEEE.std_logic_1164.all;
use ieee.numeric_std.all;

ENTITY pc_register IS
GENERIC ( n : integer := 32;
	  codeSegmentStart: integer :=500);
PORT( CLK,RST : IN std_logic;
	    d : IN std_logic_vector(n-1 DOWNTO 0);
	    q : OUT std_logic_vector(n-1 DOWNTO 0);
	enable: in std_logic
);
	
END pc_register;
ARCHITECTURE a_pc_register_nbits OF pc_register IS
BEGIN

PROCESS (d,CLK,RST,enable)
	BEGIN
		IF (RST = '1') THEN
			IF (CLK = '1') THEN 
				q <= d;
			END IF;
		ELSIF (rising_edge(CLK) and enable='1' ) THEN
			q <= d;
		END IF;
	END PROCESS;
END a_pc_register_nbits;