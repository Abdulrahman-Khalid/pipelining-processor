LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.numeric_std.all;
use std.textio.all;


ENTITY state_memory IS
	Generic(addressBits: integer :=8;
		wordSize: integer :=2);
	PORT(
		clk : IN std_logic;
		we  : IN std_logic;
		address_write,address_read : IN  std_logic_vector(addressBits - 1 DOWNTO 0);
		datain  : IN  std_logic_vector(wordSize - 1 DOWNTO 0);
		dataout : OUT std_logic_vector(wordSize - 1 DOWNTO 0));
END ENTITY state_memory;

ARCHITECTURE a_state_memory OF state_memory IS
	

	TYPE memory_type IS ARRAY(0 TO (2**addressBits) - 1) OF std_logic_vector(wordSize - 1 DOWNTO 0);
	impure function init_memory return memory_type is
		variable memory_content : memory_type;
		begin
		for i in 0 to (2**addressBits-1) loop
			memory_content(i) := "00";
		end loop;
  		return memory_content;
	end function;
	SIGNAL state_memory : memory_type := init_memory;
	
	BEGIN
		PROCESS(clk) IS
			BEGIN
				IF rising_edge(clk) THEN  
					IF we = '1' THEN
						state_memory(to_integer(unsigned(address_write))) <= datain;
					END IF;
				END IF;
		END PROCESS;
		dataout <= state_memory(to_integer(unsigned(address_read)));
END a_state_memory;