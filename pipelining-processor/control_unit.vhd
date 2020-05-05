Library ieee;
use ieee.std_logic_1164.all;

entity control_unit is
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
end entity;

Architecture behavioural of control_unit is

 
    begin
    	
        process (input,rst) 
        begin
		--reset all signals
		one_src<='0';		input_port<='0';	enable_temp2<='0';
		sel_alu<='0';		sel_data1<='0';		sel_data2<='0';
		sel_inputport<='0';	enable_mem<='0';	read_write<='0';
		enable_stack<='0';	push_pop<='0';		mem_to_pc<='0';
		clr_rbit<='0';		clr_int<='0';		write_back<='0';
		swap<='0';		rti_pop_flags<='0';	int_push_flags<='0';
		output_port<='0';
		alu_operation <= "0000";
		if rst = '0' then
		if input(4) = '0' then --Handles all ALU operations
			sel_alu <= '1';
			alu_operation <= input(3 downto 0);
			one_src <= not input(2);
			if input(3 downto 0) /= "0000" then --check for NOP
				write_back<='1';
			end if;
		elsif input = "10000" then sel_data1<='1'; output_port<='1';	--OUT
		elsif input = "10001" then input_port<='1'; write_back<='1'; 	--IN
		elsif input = "10100" then sel_data2<='1'; enable_mem<='1';	--CALL
		enable_stack<='1'; push_pop<='1'; read_write<='1';
		elsif input = "10101" then enable_mem<='1'; enable_stack<='1';	--RET
		push_pop<='0'; read_write<='0'; mem_to_pc<='1'; clr_rbit<='1';
		elsif input = "10110" then enable_mem<='1'; enable_stack<='1';	--RTI
		push_pop<='0'; read_write<='0'; mem_to_pc<='1'; clr_rbit<='1';
		rti_pop_flags<='1';
		elsif input = "10111" then enable_mem<='1'; enable_stack<='1';	--INT
		push_pop<='0'; read_write<='0'; mem_to_pc<='1'; clr_int<='1';
		int_push_flags<='1';enable_temp2<='1';
		elsif input = "11000" then sel_data1<='1'; enable_mem<='1';	--PUSH
		enable_stack<='1'; push_pop<='1'; read_write<='1';
		elsif input = "11000" then sel_data1<='1'; enable_mem<='1';	--PUSH
		enable_stack<='1'; push_pop<='1'; read_write<='1';
		elsif input = "11001" then enable_mem<='1'; enable_stack<='1'; 	--POP
		push_pop<='0'; read_write<='0'; write_back<='1';
		elsif input = "11010" then enable_mem<='1'; write_back<='1';	--LDM
		read_write<='0';
		elsif input = "11011" then enable_mem<='1'; write_back<='1';	--LDD
		read_write<='0';
		elsif input = "11100" then enable_mem<='1'; sel_data1<='1';	--STD
		read_write<='1';
		elsif input = "11101" then swap<='1'; sel_data2<='1';		--SWAP
		end if;
	end if;


        end process;

end Architecture;
