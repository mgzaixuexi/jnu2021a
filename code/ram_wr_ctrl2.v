module ram_wr_ctrl2
(
	input 			 	 clk,//fft时钟
	input			 	 rst_n,//复位，接（rst_n&key）key是启动键
	    input  			 wr_done,//ram写完成信号，也是频率分离模块使能信号  
	output reg [11:0]	 wr_addr,
	output reg  fft_valid
);

reg flag;
always @(posedge clk or negedge rst_n)
    if (!rst_n)begin
		wr_addr <= 0;
		fft_valid<=0;
		flag <= 0;
	end
	else 
	if(wr_done==1)
	begin
		if(flag)fft_valid<=1;
		if(wr_addr>=12'd1) flag<=1;
		wr_addr <= wr_addr + 1'b1;
	end


endmodule