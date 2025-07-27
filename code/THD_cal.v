module THD_calculator (
    input wire clk,                // 时钟信号
    input wire rst_n,              // 异步复位
    input wire start,              // �?始计算信�?
    input wire [15:0] ram_data,    // 从RAM读取的数�?(FFT模�??)
    output reg [15:0] ram_addr,    // RAM地址输出
    output reg [15:0] fundamental, // 基波幅�??
    output reg [15:0] harmonic2,   // 二次谐波幅�??
    output reg [15:0] harmonic3,   // 三次谐波幅�??
    output reg [15:0] harmonic4,   // 四次谐波幅�??
    output reg [15:0] harmonic5,   // 五次谐波幅�??
    output reg [15:0] THD,         // THD�?(百分比，已放大100倍)
    output reg done ,               // 计算完成信号
    output reg [15:0] max_index
);

// 状�?�定�?
localparam IDLE = 3'd0;
localparam FIND_MAX = 3'd1;
localparam READ_HARMONICS = 3'd2;
localparam CALC_THD = 3'd3;
localparam DONE = 3'd4;

reg [15:0]harmo2;
reg [15:0]harmo3;
reg [15:0]harmo4;
reg [15:0]harmo5;

reg [2:0] state;
reg [15:0] max_value;
// reg [15:0] max_index;
reg [30:0] sum_of_squares;
reg [15:0] counter;
wire [15:0]sum_of_squares_t;
reg flag;
wire cordic_tvalid;

always @(posedge clk or negedge rst_n) begin
    if (~rst_n) begin
        state <= IDLE;
        ram_addr <= 16'd0;
        fundamental <= 16'd0;
        harmonic2 <= 16'd0;
        harmonic3 <= 16'd0;
        harmonic4 <= 16'd0;
        harmonic5 <= 16'd0;
        harmo2 <= 16'd0;
        harmo3<= 16'd0;
        harmo4<= 16'd0;
        harmo5<= 16'd0;
        THD <= 16'd0;
        done <= 1'b0;
        max_value <= 16'd0;
        max_index <= 16'd0;
        sum_of_squares <= 32'd1;
        counter <= 16'd0;
        flag<=0;
    end else begin
        case (state)
            IDLE: begin
                done <= 1'b0;
                if (start) begin
                    ram_addr <= 16'd1;  // 从地�?1�?�?(地址0是DC分量)
                    max_value <= 16'd0;
                    max_index <= 16'd0;
                    counter <= 16'd1;
                    flag<=1;
                    if(flag==1) state <= FIND_MAX;
                end
            end
            
            FIND_MAX: begin
                if (counter < 16'd2048) begin  // 只检查前2048�?(单边�?)
                    if (ram_data > max_value) begin
                        max_value <= ram_data;
                        max_index <= ram_addr;
                    end
                    ram_addr <= ram_addr + 16'd1;
                    counter <= counter + 16'd1;
                end else begin
                    // 找到基波频率
                    fundamental <= max_value;
                    state <= READ_HARMONICS;
                    harmo2 <= max_index *2;
                    harmo3 <= max_index *3;
                    harmo4 <= max_index *4;
                    harmo5 <= max_index *5;
                    // 计算谐波位置
                    counter <= 16'd2;  // �?2次谐波开�?
                    ram_addr <= max_index *2;
                end
            end
            
            READ_HARMONICS: begin
                case (counter)
                    16'd2: begin 
                        ram_addr <= harmo3;
                        harmonic2 <= ram_data;
                    end
                    16'd3: begin 
                        ram_addr <= harmo4;
                        harmonic3 <= ram_data;
                    end
                    16'd4: begin 
                        ram_addr <= harmo5;
                        harmonic4 <= ram_data;
                    end
                    16'd5: begin
                        harmonic5 <= ram_data;
                        state <= CALC_THD;
 
                    end
                endcase
                
                if (counter <= 16'd5) begin
                    counter <= counter + 16'd1;
                end
            end
            CALC_THD: begin
                // 计算谐波平方�?
                sum_of_squares <= harmonic2 * harmonic2 + harmonic3*harmonic3+ 
                                 harmonic4 * harmonic4 + harmonic5*harmonic5;
                
                // 计算THD = sqrt(sum_of_squares)/fundamental * 100
                // 使用近似计算: 先放�?100倍再做除�?
                THD <= (100 * sum_of_squares_t) / fundamental ;
                
                // if(cordic_tvalid) state <= DONE;
            end
            
            DONE: begin
                
                done <= 1'b1;
                if (~start) begin
                    state <= IDLE;
                end
            end
        endcase
    end
end




// // Cordic IP核接口（�?重新配置�?31位输入）
cordic_0 u_cordic_01 (
    .aclk(clk),    // 时钟
    // 输入接口（需确保IP核配置支�?31位输入）
    .s_axis_cartesian_tvalid(state[0] | state[1]), 
    .s_axis_cartesian_tdata(sum_of_squares),         // 31位平方和
    // 输出接口
    .m_axis_dout_tvalid(cordic_tvalid),
    .m_axis_dout_tdata(sum_of_squares_t)              // 16位输�?
);

endmodule