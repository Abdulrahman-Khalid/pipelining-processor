
LIBRARY IEEE;
USE IEEE.std_logic_1164.all;

ENTITY fetch_Rdst_selector IS
PORT( 
	    EM_data1 : IN std_logic_vector(31 DOWNTO 0);
	    EM_data2 : IN std_logic_vector(31 DOWNTO 0);
	    MW_data1 : IN std_logic_vector(31 DOWNTO 0);
	    MW_data2 : IN std_logic_vector(31 DOWNTO 0);

	    REG_data : IN std_logic_vector(31 DOWNTO 0);

	    ALU_F_Rdst1 : IN std_logic;
	    ALU_F_Rdst2 : IN std_logic;
	    MEM_F_Rdst1 : IN std_logic;
	    MEM_F_Rdst2 : IN std_logic;

	    data : OUT std_logic_vector(31 DOWNTO 0)

);
	
END fetch_Rdst_selector;

ARCHITECTURE fetch_Rdst_selector1 OF fetch_Rdst_selector IS
BEGIN
PROCESS (EM_data1, EM_data2, MW_data1, MW_data2, ALU_F_Rdst1, ALU_F_Rdst2, MEM_F_Rdst1, MEM_F_Rdst2)
BEGIN

IF MEM_F_Rdst1 = '1' and ALU_F_Rdst1 = '0' and ALU_F_Rdst2 = '0' THEN
	data <= MW_data1;

ELSIF MEM_F_Rdst2 = '1' and ALU_F_Rdst1 = '0' and ALU_F_Rdst2 = '0' THEN
	data <= MW_data2;

ELSIF ALU_F_Rdst1 = '1' THEN
	data <= EM_data1;

ELSIF ALU_F_Rdst2 = '1' THEN
	data <= EM_data2;
ELSE
	data <= REG_data;

END IF;
END PROCESS;
END fetch_Rdst_selector1;
