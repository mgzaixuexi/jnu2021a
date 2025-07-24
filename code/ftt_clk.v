`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2025/03/05 15:17:35
// Design Name: 
// Module Name: ftt_clk
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


// module fft_clk(
//     input clk_32m,
//     input rst_n,
//     output clk_640k
//     );
    
// reg [5:0] clk_cnt;
// reg clk_640k_t;

// always @(posedge clk_32m or negedge rst_n)begin
//     if(~rst_n)
//     clk_cnt<=0;
//     else if(clk_cnt==50-1)
//     clk_cnt<=0;
//     else clk_cnt<=clk_cnt+1'b1;
    
//     if(~rst_n)
//     clk_640k_t<=0;
//     else if(clk_cnt==50-1)
//     clk_640k_t<=~clk_640k_t;
//     else clk_640k_t<=clk_640k_t;
    
// end    

//    BUFG BUFG_inst (
//       .O(clk_640k), // 1-bit output: Clock output
//       .I(clk_640k_t)  // 1-bit input: Clock input
//    );
   
// endmodule



//林睦版本
module fft_clk(
    input       sys_clk,    // 50MHz系统时钟输入
    input       rst_n,      // 低电平有效复位信号
    input       clk_32m,
    output      clk_640k,
    output reg  clk_1m      // 1MHz时钟输出
);
reg [5:0] clk_cnt;
reg clk_640k_t;

always @(posedge clk_32m or negedge rst_n)begin
    if(~rst_n)
    clk_cnt<=0;
    else if(clk_cnt==25-1)
    clk_cnt<=0;
    else clk_cnt<=clk_cnt+1'b1;
    
    if(~rst_n)
    clk_640k_t<=0;
    else if(clk_cnt==25-1)
    clk_640k_t<=~clk_640k_t;
    else clk_640k_t<=clk_640k_t;
    
end    

   BUFG BUFG_inst (
      .O(clk_640k), // 1-bit output: Clock output
      .I(clk_640k_t)  // 1-bit input: Clock input
   );

// 分频计数器参数
localparam DIVIDER = 25;    // 50MHz/1MHz = 50分频
localparam HALF_DIV = DIVIDER/2; // 半周期计数

// 分频计数器
reg [5:0] counter;  // 需要6位计数器（2^6=64 > 50）

always @(posedge sys_clk or negedge rst_n) begin
    if (!rst_n) begin
        // 复位时清零计数器和时钟输出
        counter <= 0;
        clk_1m <= 0;
    end
    else begin
        if (counter == DIVIDER - 1) begin
            // 达到分频周期时翻转时钟并重置计数器
            counter <= 0;
            clk_1m <= ~clk_1m;
        end
        else begin
            // 未达到分频周期时递增计数器
            counter <= counter + 1;
            
            // 在半周期点翻转时钟（可选，使占空比更精确）
            if (counter == HALF_DIV - 1) begin
                clk_1m <= ~clk_1m;
            end
        end
    end
end

endmodule