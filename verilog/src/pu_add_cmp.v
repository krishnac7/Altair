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
    output wire [4:0] o_write_reg, // select with register to write
    output wire [OPTION_REG_WIDTH-1:0] o_write_data,
    output wire o_write_en, // will latch the register on the rising edge
    // From the registers
    input [OPTION_REG_WIDTH-1:0] i_ina,
    input [OPTION_REG_WIDTH-1:0] i_inb,

    // To the Flags
    output wire o_flag_cmp,
    output wire o_write_flag,
    // From the Flags
    input wire [3:0] i_cmp_op
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
  assign o_write_reg = i_regd;

  assign muxb = (i_opcode == `OPCODE_SUB) ? (~i_inb)+1 : i_inb;

  assign {carry_sum, result_sum} = i_ina + muxb;
  assign o_write_data = result_sum;
  assign o_write_en = is_active;
  assign o_write_flag = is_active;
  assign sum_carry_sign = result_sum[OPTION_REG_WIDTH-1];
  assign sum_overflow_signed = (i_ina[OPTION_REG_WIDTH-1] == muxb[OPTION_REG_WIDTH-1]) &
         (i_ina[OPTION_REG_WIDTH-1] ^ result_sum[OPTION_REG_WIDTH-1]);

  assign cmp_eq = (i_ina == i_inb);
  assign cmp_lts = !(sum_carry_sign == sum_overflow_signed);
  assign cmp_ltu = !carry_sum;

  assign o_flag_cmp = (i_cmp_op==`FLAG_INDEX_EQ) ? cmp_eq :
         (i_cmp_op==`FLAG_INDEX_NEQ) ? !cmp_eq :
         (i_cmp_op==`FLAG_INDEX_GTU) ? !(cmp_eq | cmp_ltu) :
         (i_cmp_op==`FLAG_INDEX_GEU) ? !cmp_ltu :
         (i_cmp_op==`FLAG_INDEX_GES) ? !cmp_lts :
         (i_cmp_op==`FLAG_INDEX_LTU) ? cmp_ltu :
         (i_cmp_op==`FLAG_INDEX_LTS) ? cmp_lts :
         (i_cmp_op==`FLAG_INDEX_LEU) ? cmp_ltu | cmp_eq :
         (i_cmp_op==`FLAG_INDEX_LES) ? cmp_lts | cmp_eq :
         1'b0;

endmodule // pu_add_cmp
