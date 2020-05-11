LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;

ENTITY MuratovController IS
	PORT (
		muratov_opcode : IN STD_LOGIC_VECTOR(5 DOWNTO 0);
		muratov_function : IN STD_LOGIC_VECTOR(5 DOWNTO 0);
		muratov_alu_control : OUT STD_LOGIC_VECTOR(7 DOWNTO 0);
		branch, immediate_select, sign_extend, read_mem, write_mem, mem_to_reg, register_destination, reg_write, shift : OUT STD_LOGIC
	);
END MuratovController;

ARCHITECTURE ARCH OF MuratovController IS

	SIGNAL alu_op : STD_LOGIC_VECTOR(1 DOWNTO 0) := "00";
	
BEGIN

	muratov_alu_control <= alu_op & muratov_function WHEN alu_op = "10" ELSE alu_op & muratov_opcode;

	PROCESS(muratov_opcode, muratov_function)
	BEGIN
		alu_op <= "00";
	
		branch <= '0';
		immediate_select <= '0';
		sign_extend <= '0';
		read_mem <= '0';
		write_mem <= '0';
		mem_to_reg <= '0';
		register_destination <= '0';
		reg_write <= '0';
		shift <= '0';
		
		CASE muratov_opcode IS
			WHEN "000000" =>
				CASE muratov_function IS
					WHEN "000000" => -- sll
						alu_op <= "10";
						register_destination <= '1';
						reg_write <= '1';
						shift <= '1';
					WHEN "000011" => -- sra
						alu_op <= "10";
						register_destination <= '1';
						reg_write <= '1';
						shift <= '1';
					WHEN "000010" => -- srl
						alu_op <= "10";
						register_destination <= '1';
						reg_write <= '1';
						shift <= '1';
					WHEN OTHERS => -- R type: add, and, or, xor, etc...
						alu_op <= "10";
						register_destination <= '1';
						reg_write <= '1';
				END CASE;
			WHEN "001000" => -- addi
				alu_op <= "11";
				immediate_select <= '1';
				sign_extend <= '1';
				reg_write <= '1';
			WHEN "001001" => -- addiu
				alu_op <= "11";
				immediate_select <= '1';
				sign_extend <= '1';
				reg_write <= '1';
			WHEN "001100" => -- andi
				alu_op <= "11";
				immediate_select <= '1';
				reg_write <= '1';
			WHEN "001101" => -- ori
				alu_op <= "11";
				immediate_select <= '1';
				reg_write <= '1';
			WHEN "000100" => -- beq
				alu_op <= "01";
				immediate_select <= '1';
				sign_extend <= '1';
				reg_write <= '1';
			WHEN "000101" => -- bne
				alu_op <= "01";
				immediate_select <= '1';
				sign_extend <= '1';
				reg_write <= '1';
			WHEN "101011" => -- sw
				alu_op <= "00";
				read_mem <= '1';
				mem_to_reg <= '1';
				sign_extend <= '1';
				reg_write <= '1';
			WHEN "100011" => -- lw
				alu_op <= "00";
				write_mem <= '1';
				sign_extend <= '1';
			WHEN OTHERS =>
				alu_op <= "00";
		END CASE;
		
	END PROCESS;

END ARCH;