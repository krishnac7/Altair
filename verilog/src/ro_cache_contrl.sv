`timescale 1ns/1ns
// Documentation about this cache is in ../doc/ro_cache_contrl.sv

// This is the second implementation for this instruction cache

// TODO use one bank per way and only fetch hits
// (would add one more cycle of latency to check for the tag first)
// would improve power

// TODO use fill buffers to resume fetch while filling the cache and track
// the misses...
// would improve performance


`define INSTR_NOP 32'h00000000

`define SLICE_TAG_FROM_LABEL(LABEL) LABEL[] // TODO

// VEC is logic [LABEL_LENGTH-1:0]
`define LABEL_TAG_BITS(VEC) VEC[ADDR_TAG_LENGTH-1:0] // [17:0]
`define LABEL_LRU_BITS(VEC) VEC[SINGLE_LRU_COUNTER_LENGTH+ADDR_TAG_LENGTH-1:ADDR_TAG_LENGTH] // [19:18]
`define LABEL_VALID_BIT(VEC) VEC[LABEL_LENGTH-1] // [20]

// Slice a set of labels (read from label memory) into ways
// WAY: integer 0-3
// LABELSET logic [LABEL_ALL_WAY_LENGTH-1:0]
`define LABEL_SLICE_WAY(LABELSET, WAY) LABELSET[WAY*LABEL_LENGTH+LABEL_LENGTH-1:WAY*LABEL_LENGTH]

// part of the address which should be compared with the tag
`define ADDR_SLICE_TAG(ADDRESS) ADDRESS[ADDR_LENGTH-1:BITS_TO_ADDR_CACHE_SIZE] // [29:12]

// Get a instruction out of the set INSTRSET which corresponds to the way WAY
`define INSTR_SLICE_WAY(INSTRSET, WAY) INSTRSET[WAY*INSTR_SIZE+INSTR_SIZE-1:WAY*INSTR_SIZE]

`define SLICE_PAIRING_BIT(INSTR) INSTR[INSTR_SIZE-1] // pairing bit is the MSB of the instruction

module ro_cache_contrl #(
    parameter SET_ASSOCIATIVITY = 4,
    // Instruction's size in bit (4B = 32 bits = 1 instruction)
    parameter INSTR_SIZE = 8*4,
    // Length of the address in bit (32 bits if we'd address bytes but we address 4B instruciton)
    parameter ADDR_LENGTH = 32-2,
    parameter WRITE_LINE_SIZE = 1024*8, // 1024B line
    parameter CACHE_SIZE = 64*1024*8, // 64KB
    parameter MMU_WRITE_LENGTH = 32,

    localparam ADDRESSING_MODE = INSTR_SIZE, // we are addressing instructions
    // 12 bits to address an entire cache line
    localparam BITS_TO_ADDR_CACHE_SIZE = $clog2(CACHE_SIZE / (SET_ASSOCIATIVITY*ADDRESSING_MODE)), // 12
    localparam BITS_TO_ADDR_2_BANK = BITS_TO_ADDR_CACHE_SIZE - 1,
    localparam BITS_TO_ADDR_A_LINE = $clog2(WRITE_LINE_SIZE / ADDRESSING_MODE), // 8 bits to address a line
    localparam ADDR_TAG_LENGTH = ADDR_LENGTH - BITS_TO_ADDR_CACHE_SIZE, // 18 bits of address for each way
    localparam LABEL_BANK_ADDR_LENGTH = // 4 bits to address the tag memory
            $clog2(CACHE_SIZE/(WRITE_LINE_SIZE*SET_ASSOCIATIVITY)),
    localparam SINGLE_LRU_COUNTER_LENGTH = $clog2(SET_ASSOCIATIVITY), // 2 bits
    // 1 valid bit + LRU counter + address tag
    localparam LABEL_LENGTH = 1 + SINGLE_LRU_COUNTER_LENGTH + ADDR_TAG_LENGTH, // 1 + 2 + 18 = 21 bits
    // total size for one cache block 76 bits
    // 4 valid bits, 4 addresses and 4 LRU counters
    localparam LABEL_ALL_WAY_LENGTH = SET_ASSOCIATIVITY*LABEL_LENGTH
) (
    input logic i_clk,
    input logic i_nrst, // active low reset

    // Interface with the core
    input logic i_waiting, // the is will consume any provided instruction
    input logic i_brch, // branching to a new address
    input logic [ADDR_LENGTH-1:0] i_brch_addr, // address of the branch
    output logic o_instr_rdy, // instr0 and instr1 are ready to consume
    output logic [INSTR_SIZE-1:0] o_instr0,
    output logic [INSTR_SIZE-1:0] o_instr1,

    // Interface to the label bank
    output logic [LABEL_BANK_ADDR_LENGTH-1:0] o_label_r_addr_0, // reading address
    output logic o_label_r_0, // high to read from the bank
    output logic [LABEL_BANK_ADDR_LENGTH-1:0] o_label_w_addr_0, // writing address
    output logic [LABEL_ALL_WAY_LENGTH-1:0] o_label_w_data_0, // data to write
    output logic o_label_w_en_0, // high to write to the bank
    input logic [LABEL_ALL_WAY_LENGTH-1:0] i_label_r_data_1, // data read from bank

    // Interface for main bank0
    output logic [BITS_TO_ADDR_2_BANK-1:0] o_bank0_r_addr_0,
    output logic o_bank0_r_0,
    output logic o_bank0_w_0,
    output logic [4*INSTR_SIZE-1:0] o_bank0_w_data_0,
    input logic [4*INSTR_SIZE-1:0] i_bank0_data_1,

    // Interface for main bank1
    output logic [BITS_TO_ADDR_2_BANK-1:0] o_bank1_r_addr_0,
    output logic o_bank1_r_0,
    output logic o_bank1_w_0,
    output logic [4*INSTR_SIZE-1:0] o_bank1_w_data_0,
    input logic [4*INSTR_SIZE-1:0] i_bank1_data_1,

    // Interface with memory
    output logic [ADDR_LENGTH-1:0] o_mmu_req_addr, // FIXME send the address of the missing line
    output logic o_mmu_waiting, // high if waiting for a transfert
    input logic i_mmu_data_rdy,
    input logic i_mmu_addr_rdy,
    input logic [MMU_WRITE_LENGTH-1:0] i_mmu_bus
);
typedef enum logic[0:0] {ST_CPU, ST_MM} state_t;
// ST_CPU state for normal CPU access
// ST_MM state for memory management
state_t state_d, state_q;
logic [INSTR_SIZE-1:0] instr_nop;
logic [ADDR_LENGTH-1:0] addr_d, addr_q;
logic is_hit; // the previous address was a hit
logic pairing_bit; // two instructions were consumed we should increment by 2 the address (aka pairing bit from instr0)
logic [ADDR_LENGTH-1:0] next_addr; // address for instr0 (which pairing bit will be checked)
logic [BITS_TO_ADDR_CACHE_SIZE-1:0] primary_address; // address of instr0
logic [BITS_TO_ADDR_CACHE_SIZE-1:0] secondary_address; // address of instr1
logic addr_overflow; // only an error if not branching
logic sec_addr_overflow; // only an error if pairing bit is set
logic err_addr_overflow;
logic bank0_is_prim_0; // bank 0 should contain instr0
logic bank0_is_prim_1;
logic waiting_q;

