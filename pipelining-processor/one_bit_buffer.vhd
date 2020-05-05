Library ieee;
use ieee.std_logic_1164.all;

entity one_bit_buffer is
    port (      clk,rst,set,input	: in std_logic;
		output	: out std_logic);
end entity;

Architecture behavioural of one_bit_buffer is

 
    begin
    	
        process (clk,set,rst) 
        begin
	if rst = '1' then
		output <= '0';
	elsif rising_edge(clk) then
		if set = '1' then
			output<= input;
		end if;
	end if;


        end process;

end Architecture;
