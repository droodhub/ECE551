module saturate(input [15:0]unsigned_err, input [15:0]signed_err, input [9:0]signed_D_diff, 
			output [9:0]unsigned_err_sat, output [9:0]signed_err_sat, output [6:0]signed_D_diff_sat);

//unsigned saturation will have different bit values than signed ]
//as it can use the uppermost bit as a value as opposed to indicating pos/neg
assign unsigned_err_sat = (|unsigned_err[15:10]) ? 10'h3FF : unsigned_err[9:0];

//if num is positive, OR upper bits together -- if any of them are positive, saturate value
//if num is negative, NAND upper bits together -- if any of them are 0, saturate value
assign signed_err_sat = (~signed_err[15] && |signed_err[14:9])? 10'h1FF :(signed_err[15] && ~&signed_err[14:9])? 10'h200 : {signed_err[15], signed_err[8:0]};

assign signed_D_diff_sat = (~signed_D_diff[9] && |signed_D_diff[8:6])? 7'h3F :(signed_D_diff[9] && ~&signed_D_diff[8:6])? 7'h40 : {signed_D_diff[9], signed_D_diff[5:0]};

endmodule
