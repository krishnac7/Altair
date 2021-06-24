`define OPCODE_SUB 6'b000001
`define OPCODE_ADD 6'b000010
`define OPCODE_ICMP 6'b000011 // Integer compare

`define FLAG_INDEX_EQ 10
`define FLAG_INDEX_NEQ 1
`define FLAG_INDEX_GTU 2 // SFGTU
`define FLAG_INDEX_GTS 3 // SFGTS
`define FLAG_INDEX_GEU 4 // SFGEU
`define FLAG_INDEX_GES 5 // SFGES
`define FLAG_INDEX_LTU 6
`define FLAG_INDEX_LTS 7
`define FLAG_INDEX_LEU 8
`define FLAG_INDEX_LES 9

// TODO Carry flag
// TODO Overflow flag

// TODO SFGESI: Set the compare flag if rA >= exts(I[15:0]) signed
// TODO SFGEUI: Set the compare flag if rA >= exts(I) unsigned

// TODO SFGTSI: Set the compare flag if rA > exts(I[15:0]) signed
// ... SFGTUI

// SFLES,SFLESI,SFLEU,SFLEUI: <=

// SFLTS,SFLTSI,SFLTU,SFLTUI: <

// SFNE,SFNEI: !=

// SFEQ,SFEQI: ==

module pu_add_cmp (
    input wire i_clk,
    input wire i_rst,

    // From the Control Unit
    input wire [OPTION_OPCODE_WIDTH-1:0] i_opcode,
    input wire [4:0] i_rega, // Input A: register's number
    input wire [4:0] i_regb, // Input B: register's number
    input wire [4:0] i_regd, // Destination: register's number

    // From an other processing unit
    output wire o_unique_ack, // setting it to 1'b1 means we handle the operation
    // To an other processing unit in the chain
    input wire i_unique_ack, // If 1'b1 means some other unit already handles the operation

    // To the registers
    output wire [4:0] o_sela, // select which register we want on ina
    output wire [4:0] o_selb, // select which register we want on inb
    output wire [4:0] write_reg, // select with register to write
    output wire [OPTION_REG_WIDTH-1:0] write_data,
    output wire write_en, // will latch the register on the rising edge
    // From the registers
    input [OPTION_REG_WIDTH-1:0] ina,
    input [OPTION_REG_WIDTH-1:0] inb,

    // To the Flags
    output wire flag_cmp,
    output wire write_flag,
    // From the Flags
    input wire [3:0] cmp_op
  );
  parameter OPTION_REG_WIDTH = 64;
  parameter OPTION_OPCODE_WIDTH = 6;

  // Internals signals
  wire carry_sum;
  wire [OPTION_REG_WIDTH-1:0] result_sum;
  wire [OPTION_REG_WIDTH-1:0] muxb;
  wire cmp_eq;
  wire cmp_lts;
  wire cmp_ltu;
  wire sum_carry_sign;
  wire sum_overflow_signed;
  wire is_active;
  wire opcode_matches; // The opcode matches what we can do

  assign o_unique_ack = is_active;
  assign is_active = !i_unique_ack && opcode_matches;

  assign opcode_matches = (i_opcode == `OPCODE_SUB) |
         (i_opcode == `OPCODE_ADD) |
         (i_opcode == `OPCODE_ICMP);

  assign o_sela = i_rega;
  assign o_selb = i_regb;
  assign write_reg = i_regd;

  assign muxb = (i_opcode == `OPCODE_SUB) ? (~inb)+1 : inb;

  assign {carry_sum, result_sum} = ina + muxb;
  assign write_data = result_sum;
  assign write_en = is_active;
  assign write_flag = is_active;
  assign sum_carry_sign = result_sum[OPTION_REG_WIDTH-1];
  assign sum_overflow_signed = (ina[OPTION_REG_WIDTH-1] == muxb[OPTION_REG_WIDTH-1]) &
         (ina[OPTION_REG_WIDTH-1] ^ result_sum[OPTION_REG_WIDTH-1]);

  assign cmp_eq = (ina == inb);
  assign cmp_lts = !(sum_carry_sign == sum_overflow_signed);
  assign cmp_ltu = !carry_sum;
  always @*
  begin
    case (cmp_op)
      `FLAG_INDEX_EQ:
        flag_cmp = cmp_eq;
      `FLAG_INDEX_NEQ:
        flag_cmp = !cmp_eq;
      `FLAG_INDEX_GTU:
        flag_cmp = !(cmp_eq | cmp_ltu);
      `FLAG_INDEX_GTS:
        flag_cmp = !(cmp_eq | cmp_lts);
      `FLAG_INDEX_GEU:
        flag_cmp = !cmp_ltu;
      `FLAG_INDEX_GES:
        flag_cmp = !cmp_lts;
      `FLAG_INDEX_LTU:
        flag_cmp = cmp_ltu;
      `FLAG_INDEX_LTS:
        flag_cmp = cmp_lts;
      `FLAG_INDEX_LEU:
        flag_cmp = cmp_ltu | cmp_eq;
      `FLAG_INDEX_LES:
        flag_cmp = cmp_lts | cmp_eq;
      default:
        flag_cmp = 1'b0;
    endcase
  end

endmodule // pu_add_cmp
