LIBRARY IEEE;
USE IEEE.std_logic_1164.all;
use ieee.numeric_std.all;

ENTITY pc_circuit IS
GENERIC ( n : integer := 32);
-- Takes 4 addresses as inputs and select one of them
PORT( 
	unchanged_pc, incremented_pc, not_taken_address,
	address_loaded_from_memory,jump_address : IN std_logic_vector(n-1 DOWNTO 0); 
	unchanged_pc_enable, jump_enable, not_taken_address_enable,
	address_loaded_from_memory_enable : in std_logic;
	address_to_pc, not_taken_address_to_fetch_buffer : OUT std_logic_vector(n-1 DOWNTO 0)
);
	
END pc_circuit;

ARCHITECTURE a_pc_circuit OF pc_circuit IS

-- Define mux with 2 inputs and one output
COMPONENT mux_2X1 IS
GENERIC ( n : integer := 32);
PORT(
	input1,input2 : IN std_logic_vector(n-1 DOWNTO 0);
	output	      : OUT std_logic_vector(n-1 DOWNTO 0);
	selector      : IN std_logic
);
END COMPONENT;
signal m1_output, m2_output, m3_output :std_logic_vector(n-1 DOWNTO 0);
signal invert_address: std_logic;
BEGIN
-- Cascaded multiplixers to determine the next pc address.
m1 : mux_2X1 PORT MAP( incremented_pc, jump_address, m1_output, jump_enable);
m2 : mux_2X1 PORT MAP( m1_output, unchanged_pc, m2_output, unchanged_pc_enable);
m3 : mux_2X1 PORT MAP( m2_output, not_taken_address, m3_output, not_taken_address_enable);
m4 : mux_2X1 PORT MAP( m3_output, address_loaded_from_memory, address_to_pc, address_loaded_from_memory_enable);
-- If jump instruction keep the address of the not taken instruction
invert_address <= not jump_enable;
m5 : mux_2X1 PORT MAP( incremented_pc, jump_address, not_taken_address_to_fetch_buffer, invert_address);

END a_pc_circuit;