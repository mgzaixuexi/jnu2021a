`timescale 1ns / 1ps

module lcd_display_tb;

// Inputs
reg lcd_pclk;
reg sys_rst_n;
reg [7:0] ad_data;
reg ad_clk;
reg [31:0] data_in;
reg [31:0] bcd_data;
reg [10:0] pixel_xpos;
reg [10:0] pixel_ypos;

// Outputs
wire [23:0] pixel_data;
wire [31:0] data_out;

// Instantiate the Unit Under Test (UUT)
lcd_display uut (
    .lcd_pclk(lcd_pclk),
    .sys_rst_n(sys_rst_n),
    .ad_data(ad_data),
    .ad_clk(ad_clk),
    .data_in(data_in),
    .bcd_data(bcd_data),
    .pixel_xpos(pixel_xpos),
    .pixel_ypos(pixel_ypos),
    .pixel_data(pixel_data),
    .data_out(data_out)
);

// Generate LCD pixel clock (25MHz for 800x480 @ 60Hz)
initial begin
    lcd_pclk = 0;
    forever #20 lcd_pclk = ~lcd_pclk;  // 25MHz clock (40ns period)
end

// Generate ADC clock (10MHz)
initial begin
    ad_clk = 0;
    forever #50 ad_clk = ~ad_clk;      // 10MHz clock (100ns period)
end
// Test stimulus
initial begin
    // Initialize Inputs
    sys_rst_n = 0;
    ad_data = 0;
    data_in = 0;
    bcd_data = 0;
    pixel_xpos = 0;
    pixel_ypos = 0;
    
    // Reset
    #100;
    sys_rst_n = 1;
    
    // Test case 1: Display initialization
    #200;
    
    // Test case 2: Simulate button press (button1) - write mode
    data_in = {5'd0, 11'd150, 5'd0, 11'd410}; // Touch at (150,410) - button1
    #1000;
    data_in = 0; // Release touch
    
    // Test case 3: Write ADC data (sine wave)
    for (integer i = 0; i < 512; i = i + 1) begin
        @(posedge ad_clk);
        ad_data = 128 + 100 * $sin(i * 2 * 3.14159 / 64);
    end
    #1000;
    
    // Test case 4: Write different ADC data (triangle wave)
    for (integer i = 0; i < 512; i = i + 1) begin
        @(posedge ad_clk);
        ad_data = (i < 256) ? i : (511 - i); // Triangle wave
    end
    #1000;
    
    // Test case 5: Simulate button press (button2) - read mode
    data_in = {5'd0, 11'd350, 5'd0, 11'd410}; // Touch at (350,410) - button2
    #1000;
    //data_in = 0; // Release touch
    
    // Test case 6: Verify waveform display
    // Scan through waveform display area only
    for (integer y = 42; y < 298; y = y + 1) begin  // WAVE_AREA_Y to WAVE_AREA_Y+HEIGHT
        for (integer x = 100; x < 612; x = x + 1) begin  // WAVE_AREA_X to WAVE_AREA_X+WIDTH
            @(posedge lcd_pclk);
            pixel_xpos = x;
            pixel_ypos = y;
        end
    end
    
    // Test case 7: Full screen scan
    for (integer y = 0; y < 480; y = y + 1) begin
        for (integer x = 0; x < 800; x = x + 1) begin
            @(posedge lcd_pclk);
            pixel_xpos = x;
            pixel_ypos = y;
        end
    end
    
    // Finish simulation
    #1000;
    $finish;
end

// Monitor outputs
initial begin
    $monitor("Time=%t, X=%d, Y=%d, Pixel=0x%h, DataOut=0x%h",
             $time, pixel_xpos, pixel_ypos, pixel_data, data_out);
end

endmodule