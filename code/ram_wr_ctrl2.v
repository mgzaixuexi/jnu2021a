module ram_wr_ctrl2
(
	input 			 	 clk,//fft时钟
	input			 	 rst_n,//复位，接（rst_n&key）key是启动键
	input  			 wr_done,//ram写完成信号，也是频率分离模块使能信号  
	output reg [11:0]	 wr_addr,
	output reg  fft_valid
);

always @(posedge clk or negedge rst_n)
    if (!rst_n)begin
		wr_addr <= 0;
		fft_valid<=0;
	end
	else 
	if(wr_done==1)
	begin
		fft_valid<=1;
		if(wr_addr>=12'd4095) wr_addr <= 12'd1;
		else wr_addr <= wr_addr + 12'b1;
	end


endmodule