module Gate_module
(
	input clk_50M,
	input rst,
	input[7:0]sw,
	input signal_in,
	output[31:0]M,//标准信号计数值
	output[31:0]N,//待测信号计数值
	output gate_out
);

reg gate_out_reg;//实际闸门
reg presetGate;//预置闸门

reg[31:0]cnt;

reg[7:0]sw_reg;
reg presetGate_reg;
reg signal_in_reg;

reg[1:0]state;

reg[31:0]num_s;
reg[31:0]num_in;

reg[31:0]M_reg;
reg[31:0]N_reg;

assign M = M_reg;//M_out
assign N = N_reg;//N_out
assign gate_out = gate_out_reg;

always@(posedge clk_50M or negedge rst)//状态机
begin
	if (!rst)
	begin
		cnt <= 0;
		state <= 0;
		presetGate <= 0;
		gate_out_reg <= 0;

		presetGate_reg <= 0;
		signal_in_reg <= 0;

		num_in <= 0;
		num_s <= 0;

		M_reg <= 0;
		N_reg <= 0;
	end
	else
	begin
		cnt <= (cnt < 50_000_000 * 2 - 1) ? (cnt + 1) : 0;//0.5Hz/2s
		presetGate <= (cnt < 50_000_000) ? 1 : 0;//占空比50%

		sw_reg <= sw;
		presetGate_reg <= presetGate;
		signal_in_reg <= signal_in;

		if (sw_reg != sw)
		begin
			cnt <= 0;
			state <= 0;
			presetGate <= 0;
			gate_out_reg <= 0;

			presetGate_reg <= 0;
			signal_in_reg <= 0;

			num_in <= 0;
			num_s <= 0;

			M_reg <= 0;
			N_reg <= 0;
		end
		else
		begin
			case(state)
			0://等待预置闸门上升沿
			begin
				if (presetGate_reg == 0 & presetGate == 1)
				begin
					num_s <= 0;
					num_in <= 0;

					state <= 1;
				end
			end
			1://等待待测信号上升沿
			begin
				if (signal_in_reg == 0 & signal_in == 1)
				begin
					num_s <= 1;
					num_in <= 1;

					gate_out_reg <= 1;
					state <= 2;
				end
			end
			2://等待预置闸门下降沿
			begin
				num_s <= num_s + 1;//标准信号计数
				if (signal_in_reg == 0 & signal_in == 1)
				begin
					num_in <= num_in + 1;//分频待测信号计数
				end
				if (presetGate_reg == 1 & presetGate == 0)
				begin
					state <= 3;
				end
			end
			3://等待待测信号上升沿
			begin
				num_s <= num_s + 1;//标准信号计数
				if (signal_in_reg == 0 & signal_in == 1)
				begin
					M_reg <= num_s;
					N_reg <= num_in;

					gate_out_reg <= 0;
					state <= 0;
				end
			end
			default:
			begin
				state <= 0;
			end
			endcase
		end
	end
end

endmodule