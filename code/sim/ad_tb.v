`timescale 1ns / 1ps

module ad_tb;
reg rst_n;

parameter CLK_PERIOD = 20;      // 50MHz时钟周期(20ns)
reg clk_50m;
wire clk_32m;
wire clk_14m;
reg key_value;
reg clk_640k;
reg clk_256k;
wire clk_6_4m;
reg clk_1m;
wire clk_10m;

reg [9:0]ad_data;
    // 时钟生成
    initial begin
        clk_50m = 0;
        forever #(CLK_PERIOD/2) clk_50m = ~clk_50m;

    end

integer j;
always @(posedge clk_6_4m or negedge rst_n) begin
    if(~rst_n) begin j<=0;clk_640k<=0;end
    else 
    begin
        j<=j+1;
        if(j==5-1)
        begin
            clk_640k<=~clk_640k;
            j<=0;
        end
    end
end

integer k;
always @(posedge clk_6_4m or negedge rst_n) begin
    if(~rst_n) begin k<=0;clk_256k<=0;end
    else 
    begin
        k<=k+1;
        if(k==12-1)
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

ad ad1(
 .ad_data(ad_data),
 .clk_1m(clk_1m),
 .clk_50m(clk_50m),
 .clk_640k(clk_640k),
 .clk_256k(clk_256k),
 .rst_n(rst_n),
 .key_value(key_value)
);

  clk_wiz_0 clk_wiz_01
   (
    // Clock out ports
    .clk_out1(clk_32m),     // output clk_out1
    .clk_out2(clk_10m),
    // Status and control signals
    .reset(~rst_n), // input reset
    .locked(locked),       // output locked
   // Clock in ports
    .clk_in1(clk_50m));      // input clk_in1



     clk_wiz_2 clk_wiz_21
   (
    // Clock out ports
    .clk_out1(clk_6_4m),     // output clk_out1
    // Status and control signals
    .reset(~rst_n), // input reset
    .locked(locked),       // output locked
   // Clock in ports
    .clk_in1(clk_50m));      // input clk_in1

integer i;
reg file_loaded = 0;     // 文件加载完成标志
reg [9:0] mem [0:32000];
    initial begin
        rst_n = 0;
        #1000;
        rst_n = 1;
        key_value<=0;

    // 读取数据文件（注意文件格式）
    $readmemb("E:/diansai/jnu2021a/code/THD_signal_32MHz_10bit.txt", mem); //读取FM数据
     file_loaded = 1;     // 文件加载完成标志
    // 读取测试数据文件
    if(file_loaded)begin
        for (i = 0; i <= 32000-1; ) begin
            @(posedge clk_32m);
                ad_data <= mem[i];
                if(i==32000-1) 
                    i<=0;
                else i<= i+1;
        end
    end

    end
endmodule