module Signal_in_synchronize_module
(
	input clk_50M,
	input rst,
	input signal_in,
	output signal_in2,
	output signal_in2_out
);

//捕获待测信号的上升沿，为防止亚稳态，锁存两次
reg signal_reg1;
reg signal_reg2;

reg signal_in2_out_reg;

assign signal_in2 = signal_reg1;
assign signal_in2_out = signal_in2_out_reg;

always@(posedge clk_50M or negedge rst)
begin
	if (!rst)
	begin
		signal_reg1 <= 0;
		signal_reg2 <= 0;
	end
	else
	begin
		signal_in2_out_reg <= signal_reg1;
		signal_reg1 <= signal_reg2;
		signal_reg2 <= signal_in;
	end
end
endmodule
