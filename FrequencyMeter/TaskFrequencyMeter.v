module TaskFrequencyMeter
(
	input clk_50M,//标准信号，50M
	input rst,//复位信号
	input[7:0]sw,//拨码开关输入
	input signal_in,//输入待测信号1~10M
	output signal_out,//输出待测信号，1~10M
	output[31:0]M,//标准信号计数值 
	output[31:0]N,//待测信号计数值
	output gate_out//实际阀门输出（也就是精确门）
);

reg[31:0]M_reg;
reg[31:0]N_reg;
reg gate_out_reg;
reg signal_in2_out_reg;

wire[31:0]M_1;
wire[31:0]N_1;
wire[31:0]M_2;
wire[31:0]N_2;
wire gate_out_1;
wire gate_out_2;
wire signal_in2_out_1;
wire signal_in2_out_2;

assign M = M_reg;
assign N = N_reg;
assign gate_out = gate_out_reg;

always@(*)//对未分频信号的计数值以及已分频信号的计数值进行选择，低频信号N_1>=N_2,高频信号N_1=0，所以N_2>N_1
begin
	if (N_1 >= N_2)
	begin
		M_reg <= M_1;
		N_reg <= N_1;
		gate_out_reg <= gate_out_1;
		signal_in2_out_reg <= signal_in2_out_1;
	end
	else
	begin
		M_reg <= M_2;
		N_reg <= N_2 << 4;
		gate_out_reg <= gate_out_2;
		signal_in2_out_reg <= signal_in2_out_2;
	end
end

//输出信号
Divider_module Divider_module_inst//分频及输出
(
	.clk_50M(clk_50M),	// input  clk_50M_sig
	.rst(rst),	// input  rst_sig
	.sw(sw),	// input [7:0] sw_sig
	.signal_out(signal_out)	// output  signal_out_sig
);

//输入信号分频
Signal_in_div_module Signal_in_div_module_inst//输入信号16分频
(
	.signal_in(signal_in),	// input  signal_in_sig
	.rst(rst),	// input  rst_sig
	.signal_in1(signal_in1) 	// output  signal_in1_sig
);

//得到两种输入信号再同步
//输入信号同步
Signal_in_synchronize_module Signal_in_synchronize_module_inst1//输入信号同步（未分频）
(
	.clk_50M(clk_50M),	// input  clk_50M_sig
	.rst(rst),	// input  rst_sig
	.signal_in(signal_in),	// input  signal_in_sig
	.signal_in2(signal_in2_1),	// output  signal_in2_sig
	.signal_in2_out(signal_in2_out_1) 	// output  signal_in2_out_sig
);
Signal_in_synchronize_module Signal_in_synchronize_module_inst2//输入信号同步（已分频）
(
	.clk_50M(clk_50M),	// input  clk_50M_sig
	.rst(rst),	// input  rst_sig
	.signal_in(signal_in1),	// input  signal_in_sig
	.signal_in2(signal_in2_2),	// output  signal_in2_sig
	.signal_in2_out(signal_in2_out_2) 	// output  signal_in2_out_sig
);

//同步后分别测量
//输入信号测量
Gate_module Gate_module_inst1//输入信号测量（未分频）
(
	.clk_50M(clk_50M),	// input  clk_50M_sig
	.rst(rst),	// input  rst_sig
	.sw(sw),	// input [7:0] sw_sig
	.signal_in(signal_in2_1),	// input  signal_in_sig
	.M(M_1),	// output [31:0] M_sig
	.N(N_1),	// output [31:0] N_sig
	.gate_out(gate_out_1) 	// output  gate_out_sig
);
Gate_module Gate_module_inst2//输入信号测量（已分频）
(
	.clk_50M(clk_50M),	// input  clk_50M_sig
	.rst(rst),	// input  rst_sig
	.sw(sw),	// input [7:0] sw_sig
	.signal_in(signal_in2_2),	// input  signal_in_sig
	.M(M_2),	// output [31:0] M_sig
	.N(N_2),	// output [31:0] N_sig
	.gate_out(gate_out_2) 	// output  gate_out_sig
);

endmodule