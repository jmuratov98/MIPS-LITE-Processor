LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;

ENTITY TestBenchMIPS IS
END TestBenchMIPS;

ARCHITECTURE ARCH OF TestBenchMIPS IS

	-- Component Declaration for the single-cycle MIPS Processor in VHDL
	COMPONENT MuratovMain IS
		PORT (
			muratov_clock : IN STD_LOGIC;
			muratov_alu_res : OUT STD_LOGIC_VECTOR(31 DOWNTO 0);
			muratov_pc_out : OUT STD_LOGIC_VECTOR(31 DOWNTO 0)
		);
	END COMPONENT;
   
	--Inputs
	signal clk : std_logic := '0';
	--Outputs
	signal pc_out : std_logic_vector(31 downto 0);
	signal alu_result : std_logic_vector(31 downto 0);
	-- Clock period definitions
	constant clk_period : time := 10 ns;

BEGIN
	-- Instantiate the for the single-cycle MIPS Processor in VHDL
	uut: MuratovMain
	PORT MAP (
		muratov_clock => clk,
		muratov_pc_out => pc_out,
		muratov_alu_res => alu_result
	);

	-- Clock process definitions
	clk_process :process
	begin
		clk <= '0';
		wait for clk_period/2;
		clk <= '1';
		wait for clk_period/2;
	end process;

END ARCH;