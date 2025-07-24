module wave_freq(
    input [9:0]ad_data, //1k-100kHz
    input clk_256k,
    input clk_50m,
    input rst_n,
    output  [7:0]freq,
    output  freq_valid

);

reg [9:0] data_in;

always @(posedge clk_256k or negedge rst_n) begin
    if(~rst_n) data_in <= 0;
    else
    begin
        data_in<=ad_data;//周期放大�?256�?
    end
end

// FFT输入接口（驱动信号改为reg�??
wire [15:0] fft_s_data_tdata;  // 输入数据（实部）

// FFT输出接口（保持为wire�??
wire       fft_s_data_tready; // FFT准备好接收数�??
wire [47:0] fft_m_data_tdata; // 频谱输出数据
wire        fft_m_data_tvalid;

// 配置接口
reg [7:0]  fft_s_config_tdata;
reg        fft_s_config_tvalid;
wire       fft_s_config_tready;

assign fft_s_data_tdata = {6'b0,data_in[9:0]};  

// FFT IP核实例化
xfft_1 u_fft1(
    .aclk(clk_256k),
    .aresetn(rst_n),//fft重置信号
    .s_axis_config_tdata(8'd1),
    .s_axis_config_tvalid(1'b1),
    .s_axis_config_tready(fft_s_config_tready),  // 悬空
	
    .s_axis_data_tdata({16'h0000, fft_s_data_tdata}), // 虚部�??0，实部为输入数据
    .s_axis_data_tvalid(1'b1),//原版本完全没逻辑就放在这里了,我不如置1
    .s_axis_data_tready(fft_s_data_tready),
    .s_axis_data_tlast(fft_s_data_tlast),
	
    .m_axis_data_tdata(fft_m_data_tdata),
    .m_axis_data_tuser(),
    .m_axis_data_tvalid(fft_m_data_tvalid),
    .m_axis_data_tready(1'b1), // 假设从设备始终准备好接收
    .m_axis_data_tlast(),

    .m_axis_status_tdata(),                  // output wire [7 : 0] m_axis_status_tdata
    .m_axis_status_tvalid(),                // output wire m_axis_status_tvalid
    .m_axis_status_tready(1'b0),                // input wire m_axis_status_tready	
    // 其他事件信号悬空
    .event_frame_started(),
    .event_tlast_unexpected(),
    .event_tlast_missing(),
    .event_status_channel_halt(),
    .event_data_in_channel_halt(),
    .event_data_out_channel_halt()
);


wire [7:0] rd_addr;
wire [15:0] rd_data;
wire wave_vaild;

wire [15:0] data_modulus;
wire [15:0] wr_data;
wire [7:0] wr_addr;
wire wr_en;
wire wr_done;

ram_wr_ctrl_wave u_ram_wr_ctrl_wave(
	.clk(clk_256k),//fft时钟
	.rst_n(rst_n),//复位，接（rst_n&key）key是启动键
	.data_modulus(data_modulus),    
    .data_valid(data_valid),
	.wr_data(wr_data),
	.wr_addr(wr_addr),
	.wr_en(wr_en),
	.wr_done(wr_done)
);

ram_256x16 u_ram_256x16 (
  .clka(clk_256k),    // input wire clka
  .wea(wr_en),      // input wire [0 : 0] wea
  .addra(wr_addr),  // input wire [7 : 0] addra
  .dina(wr_data),    // input wire [15 : 0] dina
  .clkb(~clk_50m),    // input wire clkb
  .addrb(rd_addr),  // input wire [7 : 0] addrb
  .doutb(rd_data)  // output wire [15 : 0] doutb
);


// 实部fft_m_data_tdata[15:0],   是否为有符号数仍�??进一步验�??
// 虚部fft_m_data_tdata[31:16]); 
//eop信号都是不要的，全部悬空
data_modulus u_data_modulus(
	.clk(clk_50m),
	.rst_n(rst_n),
	//.key(key_value[0]),                       //键控重置，就是题目里的启动键，不是复�??
	//FFT ST接口 
    .source_real(fft_m_data_tdata[15:0]),   //实部 有符号数 
    .source_imag(fft_m_data_tdata[31:16]),   //虚部 有符号数 
	.source_eop(),
    .source_valid(fft_m_data_tvalid),  //输出有效信号，FFT变换完成后，此信号置�?? 
	.data_modulus(data_modulus),  // 取模结果
	.data_eop(),      // 结果帧结�??
	.data_valid(data_valid)     // 结果有效信号
/* 	.fft_en(fft_en)		 //fft的使能，接到数据有效或�?�时钟有效都�??
    //取模运算后的数据接口 
    .data_modulus(data_modulus),  //取模后的数据 
	.wr_addr(wr_addr),	 //写ram地址
	.wr_en(wr_en),		 //写使�??	
	.wr_done(wr_done)		 //分离模块使能 */
);

freq_cal u_freq_cal(
    . rd_data(rd_data),
    . rst_n(rst_n),
    . clk_256k(clk_256k),
    . wr_done(wr_done),
    .  rd_addr(rd_addr),
    .  freq_valid(freq_valid),
    .  freq(freq)
);





endmodule