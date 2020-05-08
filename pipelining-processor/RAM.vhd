LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.numeric_std.all;
use STD.TEXTIO.all;

ENTITY RAM IS
	GENERIC (wordSize : integer := 16; addressWidth: integer := 32; RAMSize: integer := 2**20-1); --2,147,483,647 == 2^31-1
	PORT(	
		W  : IN std_logic;
		R  : IN std_logic;
		address : IN  std_logic_vector(addressWidth - 1 DOWNTO 0);
		dataIn  : IN  std_logic_vector(2*wordSize - 1 DOWNTO 0);
		dataOut  : OUT  std_logic_vector(2*wordSize - 1 DOWNTO 0));
END ENTITY RAM;

ARCHITECTURE RAM_arch OF RAM IS
    TYPE RAMType IS ARRAY(RAMSize DOWNTO 0) of std_logic_vector(wordSize - 1 DOWNTO 0);
    
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
  		 WHILE count/=4 LOOP
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
PROCESS(W, R,address) IS
	BEGIN
	IF W = '1' THEN  
		RAM(to_integer(unsigned(address(30 downto 0)))) <= dataIn(15 downto 0);
		RAM(1+to_integer(unsigned(address(30 downto 0)))) <= dataIn(31 downto 16);
	ELSIF R = '1' THEN
		dataOut(15 downto 0) <= RAM(to_integer(unsigned(address(30 downto 0))));
		dataOut(31 downto 16) <= RAM(1+to_integer(unsigned(address(30 downto 0))));
	END IF;
END PROCESS;
END RAM_arch;
