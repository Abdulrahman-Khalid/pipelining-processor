LIBRARY IEEE;
USE IEEE.std_logic_1164.all;
use ieee.numeric_std.all;

entity data2_selector is
	GENERIC ( n : integer := 32);
 	port(
     		RF_data2,temp_pc, shift_data,effective_address
		,immediate_data: in std_logic_vector(n-1 DOWNTO 0);
     		opcode: in std_logic_vector(4 downto 0);
     		Z: out std_logic_vector(n-1 DOWNTO 0));
end data2_selector;
 
architecture a_data2_selector of data2_selector is
begin
	Z <= 	(temp_pc) 		WHEN (opcode = "10100") 			ELSE
	     	(shift_data) 		WHEN (opcode = "01000" or opcode = "01001") 	ELSE
		(immediate_data)	WHEN (opcode = "11010" or opcode = "01010")	ELSE
		(effective_address)	WHEN (opcode = "11011" or opcode = "11100")	ELSE
		(RF_data2)	 	WHEN (true);
end a_data2_selector;