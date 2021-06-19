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
 *  - REMS : Remainder signed (Module)
 *  - REMU : Remainder unsigned (Module)
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

   assign {add_carry, add_result} = add_ina + add_inb; // TODO Is it power efficient
   assign add_carry_sign = add_result[OPTION_REG_WIDTH-1];
   assign add_overflow_signed = (add_ina[OPTION_REG_WIDTH-1] == add_inb[OPTION_REG_WIDTH-1]) &
                                   (add_ina[OPTION_REG_WIDTH-1] ^ add_result[OPTION_REG_WIDTH-1]);

endmodule // alu
