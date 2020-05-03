LIBRARY IEEE;
USE IEEE.std_logic_1164.all;
-- main entity of the processor
ENTITY main IS
PORT(	
	CLK,RST : IN std_logic
);
END main;

ARCHITECTURE a_main OF main IS
-- =====================================================================================
-- COMPONENTS USED =====================================================================
-- =====================================================================================  
-- Define PC register
COMPONENT pc_register IS
GENERIC ( n : integer := 32;
	  codeSegmentStart: integer :=500);
PORT( Clk,Rst : IN std_logic;
	    d : IN std_logic_vector(n-1 DOWNTO 0);
	    q : OUT std_logic_vector(n-1 DOWNTO 0);
	enable: in std_logic);
END COMPONENT;
-- Define incrementor 
COMPONENT incrementor IS
GENERIC ( n : integer := 32);
PORT( CLK,RST : IN std_logic;
	    d : IN std_logic_vector(n-1 DOWNTO 0);
	    q : OUT std_logic_vector(n-1 DOWNTO 0);
		enable: in std_logic);
END COMPONENT;
-- Define Pc circuit 
COMPONENT pc_circuit IS
GENERIC ( n : integer := 32);
-- Takes 4 addresses as inputs and select one of them
PORT( 
	unchanged_pc, incremented_pc, not_taken_address,
	address_loaded_from_memory,jump_address : IN std_logic_vector(n-1 DOWNTO 0); 
	unchanged_pc_enable, jump_enable, not_taken_address_enable,
	address_loaded_from_memory_enable : in std_logic;
	address_to_pc : OUT std_logic_vector(n-1 DOWNTO 0));
END COMPONENT;

-- =====================================================================================
-- SIGNALS USED ========================================================================
-- =====================================================================================
signal  instruction_address, incremented_pc, not_taken_address,
        address_loaded_from_memory,jump_address , address_to_pc: std_logic_vector(31 downto 0);

signal  jump_enable, not_taken_address_enable,
        connect_memory_pc, stall, address_loaded_from_memory_enable : std_logic;
-- =====================================================================================
-- BEGINING of the program  ============================================================
-- =====================================================================================
BEGIN

-- =====================================================================================
-- PC ADDRESS HANDLING  ================================================================
-- =====================================================================================
PC_ADDRESS_CIRCUIT: pc_circuit PORT MAP( 
	instruction_address, incremented_pc, not_taken_address,
	address_loaded_from_memory,jump_address ,
	stall, jump_enable, not_taken_address_enable,
	address_loaded_from_memory_enable,
	address_to_pc );
address_loaded_from_memory_enable <= (connect_memory_pc or RST);
PC : pc_register PORT MAP(CLK,RST,address_to_pc,instruction_address,'1');

INC: incrementor PORT MAP(CLK,RST,instruction_address,incremented_pc,'1');

END a_main;