`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2025/04/27 14:50:55
// Design Name: 
// Module Name: ram_wr_ctrl
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

module ram_wr_ctrl_wave
#(
	parameter addr_300k = 2048 //单边频点地址
)
(
	input 			 	 clk,//fft时钟
	input			 	 rst_n,//复位，接（rst_n&key）key是启动键
	input  	   [15:0]    data_modulus,    
    input            	 data_valid,//取模数据有效信号
	output     [15:0]	 wr_data,
	output reg [7:0]	 wr_addr,
	output 			 	 wr_en,//写使能
	output reg 			 wr_done//ram写完成信号，也是频率分离模块使能信号
);

assign wr_data = data_modulus;
assign wr_en = (wr_addr >= 8'd254) ? 1'b0 : 1'b1;//ram写使能，写完之前都置高

always @(posedge clk or negedge rst_n)
    if (!rst_n)begin
		wr_addr <= 0;
		wr_done <= 0;
	end
	else if (wr_addr >= 8'd254)begin//ram写完了，拉高写完成信号
		wr_done <= 1;
		wr_addr <= wr_addr;
	end
	else if(data_valid)
		wr_addr <= wr_addr + 1'b1;
	else begin
		wr_addr <= wr_addr;
		wr_done <= wr_done;
	end
	

		
endmodule
	
	