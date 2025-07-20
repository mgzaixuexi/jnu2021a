`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    15:56:42 07/29/2024 
// Design Name: 
// Module Name:    seg_led 
// Project Name: 
// Target Devices: 
// Tool versions: 
// Description: 
//
// Dependencies: 
//
// Revision: 
// Revision 0.01 - File Created
// Additional Comments: 
//
//////////////////////////////////////////////////////////////////////////////////
module seg_led(
    input sys_clk,
	input sys_rst_n,
	input [2:0] state_select,
    input [4:0] state_wave,
    input [6:0] freq_cnt,
    input [7:0] phase_cnt,
    input [7:0] amp_cnt,
	output reg [5:0] seg_sel,
	output reg [7:0] seg_led
    );

reg [16:0]counter;
reg [3:0] num_select;
reg [3:0] num_wave;
reg [3:0] num1;
reg [3:0] num2;
reg [3:0] num3;

wire [3:0] freq_num1;
wire [3:0] freq_num2;
wire [3:0] freq_num3;
wire [3:0] phase_num1;
wire [3:0] phase_num2;
wire [3:0] phase_num3;
wire [3:0] amp_num1;
wire [3:0] amp_num2;
wire [3:0] amp_num3;

assign freq_num1 = freq_cnt % 10;
assign freq_num2 = freq_cnt /10 % 10;
assign freq_num3 = freq_cnt /100;
assign phase_num1 = phase_cnt % 10;
assign phase_num2 = phase_cnt /10 % 10;
assign phase_num3 = phase_cnt /100;
assign amp_num1 = amp_cnt % 10;
assign amp_num2 = amp_cnt /10 % 10;
assign amp_num3 = amp_cnt /100;

always @(posedge sys_clk or negedge sys_rst_n) 
    if(!sys_rst_n) begin
		num1 <= 0;
	    num2 <= 0;
	    num3 <= 0;
		end
	else
		case(state_select)
			3'b001: begin
						num1 <= freq_num1;
						num2 <= freq_num2;
						num3 <= freq_num3;
					end
			3'b010:	begin
			        	num1 <= phase_num1;
			        	num2 <= phase_num2;
			        	num3 <= phase_num3;
			        end
			3'b100:	begin
			        	num1 <= amp_num1;
			        	num2 <= amp_num2;
			        	num3 <= amp_num3;
			        end
			default:begin
			        	num1 <= num1;
			        	num2 <= num2;
			        	num3 <= num3;
			        end
		endcase
		
always @(posedge sys_clk or negedge sys_rst_n) 
    if(!sys_rst_n) 
		num_select<=0;
    else 
        case(state_select)
			3'b001:	num_select<=4'd1;
			3'b010:	num_select<=4'd2;
			3'b100:	num_select<=4'd3;
			default:num_select<=0;
        endcase
		
always @(posedge sys_clk or negedge sys_rst_n) 
    if(!sys_rst_n) 
		num_wave<=0;
    else 
        case(state_wave)
			5'b00001:	num_wave<=4'd1;
			5'b00010:	num_wave<=4'd2;
			5'b00100:	num_wave<=4'd3;
			5'b01000:	num_wave<=4'd4;
			5'b10000:	num_wave<=4'd5;
			default:	num_wave<=0;
        endcase
        
        
function [7:0]led;
input [3:0]num6; 
	 case (num6)  
	 4'h0 : led = 8'b1100_0000;  
	 4'h1 : led = 8'b1111_1001;  
	 4'h2 : led = 8'b1010_0100; 
	 4'h3 : led = 8'b1011_0000; 
	 4'h4 : led = 8'b1001_1001; 
	 4'h5 : led = 8'b1001_0010; 
	 4'h6 : led = 8'b1000_0010; 
	 4'h7 : led = 8'b1111_1000; 
	 4'h8 : led = 8'b1000_0000; 
	 4'h9 : led = 8'b1001_0000; 
	 default : led = 8'b1111_1111;
	 endcase
endfunction

always @(posedge sys_clk or negedge sys_rst_n) 
    if(!sys_rst_n) 
		counter<=0;
	else if(counter<99999) 
		counter<=counter+1;
	else 
		counter<=0;

always @(posedge sys_clk or negedge sys_rst_n)
    if(!sys_rst_n) 
		seg_sel<=6'b111_110;
	else if(counter==99999) 
		seg_sel<={seg_sel[4:0],seg_sel[5]};
	else 
		seg_sel<=seg_sel;

always @(posedge sys_clk or negedge sys_rst_n)
    if(!sys_rst_n) seg_led<=8'b1111_1111;
	   else 
	       case(seg_sel)
	       6'b011_111:	seg_led<=led(num_select);
	       6'b101_111:	seg_led<=led(num_wave);
		   6'b111_011:	seg_led<=led(num3);
	       6'b111_101: 	seg_led<=led(num2);
	       6'b111_110:	seg_led<=led(num1);
	       default:		seg_led<=8'b1111_1111;
	       endcase

endmodule
