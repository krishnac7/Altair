/*
* i_selection consists in 4 logic wires s0, s1, s2, s3...
* Wire N wires from i_inputs to o_outputs (N <= 2)
*
* Example:
* if i_selection=1010 then
* o_outputs={i_inputs[0], i_inputs[2]}, o_error_selection=0
* if i_selection=1011 then
* o_outputs={i_inputs[0], i_inputs[2]}, o_error_selection=1
*/
module Special_mux_4_2 (
	input wire i_clk,
	input wire i_rst,
	input wire [3:0] i_selection,
	input wire [31:0] i_inputs [3:0],
	output wire [31:0] o_outputs [1:0],
	output wire [1:0] o_en,
	output wire o_error_selection
);
assign o_error_selection = (i_selection[0] + i_selection[1] + i_selection[2] + i_selection[3]) > 2;
assign o_en[0] = i_selection[0] | i_selection[1] | i_selection[2] | i_selection[3];
assign o_en[1] = (i_selection[0] + i_selection[1] + i_selection[2] + i_selection[3]) > 1;

assign o_outputs[0] = i_selection[0]? i_inputs[0] :
       i_selection[1]? i_inputs[1] :
       i_selection[2]? i_inputs[2] :
       i_inputs[3]? i_inputs[3] :
       31'b0;
assign o_outputs[1] = i_selection[0]? (i_selection[1]? i_inputs[1]:(i_selection[2]? i_inputs[2]: i_inputs[3])) :
		(i_selection[1]? (i_selection[2]? i_inputs[2]: i_inputs[3]): 
		i_inputs[3]);

endmodule

// An other possible implementation
module Special_mux_bis_4_2 (
	input wire i_clk,
	input wire i_rst,
	input wire [3:0] i_selection,
	input wire [31:0] i_inputs [3:0],
	output wire [31:0] o_outputs [1:0],
	output wire [1:0] o_en,
	output wire o_error_selection
);
wire [3:0] int_selection_0;

assign o_error_selection = (i_selection[0] + i_selection[1] + i_selection[2] + i_selection[3]) > 2;

assign o_outputs[0] = i_selection[0]? i_inputs[0] :
	i_selection[1]? i_inputs[1] :
	i_selection[2]? i_inputs[2] :
	i_inputs[3];
assign o_en[0] = i_selection[0] | i_selection[1] | i_selection[2] | i_selection[3];

assign int_selection_0[0] = 1'b0;
assign int_selection_0[1] = i_selection[1] & i_selection[0];
assign int_selection_0[2] = i_selection[2] & (i_selection[0] | i_selection[1]);
assign int_selection_0[3] = i_selection[3] & (i_selection[0] | i_selection[1] | i_selection[2]);


assign o_outputs[1] = int_selection_0[0]? i_inputs[0] :
	int_selection_0[1]? i_inputs[1] :
	int_selection_0[2]? i_inputs[2] :
	i_inputs[3];
assign o_en[1] = (i_selection[0] + i_selection[1] + i_selection[2] + i_selection[3]) > 1;

endmodule
