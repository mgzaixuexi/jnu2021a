module top(
    input          sys_clk,        // 系统时钟
    input          sys_rst_n,      // 系统复位
    input  [2:0]   key,           // 按键输入 

    // ADC接口
    input  [9:0]   ad_data,       // ADC数据输入(10位)
    input          ad_otr,        // ADC输入电压超过量程标志
    output         ad_clk,
    // DA接口
    output         da_clk,        // DAC驱动时钟
    output [9:0]  da_data,       // DAC数据输出(10位)

    
    // 数码管接口
    output [4:0]  seg_sel,       // 数码管位选
    output [7:0]  seg_led        // 数码管段选
);

wire locked1;
wire locked2;

wire rst_n;

// 复位信号
assign rst_n = sys_rst_n & locked1 & locked2;


wire [2:0]       key_value;       // 按键值（防抖后）

wire clk_6_4m;
wire clk_25_6m;
reg clk_1m;
wire clk_32m;
wire clk_10m;
wire clk_50m;

 clk_wiz_0 clk_wiz_01
   (
    // Clock out ports
    .clk_out1(clk_32m),     // output clk_out1
    .clk_out2(clk_10m),
    .clk_out3(clk_50m),
    // Status and control signals
    .reset(~sys_rst_n), // input reset
    .locked(locked1),       // output locked
   // Clock in ports
    .clk_in1(sys_clk));      // input clk_in1

assign ad_clk = clk_50m;
assign da_data = ad_data;
assign da_clk = clk_50m;

     clk_wiz_2 clk_wiz_21
   (
    // Clock out ports
    .clk_out1(clk_25_6m),     // output clk_out1
    .clk_out2(clk_6_4m),     // output clk_out1
    // Status and control signals
    .reset(~sys_rst_n), // input reset
    .locked(locked2),       // output locked
   // Clock in ports
    .clk_in1(clk_32m));      // input clk_in1

// 按键防抖模块
key_debounce u_key_debounce(
    .clk(clk_50m),
    .rst_n(rst_n),
    .key(key),
    .key_value(key_value)
);

reg clk_640k;
integer j;
always @(posedge clk_6_4m or negedge rst_n) begin
    if(~rst_n) begin j<=0;clk_640k<=0;end
    else 
    begin
        j<=j+1;
        if(j==50-1)
        begin
            clk_640k<=~clk_640k;
            j<=0;
        end
    end
end

reg clk_256k;
integer k;
always @(posedge clk_25_6m or negedge rst_n) begin
    if(~rst_n) begin k<=0;clk_256k<=0;end
    else 
    begin
        k<=k+1;
        if(k==50-1)
        begin
            clk_256k<=~clk_256k;
            k<=0;
        end
    end
end



integer l;
always @(posedge clk_10m or negedge rst_n) begin
    if(~rst_n) begin l<=0;clk_1m<=0;end
    else 
    begin
        l<=l+1;
        if(l==5-1)
        begin
            clk_1m<=~clk_1m;
            l<=0;
        end
    end
end

wire [15:0]THD;
wire fft_m_data_tvalid;
wire data_valid;
wire freq_valid;
wire wr_done1;
wire wr_done;
wire [15:0] fundamental;
wire [15:0] harmonic2;
wire [15:0] harmonic3;
wire [15:0] harmonic4;
wire [15:0] harmonic5;
wire [7:0]freq;
wire [15:0]max_index;
ad ad1(
 .ad_data(ad_data),
 .clk_1m(clk_1m),
 .clk_50m(clk_50m),
 .clk_640k(clk_640k),
 .clk_256k(clk_256k),
 .rst_n(rst_n),
 .key_value(key_value),
 .THD(THD),
 .wr_done(wr_done),
 . wr_done1(wr_done1),
 .freq_valid(freq_valid),
 .harmonic2(harmonic2),
 .harmonic3(harmonic3),
 .harmonic4(harmonic4),
 .harmonic5(harmonic5),
 .fundamental(fundamental),
 .freq(freq),
 .max_index(max_index)

);


// 数码管显示模块
seg_led u_seg_led(
    .sys_clk(clk_50m),
    .sys_rst_n(rst_n),
    .num1(THD[7:0]),         
    .num2(wr_done),    
    .num3(wr_done1),   
    .num4(freq_valid),  
    .seg_sel(seg_sel),
    .seg_led(seg_led)
);

ila_0 u_ila_0 (
	.clk(clk_50m), // input wire clk


	.probe0(THD), // input wire [15:0]  probe0  
	.probe1(harmonic2), // input wire [0:0]  probe1 
	.probe2(harmonic3), // input wire [0:0]  probe2 
	.probe3(harmonic4), // input wire [0:0]  probe3
    .probe4(harmonic5),
    .probe5(fundamental),
    .probe6(freq),  //[7:0]
    .probe7(max_index)
);

endmodule