LIBRARY IEEE;
USE IEEE.std_logic_1164.all;
use ieee.numeric_std.all;
entity mux_4X1 is
GENERIC ( n : integer := 32);
 port(
 
     A,B,C,D : in std_logic_vector(n-1 DOWNTO 0);
     S0,S1: in STD_LOGIC;
     Z: out std_logic_vector(n-1 DOWNTO 0)
  );
end mux_4X1;
 
architecture bhv of mux_4X1 is
begin
process (A,B,C,D,S0,S1) is
begin
  if (S0 ='0' and S1 = '0') then
      Z <= A;
  elsif (S0 ='1' and S1 = '0') then
      Z <= B;
  elsif (S0 ='0' and S1 = '1') then
      Z <= C;
  else
      Z <= D;
  end if;
 
end process;
end;
