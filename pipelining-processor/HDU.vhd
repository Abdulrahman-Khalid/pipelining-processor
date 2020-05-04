library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity HDU is
    generic(n: integer := 3);
    -- WB_CU is write back signal from control unit 
    -- WB_ID_E is write back signal in Decode-Execute buffer 
    port(WB_CU, WB_ID_E, WB_E_MEM, swap_F_ID, swap_ID_E, load_ID_E, load_E_MEM, Branch_MEM: in std_logic;
        Rsrc1_F_ID, Rsrc2_F_ID, Rdst1_F_ID, Rdst2_F_ID, Rdst1_ID_E, Rdst2_ID_E, Rdst_E_MEM, Rdst_MEM: in std_logic_vector(n-1 downto 0);
        insert_bubble, flush: out std_logic);
end entity;

architecture HDU_Arch of HDU is
    signal flush1, flush2, flush3: std_logic;
    begin
        flush1 <= '1' when ((swap_F_ID = '1' and Rdst1_F_ID = Rdst_MEM) or (WB_CU = '1' and Rdst2_F_ID = Rdst_MEM)) and Branch_MEM = '1' else '0';

        flush2 <= '1' when ((swap_ID_E = '1' and Rdst1_ID_E = Rdst_MEM) or (WB_ID_E = '1' and Rdst2_ID_E = Rdst_MEM)) and Branch_MEM = '1' else '0';
        
        flush3 <= '1' when load_E_MEM = '1' and Branch_MEM = '1' and WB_E_MEM = '1' and (Rdst_E_MEM = Rdst_MEM) else '0';
        
        flush <= '1' when flush1 = '1' or flush2 = '1' or flush3 = '1' else '0';
        insert_bubble <= '1' when ((Rsrc1_F_ID = Rdst1_ID_E or Rsrc2_F_ID = Rdst1_ID_E) and load_ID_E = '1') else '0'; -- load use case
end architecture;