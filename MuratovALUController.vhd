LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;

ENTITY MuratovALUController IS
	PORT (
		muratov_alu_control : IN STD_LOGIC_VECTOR(7 DOWNTO 0);
		muratov_alu_codes : OUT STD_LOGIC_VECTOR(5 DOWNTO 0)
	);
END MuratovALUController;

ARCHITECTURE ARCH OF MuratovALUController IS

BEGIN

	PROCESS(muratov_alu_control)
	BEGIN
		CASE muratov_alu_control(7 DOWNTO 6) IS
			WHEN "00" => -- lw, sw
				muratov_alu_codes <= "100000";
			WHEN "01" => -- beq, bne
				muratov_alu_codes <= "100010";
			WHEN "10" =>
				muratov_alu_codes <= muratov_alu_control(5 DOWNTO 0);
			WHEN "11" =>
				CASE muratov_alu_control(5 DOWNTO 0) IS
					WHEN "001000" => -- addi
						muratov_alu_codes <= "100000";
					WHEN "001001" => -- addiu
						muratov_alu_codes <= "100001";
					WHEN "001100" => -- andi
						muratov_alu_codes <= "100100";
					WHEN "001101" => -- ori
						muratov_alu_codes <= "100101";
					WHEN OTHERS =>
						muratov_alu_codes <= "UUUUUU";
				END CASE;
			WHEN OTHERS =>
				muratov_alu_codes <= "UUUUUU";
		END CASE;
	END PROCESS;

END ARCH;