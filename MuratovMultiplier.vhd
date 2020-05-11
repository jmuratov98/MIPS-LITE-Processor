LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.NUMERIC_STD.ALL;

ENTITY MuratovMultiplier IS
	GENERIC ( N : INTEGER := 32 );
	PORT (
		a, b : IN STD_LOGIC_VECTOR(N-1 DOWNTO 0);
		sign : IN STD_LOGIC;
		s : OUT STD_LOGIC_VECTOR((2*N)-1 DOWNTO 0)
	);
END MuratovMultiplier;

ARCHITECTURE ARCH OF MuratovMultiplier IS
	
BEGIN

	s <= STD_LOGIC_VECTOR(UNSIGNED(a) * UNSIGNED(b)) WHEN sign = '0' ELSE STD_LOGIC_VECTOR(SIGNED(a) * SIGNED(b));
		
END ARCH;