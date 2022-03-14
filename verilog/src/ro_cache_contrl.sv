`timescale 1ns/10ps // For simulation purpose
`include "bram_single_port.v"

// See doc/ro_cache_contrl.md for documentation
module ro_cache_contrl #(
    parameter SET_ASSOCIATIVITY = 4,
    parameter INSTR_SIZE = 8*4, // Instruction's size in bit (4B = 32 bits = 1 instruction)
    parameter ADDR_LENGTH = 32, // Length of the address in bit
    parameter WRITE_LINE_SIZE = 1024*8, // 1024B line
    parameter CACHE_SIZE = 64*1024*8, // 64KB
    parameter MMU_WRITE_LENGTH = 32,
    localparam ADDRESSING_MODE = INSTR_SIZE, // we are addressing instrucitons
    localparam BITS_TO_ADDR_CACHE_SIZE = $clog2(CACHE_SIZE / (SET_ASSOCIATIVITY*ADDRESSING_MODE)), // 12 bits to address an entire cache line
    localparam BITS_TO_ADDR_A_LINE = $clog2(CACHE_SIZE / ADDRESSING_MODE), // 8 bits to address a line
    localparam ADDR_TAG_LENGTH = ADDR_LENGTH - BITS_TO_ADDR_CACHE_SIZE, // 20 bits of address for each way
    localparam TAG_BANK_ADDR_LENGTH = // 4 bits to address the tag memory
            $clog2(CACHE_SIZE/(WRITE_LINE_SIZE*SET_ASSOCIATIVITY)),
    localparam SINGLE_LRU_TAG_LENGTH = $clog2(SET_ASSOCIATIVITY),
    localparam LRU_TAG_LENGTH = SINGLE_LRU_TAG_LENGTH * SET_ASSOCIATIVITY,

    localparam TOTAL_TAG_LENGTH = LRU_TAG_LENGTH + SET_ASSOCIATIVITY*ADDR_TAG_LENGTH, // total size of one cache block 88bits
  ) (
    input logic i_clk,
    input logic i_nrst,

    // Interface from the branch unit (BRU)
    input logic [ADDR_LENGTH-1:0] i_addr, // Address to fetch
    input logic i_fetch, // when 1'b1 this module should fetch address i_addr unless i_emul_mode
    input logic i_emul_mode, // instead of fetching the memory we fetch i_emul_instr
    input logic [INSTR_SIZE-1:0] i_emul_instr,

    // Interface to the Decode stage
    output logic [INSTR_SIZE-1:0] o_instr0, // Instruction at i_addr
    output logic [INSTR_SIZE-1:0] o_instr1, // Instruction at i_addr+1
    output logic o_stall, // o_instr* are not ready yet (can be because of a miss)
    output logic o_miss, // miss

    // Interface to/from the Memory Management Unit (MMU)
    input logic i_mmu_we, // MMU writes (set o_stall=1'1)
    input logic [MMU_WRITE_LENGTH-1:0] i_mmu_data, // data to write in a burst
    input logic [ADDR_LENGTH-1:0] i_mmu_addr, // address associated to the data
    output logic o_mmu_miss, // notify the MMU about a cache miss
    output logic [ADDR_LENGTH-1:0] o_mmu_addr_miss, // the address of a cache miss

    // Interface to debug
    output logic [ADDR_LENGTH-1:0] o_dbg_evict_addr, // Evicted address for debug

    // Interface to memory bank for tags
    output logic [ADDR_TAG_LENGTH-1:0] o_tag_din;
    input logic [ADDR_TAG_LENGTH-1:0] i_tag_dout;
    output logic [TAG_BANK_ADDR_LENGTH-1:0] o_tag_addr;
    output logic o_tag_wr; // Write/Read tags

    // Interface to memory bank 0
    output logic [INSTR_SIZE-1:0] o_bank0_din;
    input logic [INSTR_SIZE-1:0] i_bank0_dout;
    output logic [BITS_TO_ADDR_CACHE_SIZE-2:0] o_bank0_addr;
    output logic o_bank0_wr;

    // Interface to memory bank 1
    output logic [INSTR_SIZE-1:0] o_bank1_din;
    input logic [INSTR_SIZE-1:0] i_bank1_dout;
    output logic [BITS_TO_ADDR_CACHE_SIZE-2:0] o_bank1_addr;
    output logic o_bank1_wr;
  );
    // TODO assert: if o_miss then o_stall must be set
    // TODO assert: when i_mmu_we then o_stall must be set
    // TODO assert: o_mmu_miss == o_miss
    // TODO o_stall can trigger an interruption and the cpu can do something
    // during the interrupt

  // FIXME make sure the cache retirement policy do not retire the line of the
  // current instr0 while providing the line for instr1


  // --
  // Instanciate a flip flop with evict_addr_d as input and evict_addr_q as input
  // TODO: make it a macro or a separate module
  logic [ADDR_LENGTH-1:0] evict_addr_q;
  logic [ADDR_LENGTH-1:0] evict_addr_d;
  always @ (posedge i_clk, negedge i_nrst)
  begin
    if (i_nrst == 1'b0)
      evict_addr_q[ADDR_LENGTH-1:0] <= 0;
    else
      evict_addr_q[ADDR_LENGTH-1:0] <= evict_addr_d[ADDR_LENGTH-1:0];
  end
  // --

  assign o_dbg_evict_addr = evict_addr_q;

  assign o_mmu_miss = o_miss;

  // TODO Instantiate tag_lru
  logic [LRU_TAG_LENGTH-1:0] old_tags, // TODO
  logic [LRU_TAG_LENGTH-1:0] new_tags, // TODO
  logic [SINGLE_LRU_TAG_LENGTH-1:0] hit, // TODO

  // module tag_lru #(
  //     parameter WAY = 4,
  //     localparam SINGLE_LRU_TAG_LENGTH = $clog2(WAY), // Size of a tag (single way)
  //     localparam LRU_TAG_LENGTH = SINGLE_LRU_TAG_LENGTH * WAY // Size of all tags
  // ) (
  //     input wire i_clk,
  //     input wire [LRU_TAG_LENGTH-1:0] old_tags,
  //     output wire [LRU_TAG_LENGTH-1:0] new_tags,
  //     input wire [SINGLE_LRU_TAG_LENGTH-1:0] hit // 00 if way0 is a hit, 01 for way1...
  // );
endmodule
