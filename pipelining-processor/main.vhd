LIBRARY IEEE;
USE IEEE.std_logic_1164.all;
-- main entity of the processor
ENTITY main IS
PORT(	
	CLK,RST,INT : IN std_logic
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
-- Define one bit buffer
COMPONENT one_bit_buffer is
    port (      clk,rst,set,clr	: in std_logic;
		output	: out std_logic);
END COMPONENT;
-- Define Control Unit
COMPONENT control_unit is
    port (      rst: in std_logic;
		input: in std_logic_vector(4 DOWNTO 0);
		alu_operation: out std_logic_vector(3 DOWNTO 0);
		one_src, input_port,
		enable_temp2,
           	sel_alu,sel_data1,		--alu ops
		sel_data2,sel_inputport,
		enable_mem, read_write,		--memory ops
		enable_stack, push_pop,
		mem_to_pc, clr_rbit,
		clr_int,
		write_back, swap,		--write back ops
		rti_pop_flags, int_push_flags, 
		output_port
			: out std_logic);
end COMPONENT;
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
	address_to_pc, not_taken_address_to_fetch_buffer : OUT std_logic_vector(n-1 DOWNTO 0));
END COMPONENT;
-- Define memory used with jump states
COMPONENT state_memory IS
	Generic(addressBits: integer :=8;
		wordSize: integer :=2);
	PORT(
		clk : IN std_logic;
		we  : IN std_logic;
		address_write,address_read : IN  std_logic_vector(addressBits - 1 DOWNTO 0);
		datain  : IN  std_logic_vector(wordSize - 1 DOWNTO 0);
		dataout : OUT std_logic_vector(wordSize - 1 DOWNTO 0));
END COMPONENT;

COMPONENT jump_check_circuit is
    port (      clk,rst: in std_logic;
		jz_opcode: in std_logic;
		current_state: in std_logic_vector(1 DOWNTO 0);
		zero_flag_bit: in std_logic;
           	output_state: out std_logic_vector(1 DOWNTO 0);
		not_taken_enable: out std_logic);
END COMPONENT;

COMPONENT register_files IS
GENERIC ( n : integer := 32);
PORT( 		Clk,Rst,wb_signal,swap_signal : IN std_logic;
	    	write_port_data1,write_port_data2 : IN std_logic_vector(n-1 DOWNTO 0);
	    	write_port_address1,write_port_address2 : IN std_logic_vector(2 DOWNTO 0);
	    	read_port_data1,read_port_data2,read_port_data3 : OUT std_logic_vector(n-1 DOWNTO 0);
	    	read_port_address1,read_port_address2,read_port_address3 : IN std_logic_vector(2 DOWNTO 0)
);
END COMPONENT;

-- =====================================================================================
-- SIGNALS USED ========================================================================
-- =====================================================================================
signal  instruction_address, incremented_pc, not_taken_address, not_taken_address_to_fetch_buffer,
        address_loaded_from_memory,jump_address , address_to_pc, write_port_data1,write_port_data2,
	read_port_data1,read_port_data2,read_port_data3: std_logic_vector(31 downto 0);

		
signal  jump_enable, not_taken_address_enable,jz_opcode,call_opcode,jmp_opcode, zero_flag_bit, 
        connect_memory_pc, stall, address_loaded_from_memory_enable, wb_signal, swap_signal, 
---------------------------------------------------------------------------------------
--interrupt and return one bit buffers output signals
	int_bit_out,int_push_bit_out,rbit_out,

---------------------------------------------------------------------------------------
--CONTOL UNIT OUTPUT SIGNALS
	one_src, 	--One source signal
	input_port, 	--Input port used signal
	enable_temp2, 	--Enable temp2 signal
--Execution Stage mux output
        sel_alu,	--Select ALU signal
	sel_data1,	--Select Data1 signal
	sel_data2,	--Select Data2 signal
	sel_inputport,	--Select input port (same as input_port but this one is instead of the output of the mux, I left it to prevent confusion as the 2 exist in the document)
--memory ops
	enable_mem,	--Enables RAM Memory module
	read_write,	--1 for write, 0 for read
	enable_stack,	--Enables stack
 	push_pop,	--1 for push, 0 for pop
	mem_to_pc,	--Connects memory output to pc input
	clr_rbit,	--Clears rbit buffer
	clr_int,	--Clears interrupt buffer
