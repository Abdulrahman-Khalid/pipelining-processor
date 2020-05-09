LIBRARY IEEE;
USE work.constants.all;
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
-- Define ROM
COMPONENT ROM IS
	GENERIC (wordSize : integer := 16; addressWidth: integer := 11; ROMSize: integer := 2048);
		PORT(	
		enable  : IN std_logic;
		address : IN  std_logic_vector(addressWidth - 1 DOWNTO 0);
		dataOut  : OUT  std_logic_vector(wordSize - 1 DOWNTO 0));
END COMPONENT ROM;
-- Define RAM
COMPONENT RAM IS
	GENERIC (wordSize : integer := 16; addressWidth: integer := 32; RAMSize: integer := 2**20-1);
	PORT(	
		W  : IN std_logic;
		R  : IN std_logic;
		address : IN  std_logic_vector(addressWidth - 1 DOWNTO 0);
		dataIn  : IN  std_logic_vector(wordSize - 1 DOWNTO 0);
		dataOut  : OUT  std_logic_vector(wordSize - 1 DOWNTO 0));
END COMPONENT RAM;
-- Define Mux 2x1
COMPONENT mux_2X1 IS
	GENERIC ( n : integer := 32);
	PORT(
		input1,input2 : IN std_logic_vector(n-1 DOWNTO 0);
		output	      : OUT std_logic_vector(n-1 DOWNTO 0);
		selector      : IN std_logic
	);	
END COMPONENT;
-- Define Stack Pointer
COMPONENT stack_pointer IS
	GENERIC ( n : integer := 32);
	PORT( CLK,RST,push_pop,enable_stack
		      : IN std_logic;
		    sp_out
		      : OUT std_logic_vector(n-1 DOWNTO 0)
	);
END COMPONENT;
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
		cu_s0,cu_s1,			--aluops
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

-- Define buffers

COMPONENT FD_buffer IS
PORT( Clk,Reset, Enable, Flush : IN std_logic;
	    d_instruction : IN std_logic_vector(15 DOWNTO 0);
	    q_instruction : OUT std_logic_vector(15 DOWNTO 0);

	    d_not_taken_address : IN std_logic_vector(31 DOWNTO 0);
	    q_not_taken_address : OUT std_logic_vector(31 DOWNTO 0);

	    d_predicted_state : IN std_logic_vector(1 DOWNTO 0);
	    q_predicted_state : OUT std_logic_vector(1 DOWNTO 0);

	    d_state_address : IN std_logic_vector(1 DOWNTO 0);
	    q_state_address : OUT std_logic_vector(1 DOWNTO 0)
);
	
END COMPONENT;

COMPONENT DE_buffer IS
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
	
END COMPONENT;

COMPONENT EM_buffer IS
PORT( Clk,Reset : IN std_logic;
	    d_WB_signals : IN std_logic_vector(4 DOWNTO 0);
	    q_WB_signals : OUT std_logic_vector(4 DOWNTO 0);

	    d_memory_signals : IN std_logic_vector(6 DOWNTO 0);
	    q_memory_signals : OUT std_logic_vector(6 DOWNTO 0);

	    d_data1 : IN std_logic_vector(31 DOWNTO 0);
	    q_data1 : OUT std_logic_vector(31 DOWNTO 0);

	    d_data2 : IN std_logic_vector(31 DOWNTO 0);
	    q_data2 : OUT std_logic_vector(31 DOWNTO 0);

	    d_Rdst1 : IN std_logic_vector(2 DOWNTO 0);
	    q_Rdst1 : OUT std_logic_vector(2 DOWNTO 0);

	    d_Rdst2 : IN std_logic_vector(2 DOWNTO 0);
	    q_Rdst2 : OUT std_logic_vector(2 DOWNTO 0)
);
	
END COMPONENT;

