LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.STD_LOGIC_UNSIGNED.ALL;

ENTITY MuratovAdder IS
	GENERIC ( N : INTEGER := 32 );
	PORT (
		a, b : IN STD_LOGIC_VECTOR(N-1 DOWNTO 0);
		carry_in : IN STD_LOGIC;
		s : OUT STD_LOGIC_VECTOR(N-1 DOWNTO 0);
		carry_out : OUT STD_LOGIC
	);
END MuratovAdder;

ARCHITECTURE ARCH OF MuratovAdder IS
	
	SIGNAL temp : STD_LOGIC_VECTOR(N DOWNTO 0);
	
BEGIN

  PROCESS(carry_in, a, b)
  BEGIN
    temp <= ( '0' & a ) + ( '0' & b ) + carry_in;
    s <= temp(N-1 DOWNTO 0);
    carry_out <= temp(N);
  END PROCESS;
		
END ARCH;