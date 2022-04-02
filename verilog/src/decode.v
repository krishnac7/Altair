// Should match bits 1 to 7
`define ALU_ADD 7'b1000000
`define ALU_SUB 7'b1001000
`define ALU_XOR 7'b1000100
`define ALU_OR  7'b1001100
`define ALU_AND 7'b1000010
`define ALU_LSL 7'b1001010
`define ALU_ASR 7'b1000110
`define ALU_LSR 7'b1001110
`define ALU_MULS 7'b1000001
`define ALU_MULU 7'b1001001
`define ALU_DIVS 7'b1000101
`define ALU_DIVU 7'b1001101
`define ALU_REMS 7'b1000011
`define ALU_REMU 7'b1001011
`define ALU_ADDI 7'b1000000 // INSTR[10] is set
`define ALU_SUBI 7'b1001000 // INSTR[10] is set
`define ALU_XORI 7'b1000100 // INSTR[10] is set
`define ALU_ORI 7'b1001100 // INSTR[10] is set
`define ALU_ANDI 7'b1000010 // INSTR[10] is set
`define ALU_LSLI 7'b1001010 // INSTR[10] is set
`define ALU_ASRI 7'b1000110 // INSTR[10] is set
`define ALU_LSRI 7'b1001110 // INSTR[10] is set
`define ALU_MULSI 7'b1000001 // INSTR[10] is set
`define ALU_MULUI 7'b1001001 // INSTR[10] is set
`define ALU_DIVSI 7'b1000101 // INSTR[10] is set
`define ALU_DIVUI 7'b1001101 // INSTR[10] is set
`define ALU_REMSI 7'b1000011 // INSTR[10] is set
`define ALU_REMUI 7'b1001011 // INSTR[10] is set
`define ALU_NOP 7'b0000000
`define ALU_SEXT 7'b0001000
`define ALU_BOOL 7'b0000100
`define ALU_SLTS 7'b0000010
`define ALU_SLTU 7'b0001010
`define ALU_SLTSI 7'b0000110
`define ALU_SLTUI 7'b0001110
`define ALU_SMOVE 7'b0000001
`define ALU_SMOVEU 7'b0001001
`define ALU_MOVEI 7'b0000101
`define ALU_MOVEIU 7'b0001101
`define ALU_MOVEINS 7'b0000011
`define ALU_MOVECYC 7'b0001011
`define ALU_MOVERI 7'b0000111 
`define ALU_MOVE 7'b0001111 

`define LSU_LDM 7'b0100000 
`define LSU_STM 7'b0101000 
`define LSU_LDMV 7'b0100100 
`define LSU_STMV 7'b0101100 
`define LSU_LDMI 7'b0100010 
`define LSU_STMI 7'b0101010 
`define LSU_LDMVI 7'b0100110 
`define LSU_STMVI 7'b0101110 
`define LSU_LDML 7'b0100001 
`define LSU_STML 7'b0101001 
`define LSU_LDMVL 7'b0100101 
`define LSU_STMVL 7'b0101101 
`define LSU_LDC 7'b1100000 
`define LSU_STC 7'b1101000 
`define LSU_LDCV 7'b1100100 
`define LSU_STCV 7'b1101100 
`define LSU_LDCI 7'b1100010 
`define LSU_STCI 7'b1101010 
`define LSU_LDCVI 7'b1100110 
`define LSU_STCVI 7'b1101110 
`define LSU_LDCL 7'b1100001 
`define LSU_STCL 7'b1101001 
`define LSU_LDCVL 7'b1100101 
`define LSU_STCVL 7'b1101101 
`define LSU_PREFETCH 7'b1100011 
`define LSU_FLUSH 7'b1101011 
`define LSU_PREFETCH 7'b1100111 
`define LSU_FLUSH 7'b1101111 

`define CMP_CMP 7'b0010000
`define CMP_CMPFRI 7'b0011000
`define CMP_CMPI 7'b0010100
`define CMP_CMPIU 7'b0011100
`define CMP_FCMP 7'b0010010
`define CMP_DCMP 7'b0011010
`define CMP_FCMPI 7'b0010110
`define CMP_DCMPI 7'b0011110
`define CMP_ENDP 7'b0010001
`define CMP_SYSCALL 7'b0011001
`define CMP_INT 7'b0010101
`define CMP_RET 7'b0010011
`define CMP_RETI 7'b0011011
`define CMP_RETC 7'b0010111

`define BRU_BNE 7'b1010000
`define BRU_BEQ 7'b1011000
`define BRU_BL 7'b1010100
`define BRU_BLE 7'b1011100
`define BRU_BG 7'b1010010
`define BRU_BGE 7'b1011010
`define BRU_BLS 7'b1010110
`define BRU_BLES 7'b1011110
`define BRU_BGS 7'b1010001
`define BRU_BGES 7'b1011001
`define BRU_BRA 7'b1010101
`define BRU_JUMP 7'b1011101
`define BRU_JUMPBR 7'b1010011
`define BRU_CALL 7'b1011011
`define BRU_CALLBR 7'b1010111

