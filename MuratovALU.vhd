LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.STD_LOGIC_UNSIGNED.ALL;
USE IEEE.STD_LOGIC_SIGNED.ALL;
USE IEEE.NUMERIC_STD.ALL;

ENTITY MuratovALU IS
	PORT (
		muratov_clock : IN STD_LOGIC;
		muratov_alu_codes : IN STD_LOGIC_VECTOR(5 DOWNTO 0);
		muratov_a, muratov_b : IN STD_LOGIC_VECTOR(31 DOWNTO 0);
		muratov_result : OUT STD_LOGIC_VECTOR(31 DOWNTO 0);
		muratov_overflow, muratov_zero : OUT STD_LOGIC
	);
END MuratovALU;

ARCHITECTURE ARCH OF MuratovALU IS

	-----------------------------------------------------------------
	-- Signals
	-----------------------------------------------------------------
	SIGNAL register_result_1 : STD_LOGIC_VECTOR(31 DOWNTO 0) := (OTHERS => '0');
	SIGNAL register_result_2 : STD_LOGIC_VECTOR(31 DOWNTO 0) := (OTHERS => '0');

	SIGNAL high_register : STD_LOGIC_VECTOR(31 DOWNTO 0) := (OTHERS => '0');
	SIGNAL low_register : STD_LOGIC_VECTOR(31 DOWNTO 0) := (OTHERS => '0');

	SIGNAL sum : STD_LOGIC_VECTOR(32 DOWNTO 0) := (OTHERS => '0');
	SIGNAL product : STD_LOGIC_VECTOR(63 DOWNTO 0) := (OTHERS => '0');
	
BEGIN
	
	-- High and low registers for multiplication and division
	HIGH_LOW_REGS : PROCESS(muratov_clock)
	BEGIN
		IF (muratov_clock = '1' AND muratov_clock'event) THEN
			IF (SIGNED(muratov_alu_codes) = "011000" OR SIGNED(muratov_alu_codes) = "011001" OR SIGNED(muratov_alu_codes) = "011010" OR SIGNED(muratov_alu_codes) = "011011") THEN
				high_register <= register_result_2;
				low_register <= register_result_1;
			END IF;
		END IF;
	END PROCESS;

	PROCESS(muratov_alu_codes, muratov_a, muratov_b, sum, product)
	BEGIN
		muratov_overflow <= '0';
		muratov_zero <= '0';
		sum <= (others => '0');
		product <= (OTHERS => '0');
	
		CASE muratov_alu_codes IS		
			WHEN "100000" => -- add
				sum <= STD_LOGIC_VECTOR(SIGNED(muratov_a(31) & muratov_a) + SIGNED(muratov_b(31) & muratov_b));
				muratov_overflow <= sum(32) xor sum(31) xor muratov_a(31) xor muratov_b(31);
				muratov_result <= sum(31 DOWNTO 0);
			WHEN "100001" => -- addu
				sum <= STD_LOGIC_VECTOR(UNSIGNED('0' & muratov_a) + UNSIGNED('0' & muratov_b));
				muratov_overflow <= sum(32) xor sum(31) xor muratov_a(31) xor muratov_b(31);
				muratov_result <= sum(31 DOWNTO 0);
			WHEN "100100" => -- and
				muratov_result <= muratov_a and muratov_b;
			WHEN "100111" => -- nor
				muratov_result <= muratov_a nor muratov_b;
			WHEN "100101" => -- or
				muratov_result <= muratov_a or muratov_b;
			WHEN "101010" => -- slt
				IF (SIGNED(muratov_a) < SIGNED(muratov_b)) THEN muratov_result <= x"00000001"; ELSE muratov_result <= X"00000000"; END IF;
			WHEN "101011" => -- sltu
				IF (UNSIGNED(muratov_a) < UNSIGNED(muratov_b)) THEN muratov_result <= x"00000001"; ELSE muratov_result <= X"00000000"; END IF;
			WHEN "000000" => -- sll
				muratov_result <= STD_LOGIC_VECTOR(UNSIGNED(muratov_a) sll 1);
			WHEN "000010" => -- srl
				muratov_result <= STD_LOGIC_VECTOR(UNSIGNED(muratov_a) srl 1);
			WHEN "100010" => -- sub
				sum <= STD_LOGIC_VECTOR(SIGNED(muratov_a(31) & muratov_b) - SIGNED(muratov_a(31) & muratov_b));
				muratov_overflow <= sum(32) xor sum(31) xor muratov_a(31) xor muratov_b(31);
				muratov_result <= sum(31 DOWNTO 0);
			WHEN "100011" => -- subu
				sum <= STD_LOGIC_VECTOR(UNSIGNED('0' & muratov_a) + UNSIGNED('0' & muratov_b));
				muratov_overflow <= sum(32) xor sum(31) xor muratov_a(31) xor muratov_b(31);
				muratov_result <= sum(31 DOWNTO 0);
			WHEN "011010" => -- div
				register_result_2 <= STD_LOGIC_VECTOR(SIGNED(muratov_a) rem SIGNED(muratov_b));
				register_result_1 <= STD_LOGIC_VECTOR(SIGNED(muratov_a) / SIGNED(muratov_b));
			WHEN "011011" => -- divu
				register_result_2 <= STD_LOGIC_VECTOR(UNSIGNED(muratov_a) rem UNSIGNED(muratov_b));
				register_result_1 <= STD_LOGIC_VECTOR(UNSIGNED(muratov_a) / UNSIGNED(muratov_b));
			WHEN "010000" => -- mfhi
				muratov_result <= high_register;
			WHEN "010010" => -- mflo
				muratov_result <= low_register;
			WHEN "011000" => -- mult
				product <= STD_LOGIC_VECTOR(SIGNED(muratov_a) * SIGNED(muratov_b));
				register_result_2 <= product(63 DOWNTO 32);
				register_result_1 <= product(31 DOWNTO 0);
			WHEN "011001" => -- multu
				product <= STD_LOGIC_VECTOR(UNSIGNED(muratov_a) * UNSIGNED(muratov_b));
				register_result_2 <= product(63 DOWNTO 32);
				register_result_1 <= product(31 DOWNTO 0);
			WHEN OTHERS =>
				muratov_result <= (OTHERS => '0');
		END CASE;
	END PROCESS;

END ARCH;