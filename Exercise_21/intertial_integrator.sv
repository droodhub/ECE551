module inertial_integrator(input clk, input rst_n, input vld, input [15:0]ptch_rt, input [15:0]AZ, output reg [15:0]ptch);

logic clk, rst_n, vld;
logic[15:0]  ptch_rt, AZ;
wire[15:0] ptch;
localparam PTCH_RT_OFFSET = 16'h0050;
inertial_integrator iDUT(.clk(clk), .rst_n(rst_n), .vld(vld), .ptch_rt(ptch_rt), .AZ(AZ), .ptch(ptch);

always begin

clk = 1'b0;
rst_n = 1'b1;
vld = 1'b0;
ptch_rt = 16'h1000 + PTCH_RT_OFFSET;
AZ = 16'h0000;

@(negedge clk) rst_n = 1'b0; //reset the DUT and then deassert
@(negedge clk) rst_n = 1'b1;

@(negedge clk) vld = 1'b1; //set vld high, hold for 500 clocks
repeat(500)@(posedge clk);

ptch_rt = PTCH_RT_OFFSET;
repeat(1000)@(posedge clk);

ptch_rt = PTCH_RT_OFFSET - 16'h1000;
repeat(500)@(posedge clk);

ptch_rt = PTCH_RT_OFFSET;
repeat(1000)@(posedge clk);

AZ = 16'h0800;
repeat(1000)@(posedge clk);

end

always
	#5 clk = ~clk;
endmodule