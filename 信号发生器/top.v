`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2025/07/20 13:30:05
// Design Name: 
// Module Name: top
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


module top(
	input 			sys_clk,
	input 			sys_rst_n,
	input  [3:0]	key,
	output 			da_clk,
	output [7:0] 	da_data,
	output [5:0] 	seg_sel,
	output [7:0] 	seg_led
    );
	
wire clk_100m;
wire clk_32m;
wire clk_50m;
wire clk_32768k;
wire locked1;
wire locked2;
wire rst_n;
wire [3:0] key_value;

assign rst_n = sys_rst_n & locked1 & locked2;
assign da_clk = clk_32768k;
	
clk_wiz_0 u_clk_wiz_0
   (
    // Clock out ports
    .clk_out1(clk_100m),     // output clk_out1
    .clk_out2(clk_32m),     // output clk_out2
    .clk_out3(clk_50m),     // output clk_out3
    // Status and control signals
    .reset(~sys_rst_n), // input reset
    .locked(locked1),       // output locked
   // Clock in ports
    .clk_in1(sys_clk));      // input clk_in1
	
clk_wiz_1 u_clk_wiz_1
   (
    // Clock out ports
    .clk_out1(clk_32768k),     // output clk_out1
    // Status and control signals
    .reset(~sys_rst_n), // input reset
    .locked(locked2),       // output locked
   // Clock in ports
    .clk_in1(clk_32m));      // input clk_in1
	
key_debounce u_key_debounce(
    .clk(clk_50m),
    .rst_n(rst_n),
    .key(key),
    .key_value(key_value)
    );

wire [31:0] wave_freq;	
wire [31:0] wave1_phase;
wire [31:0] wave2_phase;
wire [31:0] wave3_phase;
wire [31:0] wave4_phase;
wire [31:0] wave5_phase;

wire [63:0] wave1_config;
wire [63:0] wave2_config;
wire [63:0] wave3_config;
wire [63:0] wave4_config;
wire [63:0] wave5_config;

wire signed [7:0] wave1;
wire signed [7:0] wave2;
wire signed [7:0] wave3;
wire signed [7:0] wave4;
wire signed [7:0] wave5;
wire signed [7:0] wave1_t;
wire signed [7:0] wave2_t;
wire signed [7:0] wave3_t;
wire signed [7:0] wave4_t;
wire signed [7:0] wave5_t;

wire signed [7:0]	wave2_amp_cnt;
wire signed [7:0]  	wave3_amp_cnt;
wire signed [7:0]  	wave4_amp_cnt;
wire signed [7:0]  	wave5_amp_cnt;

assign wave1_config = {wave1_phase,wave_freq};
assign wave2_config = {wave2_phase,wave_freq*2};
assign wave3_config = {wave3_phase,wave_freq*3};
assign wave4_config = {wave4_phase,wave_freq*4};
assign wave5_config = {wave5_phase,wave_freq*5};

key_control u_key_control(
    .clk_50m(clk_50m),
    .rst_n(rst_n),
	.key(key_value),
	.wave_freq(wave_freq),
	.wave1_phase(wave1_phase),
	.wave2_phase(wave2_phase),
	.wave3_phase(wave3_phase),
	.wave4_phase(wave4_phase),
	.wave5_phase(wave5_phase),
	.wave2_amp_cnt(wave2_amp_cnt),
	.wave3_amp_cnt(wave3_amp_cnt),
	.wave4_amp_cnt(wave4_amp_cnt),
	.wave5_amp_cnt(wave5_amp_cnt),
    .seg_sel(seg_sel),
	.seg_led(seg_led)
    );
	
dds_compiler_0 wave1_dds (
  .aclk(clk_32768k),                                  // input wire aclk
  .s_axis_config_tvalid(1'b1),  // input wire s_axis_config_tvalid
  .s_axis_config_tdata(wave1_config),    // input wire [63 : 0] s_axis_config_tdata
  .m_axis_data_tvalid(),      // output wire m_axis_data_tvalid
  .m_axis_data_tdata(wave1)        // output wire [7 : 0] m_axis_data_tdata
);

dds_compiler_0 wave2_dds (
  .aclk(clk_32768k),                                  // input wire aclk
  .s_axis_config_tvalid(1'b1),  // input wire s_axis_config_tvalid
  .s_axis_config_tdata(wave2_config),    // input wire [63 : 0] s_axis_config_tdata
  .m_axis_data_tvalid(),      // output wire m_axis_data_tvalid
  .m_axis_data_tdata(wave2)        // output wire [7 : 0] m_axis_data_tdata
);

dds_compiler_0 wave3_dds (
  .aclk(clk_32768k),                                  // input wire aclk
  .s_axis_config_tvalid(1'b1),  // input wire s_axis_config_tvalid
  .s_axis_config_tdata(wave3_config),    // input wire [63 : 0] s_axis_config_tdata
  .m_axis_data_tvalid(),      // output wire m_axis_data_tvalid
  .m_axis_data_tdata(wave3)        // output wire [7 : 0] m_axis_data_tdata
);

dds_compiler_0 wave4_dds (
  .aclk(clk_32768k),                                  // input wire aclk
  .s_axis_config_tvalid(1'b1),  // input wire s_axis_config_tvalid
  .s_axis_config_tdata(wave4_config),    // input wire [63 : 0] s_axis_config_tdata
  .m_axis_data_tvalid(),      // output wire m_axis_data_tvalid
  .m_axis_data_tdata(wave4)        // output wire [7 : 0] m_axis_data_tdata
);

dds_compiler_0 wave5_dds (
  .aclk(clk_32768k),                                  // input wire aclk
  .s_axis_config_tvalid(1'b1),  // input wire s_axis_config_tvalid
  .s_axis_config_tdata(wave5_config),    // input wire [63 : 0] s_axis_config_tdata
  .m_axis_data_tvalid(),      // output wire m_axis_data_tvalid
  .m_axis_data_tdata(wave5)        // output wire [7 : 0] m_axis_data_tdata
);

assign wave1_t = wave1 >>> 1;
assign wave2_t = wave2 >>> 1;
assign wave3_t = wave3 >>> 1;
assign wave4_t = wave4 >>> 1;
assign wave5_t = wave5 >>> 1;

reg en;
reg signed [7:0] da_data_t;

always@(posedge clk_50m or negedge rst_n)
	if(~rst_n)
		en <= 0;
	else if(~key_value[3])
		en <= ~en;
	else 
		en <= en;

always@(posedge clk_32768k or negedge rst_n)
	if(~rst_n)
		da_data_t <= 0;
	else if(en)
		da_data_t <= wave1_t + (((wave2_t * wave2_amp_cnt) + (wave3_t * wave3_amp_cnt) + (wave4_t * wave4_amp_cnt) + (wave5_t * wave5_amp_cnt)) / 100) ;
	else 
		da_data_t <= 0;
		
assign da_data = da_data_t +512;
	
endmodule
