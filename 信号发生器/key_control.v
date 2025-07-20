`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2025/07/20 14:04:36
// Design Name: 
// Module Name: key_control
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


module key_control(
	input 						clk_50m,
	input 						rst_n,
	input   			[3:0] 	key,
	output 				[31:0]	wave_freq,
	output  			[31:0]	wave1_phase,
	output  			[31:0]	wave2_phase,
	output 	 			[31:0]	wave3_phase,
	output  			[31:0]	wave4_phase,
	output 		 		[31:0]	wave5_phase,
	output reg signed  	[7:0]	wave2_amp_cnt,
	output reg signed  	[7:0]  	wave3_amp_cnt,
	output reg signed  	[7:0]  	wave4_amp_cnt,
	output reg signed  	[7:0]   wave5_amp_cnt,
	output  			[5:0]	seg_sel,
	output  			[7:0]	seg_led
    );
	
parameter freq_1k = 131072;
parameter phase_1deg = 32'd11_930_464;

reg [2:0] state_select;
reg [4:0] state_wave;

reg [6:0] wave_freq_cnt;
reg [7:0] wave1_phase_cnt;
reg [7:0] wave2_phase_cnt;
reg [7:0] wave3_phase_cnt;
reg [7:0] wave4_phase_cnt;
reg [7:0] wave5_phase_cnt;

assign wave_freq = wave_freq_cnt * freq_1k;
assign wave1_phase = wave1_phase_cnt * phase_1deg;
assign wave2_phase = wave2_phase_cnt * phase_1deg;
assign wave3_phase = wave3_phase_cnt * phase_1deg;
assign wave4_phase = wave4_phase_cnt * phase_1deg;
assign wave5_phase = wave5_phase_cnt * phase_1deg;

always @(posedge clk_50m or negedge rst_n)
	if(~rst_n)begin
		state_select <= 3'b001;
	    state_wave <= 5'b00001;
		end
	else if(~key[0])
		state_select <= {state_select[1:0],state_select[2]};
	else if(~key[1])
		state_wave <= {state_wave[3:0],state_wave[4]};
	else begin
		state_select <= state_select;
	    state_wave <= state_wave;
		end
		
always @(posedge clk_50m or negedge rst_n)
	if(~rst_n)begin
		wave_freq_cnt <=1;
		wave1_phase_cnt <= 0;
		wave2_phase_cnt <= 0;
		wave3_phase_cnt <= 0;
		wave4_phase_cnt <= 0;
		wave5_phase_cnt <= 0;
		wave2_amp_cnt <=  0;
		wave3_amp_cnt <=  0;
		wave4_amp_cnt <=  0;
		wave5_amp_cnt <=  0;
		end
	else begin
		case(state_select)
			3'b001:	if(~key[2])
						if(wave_freq_cnt >= 100)
							wave_freq_cnt <= 1;
						else 
							wave_freq_cnt <= wave_freq_cnt + 1'b1;
					else wave_freq_cnt <= wave_freq_cnt;
			3'b010:	if(~key[2])
						case(state_wave)
							5'b00001:	if(wave1_phase_cnt >= 180)
							            	wave1_phase_cnt <= 1;
							            else 
							            	wave1_phase_cnt <= wave1_phase_cnt + 1'b1;
							5'b00010:	if(wave2_phase_cnt >= 180)
							            	wave2_phase_cnt <= 1;
							            else 
							            	wave2_phase_cnt <= wave2_phase_cnt + 1'b1;
							5'b00100:	if(wave3_phase_cnt >= 180)
							            	wave3_phase_cnt <= 1;
							            else 
							            	wave3_phase_cnt <= wave3_phase_cnt + 1'b1;
							5'b01000:	if(wave4_phase_cnt >= 180)
							            	wave4_phase_cnt <= 1;
							            else 
							            	wave4_phase_cnt <= wave4_phase_cnt + 1'b1;
							5'b10000:	if(wave5_phase_cnt >= 180)
							            	wave5_phase_cnt <= 1;
							            else 
							            	wave5_phase_cnt <= wave5_phase_cnt + 1'b1;
							default:	begin
											wave1_phase_cnt <=  wave1_phase_cnt;
							                wave2_phase_cnt <=  wave2_phase_cnt;
							                wave3_phase_cnt <=  wave3_phase_cnt;
							                wave4_phase_cnt <=  wave4_phase_cnt;
							                wave5_phase_cnt <=  wave5_phase_cnt;
										end
						endcase
					else begin
						wave1_phase_cnt <=  wave1_phase_cnt;
					    wave2_phase_cnt <=  wave2_phase_cnt;
					    wave3_phase_cnt <=  wave3_phase_cnt;
					    wave4_phase_cnt <=  wave4_phase_cnt;
					    wave5_phase_cnt <=  wave5_phase_cnt;
						end
			3'b100:	if(~key[2])
						case(state_wave)
							5'b00010:	if(wave2_amp_cnt >= 100)
							            	wave2_amp_cnt <= 1;
							            else 
							            	wave2_amp_cnt <= wave2_amp_cnt + 1;
							5'b00100:	if(wave3_amp_cnt >= 100)
							            	wave3_amp_cnt <= 1;
							            else 
							            	wave3_amp_cnt <= wave3_amp_cnt + 1;
							5'b01000:	if(wave4_amp_cnt >= 100)
							            	wave4_amp_cnt <= 1;
							            else 
							            	wave4_amp_cnt <= wave4_amp_cnt + 1;
							5'b10000:	if(wave5_amp_cnt >= 100)
							            	wave5_amp_cnt <= 1;
							            else 
							            	wave5_amp_cnt <= wave5_amp_cnt + 1;
							default:	begin
							                wave2_amp_cnt <=  wave2_amp_cnt;
							                wave3_amp_cnt <=  wave3_amp_cnt;
							                wave4_amp_cnt <=  wave4_amp_cnt;
							                wave5_amp_cnt <=  wave5_amp_cnt;
										end
						endcase
					else begin
					    wave2_amp_cnt <=  wave2_amp_cnt;
					    wave3_amp_cnt <=  wave3_amp_cnt;
					    wave4_amp_cnt <=  wave4_amp_cnt;
					    wave5_amp_cnt <=  wave5_amp_cnt;
						end
			default:begin
					wave_freq_cnt <=1;
					wave1_phase_cnt <= 0;
					wave2_phase_cnt <= 0;
					wave3_phase_cnt <= 0;
					wave4_phase_cnt <= 0;
					wave5_phase_cnt <= 0;
					wave2_amp_cnt <=  0;
					wave3_amp_cnt <=  0;
					wave4_amp_cnt <=  0;
					wave5_amp_cnt <=  0;
					end	
		endcase
		end
		
reg [6:0] freq_cnt;
reg [7:0] phase_cnt;
reg [7:0] amp_cnt;
		
always @(posedge clk_50m or negedge rst_n)
	if(~rst_n)begin
		freq_cnt <= 0;
	    phase_cnt <= 0;
	    amp_cnt <= 0;
		end
	else begin
		freq_cnt <= freq_cnt;
		case(state_wave)
			5'b00001:	begin
						phase_cnt <= wave1_phase_cnt;
						amp_cnt <= 100;
						end
			5'b00010:	begin
			            phase_cnt <= wave2_phase_cnt;
			            amp_cnt <= wave2_amp_cnt;
			            end
			5'b00100:	begin
			            phase_cnt <= wave3_phase_cnt;
			            amp_cnt <= wave3_amp_cnt;
			            end
			5'b01000:	begin
			            phase_cnt <= wave4_phase_cnt;
			            amp_cnt <= wave4_amp_cnt;
			            end
			5'b10000:	begin
			            phase_cnt <= wave5_phase_cnt;
			            amp_cnt <= wave5_amp_cnt;
			            end
			default:	begin
			            phase_cnt <= phase_cnt;
			            amp_cnt <= amp_cnt;
						end
		endcase
		end
		
seg_led u_seg_led(
    .sys_clk(clk_50m),
	.sys_rst_n(rst_n),
	.state_select(state_select),
	.state_wave(state_wave),
	.freq_cnt(freq_cnt),
	.phase_cnt(phase_cnt),
	.amp_cnt(amp_cnt),
	.seg_sel(seg_sel),
	.seg_led(seg_led)
    );
		
endmodule
