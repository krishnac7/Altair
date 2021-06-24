`define OPCODE_AND 6'b000100
`define OPCODE_OR 6'b000101
`define OPCODE_XOR 6'b000110
`define OPCODE_ANDI 6'b000111
`define OPCODE_ORI 6'b001000
`define OPCODE_XORI 6'b001001

module pu_bitwise (
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
    input [OPTION_REG_WIDTH-1:0] i_inb
  );
  parameter OPTION_REG_WIDTH = 64;
  parameter OPTION_OPCODE_WIDTH = 6;
  // Internals signals
  wire opcode_matches_bitwise;
  wire is_active;

  assign opcode_matches_bitwise = (i_opcode == `OPCODE_AND) |
         (i_opcode == `OPCODE_OR) |
         (i_opcode == `OPCODE_XOR) |
         (i_opcode == `OPCODE_ANDI) |
         (i_opcode == `OPCODE_ORI) |
         (i_opcode == `OPCODE_XORI);
  assign is_active = !i_unique_ack & opcode_matches_bitwise;
  assign o_unique_ack = is_active;
  assign o_write_reg = i_regd;
  assign o_sela = i_rega;
  assign o_selb = i_regb;
  assign o_write_data = (i_opcode == `OPCODE_AND)? i_ina & i_inb:
         (i_opcode == `OPCODE_OR)? i_ina | i_inb:
         (i_opcode == `OPCODE_XOR)? i_ina ^ i_inb:
         1'b0;// TODO
  assign o_write_en = is_active;


endmodule
