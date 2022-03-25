module Signal_in_div_module
(
	input signal_in,
	input rst,
	output signal_in1
);

reg[31:0]cnt;
reg signal_in1_reg;

assign signal_in1 = signal_in1_reg;

always@(posedge signal_in or negedge rst)
begin
	if (!rst)
	begin
		cnt <= 0;
		signal_in1_reg <= 0;
	end
	else
	begin
		cnt <= (cnt < 8 - 1) ? (cnt + 1) : 0;//16分频
		if (cnt == 8 - 1)
		begin
			signal_in1_reg <= ~signal_in1_reg;
		end
	end
end

endmodule