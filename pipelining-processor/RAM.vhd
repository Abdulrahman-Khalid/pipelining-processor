LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.numeric_std.all;
use STD.TEXTIO.all;

ENTITY RAM IS
	GENERIC (wordSize : integer := 16; addressWidth: integer := 12; RAMSize: integer := 4096);
	PORT(	
		W  : IN std_logic;
		R  : IN std_logic;
		address : IN  std_logic_vector(addressWidth - 1 DOWNTO 0);
		dataIn  : IN  std_logic_vector(wordSize - 1 DOWNTO 0);
		dataOut  : OUT  std_logic_vector(wordSize - 1 DOWNTO 0));
END ENTITY RAM;

ARCHITECTURE RAM_arch OF RAM IS
    TYPE RAMType IS ARRAY(RAMSize - 1 DOWNTO 0) of std_logic_vector(wordSize - 1 DOWNTO 0);
    
	-- Input RAM Data from Assembler Program

  	IMPURE FUNCTION fillRAM RETURN RAMType is
		VARIABLE RAMContent : RAMType;
		VARIABLE textLine : line;
		VARIABLE c : character;
		VARIABLE count: integer;
		VARIABLE i: integer;
		VARIABLE binaryTextLine: std_logic_vector(wordSize - 1 DOWNTO 0);
		FILE RAMFile: text;
	BEGIN
		 file_open(RAMFile, "out.mem",  read_mode);
		 count := 0;
  		 WHILE not ENDFILE(RAMFile) LOOP
     			readline(RAMFile, textLine);
			read(textLine, c);
			read(textLine, c);
			read(textLine, c);
			read(textLine, c);
			read(textLine, c);
			for i in RAMContent(count)'range loop
			read(textLine, c);
			case c is
			when 'X' => binaryTextLine := binaryTextLine(wordSize - 2 downto 0) & 'X';
			when '0' => binaryTextLine := binaryTextLine(wordSize - 2 downto 0) & '0';
			when '1' => binaryTextLine := binaryTextLine(wordSize - 2 downto 0) & '1';
			when others => binaryTextLine := binaryTextLine(wordSize - 2 downto 0) & '0';
			end case;
			end loop;
			RAMContent(count) := binaryTextLine(wordSize - 1 DOWNTO 0);
			count := count + 1;
  		 END LOOP;
		 file_close(RAMFile);
  		 RETURN RAMContent;
	END FUNCTION fillRAM;
SIGNAL RAM : RAMType := fillRAM;
BEGIN
PROCESS(W, R) IS
	BEGIN
	IF W = '1' THEN  
		RAM(to_integer(unsigned(address))) <= dataIn;
	ELSIF R = '1' THEN
		dataOut <= RAM(to_integer(unsigned(address)));
	END IF;
END PROCESS;
END RAM_arch;
