module ad(
    input [9:0]ad_data, //1k-100kHz
    input clk_50m,
    input clk_640k,
    input clk_256k,
    input key_value,
    input rst_n,
    input clk_1m
);


wire [7:0]freq;
wire freq_valid;
// wave_freq u_wave_freq(
//     .ad_data(ad_data), //1k-100kHz
//     . clk_256k(clk_256k),
//     . clk_50m(clk_50m),
//     . rst_n(rst_n),
//     . freq(freq),
//     .freq_valid(freq_valid)
// );

assign freq_valid = 1;
assign freq = 8'd4; 
reg  [9:0]data_in;
reg clk_in;
integer i;
always @(posedge clk_1m or negedge rst_n) begin
    if(~rst_n) begin i<=0;clk_in<=0;end
    else 
    begin
            if(freq_valid)begin
            i<=i+1;
            if(i==1100/(freq*2)-1)
            begin
                clk_in<=~clk_in;
                i<=0;
            end
        end
    end
end

always @(posedge clk_in or negedge rst_n) begin
    if(~rst_n) data_in <= 0;
    else
    begin
        data_in<=ad_data;//周期放大10倍
    end
end


wire [11:0]ram_addr_in;
wire [11:0]fft_addr_in;
wire [9:0] ram_data_in;
wire [9:0] fft_data_in;


wire wr_done1;
 ram_wr_ctrl1 u_ram_wr_ctrl1
(
	.clk(clk_in),//读取数据时钟
	.rst_n(rst_n),//复位，接（rst_n&key）key是启动键
	.data_in(data_in),    
	.wr_data(ram_data_in),
	.wr_addr(ram_addr_in),
    .wr_done(wr_done1)
);

ram_4096x10 u_ram_4096x10 (
  .clka(clk_in),    // input wire clka
  .wea(1),      // input wire [0 : 0] wea
  .addra(ram_addr_in),  // input wire [11 : 0] addra
  .dina(ram_data_in),    // input wire [9 : 0] dina
  .clkb(clk_640k),    // input wire clkb
  .addrb(fft_addr_in),  // input wire [11 : 0] addrb
  .doutb(fft_data_in)  // output wire [9 : 0] doutb
);

wire		fft_valid;//fft重置信号
ram_wr_ctrl2 u_ram_wr_ctrl2
(
	.clk(clk_640k),//fft时钟
	.rst_n(rst_n),//复位，接（rst_n&key）key是启动键
    .wr_done(wr_done1) ,
	.wr_addr(fft_addr_in),
    .fft_valid(fft_valid)
);

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

assign fft_s_data_tdata = {6'b0,fft_data_in[9:0]};  

wire 		fft_shutdown;


// //fft控制模块，按键启动fft，ram写入完成后关�??
// fft_ctrl u_fft_ctrl(
// 	.clk(clk_50m),
// 	.rst_n(rst_n),
// 	.key(key_value),
// 	.fft_shutdown(fft_shutdown),
// 	.fft_valid(fft_valid)
// );

// FFT IP核实例化
xfft_0 u_fft(
    .aclk(clk_640k),
    .aresetn(fft_valid&rst_n),//fft重置信号
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

wire [11:0] rd_addr;
wire [15:0] rd_data;
wire wave_vaild;

wire [15:0] data_modulus;
wire [15:0] wr_data;
wire [11:0] wr_addr;
wire wr_en;
wire wr_done;

ram_wr_ctrl u_ram_wr_ctrl(
	.clk(clk_640k),//fft时钟
	.rst_n(rst_n),//复位，接（rst_n&key）key是启动键
	.data_modulus(data_modulus),    
    .data_valid(data_valid),
	.wr_data(wr_data),
	.wr_addr(wr_addr),
	.wr_en(wr_en),
	.wr_done(wr_done)
);

ram_4096x16 u_ram_4096x16 (
  .clka(clk_640k),    // fft时钟
  .wea(wr_en),      // input wire [0 : 0] wea
  .addra(wr_addr),  // input wire [11 : 0] addra
  .dina(wr_data),    // input wire [15 : 0] dina
  .clkb(~clk_50m),    // 分离模块时钟
  .addrb(rd_addr),  // input wire [11 : 0] addrb
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
						

// wire [9:0]Uo2,Uo3,Uo4,Uo5;
// wire THD_t;

// assign THD_t = (Uo2*Uo2)+(Uo3*Uo3)+(Uo4*Uo4)+(Uo5*Uo5);

wire [15:0] fundamental;
wire [15:0] harmonic2;
wire [15:0] harmonic3;
wire [15:0] harmonic4;
wire [15:0] harmonic5;
wire [15:0] THD;

THD_calculator uut (
    .clk(clk_50m),
    .rst_n(rst_n),
    .start(wr_done),
    .ram_data(rd_data),
    .ram_addr(rd_addr),
    .fundamental(fundamental),
    .harmonic2(harmonic2),
    .harmonic3(harmonic3),
    .harmonic4(harmonic4),
    .harmonic5(harmonic5),
    .THD(THD),
    .done(done)
);


endmodule