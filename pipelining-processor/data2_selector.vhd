LIBRARY IEEE;
USE IEEE.std_logic_1164.all;
use ieee.numeric_std.all;

entity data2_selector is
	GENERIC ( n : integer := 32);
 	port(
     		RF_data2,temp_pc: in std_logic_vector(n-1 DOWNTO 0);
		rom_dataout: in std_logic_vector(15 downto 0);
		immediate_5bits: in std_logic_vector(4 downto 0);
		eff: in std_logic_vector(3 downto 0);
     		opcode: in std_logic_vector(4 downto 0);
     		Z: out std_logic_vector(n-1 DOWNTO 0));
end data2_selector;
 
architecture a_data2_selector of data2_selector is
begin
process (RF_data2,temp_pc,eff,immediate_5bits,opcode) is
begin
  if (opcode = "10100")then -- call instruction
      Z <= temp_pc;
  elsif (opcode = "01000" or opcode = "01001") then -- SHL or SHR -- IMEDIATE DATA 5 BITS
      Z <= "0000000000000000"&"00000000000"&immediate_5bits;
  elsif (opcode = "11010" or opcode = "01010") then -- 01010 IADD or 11010 LDM -- IMEDIATE DATA
      Z <="0000000000000000"&rom_dataout;
  elsif (opcode = "11011" or opcode = "11100") then  --11011 LDD or 11100 STD -- EFFECTIVE ADDRESS
      Z <="00000000"&eff&rom_dataout;
  else
      Z <= RF_data2;
  end if; 
 
end process;
end a_data2_selector;