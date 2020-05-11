LIBRARY IEEE;
USE IEEE.std_logic_1164.all;
use ieee.numeric_std.all;
USE work.constants.all;

ENTITY RAM_datain is
GENERIC ( n : integer := 32);
 port(
     data,temp2 : in std_logic_vector(n-1 DOWNTO 0);
     flags : in std_logic_vector(flagsCount-1 DOWNTO 0);
     temp2_enable,flags_enable: in STD_LOGIC;
     data_out: out std_logic_vector(n-1 DOWNTO 0)
  );
END RAM_datain;
 
architecture a_RAM_datain of RAM_datain is
begin
process (data,temp2,flags,temp2_enable,flags_enable) is
begin
  if (temp2_enable = '1') then
      data_out <= temp2;
  elsif (flags_enable = '1') then
      data_out <= "00000000000000000000000000000"&flags;
  else
      data_out <= data;
  end if;
 
end process;
end a_RAM_datain;