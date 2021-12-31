module Special_mux_4_1 (
	input wire i_clk,
	input wire i_rst,
	input wire [3:0] i_selection,
	input wire [31:0] i_inputs [3:0],
	output wire [31:0] o_outputs,
	output wire o_en,
	output wire o_error_selection
);
assign o_error_selection = (i_selection[0] + i_selection[1] + i_selection[2] + i_selection[3]) > 1;
assign o_en = i_selection[0] | i_selection[1] | i_selection[2] | i_selection[3];

assign o_outputs = i_selection[0]? i_inputs[0] :
       i_selection[1]? i_inputs[1] :
       i_selection[2]? i_inputs[2] :
       i_inputs[3]? i_inputs[3] :
       31'b0;

endmodule
