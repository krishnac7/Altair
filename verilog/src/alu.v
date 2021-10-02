// Parametric Arithmetic Logic Unit
`define FUNC_ADD 4'b0000
`define FUNC_SLTS 4'b0010
`define FUNC_SLTU 4'b1010
module ALU (
	input wire i_clk,
	input wire i_rst,
	input wire i_en,

	input wire [3:0] i_function,
	input wire i_inv_c, // make c = -c
	input wire [31:0] i_b,
	input wire [31:0] i_c,
	input wire [5:0] i_rd,

	output wire [5:0] o_rd, // destination register
	output wire [31:0] o_val, // value to write to the destination
	output wire o_wr // 1'b1 to write o_val to register o_rd
);

wire is_func_add;
wire [31:0] inv_c;
wire [31:0] result_sum;
wire carry_sum;
wire sum_carry_sign;

wire cmp_eq; // TODO unused
wire cmp_lts;
wire cmp_ltu;

assign cmp_eq = (i_b == i_c);
assign cmp_lts = (i_b[31] != i_c[31]) ? i_b[31] : (i_b[31]!=sum_carry_sign);
assign cmp_ltu = !carry_sum;

assign inv_c = i_inv_c ? (~i_c)+1 : i_c;
assign {carry_sum, result_sum} = i_b + inv_c;
assign sum_carry_sign = result_sum[31];

assign o_rd = i_rd;

assign o_val = (i_function == `FUNC_ADD) ? result_sum :
	(i_function == `FUNC_SLTS) ? cmp_lts:
	(i_function == `FUNC_SLTU) ? cmp_ltu:
	32'b0;

assign o_wr = i_en;
	
endmodule