always_ff @ (posedge i_clk or negedge i_nrst)
begin
    if (i_nrst == 1'b0) state_q <= ST_CPU;
    else state_q <= state_d;
end

always_ff @ (posedge i_clk or negedge i_nrst)
begin
    if (i_nrst == 1'b0) waiting_q <= 1'b0;
    else waiting_q <= i_waiting;
end

always_ff @ (posedge i_clk or negedge i_nrst)
begin
    if (i_nrst == 1'b0) bank0_is_prim_1 <= 1'b0;
    else bank0_is_prim_1 <= bank0_is_prim_0;
end

// Update the internal address to index the cache (or memory on a miss)
// Do not update the branch while in ST_MM (until the miss is resolved and
// execution resumed)
always_ff @ (posedge i_clk) if (state_q == ST_CPU) addr_q <= addr_d;
// on a branch we just use the branch's address
assign addr_d = (i_brch == 1'b1)? i_brch_addr: next_addr;
// else we increment the address depending on how many instructions were
// fetched
always_comb
begin
    if (is_hit == 1'b1) {addr_overflow, next_addr} = addr_q+pairing_bit+1;
    else begin
        addr_overflow = 1'b0;
        next_addr = addr_q;
    end
end
assign err_addr_overflow = addr_overflow & ~i_brch & i_waiting;
// Only take the lower bits to address the main banks (bank0 and bank1)
assign primary_address = addr_d[BITS_TO_ADDR_CACHE_SIZE-1:0];
assign {sec_addr_overflow, secondary_address} = primary_address+1;
always_comb
begin
    // index bank0 if address%2 == 0 else index bank1
    // FIXME add a mux for ST_MM
    if (primary_address[0] == 1'b0) begin
        bank0_is_prim_0 = 1'b1;
        o_bank0_r_addr_0 = primary_address[BITS_TO_ADDR_CACHE_SIZE-1:1];
        o_bank1_r_addr_0 = secondary_address[BITS_TO_ADDR_CACHE_SIZE-1:1];
        // Note: if o_bank0_r_addr_0 and o_bank1_r_addr_0 does not map to
        // the same tag addr_overflow is set
        o_label_r_addr_0 = primary_address[BITS_TO_ADDR_CACHE_SIZE-1:BITS_TO_ADDR_A_LINE];
    end else begin
        bank0_is_prim_0 = 1'b0;
        o_bank0_r_addr_0 = secondary_address[BITS_TO_ADDR_CACHE_SIZE-1:1];
        o_bank1_r_addr_0 = primary_address[BITS_TO_ADDR_CACHE_SIZE-1:1];
    end
end
assign o_bank0_r_0 = (state_q == ST_CPU) ? i_waiting : // TODO do not read when miss?
                            1'b0 ; // TODO do not set when writing and if miss
assign o_label_r_0 = (state_q == ST_CPU) ? i_waiting : // TODO do not read when miss?
                            1'b0 ;

// Read data back from label memory and detect hit/miss
logic [SET_ASSOCIATIVITY-1:0] all_hits; // all hits per way
for (genvar WAY = 0; WAY < SET_ASSOCIATIVITY; WAY++) begin : foreach_way
    logic [LABEL_LENGTH-1:0] label_way;
    logic [SINGLE_LRU_COUNTER_LENGTH-1:0] lru_way;
    logic [ADDR_TAG_LENGTH-1:0] tag_way;
    logic valid_way;
    logic hit_way; // This way is a hit
    assign label_way = `LABEL_SLICE_WAY(i_label_r_data_1, WAY);
    assign lru_way = `LABEL_LRU_BITS(label_way);
    assign tag_way = `LABEL_TAG_BITS(label_way);
    assign valid_way = `LABEL_VALID_BIT(label_way);

    // TODO check valid_way first and only compare tag if the way is valid?
    // it would save power but add delay
    // TODO use piority logic to stop checking testing tags when a hit is
    // already encontered, would be a lot slower but save a little power
    
    // Detect a hit on this way
    assign hit_way = (valid_way == 1'b1 && tag_way == `ADDR_SLICE_TAG(addr_q)) ?
        1'b1 : 1'b0;
    assign all_hits[WAY] = hit_way;
end
assign is_hit = |all_hits; // One of the ways is a hit
assign state_d = (is_hit == 1'b0)? ST_MM: ST_CPU;

// Detect if more than one hit occurs (should not happen)
// Note: This is not an essential path, can be removed if it becomes critical
logic err_multi_hit; // more than one hit (should not happen)
logic [SET_ASSOCIATIVITY-2:0] multi_hit_err_detect;
for (genvar WAY = 0; WAY < SET_ASSOCIATIVITY; WAY++) begin : multi_hit_for
    logic prop; // propagate any hit on a previous way
    if (WAY == 0) begin
        assign prop = all_hits[WAY];
    end else begin
        // raise an error on this way if it is a hit and an other hit has been
        // propagated
        assign multi_hit_err_detect[WAY-1] = all_hits[WAY] & multi_hit_for[WAY-1].prop;
        assign prop = all_hits[WAY] | multi_hit_for[WAY-1].prop;
        // Note prop[SET_ASSOCIATIVITY-1] if not used and will be removed auto.
    end
end
assign err_multi_hit = |multi_hit_err_detect;

// Selection which way contains the instruction
// TODO make it parametric
logic [INSTR_SIZE-1:0] instr_bank0 = (`INSTR_SLICE_WAY(i_bank0_data_1, 0) & {INSTR_SIZE{all_hits[0]}}) |
                (`INSTR_SLICE_WAY(i_bank0_data_1, 1) & {INSTR_SIZE{all_hits[1]}}) |
                (`INSTR_SLICE_WAY(i_bank0_data_1, 2) & {INSTR_SIZE{all_hits[2]}}) | 
                (`INSTR_SLICE_WAY(i_bank0_data_1, 3) & {INSTR_SIZE{all_hits[3]}});
logic [INSTR_SIZE-1:0] instr_bank1 = (`INSTR_SLICE_WAY(i_bank1_data_1, 0) & {INSTR_SIZE{all_hits[0]}}) |
                (`INSTR_SLICE_WAY(i_bank1_data_1, 1) & {INSTR_SIZE{all_hits[1]}}) |
                (`INSTR_SLICE_WAY(i_bank1_data_1, 2) & {INSTR_SIZE{all_hits[2]}}) | 
                (`INSTR_SLICE_WAY(i_bank1_data_1, 3) & {INSTR_SIZE{all_hits[3]}});

logic [INSTR_SIZE-1:0] instr_0;
logic [INSTR_SIZE-1:0] instr_1;
always_comb begin
    if (bank0_is_prim_1 == 1'b1) begin
        instr_0 = instr_bank0;
        pairing_bit = `SLICE_PAIRING_BIT(instr_bank0);
        instr_1 = pairing_bit? instr_bank1: `INSTR_NOP; // TODO set a macro
    end else begin
        instr_0 = instr_bank1;
        pairing_bit = `SLICE_PAIRING_BIT(instr_bank1);
        instr_1 = pairing_bit? instr_bank0: `INSTR_NOP;
    end
end

// TODO is the error checking required here?
assign o_instr_rdy = (state_q == ST_CPU) && (is_hit == 1'b1) &&
    (err_addr_overflow == 1'b0) && (err_multi_hit == 1'b0);

// TODO check parity bit on the primary instruction 
// and submit second instruction if needed

endmodule

`ifdef SIMULATION
module ro_cache_contrl_tb();
// Simulation's signals
reg i_clk;
always #1 i_clk = ~i_clk;
reg i_nrst;
reg i_waiting;
reg i_brch;
reg [29:0] i_brch_addr;
wire o_instr_rdy;
wire [31:0] o_instr0;
wire [31:0] o_instr1;
wire [3:0] o_label_r_addr_0;
wire o_label_r_0;
wire [3:0] o_label_w_addr_0; // FIXME what size?
wire [83:0] o_label_w_data_0;
wire o_label_w_en_0;
reg [83:0] i_label_r_data_1;

wire [10:0] o_bank0_r_addr_0;
wire o_bank0_r_0;
wire o_bank0_w_0;
wire [127:0] o_bank0_w_data_0;
reg [127:0] i_bank0_data_1;

wire [10:0] o_bank1_r_addr_0;
wire o_bank1_r_0;
wire o_bank1_w_0;
wire [127:0] o_bank1_w_data_0;
reg [127:0] i_bank1_data_1;

wire [29:0] o_mmu_req_addr;
wire o_mmu_waiting;
reg i_mmu_data_rdy;
reg i_mmu_addr_rdy;
reg [31:0] i_mmu_bus;

initial begin
    i_clk = 1'b1;
    i_nrst = 1'b0;
    i_waiting = 1'b1; // ready to consume instructions
    i_brch = 1'b0; // not branching
    i_brch_addr = {30{1'b0}};
    i_label_r_data_1 = {76{1'b1}};
    i_bank0_data_1 = {128{1'b1}};
    i_bank1_data_1 = {128{1'b1}};
    i_mmu_data_rdy = 1'b0;
    i_mmu_addr_rdy = 1'b0;
end

ro_cache_contrl dut (
    .i_clk,
    .i_nrst,

    // Interface with the core
    .i_waiting, // the is will consume any provided instruction
    .i_brch, // branching to a new address
    .i_brch_addr, // address of the branch
    .o_instr_rdy, // instr0 and instr1 are ready to consume
    .o_instr0,
    .o_instr1,

    // Interface to the label bank
    .o_label_r_addr_0, // reading address
    .o_label_r_0, // high to read from the bank
    .o_label_w_addr_0, // writing address
    .o_label_w_data_0, // data to write
    .o_label_w_en_0, // high to write to the bank
    .i_label_r_data_1, // data read from bank

    // Interface for main bank0
    .o_bank0_r_addr_0,
    .o_bank0_r_0,
    .o_bank0_w_0,
    .o_bank0_w_data_0,
    .i_bank0_data_1,

    // Interface for main bank1
    .o_bank1_r_addr_0,
    .o_bank1_r_0,
    .o_bank1_w_0,
    .o_bank1_w_data_0,
    .i_bank1_data_1,

    // Interface with memory
    .o_mmu_req_addr, // FIXME send the address of the missing line
    .o_mmu_waiting, // high if waiting for a transfert
    .i_mmu_data_rdy,
    .i_mmu_addr_rdy,
    .i_mmu_bus
);

// Simulation's program
initial begin
    $dumpfile("/tmp/trace.vcd");
    $dumpvars;
    #2;
    i_nrst = 1'b1; // Start
    @(posedge i_clk); #1;
    i_brch = 1'b1;
    i_brch_addr = 30'hf000004;// 100
    i_waiting = 1'b1;
    #1; assert (o_bank0_r_addr_0 == 12'h0002) // Primary
    assert (o_bank1_r_addr_0 == 12'h0002)
    @(posedge i_clk); #1;
    i_brch = 1'b1;
    i_brch_addr = 30'hf000005; // 101

    #1; assert (o_bank0_r_addr_0 == 12'h0003)
    assert (o_bank1_r_addr_0 == 12'h0002) // Primary
    @(posedge i_clk); #1;
    @(posedge i_clk); #1;
    @(posedge i_clk); #1;
    #1000;
    $finish;
end
// Fake label bank
always@*
begin
    if (o_bank0_r_0 == 1'b1) begin
        i_label_r_data_1 = {72'h9100000013, o_label_r_addr_0};
    end
end
endmodule
`endif
