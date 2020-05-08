LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.numeric_std.all;
use STD.TEXTIO.all;

ENTITY ROM IS
	GENERIC (wordSize : integer := 16; addressWidth: integer := 11; ROMSize: integer := 2048);
	PORT(	
		enable  : IN std_logic;
		address : IN  std_logic_vector(addressWidth - 1 DOWNTO 0);
		dataOut  : OUT  std_logic_vector(wordSize - 1 DOWNTO 0));
END ENTITY ROM;

ARCHITECTURE ROM_arch OF ROM IS
    TYPE ROMType IS ARRAY(ROMSize - 1 DOWNTO 0) of std_logic_vector(wordSize - 1 DOWNTO 0);
    
	-- Input ROM Data from Assembler Program

  	IMPURE FUNCTION fillROM RETURN ROMType is
		VARIABLE ROMContent : ROMType;
		VARIABLE textLine : line;
		VARIABLE c : character;
		VARIABLE count: integer;
		VARIABLE i: integer;
		VARIABLE binaryTextLine: std_logic_vector(wordSize - 1 DOWNTO 0);
		FILE ROMFile: text;
	BEGIN
		 file_open(ROMFile, "out.mem",  read_mode);
		 count := 0;
  		 WHILE not ENDFILE(ROMFile) LOOP
			readline(ROMFile, textLine);
			read(textLine, c);
			read(textLine, c);
			read(textLine, c);
			read(textLine, c);
			read(textLine, c);
			for i in ROMContent(count)'range loop
			read(textLine, c);
			case c is
			when 'X' => binaryTextLine := binaryTextLine(wordSize - 2 downto 0) & 'X';
			when '0' => binaryTextLine := binaryTextLine(wordSize - 2 downto 0) & '0';
			when '1' => binaryTextLine := binaryTextLine(wordSize - 2 downto 0) & '1';
			when others => binaryTextLine := binaryTextLine(wordSize - 2 downto 0) & '0';
			end case;
			end loop;
			ROMContent(count) := binaryTextLine(wordSize - 1 DOWNTO 0);
			count := count + 1;
  		 END LOOP;
		 file_close(ROMFile);
  		 RETURN ROMContent;
	END FUNCTION fillROM;
SIGNAL ROM : ROMType := fillROM;
BEGIN
PROCESS(enable,address) IS
	BEGIN
	IF enable = '1' THEN
		dataOut <= ROM(to_integer(unsigned(address)));
	END IF;
END PROCESS;
END ROM_arch;
