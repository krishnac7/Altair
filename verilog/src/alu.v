/*
 * Implements operations:
 *  - CMP: Compare
 *  - ADD : Add
 *  - SUB : Subtrat
 *  - OR : Bitwise operations
 *  - XOR : Bitwise operations
 *  - AND : Bitwise operations
 *  - MULS : Multiply signed
 *  - MULU : Multiply unsigned
 *  - MOVE : Move register's value
 *  - DIVS : Divide signed
 *  - DIVU : Divide unsigned
 *  - REMS : Remainder signed (Modulo)
 *  - REMU : Remainder unsigned (Modulo)
 */
module alu (
            input clk,
            input rst,
            input opcode,
            input rega,
            input regb
            );
   parameter OPTION_REG_WIDTH = 64; // Register's width, set it 32 to use 32bits only
   parameter FEATURE_MUL = "ENABLED"; // Implements MULS and MULU
   parameter FEATURE_DIV = "ENABLED"; // Implements DIVS and DIVU
   parameter FEATURE_REM = "ENABLED"; // Implements REMS and REMU
   parameter FEATURE_MOVE = "ENABLED"; // Implements MOVE

   // Inputs
   wire           clk;
   wire           rst;
   wire [3:0]     opcode;
   wire [63:0]    rega;
   wire [63:0]    regb;

   // ADD
   wire [OPTION_REG_WIDTH-1:0] add_ina;
   wire [OPTION_REG_WIDTH-1:0] add_inb;
   wire           add_carry;
   wire           add_carry_sign;
   wire           add_overflow_signed; // Overflow on signed operation, output sign is different from inputs' signs
   wire [OPTION_REG_WIDTH-1:0] add_result;

   // LOGIC
   wire [OPTION_REG_WIDTH-1:0] logic_ina;
   wire [OPTION_REG_WIDTH-1:0] logic_inb;
   wire [OPTION_REG_WIDTH-1:0] logic_result;
   wire [1:0] i_logic_op; // Input: type of logic operation

   // Flags internals
   wire [3:0] i_cmp_op;
   wire           cmp_flag;
   wire           a_eq_b; // Set to 1'b1 if rega == regb
   wire           a_lts_b; // Less Than for Signed: a < b
   wire           a_ltu_b; // Less Than for Unsigned: a < b

   // ADD implementation
   assign {add_carry, add_result} = add_ina + add_inb; // TODO Is it power efficient ?
   assign add_carry_sign = add_result[OPTION_REG_WIDTH-1];
   assign add_overflow_signed = (add_ina[OPTION_REG_WIDTH-1] == add_inb[OPTION_REG_WIDTH-1]) &
                                   (add_ina[OPTION_REG_WIDTH-1] ^ add_result[OPTION_REG_WIDTH-1]);
   // TODO Add regb_mux to set to -regb if required
   // TODO Add carry_in in the add operation, required for SUBSTRACTIONS to
   // work

   // LOGIC implementation
   always @(*) // Combinational block
   begin
	   case (i_logic_op)
		2'b00: // OR
			logic_result = logic_ina | logic_inb;
		2'b01: // XOR
			logic_result = logic_ina ^ logic_inb;
		2'b10: // AND
			logic_result = logic_ina & logic_inb;
		default: // NOT
			logic_result = ~logic_ina;
	   endcase // case (i_logic_op)
   end

   // Flags implementation
   assign a_eq_b = (rega == regb);
   assign a_ltu_b = !add_carry;
   assign a_lts_b = !(add_carry_sign == add_overflow_signed);
   always @(*) // Combinational block
   begin
	   case (i_cmp_op)
		   4'b0000: // a equals b
			   flag = a_eq_b;
		   4'b0001: // a non-equals b
			   flag = !a_eq_b;
		   4'b0010: // a > b for unsigned
			   flag = !(a_ltu_b | a_eq_b);
		   4'b0011: // a > b for signed
			   flag = !(a_lts_b | a_eq_b);
		   4'b0100: // a >= b for unsigned
			   flag = !(a_ltu_b);
		   4'b0101: // a >= b for signed
			   flag = !(a_lts_b);
		   4'b0110: // a < b for unsigned
			   flag = a_ltu_b;
		   4'b0111: // a < b for signed
			   flag = a_lts_b;
		   4'b1000: // a <= b for unsigned
			   flag = a_ltu_b | a_eq_b;
		   4'b1001: // a <= b for signed
			   flag = a_lts_b | a_eq_b;
		   default:
			   flag = 0;
	   endcase
   end
      
endmodule // alu
