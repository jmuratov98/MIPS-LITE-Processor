LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.STD_LOGIC_UNSIGNED.ALL;
USE IEEE.NUMERIC_STD.ALL;

ENTITY MuratovMain IS
	PORT (
		muratov_clock : IN STD_LOGIC;
		muratov_alu_res : OUT STD_LOGIC_VECTOR(31 DOWNTO 0);
		muratov_pc_out : OUT STD_LOGIC_VECTOR(31 DOWNTO 0)
	);
END MuratovMain;

ARCHITECTURE ARCH OF MuratovMain IS
	
	-----------------------------------------------------------------
	-- Instruction Memory
	-----------------------------------------------------------------
	COMPONENT MuratovInstructionMemory IS
		PORT (
			muratov_read_address : IN STD_LOGIC_VECTOR(31 DOWNTO 0);
			muratov_instruction : OUT STD_LOGIC_VECTOR(31 DOWNTO 0)
		);
	END COMPONENT;
	
	-----------------------------------------------------------------
	-- Controller for the processing unit
	-----------------------------------------------------------------
	COMPONENT MuratovController IS
		PORT (
			muratov_opcode : IN STD_LOGIC_VECTOR(5 DOWNTO 0);
			muratov_function : IN STD_LOGIC_VECTOR(5 DOWNTO 0);
			muratov_alu_control : OUT STD_LOGIC_VECTOR(7 DOWNTO 0);
			branch, immediate_select, sign_extend, read_mem, write_mem, mem_to_reg, register_destination, reg_write, shift : OUT STD_LOGIC
		);
	END COMPONENT;

	-----------------------------------------------------------------
	-- Multiplexer
	-----------------------------------------------------------------	
	COMPONENT MuratovMux IS
		GENERIC ( N : INTEGER := 32 );
		PORT (
			a, b : IN STD_LOGIC_VECTOR(N-1 DOWNTO 0);
			s : IN STD_LOGIC;
			z : OUT STD_LOGIC_VECTOR(N-1 DOWNTO 0)
		);
	END COMPONENT;

	-----------------------------------------------------------------
	-- Register File
	-----------------------------------------------------------------		
	COMPONENT MuratovRegisterFile IS
		PORT (
			muratov_clock, muratov_write_enable : IN STD_LOGIC;
			muratov_read_register_1, muratov_read_register_2, muratov_write_register : IN STD_LOGIC_VECTOR(4 DOWNTO 0);
			muratov_write_data : IN STD_LOGIC_VECTOR(31 DOWNTO 0);
			muratov_read_data_1, muratov_read_data_2 : OUT STD_LOGIC_VECTOR(31 DOWNTO 0)
		);
	END COMPONENT;
	
	-----------------------------------------------------------------
	-- Control unit for the arithmetic logic unit
	-----------------------------------------------------------------			
	COMPONENT MuratovALUController IS
		PORT (
			muratov_alu_control : IN STD_LOGIC_VECTOR(7 DOWNTO 0);
			muratov_alu_codes : OUT STD_LOGIC_VECTOR(5 DOWNTO 0)
		);
	END COMPONENT;
	
	-----------------------------------------------------------------
	-- Arithmetic Logic Unit
	-----------------------------------------------------------------			
	COMPONENT MuratovALU IS
		PORT (
			muratov_clock : IN STD_LOGIC;
			muratov_alu_codes : IN STD_LOGIC_VECTOR(5 DOWNTO 0);
			muratov_a, muratov_b : IN STD_LOGIC_VECTOR(31 DOWNTO 0);
			muratov_result : OUT STD_LOGIC_VECTOR(31 DOWNTO 0);
			muratov_overflow, muratov_zero : OUT STD_LOGIC
		);
	END COMPONENT;
	
	-----------------------------------------------------------------
	-- ADDER
	-----------------------------------------------------------------			
	COMPONENT MuratovAdder IS
		GENERIC ( N : INTEGER := 32 );
		PORT (
			a, b : IN STD_LOGIC_VECTOR(N-1 DOWNTO 0);
			carry_in : IN STD_LOGIC;
			s : OUT STD_LOGIC_VECTOR(N-1 DOWNTO 0);
			carry_out : OUT STD_LOGIC
		);
	END COMPONENT;
	
	-----------------------------------------------------------------
	-- Random Access Memory
	-----------------------------------------------------------------	
	COMPONENT MuratovRAM IS
		PORT (
			muratov_clock, muratov_write_enable, muratov_read_enable : IN STD_LOGIC;
			muratov_mem_address, muratov_write_data : IN STD_LOGIC_VECTOR(31 DOWNTO 0);
			muratov_read_data : OUT STD_LOGIC_VECTOR(31 DOWNTO 0)
		);
	END COMPONENT;
	
	-----------------------------------------------------------------
	-- Signals
	-----------------------------------------------------------------
	
	-- Program counter
	SIGNAL muratov_pc_current, muratov_pc_next, muratov_pc2 : STD_LOGIC_VECTOR(31 DOWNTO 0) := (OTHERS => '0');
	
	-- Instruction register
	SIGNAL muratov_instruction : STD_LOGIC_VECTOR(31 DOWNTO 0);

	SIGNAL muratov_opcode : STD_LOGIC_VECTOR(5 DOWNTO 0);
	SIGNAL muratov_rs : STD_LOGIC_VECTOR(4 DOWNTO 0);
	SIGNAL muratov_rt : STD_LOGIC_VECTOR(4 DOWNTO 0);
	SIGNAL muratov_rd : STD_LOGIC_VECTOR(4 DOWNTO 0);
	SIGNAL muratov_shamt : STD_LOGIC_VECTOR(4 DOWNTO 0);
	SIGNAL muratov_function_code : STD_LOGIC_VECTOR(5 DOWNTO 0);
	SIGNAL muratov_immediate : STD_LOGIC_VECTOR(15 DOWNTO 0);
	SIGNAL muratov_extended_immediate : STD_LOGIC_VECTOR(31 DOWNTO 0);
	
	-- Control signals
	SIGNAL muratov_alu_control : STD_LOGIC_VECTOR(7 DOWNTO 0);
	SIGNAL branch, immediate_select, zero_sign_extend, read_mem, write_mem, mem_to_reg, register_destination, reg_write, shift : STD_LOGIC := '0';
	SIGNAL muratov_alu_codes : STD_LOGIC_VECTOR(5 DOWNTO 0) := "000000";
	
	-- Register File
	SIGNAL register_write_dest : STD_LOGIC_VECTOR(4 DOWNTO 0);
	SIGNAL muratov_reg_1_data, muratov_reg_2_data, muratov_reg_write_data : STD_LOGIC_VECTOR(31 DOWNTO 0) := (OTHERS => '0');
	
	-- ALU
	SIGNAL muratov_alu_data_2 : STD_LOGIC_VECTOR(31 DOWNTO 0) := (OTHERS => '0');
	SIGNAL muratov_alu_result : STD_LOGIC_VECTOR(31 DOWNTO 0) := (OTHERS => '0');
	SIGNAL muratov_alu_overflow, muratov_alu_zero : STD_LOGIC;
	
	-- branching
	SIGNAL muratov_shifted_imm : STD_LOGIC_VECTOR(31 DOWNTO 0) := (OTHERS => '0');
	SIGNAL muratov_adder_res : STD_LOGIC_VECTOR(31 DOWNTO 0) := (OTHERS => '0');
	
	-- RAM
	SIGNAL mem_read_data : STD_LOGIC_VECTOR(31 DOWNTO 0);
	
	SIGNAL mux4_result : STD_LOGIC_VECTOR(31 DOWNTO 0);
	
	SIGNAL sign_extend_immediate_modelsim : STD_LOGIC_VECTOR(31 DOWNTO 0);
	SIGNAL zero_extend_immediate_modelsim : STD_LOGIC_VECTOR(31 DOWNTO 0);
	SIGNAL branch_and_alu_zero_modelsim : STD_LOGIC;
	
