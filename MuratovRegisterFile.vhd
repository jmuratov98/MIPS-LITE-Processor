LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.NUMERIC_STD.ALL;

USE WORK.MURATOV_MIPS.ALL;

ENTITY MuratovRegisterFile IS
	PORT (
		muratov_clock, muratov_write_enable : IN STD_LOGIC;
		muratov_read_register_1, muratov_read_register_2, muratov_write_register : IN STD_LOGIC_VECTOR(4 DOWNTO 0);
		muratov_write_data : IN STD_LOGIC_VECTOR(31 DOWNTO 0);
		muratov_read_data_1, muratov_read_data_2 : OUT STD_LOGIC_VECTOR(31 DOWNTO 0)
	);
END MuratovRegisterFile;

ARCHITECTURE ARCH OF MuratovRegisterFile IS

	SIGNAL muratov_registers : mem_array := (OTHERS => (OTHERS => '0'));

BEGIN

	muratov_read_data_1 <= muratov_registers(TO_INTEGER(UNSIGNED(muratov_read_register_1)));
	muratov_read_data_2 <= muratov_registers(TO_INTEGER(UNSIGNED(muratov_read_register_2)));
	
	PROCESS(muratov_clock)
	BEGIN
		IF(muratov_clock = '1' AND muratov_clock'event AND muratov_write_enable = '1') THEN
			muratov_registers(TO_INTEGER(UNSIGNED(muratov_write_register))) <= muratov_write_data;
		END IF;
	END PROCESS;

END ARCH;