--write back ops
	write_back,	--Writes back to register file
	swap,		--Swap operation
	rti_pop_flags, 	--Pops flags due to rti
	int_push_flags, --Pushs flags due to int
	output_port	--Output port used signal
	: std_logic;
signal alu_operation: std_logic_vector(3 DOWNTO 0); -- alu operation used
---------------------------------------------------------------------------------------

signal output_state,state_data_read,state_data_read_fetch_buffer: std_logic_vector(1 downto 0);
signal state_address_write,state_address_read : std_logic_vector(7 DOWNTO 0);
signal write_port_address1,write_port_address2,read_port_address1,read_port_address2,read_port_address3 : std_logic_vector(2 DOWNTO 0);
signal opcode: std_logic_vector(4 downto 0);
-- =====================================================================================
-- BEGINING of the program  ============================================================
-- =====================================================================================
BEGIN
-- =====================================================================================
-- 3 one bit buffers  ==================================================================
-- =====================================================================================

INT_BIT: one_bit_buffer
PORT MAP(	CLK,RST,INT,clr_int,int_bit_out);
--RBIT: one_bit_buffer
--PORT MAP(	CLK,RST,RET_OR_RTI FROM FETCH DETECTION, clr_rbit,rbit_out);
INT_PUSH_BIT: one_bit_buffer
PORT MAP(	CLK,RST,int_push_flags,int_push_bit_out,int_push_bit_out);



CU: control_unit
port MAP (      RST, OPCODE,
		alu_operation,
		one_src, input_port,
		enable_temp2,
           	sel_alu,sel_data1,		--alu ops
		sel_data2,sel_inputport,
		enable_mem, read_write,		--memory ops
		enable_stack, push_pop,
		mem_to_pc, clr_rbit,
		clr_int,
		write_back, swap,		--write back ops
		rti_pop_flags, int_push_flags, 
		output_port);
-- =====================================================================================
-- Register Files  =====================================================================
-- =====================================================================================
RF: register_files 
PORT MAP(	CLK,RST,wb_signal,swap_signal,write_port_data1,write_port_data2,
	    	write_port_address1,write_port_address2, 
	    	read_port_data1,read_port_data2,read_port_data3,
	    	read_port_address1,read_port_address2,read_port_address3);

-- =====================================================================================
-- PC ADDRESS HANDLING  ================================================================
-- =====================================================================================
-- TODO set not taken address to the one coming from fetch buffer, also put the address in the buffer (set not taken adddress to fetch buffer) 
PC_ADDRESS_CIRCUIT: pc_circuit PORT MAP( 
	instruction_address, incremented_pc, not_taken_address,
	address_loaded_from_memory,jump_address ,
	stall, jump_enable, not_taken_address_enable,
	address_loaded_from_memory_enable,
	address_to_pc, not_taken_address_to_fetch_buffer );
address_loaded_from_memory_enable <= (connect_memory_pc or RST);
PC : pc_register PORT MAP(CLK,RST,address_to_pc,instruction_address,'1');

INC: incrementor PORT MAP(CLK,RST,instruction_address,incremented_pc,'1');

-- =====================================================================================
-- DYNAMIC PREDICTION FOR JUMP INSTRUCTION =============================================
-- =====================================================================================


jz_opcode<= (opcode(4)and (not opcode(3)) and (not opcode(2)) and opcode(1) and (not opcode(0)) );
jmp_opcode<= (opcode(4)and (not opcode(3)) and (not opcode(2)) and opcode(1) and  opcode(0) );
call_opcode<= (opcode(4)and (not opcode(3)) and opcode(2)and (not opcode(1)) and (not opcode(0)));
jump_enable <= ( 
jmp_opcode or call_opcode or (
jz_opcode and (
(state_data_read(1) and state_data_read(0)) or  
(state_data_read(1) and (not state_data_read(0)))    
)));

-- TODO set state data from fetch buffer and zero flag bit
JCC: jump_check_circuit PORT MAP (CLK,RST,jz_opcode,state_data_read_fetch_buffer, zero_flag_bit, output_state,
		not_taken_address_enable);
-- TODO set state data read and write also but state data read in fetch buffer
SM: state_memory PORT MAP(CLK ,not_taken_address_enable,state_address_write,state_address_read ,
		output_state , state_data_read);


END a_main;