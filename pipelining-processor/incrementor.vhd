LIBRARY IEEE;
USE IEEE.std_logic_1164.all;
USE IEEE.numeric_std.all;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

ENTITY incrementor IS
GENERIC ( n : integer := 32);
PORT( CLK,RST : IN std_logic;
	    d : IN std_logic_vector(n-1 DOWNTO 0);
	    q : OUT std_logic_vector(n-1 DOWNTO 0);
		enable: in std_logic
);
	
END incrementor;
ARCHITECTURE a_incrementor_register_nbits OF incrementor IS
BEGIN
PROCESS (d,CLK,RST,enable)
BEGIN
IF RST = '1' THEN
q <= d;
ELSIF (falling_edge(CLK) and enable='1') THEN
q <= (d+1);
END IF;
END PROCESS;
END a_incrementor_register_nbits;