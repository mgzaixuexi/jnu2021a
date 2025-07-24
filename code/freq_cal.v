module freq_cal(
    input [15:0]rd_data,
    input rst_n,
    input clk_256k,
    input wr_done,
    output reg [7:0]rd_addr,
    output reg freq_valid,
    output reg [7:0]freq
);

reg [15:0] max_data;
reg [7:0] max_index;

always @(posedge clk_256k or negedge rst_n) begin
    if(~rst_n) 
    begin
        max_data<=0;
        max_index<=0;
        freq_valid<=0;
    end
    if(wr_done & (~freq_valid))
    begin
        if(rd_data > max_data) begin
            max_data <= rd_data;
            max_index <= rd_addr;
        end
        rd_addr = rd_addr+1;
        if(rd_addr >= 8'd120) begin // FFT帧结束
            freq<=max_index;
            freq_valid<=1;
        end
    end
end
endmodule