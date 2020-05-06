
LIBRARY IEEE;
USE IEEE.std_logic_1164.all;

ENTITY ALU_in2_selector IS
PORT( 
	    EM_data1 : IN std_logic_vector(31 DOWNTO 0);
	    EM_data2 : IN std_logic_vector(31 DOWNTO 0);
	    MW_data1 : IN std_logic_vector(31 DOWNTO 0);
	    MW_data2 : IN std_logic_vector(31 DOWNTO 0);

	    DE_data2 : IN std_logic_vector(31 DOWNTO 0);

	    ALU_ALU_Rdst1_Rsrc2 : IN std_logic;
	    ALU_ALU_Rdst2_Rsrc2 : IN std_logic;
	    MEM_ALU_Rdst1_Rsrc2 : IN std_logic;
	    MEM_ALU_Rdst2_Rsrc2 : IN std_logic;

	    ALU_in2 : OUT std_logic_vector(31 DOWNTO 0)

);
	
END ALU_in2_selector;

ARCHITECTURE ALU_in2_selector1 OF ALU_in2_selector IS
BEGIN
PROCESS (EM_data1, EM_data2, MW_data1, MW_data2, DE_data2, ALU_ALU_Rdst1_Rsrc2, ALU_ALU_Rdst2_Rsrc2, MEM_ALU_Rdst1_Rsrc2, MEM_ALU_Rdst2_Rsrc2)
BEGIN

IF MEM_ALU_Rdst1_Rsrc2 = '1' and ALU_ALU_Rdst1_Rsrc2 = '0' and ALU_ALU_Rdst2_Rsrc2 = '0' THEN
	ALU_in2 <= MW_data1;

ELSIF MEM_ALU_Rdst2_Rsrc2 = '1' and ALU_ALU_Rdst1_Rsrc2 = '0' and ALU_ALU_Rdst2_Rsrc2 = '0' THEN
	ALU_in2 <= MW_data2;

ELSIF ALU_ALU_Rdst1_Rsrc2 = '1' THEN
	ALU_in2 <= EM_data1;

ELSIF ALU_ALU_Rdst2_Rsrc2 = '1' THEN
	ALU_in2 <= EM_data2;
ELSE 
	ALU_in2 <= DE_data2;

END IF;
END PROCESS;
END ALU_in2_selector1;