`define VFPU_FADD 7'b0110000
`define VFPU_FSUB 7'b0111000
`define VFPU_FMUL 7'b0110100
`define VFPU_FMULADD 7'b0111100
`define VFPU_VFADD 7'b0110010
`define VFPU_VFSUB 7'b0111010
`define VFPU_VFMUL 7'b0110110
`define VFPU_VFMULADD 7'b0111110
`define VFPU_VFADDS 7'b0110001
`define VFPU_VFSUBS 7'b0111001
`define VFPU_VFMULS 7'b0110101
`define VFPU_VFMULADDS 7'b0111101
`define VFPU_FMULSUB 7'b0110011
`define VFPU_VFMULSUB 7'b0111011
`define VFPU_VFMULSUBS 7'b0110111
`define VFPU_VFSHUFFLE 7'b0111111
`define VFPU_FMOVE 7'b1110000
`define VFPU_VMOVE 7'b1111000
`define VFPU_FMOVEI 7'b1110100
`define VFPU_VFMOVEI 7'b1111100
`define VFPU_FNEG 7'b1110010
`define VFPU_FABS 7'b1111010
`define VFPU_VFNEG 7'b1110110
`define VFPU_VFABS 7'b1111110
`define VFPU_VFTOH 7'b1110001
`define VFPU_VHTOF 7'b1111001
`define VFPU_VFTOI 7'b1110101
`define VFPU_VITOF 7'b1111101
`define VFPU_VFTOD 7'b1110011
`define VFPU_VDTOF 7'b1111011
`define VFPU_FMIN 7'b1110111
`define VFPU_FMAX 7'b1111111
`define VFPU_FDIV 7'b0110000
`define VFPU_FSQRT 7'b0111000
`define VFPU_FATAN 7'b0110010
`define VFPU_FATAN2 7'b0111010
`define VFPU_FEXP 7'b0110110
`define VFPU_FSUM 7'b0110001
`define VFPU_FIPR 7'b0111001
`define VFPU_FSIN 7'b0110101
`define VFPU_DMOVEI 7'b1110000
`define VFPU_DADD 7'b1111000
`define VFPU_DSUB 7'b1110100
`define VFPU_DMUL 7'b1111100
`define VFPU_DABS 7'b1110010
`define VFPU_DNEG 7'b1111010
`define VFPU_DMIN 7'b1110110
`define VFPU_DMAX 7'b1111110
`define VFPU_DDIV 7'b1110001
`define VFPU_DSQRT 7'b1111001
`define VFPU_DSIN 7'b1110101

`define DMA_LDDMA 7'b1010000
`define DMA_STDMA 7'b1011000
`define DMA_LDDMACL 7'b1010100
`define DMA_STDMACL 7'b1011100
`define DMA_DMAI 7'b1010010
`define DMA_LDDMA 7'b1010001
`define DMA_STDMA 7'b1011001
`define DMA_LDDMACL 7'b1010101
`define DMA_STDMACL 7'b1011101
`define DMA_DMAI 7'b1010011
`define DMA_WAIT 7'b1011111

