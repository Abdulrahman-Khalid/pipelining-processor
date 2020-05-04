library IEEE;
use IEEE.std_logic_1164.all;
USE IEEE.numeric_std.all;
USE work.constants.all;

entity HDU is
    generic(n: integer := 3);
    port(
        swap_F_ID, swap_ID_E, load_ID_E, load_E_MEM, Branch_MEM: in std_logic;
        Rdst1_F_ID, Rdst2_F_ID, Rdst1_ID_E, Rdst2_ID_E, Rdst_E_MEM, Rdst_MEM: in std_logic_vector(n-1 downto 0);
        insert_bubble, flush, hazard_detected: out std_logic;
end entity;

architecture HDU_Arch of alu is
    
    begin
        insert_bubble <= '0';
        flush <= '0';
        hazard_detected <= (insert_bubble and flush);
end architecture;