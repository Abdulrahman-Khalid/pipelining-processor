
LIBRARY IEEE;
USE IEEE.std_logic_1164.all;

ENTITY forwarding_unit IS
PORT( 
	EM_Rdst1 : IN std_logic_vector(2 DOWNTO 0);
	EM_Rdst2 : IN std_logic_vector(2 DOWNTO 0);
	EM_WB_signal: IN std_logic;
	EM_swap_signal: IN std_logic;
	EM_memory_signal : IN std_logic;

	MW_Rdst1 : IN std_logic_vector(2 DOWNTO 0);
	MW_Rdst2 : IN std_logic_vector(2 DOWNTO 0);
	MW_WB_signal : IN std_logic;
	MW_swap_signal : IN std_logic;

	memory_instruction : IN std_logic_vector(15 DOWNTO 0);

	DE_Rsrc1 : IN std_logic_vector(2 DOWNTO 0);
	DE_Rsrc2 : IN std_logic_vector(2 DOWNTO 0);
	DE_WB_signal : IN std_logic;
	DE_swap_signal : IN std_logic;
	DE_s1: IN std_logic;
	DE_s0: IN std_logic;
	DE_oneSrc_signal : IN std_logic;

	--OUTPUT SIGNALS FOR FORWARDING TO FETCH
	ALU_F_Rdst1 : OUT std_logic;
	ALU_F_Rdst2 : OUT std_logic;
	MEM_F_Rdst1 : OUT std_logic;
	MEM_F_Rdst2 : OUT std_logic;

	--OUTPUT SIGNALS FOR FORWARDING FROM ALU TO ALU
	ALU_ALU_Rdst1_Rsrc1 : OUT std_logic;
	ALU_ALU_Rdst1_Rsrc2 : OUT std_logic;
	ALU_ALU_Rdst2_Rsrc1 : OUT std_logic;
	ALU_ALU_Rdst2_Rsrc2 : OUT std_logic;

	--OUTPUT SIGNALS FOR FORWARDING FROM MEMORY TO ALU
	MEM_ALU_Rdst1_Rsrc1 : OUT std_logic;
	MEM_ALU_Rdst1_Rsrc2 : OUT std_logic;
	MEM_ALU_Rdst2_Rsrc1 : OUT std_logic;
	MEM_ALU_Rdst2_Rsrc2 : OUT std_logic
);
	
END forwarding_unit;

ARCHITECTURE forwarding_unit1 OF forwarding_unit IS

SIGNAL memory_OpCode : std_logic_vector(4 DOWNTO 0);
SIGNAL memory_Rdst : std_logic_vector(2 DOWNTO 0);

BEGIN

memory_OpCode <= memory_instruction(15 DOWNTO 11);
memory_Rdst <= memory_instruction(2 DOWNTO 0);

--================================ALU/FETCH FORWARDING====================================================
PROCESS(memory_OpCode, memory_Rdst, EM_WB_signal, EM_swap_signal, EM_memory_signal, EM_Rdst1, EM_Rdst2)
BEGIN

IF ((memory_OpCode = "10010") or (memory_OpCode = "10011") or (memory_OpCode = "10100")) 
	and ((EM_WB_signal = '1') or (EM_swap_signal = '1')) and (EM_memory_signal = '0') 
	and (memory_Rdst = EM_Rdst1) THEN

	ALU_F_Rdst1 <= '1';
ELSE
	ALU_F_Rdst1 <= '0';
END IF;

IF (memory_OpCode = "10010" or memory_OpCode = "10011" or memory_OpCode = "10100") 
	and (EM_swap_signal = '1') and (memory_Rdst = EM_Rdst2) THEN

	ALU_F_Rdst2 <= '1';
ELSE
	ALU_F_Rdst2 <= '0';
END IF;
END PROCESS;
--===========================================================================================================

--=======================================MEM/FETCH FORWARDING=================================================
PROCESS(memory_OpCode, memory_Rdst, MW_WB_signal, MW_swap_signal, MW_Rdst1, MW_Rdst2)
BEGIN

IF (memory_OpCode = "10010" or memory_OpCode = "10011" or memory_OpCode = "10100") 
	and ((MW_WB_signal = '1') or (MW_swap_signal = '1')) and (memory_Rdst = MW_Rdst1) THEN

	MEM_F_Rdst1 <= '1';
ELSE
	MEM_F_Rdst1 <= '0';
END IF;

IF (memory_OpCode = "10010" or memory_OpCode = "10011" or memory_OpCode = "10100") 
	and (MW_swap_signal = '1') and (memory_Rdst = MW_Rdst2) THEN

	MEM_F_Rdst2 <= '1';
ELSE
	MEM_F_Rdst2 <= '0';
