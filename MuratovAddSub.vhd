LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.NUMERIC_STD.ALL;

ENTITY MuratovAddSub IS
	GENERIC ( N : INTEGER := 32 );
	PORT (
		a, b : IN STD_LOGIC_VECTOR(N-1 DOWNTO 0);
		sub : IN STD_LOGIC;
		s : OUT STD_LOGIC_VECTOR(N-1 DOWNTO 0);
		zero, overflow, negative : OUT STD_LOGIC
	);
END MuratovAddSub;

ARCHITECTURE ARCH OF MuratovAddSub IS

	COMPONENT MuratovAdder IS
		GENERIC ( N : INTEGER := 32 );
		PORT (
			a, b : IN STD_LOGIC_VECTOR(N-1 DOWNTO 0);
			carry_in : IN STD_LOGIC;
			s : OUT STD_LOGIC_VECTOR(N-1 DOWNTO 0);
			carry_out : OUT STD_LOGIC
		);
	END COMPONENT;
	
	SIGNAL sub_vec : STD_LOGIC_VECTOR(N-1 DOWNTO 0) := (OTHERS => '0');
	
	SIGNAL one_comp_b : STD_LOGIC_VECTOR(N-1 DOWNTO 0) := (OTHERS => '0');
	
	SIGNAL result : STD_LOGIC_VECTOR(N-1 DOWNTO 0);
	SIGNAL carry_out : STD_LOGIC;
	
	CONSTANT c_zero : STD_LOGIC_VECTOR(N-1 DOWNTO 0) := (OTHERS => '0');
	
BEGIN

	sub_vec <= (OTHERS => sub);
	
	one_comp_b <= b xor sub_vec;
	
	ADDER : MuratovAdder PORT MAP( a, one_comp_b, sub, result, carry_out );
	
	s <= result;
	zero <= '1' WHEN result = c_zero ELSE '0';
	overflow <= carry_out xor result(N-1) xor a(N-1) xor b(N-1);
	negative <= result(N-1);
		
END ARCH;