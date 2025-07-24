module ram_wr_ctrl1
(
	input 			 	 clk,//fft时钟
	input			 	 rst_n,//复位，接（rst_n&key）key是启动键
	input  	   [15:0]    data_in,    
	output     [15:0]	 wr_data,
	output reg [11:0]	 wr_addr,
    output reg 			 wr_done//ram写完成信号，也是频率分离模块使能信号
);

reg flag;
assign wr_data = data_in;
always @(posedge clk or negedge rst_n)
begin
    if (!rst_n)begin
		wr_addr <= 0;
		wr_done <= 0;
		flag <= 1;
	end
	else 
	if(flag)
	begin
		wr_addr <= wr_addr + 1'b1;
		if(wr_addr>=12'd4094) 
		begin 
			wr_done <= 1'd1;
			flag<=0;
		end
	end
	else wr_done <= 1'd1;
end

endmodule