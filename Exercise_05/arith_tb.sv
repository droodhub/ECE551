module testbench();
reg [7:0] stimA, stimB;
reg sub;
wire [7:0] sum;
wire ov;

arith iDUT(.A(stimA), .B(stimB), .SUB(sub), .SUM(sum), .OV(ov));

initial begin
//test for positive overflow
stimA = 8'h7F;
stimB = 8'h40;
sub = 1'b0;
#5;
//found overflow error in this case 
//says there is overflow when none should be present-- subtracting number from itself should equal 0
stimA = 8'hAA;
stimB = 8'hAA;
sub = 1'b1;
#5;
stimA = 8'h70;
stimB = 8'h7A;
sub = 1'b1;
#5;
stimA = 8'h0A;
stimB = 8'h0A;
sub = 1'b1;
#5;
//normal cases -- non-overflow addition + subtraction
stimA = 8'h0F;
stimB = 8'h01;
sub = 1'b0;
#5;
stimA = 8'h0F;
stimB = 8'h02;
sub = 1'b1;
#5;
//should cause negative overflow
stimA = 8'h80;
stimB = 8'h0A;
sub = 1'b1;
#5;



end
endmodule;
