library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity HDU is
    generic(n: integer := 3);
    -- WB_CU is write back signal from control unit 
    -- WB_ID_E is write back signal in Decode-Execute buffer 
    -- WB_E_MEM is write back signal in Execute-Memory buffer 
    -- swap_CU is swap signal from control unit 
    -- swap_ID_E is swap signal from Decode-Execute buffer 
    -- load_ID_E is load signal from Decode-Execute buffer 
    -- load_E_MEM is load signal from Execute-Memory buffer 
    -- Branch_Fetch is '1' if jmp or jz or call from memory

    -- Rsrc1_F_ID is Rsrc from Fetch-Decode buffer
    -- Rsrc2_F_ID is Rsrc from Fetch-Decode buffer
    -- Rdst1_F_ID is Rdst from Fetch-Decode buffer
    -- Rdst2_F_ID is Rdst from Fetch-Decode buffer
    -- Rdst1_ID_E is Rdst from Decode-Execute buffer
    -- Rdst2_ID_E is Rdst from Decode-Execute buffer
    -- Rdst_E_MEM is Rdst from Execute-Memory buffer
    -- Rdst1_Fetch is Rdst from fetch memory
    port(WB_CU, WB_ID_E, WB_E_MEM, swap_CU, swap_ID_E, load_ID_E, load_E_MEM, load_MEM_WB, Branch_Fetch, one_src_F_ID, two_src_F_ID: in std_logic;
        Rsrc1_F_ID, Rsrc2_F_ID, Rdst1_F_ID, Rdst2_F_ID, Rdst1_ID_E, Rdst2_ID_E, Rdst_E_MEM, Rdst_MEM_WB, Rdst_Fetch: in std_logic_vector(n-1 downto 0);
        insert_bubble, flush: out std_logic);
end entity;



architecture HDU_Arch of HDU is
    signal flush1, flush2, flush3: std_logic;
    begin
        flush1 <= '1' when  ( load_ID_E = '1' and Branch_Fetch = '1' and (Rdst1_ID_E = Rdst_Fetch) ) or ( ((swap_CU = '1' and Rdst2_F_ID = Rdst_Fetch) or ((WB_CU = '1' or swap_CU = '1') and Rdst1_F_ID = Rdst_Fetch)) and Branch_Fetch = '1' and load_ID_E = '0' ) else '0';

        flush2 <= '1' when ( load_E_MEM = '1' and Branch_Fetch = '1' and (Rdst_E_MEM = Rdst_Fetch) ) or ( ((swap_ID_E = '1' and Rdst2_ID_E = Rdst_Fetch) or ((WB_ID_E = '1' or swap_ID_E = '1') and Rdst1_ID_E = Rdst_Fetch)) and Branch_Fetch = '1' and load_E_MEM = '0' ) else '0';
        
        flush3 <= '1' when load_MEM_WB = '1' and Branch_Fetch = '1' and (Rdst_MEM_WB = Rdst_Fetch) else '0';
        
        flush <= '1' when flush1 = '1' or flush2 = '1' or flush3 = '1' else '0';

        insert_bubble <= '1' when (((Rsrc1_F_ID = Rdst1_ID_E and (one_src_F_ID = '1' or two_src_F_ID = '1')) or (two_src_F_ID = '1' and Rsrc2_F_ID = Rdst1_ID_E)) and load_ID_E = '1') else '0'; -- load use case
end architecture;