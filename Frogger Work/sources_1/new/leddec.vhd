LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;

ENTITY leddec IS
	PORT (
		dig : IN STD_LOGIC_VECTOR (1 DOWNTO 0);
		f_data : IN STD_LOGIC_VECTOR (15 DOWNTO 0);
		anode : OUT STD_LOGIC_VECTOR (3 DOWNTO 0);
		seg : OUT STD_LOGIC_VECTOR (6 DOWNTO 0)
	);
END leddec;

ARCHITECTURE Behavioral OF leddec IS
SIGNAL data : std_logic_vector(3 downto 0);
BEGIN
    data <= f_data(3 DOWNTO 0) WHEN dig = "00" ELSE

			   f_data(7 DOWNTO 4) WHEN dig = "01" ELSE

			   f_data(11 DOWNTO 8) WHEN dig = "10" ELSE

			   f_data(15 DOWNTO 12);
	-- Turn on segments corresponding to 4-bit data word
	seg <= "0000001" WHEN data = "0000" ELSE --0
	       "1001111" WHEN data = "0001" ELSE --1
	       "0010010" WHEN data = "0010" ELSE --2
	       "0000110" WHEN data = "0011" ELSE --3
	       "1001100" WHEN data = "0100" ELSE --4
	       "0100100" WHEN data = "0101" ELSE --5
	       "0100000" WHEN data = "0110" ELSE --6
	       "0001111" WHEN data = "0111" ELSE --7
	       "0000000" WHEN data = "1000" ELSE --8
	       "0000100" WHEN data = "1001" ELSE --9
	       "0001000" WHEN data = "1010" ELSE --A
	       "1100000" WHEN data = "1011" ELSE --B
	       "0110001" WHEN data = "1100" ELSE --C
	       "1000010" WHEN data = "1101" ELSE --D
	       "0110000" WHEN data = "1110" ELSE --E
	       "0111000" WHEN data = "1111" ELSE --F
	       "1111111";
	-- Turn on anode of 7-segment display addressed by 2-bit digit selector dig
	anode <= "1110" WHEN dig = "00" ELSE --0
	         "1101" WHEN dig = "01" ELSE --1
	         "1011" WHEN dig = "10" ELSE --2
	         "0111" WHEN dig = "11" ELSE --3
	         "1111";
	        
END Behavioral;