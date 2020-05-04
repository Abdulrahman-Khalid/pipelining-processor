LIBRARY IEEE;
USE IEEE.std_logic_1164.all;

ENTITY register_files IS
GENERIC ( n : integer := 32);
PORT( Clk,Rst,wb_signal,swap_signal : IN std_logic;
	    	write_port_data1,write_port_data2 : IN std_logic_vector(n-1 DOWNTO 0);
	    	write_port_address1,write_port_address2 : IN std_logic_vector(2 DOWNTO 0);
	    	read_port_data1,read_port_data2,read_port_data3 : OUT std_logic_vector(n-1 DOWNTO 0);
	    	read_port_address1,read_port_address2,read_port_address3 : IN std_logic_vector(2 DOWNTO 0)
);
	
END register_files;
ARCHITECTURE a_register_files OF register_files IS
COMPONENT register_nbits IS
GENERIC ( n : integer := 32);
PORT( Clk,Rst : IN std_logic;
	d1,d2 : IN std_logic_vector(n-1 DOWNTO 0);
	q : OUT std_logic_vector(n-1 DOWNTO 0);
 	enable1,enable2,wb_signal,swap_signal: in std_logic
);
END COMPONENT;
COMPONENT decoder IS
PORT(  d_input  : IN std_logic_vector(2 DOWNTO 0);
	d_enable: IN std_logic;
       d_output : OUT std_logic_vector(7 downto 0));
END COMPONENT;

COMPONENT tristate IS
GENERIC ( n : integer := 32);
PORT(  input  : IN std_logic_vector(n-1 DOWNTO 0);
       enable : IN std_logic;
       output : OUT std_logic_vector(n-1 DOWNTO 0));
END COMPONENT;

-- =================
signal  r_port1,r_port2,r_port3,w_port1,w_port2: std_logic_vector(7 downto 0);
type mySignal is array (0 to 7) of std_logic_vector(31 downto 0);
signal regiTri: mySignal;
BEGIN 

	-- Define decoders to be the enable of the tristate buffers for the specific register for each read port
	read_port1_decoder : decoder port map(read_port_address1,'1',r_port1);
	read_port2_decoder : decoder port map(read_port_address2,'1',r_port2);
	read_port3_decoder : decoder port map(read_port_address3,'1',r_port3);
	-- Define decoder to identify which registe to write to in each write port
	write_port1_decoder : decoder port map(write_port_address1,'1',w_port1);	
	write_port2_decoder : decoder port map(write_port_address2,'1',w_port2);

	-- Define registers R0 to R7, Defines Tri state buffers for read port1
	loop1: FOR i IN 0 TO 7 GENERATE
		regs: register_nbits PORT MAP(Clk,Rst,write_port_data1,write_port_data2,regiTri(i),w_port1(i),w_port2(i),wb_signal,swap_signal);
		tristatebuffers_read_port1: tristate PORT MAP(regiTri(i),r_port1(i),read_port_data1);
	END GENERATE loop1;

	-- Define tristate buffers for second port
	loop2: FOR i IN 0 TO 7 GENERATE
		tristatebuffers_read_port2: tristate PORT MAP(regiTri(i),r_port2(i),read_port_data2);
	END GENERATE loop2;

	-- Define tristate buffers for third port
	loop3: FOR i IN 0 TO 7 GENERATE
		tristatebuffers_read_port2: tristate PORT MAP(regiTri(i),r_port3(i),read_port_data3);
	END GENERATE loop3;

END a_register_files;