COMPONENT MW_buffer IS
PORT( Clk,Reset : IN std_logic;
	    d_WB_signals : IN std_logic_vector(4 DOWNTO 0);
	    q_WB_signals : OUT std_logic_vector(4 DOWNTO 0);

	    d_data1 : IN std_logic_vector(31 DOWNTO 0);
	    q_data1 : OUT std_logic_vector(31 DOWNTO 0);

	    d_data2 : IN std_logic_vector(31 DOWNTO 0);
	    q_data2 : OUT std_logic_vector(31 DOWNTO 0);

	    d_Rdst1 : IN std_logic_vector(2 DOWNTO 0);
	    q_Rdst1 : OUT std_logic_vector(2 DOWNTO 0);

	    d_Rdst2 : IN std_logic_vector(2 DOWNTO 0);
	    q_Rdst2 : OUT std_logic_vector(2 DOWNTO 0)
);
	
END COMPONENT;

--Define forwarding unit

COMPONENT forwarding_unit IS
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
	DE_memory_signal : IN std_logic;
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
	
END COMPONENT;

--Define ALU input selectors

COMPONENT ALU_in1_selector IS
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
	
END COMPONENT;

COMPONENT ALU_in2_selector IS
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
	
END COMPONENT;

--Define fetch Rdst selector

COMPONENT fetch_Rdst_selector IS
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
	
END COMPONENT;

--Define flag register


COMPONENT flag_reg IS
PORT( Clk,Reset, Enable : IN std_logic;

	    d_flags : IN std_logic_vector(3 DOWNTO 0);
	    q_flags : OUT std_logic_vector(3 DOWNTO 0)
);
	
END COMPONENT;
-- =====================================================================================
-- SIGNALS USED ========================================================================
-- =====================================================================================
signal  instruction_address, incremented_pc, not_taken_address, not_taken_address_to_fetch_buffer,
        address_loaded_from_memory,jump_address , address_to_pc, write_port_data1,write_port_data2,
	read_port_data1,read_port_data2,read_port_data3: std_logic_vector(31 downto 0);
---------------------------------------------------------------------------------------
signal ram_read,ram_write,rom_read :std_logic;
signal ram_address : std_logic_vector(RAM_ADDRESS_WIDTH-1 DOWNTO 0);
signal rom_address :  std_logic_vector(ROM_ADDRESS_WIDTH - 1 DOWNTO 0);
signal ram_data_in,ram_data_out : std_logic_vector( 2*WORD_SIZE - 1 DOWNTO 0);
signal rom_data_out : std_logic_vector(WORD_SIZE - 1 DOWNTO 0);
---------------------------------------------------------------------------------------
signal sp_out,m_mux1_out,m_mux2_out : std_logic_vector(2*WORD_SIZE-1 DOWNTO 0);
signal M_sel : std_logic;

---------------------------------------------------------------------------------------
signal  jump_enable, not_taken_address_enable,jz_opcode,call_opcode,jmp_opcode, zero_flag_bit, 
        connect_memory_pc, stall, address_loaded_from_memory_enable, wb_signal, swap_signal, 
---------------------------------------------------------------------------------------
--interrupt and return one bit buffers output signals
	int_bit_out,int_push_bit_out,rbit_out,
	ret_opcode,rti_opcode,rti_or_ret,
---------------------------------------------------------------------------------------
--CONTOL UNIT OUTPUT SIGNALS
	one_src, 	--One source signal
	input_port, 	--Input port used signal
	enable_temp2, 	--Enable temp2 signal
--Execution Stage mux input
	cu_s0,		--Selector for the mux  S0
	cu_s1,		--Selector for the mux  S1
--memory ops
	enable_mem,	--Enables ROM Memory module
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

---------------------------------------------------------------------------------------
--FETCH DECODE BUFFER SIGNALS

