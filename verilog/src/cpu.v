`timescale 1ns/10ps // for simulation purpose
/*
 * Top level CPU entity
 */
module  cpu (
	input wire clk,
	input wire rst
);

wire [127:0] int_spm_out;

wire [31:0] int_split_0;
wire int_split_0_commit;
wire [31:0] int_split_1;
wire int_split_1_commit;
wire [31:0] int_split_2;
wire int_split_2_commit;
wire [31:0] int_split_3;
wire int_split_3_commit;

l1_spm_manager spm_i 
#(
	.DATASIZE(128),
	.ADDRSIZE(20)
)
(
	.clk(clk),
	.rst(rst),
	.wr(), // TODO
	.stall(),
	.addr(),
	.din(),
	.dout(int_spm_out),
	.dma_access(),
	.dma_wr(),
	.dma_addr(),
	.dma_din(),
	.dma_dout()
);

split_long_word_into_instructions splitter (
	.i_vliw(),
	.o_instr_0(),
	.o_instr_0_commit(),
	.o_instr_1(),
	.o_instr_1_commit(),
	.o_instr_2(),
	.o_instr_2_commit(),
	.o_instr_3(),
	.o_instr_3_commit(),
	.o_pc_increment(),
	.o_error_instr0()
);

Decode decode
#(
)
(
	.i_clk(),
	.i_rst(),
	.i_en(),
	.i_instr_0_commit(int_split_0_commit),
	.i_instr_0(int_split_0),
	.i_instr_0_commit(int_split_1_commit),
	.i_instr_1(int_split_1),
	.i_instr_0_commit(int_split_2_commit),
	.i_instr_2(int_split_2),
	.i_instr_0_commit(int_split_3_commit),
	.i_instr_3(int_split_3),

);

endmodule

/*
 * Input: 128bits {P0 INSTR0 P1 INSTR1 P2 INSTR2 P3 INSTR3}
 * Splits it into 4 instructions
 * if {P0, ... } => error, behavior depends on COMMIT_IF_ERROR
 * if {!P0, !P1, !P2, !P3} => commit 1 instruction
 * if {!P0, P1, !P2, !P3} => commit 2 instructions
 * if {!P0, P1, P2, !P3} => commit 3 instructions
 * if {!P0, P1, P2, P3} => commit all instructions
 */
module split_long_word_into_instructions (
	input wire [VLIWSIZE-1:0] i_vliw, // very long instruction word to split
	output wire [INSTRSIZE-1:0] o_instr_0, // first instruction in vliw
	output wire o_instr_0_commit, // first instruction should be executed
	output wire [INSTRSIZE-1:0] o_instr_1,
	output wire o_instr_1_commit,
	output wire [INSTRSIZE-1:0] o_instr_2,
	output wire o_instr_2_commit,
	output wire [INSTRSIZE-1:0] o_instr_3,
	output wire o_instr_3_commit,

	// How many instructions are to be executed = program counter
	// increment
	output wire [1:0] o_pc_increment, 

	// Instruction 0 should not commit, wrong pc?
	// if  COMMIT_IF_ERROR is set the program counter
	// is incremented by 1 but nothing not instruction is
	// executed
	output wire o_error_instr0;
);
parameter VLIWSIZE = 128;
parameter INSTRSIZE = 31;
parameter COMMIT_IF_ERROR = 0;

generate
	if (COMMIT_IF_ERROR)
		assign o_instr_0_commit = 1'b1;
	else
		assign o_instr_0_commit = i_vliw[0];
endgenerate
assign o_instr_0 = i_vliw[1:31];

assign o_instr_1_commit = o_instr_0_commit && i_vliw[32];
assign o_instr_1 = i_vliw[33:63];

assign o_instr_2 = i_vliw[65:95];
assign o_instr_2_commit = i_vliw[64] && o_instr_1_commit;

assign o_instr_3 = i_vliw[97:127];
assign o_instr_3_commit = i_vliw[96] && o_instr_2_commit;

assign o_error_instr0 = i_vliw[0];

generate
	if (COMMIT_IF_ERROR)
		assign o_pc_increment = o_instr_0_commit + o_instr_1_commit + o_instr_2_commit + o_instr_3_commit;
	else
		assign o_pc_increment = (o_error_instr0) ? 1 : o_instr_1_commit + o_instr_2_commit + o_instr_3_commit + 1;
endgenerate

endmodule

// L1 instruction cache, scratchpad memory
// Allows the DMA unit to access the scratchpad and stalls the CPU
module l1_spm_manager (
	input wire clk,
	input wire rst,

	input wire wr,
	output wire stall, // Stall the CPU while the DMA is accessing the memory
	input wire [ADDRSIZE-1:0] addr,
	input wire [DATASIZE-1:0] din,
	output wire [DATASIZE-1:0] dout,

	input reg dma_access, // Need to be set to stall the CPU and get DMA access
	input wire dma_wr,
	input wire [ADDRSIZE-1:0] dma_addr,
	input wire [DATASIZE-1:0] dma_din,
	outpout wire [DATASIZE-1:0] dma_dout
);
parameter DATASIZE = 32;
parameter ADDRSIZE = 10;

// Internal wires
wire int_wr;
wire [ADDRSIZE-1:0] int_addr;
wire [DATASIZE-1:0] int_din;
wire [DATASIZE-1:0] int_dout;

// Internal registers
reg int_stall = 1'b0;

assign int_wr = (dma_access) ? dma_wr : wr;
assign int_addr = (dma_access) ? dma_addr : addr;
assign int_din = (dma_access) ? dma_din : din;

// TODO set dout to 0s ?
assign dout = int_dout;
assign dma_dout = int_dout;
assign stall = int_stall;

always @ (posedge(clk))
begin
	int_stall = dma_access;
end

bram_single_port bram_spm_i
#(
	.DATASIZE = DATASIZE,
	.ADDRSIZE = ADDRSIZE
)
(
	.clk(clk),
	.wr(int_wr),
	.addr(int_addr),
	.din(int_din),
	.dout(int_dout)
);

endmodule
