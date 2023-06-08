module PID_math_tb();

logic [15:0] ptch, ptch_rt;
logic [17:0] integrator;
logic [11:0] PID_cntrl;

PID_math iDUT(.ptch(ptch), .ptch_rt(ptch_rt), .integrator(integrator), .PID_cntrl(PID_cntrl));

initial begin
//testing outline provided in class
	ptch = 16'hFF00;
	ptch_rt = 16'h0FFF;
	integrator = 18'h3C000;
	
	//repeat blocks go as follows:
	//ramp up & down ptch_rt every block
	//ramp up & down integrator every other block(2 blocks up -> 2 blocks down)
	//continuously ramp up ptch over all 8 blocks
	repeat(64) begin
		#2;
		ptch = ptch + 16'h0001;
		ptch_rt = ptch_rt - 16'h0100;
		integrator = integrator + 18'h00080;
	end
	
	repeat(64) begin
		#2;
		ptch = ptch + 16'h0001;
		ptch_rt = ptch_rt + 16'h0100;
		integrator = integrator + 18'h00080;
	end
	
	repeat(64) begin
		#2;
		ptch = ptch + 16'h0001;
		ptch_rt = ptch_rt - 16'h0100;
		integrator = integrator - 18'h00080;
	end

	repeat(64) begin
		#2;
		ptch = ptch + 16'h0001;
		ptch_rt = ptch_rt + 16'h0100;
		integrator = integrator - 18'h00080;
	end
	
	repeat(64) begin
		#2;
		ptch = ptch + 16'h0001;
		ptch_rt = ptch_rt - 16'h0100;
		integrator = integrator + 18'h00080;
	end
	
	repeat(64) begin
		#2;
		ptch = ptch + 16'h0001;
		ptch_rt = ptch_rt + 16'h0100;
		integrator = integrator + 18'h00080;
	end
	
	repeat(64) begin
		#2;
		ptch = ptch + 16'h0001;
		ptch_rt = ptch_rt - 16'h0100;
		integrator = integrator - 18'h00080;
	end

	repeat(64) begin
		#2;
		ptch = ptch + 16'h0001;
		ptch_rt = ptch_rt + 16'h0100;
		integrator = integrator - 18'h00080;
	end

end


endmodule
