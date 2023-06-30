module vga_controller(
  input wire clk,
  input wire reset,
  input [7:0] Red_in,
  input [7:0] Green_in,
  input [7:0] Blue_in,
  output reg clk_5MHZ , 
  output wire [7:0] red,
  output wire [7:0] green,
  output wire [7:0] blue,
  output wire hsync,
  output wire vsync
);

  // VGA timings
  parameter H_DISPLAY = 1920;      // Horizontal display resolution
  parameter H_FRONT_PORCH = 88;   // Horizontal front porch
  parameter H_SYNC_PULSE = 44;    // Horizontal sync pulse
  parameter H_BACK_PORCH = 148;    // Horizontal back porch
  parameter V_DISPLAY = 1080;      // Vertical display resolution
  parameter V_FRONT_PORCH = 4;   // Vertical front porch
  parameter V_SYNC_PULSE = 5;     // Vertical sync pulse
  parameter V_BACK_PORCH = 36;    // Vertical back porch

  reg [10:0] h_cnt;
  reg [10:0] v_cnt;
  reg [5:0]conuter;
  reg hsync_reg;
  reg vsync_reg;

//clock divider => for 1920*1080 most 100MHZ convert to 5MHZ
always @(posedge clk)
begin
	if (counter == 20)begin 
		clk_5MHZ <= ~clk_5MHZ;
		counter <= 0;
		end
	else
      counter <= counter + 1;
end

  always @(posedge clk_5MHZ or posedge reset) begin
    if (reset) begin
      h_cnt <= 0;
      v_cnt <= 0;
      hsync_reg <= 0;
      vsync_reg <= 0;
    end else if (h_cnt == H_DISPLAY + H_FRONT_PORCH + H_SYNC_PULSE + H_BACK_PORCH - 1) begin
      h_cnt <= 0;
      if (v_cnt == V_DISPLAY + V_FRONT_PORCH + V_SYNC_PULSE + V_BACK_PORCH - 1) begin
        v_cnt <= 0;
        vsync_reg <= ~vsync_reg;
      end else begin
        v_cnt <= v_cnt + 1;
      end
    end else begin
      h_cnt <= h_cnt + 1;
      hsync_reg <= (h_cnt < H_SYNC_PULSE) ? 1 : 0;
    end
  end

  assign hsync = hsync_reg;
  assign vsync = vsync_reg;

  // RGB color generation
  always @(posedge clk) begin
    if (v_cnt >= V_FRONT_PORCH && v_cnt < V_DISPLAY + V_FRONT_PORCH && h_cnt >= H_FRONT_PORCH && h_cnt < H_DISPLAY + H_FRONT_PORCH) begin
      red <= Red_in;   
      green <= Green_in; 
      blue <= Blue_in;  
    end else begin
      red <= 8'h0;   
      green <= 8'h0; 
      blue <= 8'h0;  
    end
  end

endmodule