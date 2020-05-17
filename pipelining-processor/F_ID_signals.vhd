Library ieee;
use ieee.std_logic_1164.all;

entity F_ID_signals is
    port ( input: in std_logic_vector(4 DOWNTO 0); one_src_F_ID, two_src_F_ID: out std_logic);
end entity;

Architecture F_ID_signals_arch of F_ID_signals is
    begin
        -- one src => 10000 11100 01000 01001 01010 
        -- two src => 00100 00101 00110 00111 11101
        one_src_F_ID <= '1' when input = "10000" or input = "11100" else (not input(2)) when input(4) = '0' and input /= "00000" else '0';
        two_src_F_ID <= '1' when (input(4 downto 2) = "001") or (input = "11101") else '0';
end Architecture;
