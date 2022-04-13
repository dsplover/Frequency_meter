# FrequencyMeter
## FPGA EP4CE6F17C8实现FrequencyMeter(频率计)
频率也由FPGA输出
使用quartus ii 将文件下载至FPGA板，连接FPGA的T13，R13管脚，使用signaltap显示测量值M，N
fre=N/M*50_000_000
## 模块设计
- 顶层模块TaskFrequencyMeter：
对M，N的选择组合逻辑（比较N_1，N_2大小），
输出信号模块实例Divider_module_inst，
输入信号分频模块实例Signal_in_div_module_inst，
输入信号未分频和已分频的时钟同步模块实例Signal_in_synchronize_module_inst1、2，
输入信号未分频和已分频的测量模块实例Gate_module_inst1、2
- 输出信号模块Divider_module
8位拨码开关与7选1选择器选择最终的输出信号
PLL输出高频
对clk_50M进行分频
8位拨码开关对输出信号进行选择以及对分频情况进行选择
- 输入信号分频模块Signal_in_div_module
对输入信号进行16分频
- 输入信号未分频和已分频的时钟同步模块Signal_in_synchronize_module
锁存两次防止亚稳态，并与时钟信号同步
- 输入信号未分频和已分频的测量模块Gate_module
设置0.5Hz，50%占空比的预置闸门
###状态机：
   0：等待预置闸门上升沿，若满足相应条件，state=1;
   1：等待待测信号上升沿，若满足相应条件，实际闸门打开/计数初始化/state=2;
   2：等待预置闸门下降沿，若满足相应条件，计数/state=3;
   3：等待待测信号上升沿，若满足相应条件，计数/实际闸门关闭/state=0;
# **注：**
*开始在FPGA板上运行程序后，会出现多个FPGA管脚乱跳的情况，这是由于在顶层模块输出设置了32位的M和N，会分配64个管脚作为Fitter Location，但这不影响频率计的频率测量
*最好使用短导线进行连接
*使用modelsim和signaltap帮助代码的理解
