
LIBRARY IEEE;
USE IEEE.std_logic_1164.all;

ENTITY DE_buffer IS
PORT( Clk,Reset : IN std_logic;
	    d_WB_signals : IN std_logic_vector(4 DOWNTO 0);
	    q_WB_signals : OUT std_logic_vector(4 DOWNTO 0);

	    d_memory_signals : IN std_logic_vector(6 DOWNTO 0);
	    q_memory_signals : OUT std_logic_vector(6 DOWNTO 0);

	    d_excute_signals : IN std_logic_vector(8 DOWNTO 0);
	    q_excute_signals : OUT std_logic_vector(8 DOWNTO 0);

	    d_data1 : IN std_logic_vector(31 DOWNTO 0);
	    q_data1 : OUT std_logic_vector(31 DOWNTO 0);

	    d_data2 : IN std_logic_vector(31 DOWNTO 0);
	    q_data2 : OUT std_logic_vector(31 DOWNTO 0);

	    d_Rsrc1 : IN std_logic_vector(2 DOWNTO 0);
	    q_Rsrc1 : OUT std_logic_vector(2 DOWNTO 0);

	    d_Rsrc2 : IN std_logic_vector(2 DOWNTO 0);
	    q_Rsrc2 : OUT std_logic_vector(2 DOWNTO 0);

	    d_Rdst1 : IN std_logic_vector(2 DOWNTO 0);
	    q_Rdst1 : OUT std_logic_vector(2 DOWNTO 0);

	    d_Rdst2 : IN std_logic_vector(2 DOWNTO 0);
	    q_Rdst2 : OUT std_logic_vector(2 DOWNTO 0)
);
	
END DE_buffer;

ARCHITECTURE DE_buffer1 OF DE_buffer IS
BEGIN
PROCESS (Clk, Reset)
BEGIN
IF Reset = '1' THEN
	q_WB_signals <= (OTHERS=>'0');
	q_memory_signals <= (OTHERS=>'0');
	q_excute_signals <= (OTHERS=>'0');
	q_data1 <= (OTHERS=>'0');
	q_data2 <= (OTHERS=>'0');
	q_Rsrc1 <= (OTHERS=>'0');
	q_Rsrc2 <= (OTHERS=>'0');
	q_Rdst1 <= (OTHERS=>'0');
	q_Rdst2 <= (OTHERS=>'0');

ELSIF (rising_edge(Clk)) THEN
	q_WB_signals <= d_WB_signals;
	q_memory_signals <= d_memory_signals;
	q_excute_signals <= d_excute_signals;
	q_data1 <= d_data1;
	q_data2 <= d_data2;
	q_Rdst1 <= d_Rdst1;
	q_Rdst2 <= d_Rdst2;
	q_Rsrc1 <= d_Rsrc1;
	q_Rsrc2 <= d_Rsrc2;
END IF;
END PROCESS;
END DE_buffer1;
