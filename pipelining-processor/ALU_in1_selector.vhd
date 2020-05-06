
LIBRARY IEEE;
USE IEEE.std_logic_1164.all;

ENTITY ALU_in1_selector IS
PORT( 
	    EM_data1 : IN std_logic_vector(31 DOWNTO 0);
	    EM_data2 : IN std_logic_vector(31 DOWNTO 0);
	    MW_data1 : IN std_logic_vector(31 DOWNTO 0);
	    MW_data2 : IN std_logic_vector(31 DOWNTO 0);

	    DE_data1 : IN std_logic_vector(31 DOWNTO 0);

	    ALU_ALU_Rdst1_Rsrc1 : IN std_logic;
	    ALU_ALU_Rdst2_Rsrc1 : IN std_logic;
	    MEM_ALU_Rdst1_Rsrc1 : IN std_logic;
	    MEM_ALU_Rdst2_Rsrc1 : IN std_logic;

	    ALU_in1 : OUT std_logic_vector(31 DOWNTO 0)

);
	
END ALU_in1_selector;

ARCHITECTURE ALU_in1_selector1 OF ALU_in1_selector IS
BEGIN
PROCESS (EM_data1, EM_data2, MW_data1, MW_data2, DE_data1, ALU_ALU_Rdst1_Rsrc1, ALU_ALU_Rdst2_Rsrc1, MEM_ALU_Rdst1_Rsrc1, MEM_ALU_Rdst2_Rsrc1)
BEGIN

IF MEM_ALU_Rdst1_Rsrc1 = '1' and ALU_ALU_Rdst1_Rsrc1 = '0' and ALU_ALU_Rdst2_Rsrc1 = '0' THEN
	ALU_in1 <= MW_data1;

ELSIF MEM_ALU_Rdst2_Rsrc1 = '1' and ALU_ALU_Rdst1_Rsrc1 = '0' and ALU_ALU_Rdst2_Rsrc1 = '0' THEN
	ALU_in1 <= MW_data2;

ELSIF ALU_ALU_Rdst1_Rsrc1 = '1' THEN
	ALU_in1 <= EM_data1;

ELSIF ALU_ALU_Rdst2_Rsrc1 = '1' THEN
	ALU_in1 <= EM_data2;
ELSE 
	ALU_in1 <= DE_data1;

END IF;
END PROCESS;
END ALU_in1_selector1;