END IF;
END PROCESS;
--===============================================================================================================

--================================ALU/ALU FORWARDING====================================================
PROCESS(DE_WB_signal, DE_swap_signal,DE_oneSrc_signal, DE_s1, DE_s0, EM_WB_signal, EM_swap_signal, EM_memory_signal, EM_Rdst1, EM_Rdst2, DE_Rsrc1, DE_Rsrc2)
BEGIN

IF (((DE_WB_signal = '1') and (DE_s1 = '0') and (DE_s0 = '0')) or DE_swap_signal = '1' or((DE_s1 = '0') and (DE_s0 = '1')) )
	and ((EM_WB_signal = '1') or (EM_swap_signal = '1'))
	and (EM_memory_signal = '0') THEN

	IF EM_Rdst1 = DE_Rsrc1 THEN
		ALU_ALU_Rdst1_Rsrc1 <= '1';
	ELSE
		ALU_ALU_Rdst1_Rsrc1 <= '0';
	END IF;

	IF (EM_Rdst1 = DE_Rsrc2) and (DE_oneSrc_signal = '0') THEN
		ALU_ALU_Rdst1_Rsrc2 <= '1';
	ELSE
		ALU_ALU_Rdst1_Rsrc2 <= '0';
	END IF;

ELSE
	ALU_ALU_Rdst1_Rsrc1 <= '0';
	ALU_ALU_Rdst1_Rsrc2 <= '0';
END IF;

IF (((DE_WB_signal = '1') and (DE_s1 = '0') and (DE_s0 = '0')) or DE_swap_signal = '1' or ((DE_s1 = '0') and (DE_s0 = '1')))
 	and (EM_swap_signal = '1') THEN
	
	IF EM_Rdst2 = DE_Rsrc1 THEN
		ALU_ALU_Rdst2_Rsrc1 <= '1';
	ELSE
		ALU_ALU_Rdst2_Rsrc1 <= '0';
	END IF;

	IF (EM_Rdst2 = DE_Rsrc2) and (DE_oneSrc_signal = '0') THEN
		ALU_ALU_Rdst2_Rsrc2 <= '1';
	ELSE
		ALU_ALU_Rdst2_Rsrc2 <= '0';
	END IF;
ELSE
	ALU_ALU_Rdst2_Rsrc1 <= '0';
	ALU_ALU_Rdst2_Rsrc2 <= '0';
END IF;
END PROCESS;
--===========================================================================================================

--================================MEM/ALU FORWARDING====================================================
PROCESS(DE_WB_signal, DE_swap_signal, DE_s1, DE_s0, DE_oneSrc_signal, MW_WB_signal, MW_swap_signal, MW_Rdst1, MW_Rdst2, DE_Rsrc1, DE_Rsrc2)
BEGIN

IF (((DE_WB_signal = '1') and (DE_s1 = '0') and (DE_s0 = '0')) or DE_swap_signal = '1' or ((DE_s1 = '0') and (DE_s0 = '1')))
 	and ((MW_WB_signal = '1') or (MW_swap_signal = '1')) THEN
	
	IF MW_Rdst1 = DE_Rsrc1 THEN
		MEM_ALU_Rdst1_Rsrc1 <= '1';
	ELSE
		MEM_ALU_Rdst1_Rsrc1 <= '0';
	END IF;

	IF (MW_Rdst1 = DE_Rsrc2) and (DE_oneSrc_signal = '0') THEN
		MEM_ALU_Rdst1_Rsrc2 <= '1';
	ELSE
		MEM_ALU_Rdst1_Rsrc2 <= '0';
	END IF;
ELSE
	MEM_ALU_Rdst1_Rsrc1 <= '0';
	MEM_ALU_Rdst1_Rsrc2 <= '0';
END IF;

IF (((DE_WB_signal = '1') and (DE_s1 = '0') and (DE_s0 = '0')) or DE_swap_signal = '1' or ((DE_s1 = '0') and (DE_s0 = '1')))
 	and (MW_swap_signal = '1') THEN
	
	IF MW_Rdst2 = DE_Rsrc1 THEN
		MEM_ALU_Rdst2_Rsrc1 <= '1';
	ELSE
		MEM_ALU_Rdst2_Rsrc1 <= '0';
	END IF;

	IF (MW_Rdst2 = DE_Rsrc2)and (DE_oneSrc_signal = '0') THEN
		MEM_ALU_Rdst2_Rsrc2 <= '1';
	ELSE
		MEM_ALU_Rdst2_Rsrc2 <= '0';
	END IF;
ELSE
	MEM_ALU_Rdst2_Rsrc1 <= '0';
	MEM_ALU_Rdst2_Rsrc2 <= '0';
END IF;
END PROCESS;
--===========================================================================================================

END forwarding_unit1;