BEGIN

	PROGRAM_COUNTER_REGISTER : PROCESS(muratov_clock)
	BEGIN
		IF(muratov_clock = '1' AND muratov_clock'event) THEN
			muratov_pc_current <= muratov_pc_next;
		END IF;
	END PROCESS;
	
	muratov_pc2 <= muratov_pc_current + 4;

	INSTRUCTION_MEMORY : MuratovInstructionMemory PORT MAP ( muratov_pc_current, muratov_instruction );
	
	muratov_opcode <= muratov_instruction(31 DOWNTO 26);
	muratov_rs <= muratov_instruction(25 DOWNTO 21);
	muratov_rt <= muratov_instruction(20 DOWNTO 16);
	muratov_rd <= muratov_instruction(15 DOWNTO 11);
	muratov_shamt <= muratov_instruction(10 DOWNTO 6);
	muratov_function_code <= muratov_instruction(5 DOWNTO 0);
	muratov_immediate <= muratov_instruction(15 DOWNTO 0);
	
	CONTROLLER : MuratovController 
	PORT MAP ( muratov_opcode, muratov_function_code, muratov_alu_control, branch, immediate_select, zero_sign_extend, read_mem, write_mem, mem_to_reg, register_destination, reg_write, shift );
	
	REGISTER_DESTINATION_MUX : MuratovMux
	GENERIC MAP(5)
	PORT MAP (
		a => muratov_rt,
		b => muratov_rd,
		s => register_destination,
		z => register_write_dest
	);
	
	REGISTER_FILE : MuratovRegisterFile
	PORT MAP(
		muratov_clock => muratov_clock,
		muratov_write_enable => reg_write,
		muratov_read_register_1 => muratov_rs,
		muratov_read_register_2 => muratov_rt,
		muratov_write_register => register_write_dest,
		muratov_write_data => muratov_reg_write_data,
		muratov_read_data_1 => muratov_reg_1_data,
		muratov_read_data_2 => muratov_reg_2_data
	);
	
	sign_extend_immediate_modelsim <= STD_LOGIC_VECTOR(RESIZE(UNSIGNED(muratov_immediate), 32));
	zero_extend_immediate_modelsim <= STD_LOGIC_VECTOR(RESIZE(SIGNED(muratov_immediate), 32));
	SIGN_OR_ZERO_EXTEND_MUX : MuratovMux
	GENERIC MAP(32)
	PORT MAP(
		a => sign_extend_immediate_modelsim,
		b => zero_extend_immediate_modelsim,
		s => zero_sign_extend,
		z => muratov_extended_immediate
	);
	
	ALU_CONTROL_UNIT : MuratovALUController PORT MAP( muratov_alu_control, muratov_alu_codes );
	
	IMMEDIATE_OR_REGISTER_DATA_MUX : MuratovMux
	GENERIC MAP (32)
	PORT MAP(
		a => muratov_reg_2_data,
		b => muratov_extended_immediate,
		s => immediate_select,
		z => muratov_alu_data_2
	);
	
	ALU : MuratovALU
	PORT MAP(
		muratov_clock => muratov_clock,
		muratov_alu_codes => muratov_alu_codes,
		muratov_a => muratov_reg_1_data,
		muratov_b => muratov_alu_data_2,
		muratov_result => muratov_alu_result,
		muratov_overflow => muratov_alu_overflow,
		muratov_zero => muratov_alu_zero
	);
	
	muratov_shifted_imm <= muratov_extended_immediate(31 DOWNTO 2) & "00";
	
	muratov_adder_res <= STD_LOGIC_VECTOR(UNSIGNED(muratov_pc2) + UNSIGNED(muratov_shifted_imm));
	
	branch_and_alu_zero_modelsim <= branch and muratov_alu_zero;
	MUX4 : MuratovMux
	GENERIC MAP(32)
	PORT MAP(
		a => muratov_pc2,
		b => muratov_adder_res,
		s => branch_and_alu_zero_modelsim,
		z => muratov_pc_next
	);
	
	MEMORY : MuratovRAM
	PORT MAP (
		muratov_clock => muratov_clock,
		muratov_write_enable => write_mem,
		muratov_read_enable => read_mem,
		muratov_mem_address => muratov_alu_result,
		muratov_write_data => muratov_reg_2_data,
		muratov_read_data => mem_read_data
	);
	
	MEM_TO_REGISTER_MUX : MuratovMux
	GENERIC MAP(32)
	PORT MAP(
		a => muratov_alu_result,
		b => mem_read_data,
		s => mem_to_reg,
		z => muratov_reg_write_data
	);

	muratov_alu_res <= muratov_alu_result;
	muratov_pc_out <= muratov_pc_current;
	
END ARCH;