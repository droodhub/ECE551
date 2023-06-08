module ring_osc_test();

reg stim1, stim2;

ring_osc iDUT(.en(stim1), .out(stim2));

initial begin
stim1 = 0;
#15;
stim1 = 1;
#15;
end


endmodule
