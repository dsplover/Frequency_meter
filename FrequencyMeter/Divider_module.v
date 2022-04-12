module Divider_module//分频器，8个拨码开关选择特定频率，缺省值为10M。
(
	input clk_50M,
	input rst,
	input[7:0]sw,
	output signal_out
);

reg signal_reg;

reg[31:0]cntFlag;
reg[31:0]cnt;

reg[2:0]flag;//逻辑门选择信号

//实际为7选1选择器，用flag值来快速实现
assign signal_out =
(signal_reg & (flag == 0))//clk_50M分频
| (clk_50M & (flag == 1))//PLL
| (clk_100M & (flag == 2))
| (clk_150M & (flag == 3))
| (clk_200M & (flag == 4))
| (clk_300M & (flag == 5))
| (clk_400M & (flag == 6));

PLL	PLL_inst//高频信号使用PLL生成
(
	.inclk0(clk_50M),
	.c0(clk_100M),
	.c1(clk_150M),
	.c2(clk_200M),
	.c3(clk_300M),
	.c4(clk_400M)
);


always@(posedge clk_50M or negedge rst)//分频信号产生
begin
	if (!rst)
	begin
		cnt <= 0;
		signal_reg <= 0;
	end
	else
	begin
		cnt <= (cnt < cntFlag - 1) ? (cnt + 1) : 0;
		signal_reg <= (cnt < cntFlag[31:1]) ? 1 : 0;
	end
end

always@(sw)//通过拨码开关得到flag以及cntflag的值
begin
	case(sw)
		8'b0000_0001 : //1Hz
	begin
		flag <= 0;
		cntFlag <= 50_000_000 / 1;
	end
	8'b0000_0010 : //25/24Hz
	begin
		flag <= 0;
		cntFlag <= 50_000_000 / 25 * 24;
	end
	8'b0000_0100 : //199Hz
	begin
		flag <= 0;
		cntFlag <= 50_000_000 / 199;
	end
	8'b0000_1000 : //1KHz
	begin
		flag <= 0;
		cntFlag <= 50_000_000 / 1_000;
	end
	8'b0001_0000 : //1MHz
	begin
		flag <= 0;
		cntFlag <= 50_000_000 / 1_000_000;
	end
	8'b0010_0000 : //25MHz
	begin
		flag <= 0;
		cntFlag <= 50_000_000 / 25_000_000;
	end
	8'b0100_0000 : //50MHz
	begin
		flag <= 1;
	end
	8'b1000_0000 : //100MHz
	begin
		flag <= 2;
	end
	8'b0110_0000 : //150MHz
	begin
		flag <= 3;
	end
	8'b1010_0000 : //200MHz
	begin
		flag <= 4;
	end
	8'b1100_0000 : //300MHz
	begin
		flag <= 5;
	end
	8'b1110_0000 : //max:400MHz
	begin
		flag <= 6;
	end
	default://10MHz
	begin
		flag <= 0;
		cntFlag <= 50_000_000 / 10_000_000;
	end
	endcase
end

endmodule