// TODO use "don't care" to decode the instructions

// identify the EXecution Unit to be used
// Used by the Decode module to know if an intruction
// should be interpreted as ALU, LSU, BRU...
module identify_exu (
	input wire [31:0] instruction,
	input wire commit,
	ouput wire is_ALU,
	output wire is_VFPU,
	output wire is_LSU,
	output wire is_BRU,
	output wire is_DMA,
	output wire is_CMP
);
	// TODO optimise for "do not care"
	assign is_ALU = commit & (instruction[1:7] == ALU_ADD ||
		instruction[1:7] == ALU_SUB || 
		instruction[1:7] == ALU_XOR ||
		instruction[1:7] == ALU_OR ||
		instruction[1:7] == ALU_AND ||
		instruction[1:7] == ALU_LSL ||
		instruction[1:7] == ALU_ASR ||
		instruction[1:7] == ALU_LSR ||
		instruction[1:7] == ALU_MULS ||
		instruction[1:7] == ALU_MULU ||
		instruction[1:7] == ALU_DIVS ||
		instruction[1:7] == ALU_DIVU ||
		instruction[1:7] == ALU_REMS ||
		instruction[1:7] == ALU_REMU ||
		instruction[1:7] == ALU_ADDI ||
		instruction[1:7] == ALU_SUBI ||
		instruction[1:7] == ALU_XORI ||
		instruction[1:7] == ALU_ORI ||
		instruction[1:7] == ALU_ANDI ||
		instruction[1:7] == ALU_LSLI ||
		instruction[1:7] == ALU_ASRI ||
		instruction[1:7] == ALU_LSRI ||
		instruction[1:7] == ALU_MULSI ||
		instruction[1:7] == ALU_MULUI ||
		instruction[1:7] == ALU_DIVSI ||
		instruction[1:7] == ALU_DIVUI ||
		instruction[1:7] == ALU_REMSI ||
		instruction[1:7] == ALU_REMUI ||
		instruction[1:7] == ALU_NOP ||
		instruction[1:7] == ALU_SEXT ||
		instruction[1:7] == ALU_BOOL ||
		instruction[1:7] == ALU_SLTS ||
		instruction[1:7] == ALU_SLTU ||
		instruction[1:7] == ALU_SLTSI ||
		instruction[1:7] == ALU_SLTUI ||
		instruction[1:7] == ALU_SMOVE ||
		instruction[1:7] == ALU_SMOVEU ||
		instruction[1:7] == ALU_MOVEI ||
		instruction[1:7] == ALU_MOVEIU ||
		instruction[1:7] == ALU_MOVEINS ||
		instruction[1:7] == ALU_MOVECYC ||
		instruction[1:7] == ALU_MOVERI ||
		instruction[1:7] == ALU_MOVE);

	assign is_VFPU = commit & (instruction[1:7] == VFPU_FADD ||
		instruction[1:7] == VFPU_FSUB ||
		instruction[1:7] == VFPU_FMUL ||
		instruction[1:7] == VFPU_FMULADD ||
		instruction[1:7] == VFPU_VFADD ||
		instruction[1:7] == VFPU_VFSUB ||
		instruction[1:7] == VFPU_VFMUL ||
		instruction[1:7] == VFPU_VFMULADD ||
		instruction[1:7] == VFPU_VFADDS ||
		instruction[1:7] == VFPU_VFSUBS ||
		instruction[1:7] == VFPU_VFMULS ||
		instruction[1:7] == VFPU_VFMULADDS ||
		instruction[1:7] == VFPU_FMULSUB ||
		instruction[1:7] == VFPU_VFMULSUB ||
		instruction[1:7] == VFPU_VFMULSUBS ||
		instruction[1:7] == VFPU_VFSHUFFLE ||
		instruction[1:7] == VFPU_FMOVE ||
		instruction[1:7] == VFPU_VMOVE ||
		instruction[1:7] == VFPU_FMOVEI ||
		instruction[1:7] == VFPU_VFMOVEI ||
		instruction[1:7] == VFPU_FNEG ||
		instruction[1:7] == VFPU_FABS ||
		instruction[1:7] == VFPU_VFNEG ||
		instruction[1:7] == VFPU_VFABS ||
		instruction[1:7] == VFPU_VFTOH ||
		instruction[1:7] == VFPU_VHTOF ||
		instruction[1:7] == VFPU_VFTOI ||
		instruction[1:7] == VFPU_VITOF ||
		instruction[1:7] == VFPU_VFTOD ||
		instruction[1:7] == VFPU_VDTOF ||
		instruction[1:7] == VFPU_FMIN ||
		instruction[1:7] == VFPU_FMAX ||
		instruction[1:7] == VFPU_FDIV ||
		instruction[1:7] == VFPU_FSQRT ||
		instruction[1:7] == VFPU_FATAN ||
		instruction[1:7] == VFPU_FATAN2 ||
		instruction[1:7] == VFPU_FEXP ||
		instruction[1:7] == VFPU_FSUM ||
		instruction[1:7] == VFPU_FIPR ||
		instruction[1:7] == VFPU_FSIN ||
		instruction[1:7] == VFPU_DMOVEI ||
		instruction[1:7] == VFPU_DADD ||
		instruction[1:7] == VFPU_DSUB ||
		instruction[1:7] == VFPU_DMUL ||
		instruction[1:7] == VFPU_DABS ||
		instruction[1:7] == VFPU_DNEG ||
		instruction[1:7] == VFPU_DMIN ||
		instruction[1:7] == VFPU_DMAX ||
		instruction[1:7] == VFPU_DDIV ||
		instruction[1:7] == VFPU_DSQRT ||
		instruction[1:7] == VFPU_DSIN);
	assign is_LSU = commit & (instruction[1:7] == LSU_LDM || 
		instruction[1:7] == LSU_STM || 
		instruction[1:7] == LSU_LDMV || 
		instruction[1:7] == LSU_STMV || 
		instruction[1:7] == LSU_LDMI || 
		instruction[1:7] == LSU_STMI || 
		instruction[1:7] == LSU_LDMVI || 
		instruction[1:7] == LSU_STMVI || 
		instruction[1:7] == LSU_LDML || 
		instruction[1:7] == LSU_STML || 
		instruction[1:7] == LSU_LDMVL || 
		instruction[1:7] == LSU_STMVL || 
		instruction[1:7] == LSU_LDC || 
		instruction[1:7] == LSU_STC || 
		instruction[1:7] == LSU_LDCV || 
		instruction[1:7] == LSU_STCV || 
		instruction[1:7] == LSU_LDCI || 
		instruction[1:7] == LSU_STCI || 
		instruction[1:7] == LSU_LDCVI || 
		instruction[1:7] == LSU_STCVI || 
		instruction[1:7] == LSU_LDCL || 
		instruction[1:7] == LSU_STCL || 
		instruction[1:7] == LSU_LDCVL || 
		instruction[1:7] == LSU_STCVL || 
		instruction[1:7] == LSU_PREFETCH || 
		instruction[1:7] == LSU_FLUSH || 
		instruction[1:7] == LSU_PREFETCH || 
		instruction[1:7] == LSU_FLUSH);
	assign is_BRU = commit & (instruction[1:7] == BRU_BNE ||
		instruction[1:7] == BRU_BEQ ||
		instruction[1:7] == BRU_BL ||
		instruction[1:7] == BRU_BLE ||
		instruction[1:7] == BRU_BG ||
		instruction[1:7] == BRU_BGE ||
		instruction[1:7] == BRU_BLS ||
		instruction[1:7] == BRU_BLES ||
		instruction[1:7] == BRU_BGS ||
		instruction[1:7] == BRU_BGES ||
		instruction[1:7] == BRU_BRA ||
		instruction[1:7] == BRU_JUMP ||
		instruction[1:7] == BRU_JUMPBR ||
		instruction[1:7] == BRU_CALL ||
		instruction[1:7] == BRU_CALLBR);
	assign is_DMA = commit & (instruction[1:7] == DMA_LDDMA ||
		instruction[1:7] == DMA_STDMA ||
		instruction[1:7] == DMA_LDDMACL ||
		instruction[1:7] == DMA_STDMACL ||
		instruction[1:7] == DMA_DMAI ||
		instruction[1:7] == DMA_LDDMA ||
		instruction[1:7] == DMA_STDMA ||
		instruction[1:7] == DMA_LDDMACL ||
		instruction[1:7] == DMA_STDMACL ||
		instruction[1:7] == DMA_DMAI ||
		instruction[1:7] == DMA_WAIT);
	assign is_CMP = commit & (instruction[1:7] == CMP_CMP ||
		instruction[1:7] == CMP_CMPFRI ||
		instruction[1:7] == CMP_CMPI ||
		instruction[1:7] == CMP_CMPIU ||
		instruction[1:7] == CMP_FCMP ||
		instruction[1:7] == CMP_DCMP ||
		instruction[1:7] == CMP_FCMPI ||
		instruction[1:7] == CMP_DCMPI ||
		instruction[1:7] == CMP_ENDP ||
		instruction[1:7] == CMP_SYSCALL ||
		instruction[1:7] == CMP_INT ||
		instruction[1:7] == CMP_RET ||
		instruction[1:7] == CMP_RETI ||
		instruction[1:7] == CMP_RETC);
