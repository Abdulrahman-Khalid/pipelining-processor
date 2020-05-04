LIBRARY IEEE;
USE IEEE.std_logic_1164.all;

-- Full adder Entity
ENTITY FullAdder IS  
     PORT( 
            a,b,cin : IN STD_LOGIC;
            s,cout : OUT STD_LOGIC
          );
END FullAdder;

-- Full adder Architecture
ARCHITECTURE FullAdderArch OF FullAdder IS
    BEGIN
         PROCESS (a,b,cin)
              BEGIN 
              s <= a XOR b XOR cin;
              cout <= (a AND b) or (cin AND (a XOR b));
         END PROCESS;
END FullAdderArch;
