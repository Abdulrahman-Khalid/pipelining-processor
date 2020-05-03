LIBRARY IEEE;
USE IEEE.std_logic_1164.all;
use ieee.numeric_std.all;

ENTITY mux_2X1 IS
GENERIC ( n : integer := 32);
PORT(
	input1,input2 : IN std_logic_vector(n-1 DOWNTO 0);
	output	      : OUT std_logic_vector(n-1 DOWNTO 0);
	selector      : IN std_logic
);
	
END mux_2X1;

ARCHITECTURE a_mux_2X1 OF mux_2X1 IS
BEGIN
	output <= (input1) WHEN selector = '0' ELSE
		  (input2) WHEN selector = '1';
END a_mux_2X1;