endmodule

// ALU specific final decoding and instanciate the arithmetic logic
module Decode_ALU (
	input wire i_clk,
	input wire i_rst,
	input wire i_en,

	input wire [31:0] i_instr,

	output reg o_rd, // 
	output reg o_val, // value to be written
	output reg o_wr, 
);
reg alu_en := 1'b0;
reg alu_function;
reg alu_inv_c;
reg alu_use_imm;
reg alu_b;
reg alu_c;
reg alu_imm;
reg alu_rd;

wire alu_o_rd;
wire alu_o_val;
wire alu_o_wr;

// store ALU's outputs in registers
always @ (posedge(i_clk)
begin
	o_rd <= alu_o_rd;
	o_val <= alu_o_val;
	o_wr <= alu_o_wr;
end

// TODO	issue to N ALU 
always @ (posedge(i_clk))
begin
	if (i_instr_0[7:4] == OPCODE_ADD || i_instr_0[7:4] == OPCODE_SUB)
		alu_en = 1'b1;
	else
		alu_en = 1'b0;

	alu_function = i_instr_0[7:4];
	alu_inv_c = i_instr_0[7:4] == OPCODE_SUB;
	alu_use_imm = i_instr_0[10];
	alu_b = i_instr_0[25:20];
	alu_c = i_instr_0[19:14];

	// Set imm is needed
	if (i_instr_0[10] == 1'b1)
	begin
		// Signed extend
		if (i_instr_0[7:4] == OPCODE_XORI ||
			i_instr_0[7:4] == OPCODE_ORI ||
			i_instr_0[7:4] == OPCODE_ANDI)
			alu_imm = {23'hffffff, i_instr_0[19:11]};
		// Unsigned extend
		else if (i_instr_0[7:4] == OPCODE_ADDI ||
			i_instr_0[7:4] == OPCODE_SUBI ||
			i_instr_0[7:4] == OPCODE_LSLI ||
			i_instr_0[7:4] == OPCODE_ASRI ||
			i_instr_0[7:4] == OPCODE_LSRI)
			alu_imm = {23'h000000, i_instr_0[19:11]};
		// Unsigned from 16 bits
		else if (i_instr_0[7:4] == OPCODE_SMOVE)
			alu_imm = {16'h0000, i_instr_0[25:10]};
		// Signed from 18 bits
		else if (i_instr_0[7:4] == OPCODE_MOVEI)
			alu_imm = {14'hffff, i_instr_0[25:8]};
		// Unsigned from 18 bits
		else if (i_instr_0[7:4] == OPCODE_MOVEIU)
			alu_imm = {14'h0000, i_instr_0[25:8]};
		else alu_imm = 32'h00000000;
	end
end

alu alu(
	.i_clk (i_clk),
	.i_rst (i_rst),
	.i_en (alu_en),

	// Inputs
	.i_function(alu_function),
	.i_inv_c(alu_inv_c),
	.i_use_imm(alu_use_imm),
	.i_b(alu_b),
	.i_c(alu_c),
	.i_imm(alu_imm),
	.i_rd(alu_rd),

	// Outputs
	.o_rd(alu_o_rd),
	.o_val(alu_o_val),
	.o_wr(alu_o_wr)
);

endmodule
			
// Decode 4 instructions and assign them to ALU/LSU/VFPU/BRU/DMA/CMP specific
// decode function (cf Decode_ALU)
// FIXME update the comment with Decode_LSU...
module Decode (
	input wire i_clk,
	input wire i_rst,
	input wire i_en,

	input wire i_instr_0_commit,
	input wire [31:0] i_instr_0,
	input wire i_instr_1_commit,
	input wire [31:0] i_instr_1,
	input wire i_instr_2_commit,
	input wire [31:0] i_instr_2,
	input wire i_instr_3_commit,
	input wire [31:0] i_instr_3,

	ouput wire error_missing_alu, // Too many instructions require ALU
	ouput wire error_missing_vfpu,
	ouput wire error_missing_lsu,
	ouput wire error_missing_bru,
	ouput wire error_missing_dma,
	ouput wire error_missing_cmp,
);

wire instr_0_ALU;
wire instr_0_VFPU;
wire instr_0_LSU;
wire instr_0_BRU;
wire instr_0_DMA;
wire instr_0_CMP;
identify_exu id_exu_0 (
	.instruction(i_instr_0),
	.commit(i_instr_0_commit),
	.is_ALU(instr_0_ALU),
	.is_VFPU(instr_0_VFPU),
	.is_LSU(instr_0_LSU),
	.is_BRU(instr_0_BRU),
	.is_DMA(instr_0_DMA),
	.is_CMP(instr_0_CMP)
);

wire instr_1_ALU;
wire instr_1_VFPU;
wire instr_1_LSU;
wire instr_1_BRU;
wire instr_1_DMA;
wire instr_1_CMP;
identify_exu id_exu_1 (
	.instruction(i_instr_1),
	.commit(i_instr_1_commit),
	.is_ALU(instr_1_ALU),
	.is_VFPU(instr_1_VFPU),
	.is_LSU(instr_1_LSU),
	.is_BRU(instr_1_BRU),
	.is_DMA(instr_1_DMA),
	.is_CMP(instr_1_CMP)
);

wire instr_2_ALU;
wire instr_2_VFPU;
wire instr_2_LSU;
wire instr_2_BRU;
wire instr_2_DMA;
wire instr_2_CMP;
identify_exu id_exu_2 (
	.instruction(i_instr_2),
	.commit(i_instr_2_commit),
	.is_ALU(instr_2_ALU),
	.is_VFPU(instr_2_VFPU),
	.is_LSU(instr_2_LSU),
	.is_BRU(instr_2_BRU),
	.is_DMA(instr_2_DMA),
	.is_CMP(instr_2_CMP)
);

wire instr_3_ALU;
wire instr_3_VFPU;
wire instr_3_LSU;
wire instr_3_BRU;
wire instr_3_DMA;
wire instr_3_CMP;
identify_exu id_exu_3 (
	.instruction(i_instr_3),
	.commit(i_instr_3_commit),
	.is_ALU(instr_3_ALU),
	.is_VFPU(instr_3_VFPU),
	.is_LSU(instr_3_LSU),
	.is_BRU(instr_3_BRU),
	.is_DMA(instr_3_DMA),
	.is_CMP(instr_3_CMP)
);

wire [31:0] muxed_ALU_0;
wire en_ALU_0;
wire [31:0] muxed_ALU_1;
wire en_ALU_1;
// Assign an instruction to an ALU (Arithmetic Logic Unit) parser
// TODO no hardcoded number of ALU (2 here)
Special_mux_4_2 alu_mux(
	.i_clk(i_clk),
	.i_rst(i_rst),
	.i_selection({instr_3_ALU, instr_2_ALU, instr_1_ALU, instr_0_ALU}),
	.i_inputs({i_instr_3, i_instr_2, i_instr_1, i_instr_0}),
	.o_outputs({muxed_ALU_0, muxed_ALU_1}), // TODO
	.o_en({en_ALU_0, en_ALU_1}),
	.o_error_selection(error_missing_alu)
);

// TODO no hardcoded number of VFPU (1 here)
Special_mux_4_1 vfpu_mux(
	.i_clk(i_clk),
	.i_rst(i_rst),
	.i_selection({instr_3_VFPU, instr_2_VFPU, instr_1_VFPU, instr_0_VFPU}),
	.i_inputs({i_instr_3, i_instr_2, i_instr_1, i_instr_0}),
	.o_outputs(), // TODO
	.o_en(),
	.o_error_selection(error_missing_vfpu)
);

// TODO no hardcoded number of LSU (2 here)
Special_mux_4_2 lsu_mux(
	.i_clk(i_clk),
	.i_rst(i_rst),
	.i_selection({instr_3_LSU, instr_2_LSU, instr_1_LSU, instr_0_LSU}),
	.i_inputs({i_instr_3, i_instr_2, i_instr_1, i_instr_0}),
	.o_outputs(), // TODO
	.o_en(),
	.o_error_selection(error_missing_lsu)
);

// TODO no hardcoded number of BRU (1 here)
Special_mux_4_1 bru_mux(
	.i_clk(i_clk),
	.i_rst(i_rst),
	.i_selection({instr_3_BRU, instr_2_BRU, instr_1_BRU, instr_0_BRU}),
	.i_inputs({i_instr_3, i_instr_2, i_instr_1, i_instr_0}),
	.o_outputs(), // TODO
	.o_en(),
	.o_error_selection(error_missing_bru)
);

// TODO no hardcoded number of DMA (1 here)
Special_mux_4_1 dma_mux(
	.i_clk(i_clk),
	.i_rst(i_rst),
	.i_selection({instr_3_DMA, instr_2_DMA, instr_1_DMA, instr_0_DMA}),
	.i_inputs({i_instr_3, i_instr_2, i_instr_1, i_instr_0}),
	.o_outputs(), // TODO
	.o_en(),
	.o_error_selection(error_missing_dma)
);

// TODO no hardcoded number of CMP (1 here)
Special_mux_4_1 cmp_mux(
	.i_clk(i_clk),
	.i_rst(i_rst),
	.i_selection({instr_3_CMP, instr_2_CMP, instr_1_CMP, instr_0_CMP}),
	.i_inputs({i_instr_3, i_instr_2, i_instr_1, i_instr_0}),
	.o_outputs(), // TODO
	.o_en(),
	.o_error_selection(error_missing_cmp)
);

// FIXME instanciate Decode_ALU
// takes as input:
//	[31:0] muxed_ALU_0;
//	en_ALU_0;

// FIXME instanciate Decode_ALU
// takes as input:
//	[31:0] muxed_ALU_1;
//	en_ALU_1;

endmodule
