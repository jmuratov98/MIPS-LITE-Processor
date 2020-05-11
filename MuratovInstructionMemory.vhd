LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.NUMERIC_STD.ALL;

USE WORK.MURATOV_MIPS.ALL;

ENTITY MuratovInstructionMemory IS
	PORT (
		muratov_read_address : IN STD_LOGIC_VECTOR(31 DOWNTO 0);
		muratov_instruction : OUT STD_LOGIC_VECTOR(31 DOWNTO 0)
	);
END MuratovInstructionMemory;

ARCHITECTURE ARCH OF MuratovInstructionMemory IS

	SIGNAL muratov_rom : mem_array := (
		"00100000000000000000000000000001", 			-- addi $r0, $r0, 1
		"00100000000000010000000000000010", 			-- addi $r1, $r0, 2
		"00000000000000010001000000100000",				-- add $r2, r0, $r1
		"00000000001000100001100000100000",				-- add $r3, r1, $r2
		"00000000010000110010000000100000",				-- add $r4, r2, $r3
		"00000000011001000000000000011000",				-- mult $r3, $r4
		"00000000000000000010100000010010",				-- mflo $r5
		OTHERS => (OTHERS => '0')
	);

BEGIN

	muratov_instruction <= muratov_rom(TO_INTEGER(UNSIGNED(muratov_read_address(6 DOWNTO 2)))) WHEN muratov_read_address < x"0000001f" ELSE x"00000000";

END ARCH;