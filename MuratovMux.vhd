LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;

ENTITY MuratovMux IS
	GENERIC ( N : INTEGER := 32 );
	PORT (
		a, b : IN STD_LOGIC_VECTOR(N-1 DOWNTO 0);
		s : IN STD_LOGIC;
		z : OUT STD_LOGIC_VECTOR(N-1 DOWNTO 0)
	);
END MuratovMux;

ARCHITECTURE ARCH OF MuratovMux IS
	
BEGIN

	z <= b WHEN s = '1' ELSE a;
		
END ARCH;