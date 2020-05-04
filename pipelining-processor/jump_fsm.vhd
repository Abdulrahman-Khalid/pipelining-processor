Library ieee;
use ieee.std_logic_1164.all;

entity jump_fsm is
    port (      clk,rst: in std_logic;
		current_state: in std_logic_vector(1 DOWNTO 0);
		input: in std_logic;
           	output: out std_logic_vector(1 DOWNTO 0));
end entity;

Architecture moore_fsm of jump_fsm is
        signal next_state : std_logic_vector(1 DOWNTO 0);
    begin
    
        -- Produce next state 
        process (current_state,input,clk) 
        begin
	if rising_edge(clk) then
            case current_state is
                when "11" =>
                    if input = '1' then output <= "11"; else output <= "10"; end if;
                when "10" =>
                    if input = '1' then output <= "11"; else output <= "01"; end if;
                when "01" =>
                    if input = '1' then output <= "10"; else output <= "00"; end if;
                when "00" =>
                    if input = '1' then output <= "01"; else output <= "00"; end if;
		when others =>
		    output <= "11";
            end case;
	end if;
        end process;

end Architecture;