SIGNAL FD_Flush, FD_Enable : std_logic;
SIGNAL FD_d_instruction, FD_q_instruction : std_logic_vector(15 DOWNTO 0);
SIGNAL FD_d_not_taken_address, FD_q_not_taken_address : std_logic_vector(31 DOWNTO 0);
SIGNAL FD_d_predicted_state, FD_q_predicted_state : std_logic_vector(1 DOWNTO 0);
SIGNAL FD_d_state_address, FD_q_state_address : std_logic_vector(1 DOWNTO 0);
----------------------------------------------------------------------------------------
--DECODE EXCUTE BUFFER SIGNALS

SIGNAL DE_d_WB_signals, DE_q_WB_signals : std_logic_vector(4 DOWNTO 0);
SIGNAL DE_d_excute_signals, DE_q_excute_signals : std_logic_vector(8 DOWNTO 0);
SIGNAL DE_d_memory_signals, DE_q_memory_signals : std_logic_vector(6 DOWNTO 0); 
SIGNAL DE_d_data1, DE_q_data1 : std_logic_vector(31 DOWNTO 0);
SIGNAL DE_d_data2, DE_q_data2 : std_logic_vector(31 DOWNTO 0);
SIGNAL DE_d_Rsrc1, DE_q_Rsrc1 : std_logic_vector(2 DOWNTO 0);
SIGNAL DE_d_Rsrc2, DE_q_Rsrc2 : std_logic_vector(2 DOWNTO 0);
SIGNAL DE_d_Rdst1, DE_q_Rdst1 : std_logic_vector(2 DOWNTO 0);
SIGNAL DE_d_Rdst2, DE_q_Rdst2 : std_logic_vector(2 DOWNTO 0);
----------------------------------------------------------------------------------------
--EXECUTE MEMORY BUFFER SIGNALS
SIGNAL EM_q_WB_signals : std_logic_vector(4 DOWNTO 0);
SIGNAL EM_q_memory_signals : std_logic_vector(6 DOWNTO 0); 
SIGNAL EM_d_data1, EM_q_data1 : std_logic_vector(31 DOWNTO 0);
SIGNAL EM_d_data2, EM_q_data2 : std_logic_vector(31 DOWNTO 0);
SIGNAL EM_d_Rdst1, EM_q_Rdst1 : std_logic_vector(2 DOWNTO 0);
SIGNAL EM_d_Rdst2, EM_q_Rdst2 : std_logic_vector(2 DOWNTO 0);
-- =====================================================================================
-- BEGINING of the progrom  ============================================================
-- =====================================================================================
BEGIN
-- =====================================================================================
-- ROM  ================================================================================
-- =====================================================================================

ROM1: ROM
PORT MAP(	rom_read, rom_address,rom_data_out);
-- =====================================================================================
-- RAM  ================================================================================
-- =====================================================================================

RAM1: RAM
PORT MAP(	ram_write,ram_read, ram_address,ram_data_in,ram_data_out);

-- =====================================================================================
-- 3 one bit buffers  ==================================================================
-- =====================================================================================
rti_opcode<= (opcode(4)and (not opcode(3)) and  opcode(2) and opcode(1) and (not opcode(0)) );
ret_opcode<= (opcode(4)and (not opcode(3)) and  opcode(2) and (not opcode(1)) and opcode(0) );
rti_or_ret<= ret_opcode or rti_opcode;
----------------------------------------------------------------------------------------
INT_BIT: one_bit_buffer
PORT MAP(	CLK,RST,INT,clr_int,int_bit_out);
RBIT: one_bit_buffer
PORT MAP(	CLK,RST,rti_or_ret, clr_rbit,rbit_out);
INT_PUSH_BIT: one_bit_buffer
PORT MAP(	CLK,RST,int_push_flags,int_push_bit_out,int_push_bit_out);

-- =====================================================================================
-- Control Unit  =======================================================================
-- =====================================================================================

