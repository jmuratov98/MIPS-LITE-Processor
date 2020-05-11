LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.NUMERIC_STD.ALL;

USE WORK.MURATOV_MIPS.ALL;

ENTITY MuratovRAM IS
	PORT (
		muratov_clock, muratov_write_enable, muratov_read_enable : IN STD_LOGIC;
		muratov_mem_address, muratov_write_data : IN STD_LOGIC_VECTOR(31 DOWNTO 0);
		muratov_read_data : OUT STD_LOGIC_VECTOR(31 DOWNTO 0)
	);
END MuratovRAM;

ARCHITECTURE ARCH OF MuratovRAM IS

	SIGNAL muratov_ram : mem_array := (OTHERS => (OTHERS => '0'));

BEGIN

	muratov_read_data <= muratov_ram(TO_INTEGER(UNSIGNED(muratov_mem_address(6 DOWNTO 2)))) WHEN muratov_read_enable = '1' ELSE x"00000000";
	
	PROCESS(muratov_clock)
	BEGIN
		IF (muratov_clock = '1' AND muratov_clock'event AND muratov_write_enable = '1') THEN
			muratov_ram(TO_INTEGER(UNSIGNED(muratov_mem_address(6 DOWNTO 2)))) <= muratov_write_data;
		END IF;
	END PROCESS;

END ARCH;