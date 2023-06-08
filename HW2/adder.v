
module adder(input [3:0] A, input [3:0] B, input cin, output [3:0] sum, output co);

assign {co, sum} = A + B + cin;

endmodule