CU: control_unit
port MAP (      RST, OPCODE,
		alu_operation,
		one_src, input_port,
		enable_temp2,
		cu_s0,cu_s1,			--alu ops
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

-- ROM connections =====================================================================
rom_read<='1';
rom_address<=instruction_address(10 downto 0);
mux_rom_fd_int: mux_2X1
GENERIC MAP(16)
PORT MAP(rom_data_out,"1011100000000000",FD_d_instruction,int_bit_out);
opcode<=FD_d_instruction(15 downto 11);
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

--========================================================================================
--FETCH DECODE BUFFER=====================================================================
--========================================================================================

fdbuff : FD_buffer PORT MAP(CLK, RST, FD_Enable, FD_Flush, FD_d_instruction, FD_q_instruction,
 	FD_d_not_taken_address, FD_q_not_taken_address, FD_d_predicted_state, FD_q_predicted_state,
	FD_d_state_address, FD_q_state_address);

--========================================================================================
--DECODE EXCUTE BUFFER====================================================================
--========================================================================================
DE_d_WB_signals <= write_back&swap&output_port&rti_pop_flags&int_push_flags;
DE_d_memory_signals <= enable_mem&read_write&enable_stack&push_pop&mem_to_pc&clr_rbit&clr_int;
DE_d_excute_signals <= alu_operation&input_port&one_src&cu_s1&cu_s0&enable_temp2;

debuff : DE_buffer PORT MAP(CLK, RST,DE_d_WB_signals,DE_q_WB_signals,
	DE_d_memory_signals , DE_q_memory_signals,
	DE_d_excute_signals , DE_q_excute_signals, DE_d_data1, DE_q_data1, DE_d_data2, DE_q_data2,
	DE_d_Rsrc1, DE_q_Rsrc1, DE_d_Rsrc2, DE_q_Rsrc2, DE_d_Rdst1, DE_q_Rdst1, DE_d_Rdst2, DE_q_Rdst2);

--========================================================================================
--EXECUTE MEMORY BUFFER ========================================================================
--========================================================================================
embuff : EM_buffer
PORT MAP(
	Clk,RST,DE_q_WB_signals, EM_q_WB_signals,DE_q_memory_signals,EM_q_memory_signals,
	EM_d_data1,EM_q_data1,EM_d_data2,EM_q_data2,EM_d_Rdst1,EM_q_Rdst1,EM_d_Rdst2,EM_q_Rdst2
	);


--========================================================================================
-- Memory Signals Order
-- clr_int 0
-- clr_rbit 1
-- mem_to_pc 2
-- push_pop 3
-- enable_stack 4
-- read_write 5
-- enable_mem 6
--========================================================================================
-- Write Back Signals Order
-- int_push_flags 0
-- rti_pop_flags 1
-- output_port 2
-- swap 3
-- write_back 4
--========================================================================================

--========================================================================================
--STACK POINTER CONNECTIONS ==============================================================
--========================================================================================
connect_memory_pc <= EM_q_memory_signals(2);
sp: stack_pointer
	PORT MAP( CLK,RST,EM_q_memory_signals(3),EM_q_memory_signals(4),sp_out
	);
--TODO: what is M_sel? is it enable_stack? What Data ? is it data2?
m_sel<=EM_q_memory_signals(4);
ram_in_mux2x1_1: mux_2X1
	GENERIC MAP(32)
	PORT MAP(
		EM_q_data2,sp_out,
		m_mux1_out,
		m_sel
	);	
ram_in_mux2x1_2: mux_2X1
	GENERIC MAP(32)
	PORT MAP(
		m_mux1_out,"00000000000000000000000000000010",
		m_mux2_out,
		clr_int
	);
ram_in_mux2x1_3: mux_2X1
	GENERIC MAP(32)
	PORT MAP(
		m_mux2_out,"00000000000000000000000000000000",
		ram_address,
		RST
	);
ram_read <= (EM_q_memory_signals(6) and not EM_q_memory_signals(5)) or RST;
ram_write <= EM_q_memory_signals(6) and EM_q_memory_signals(5);
address_loaded_from_memory<=ram_data_out;


END a_main;