module piezo_drv(input clk, input rst_n, input en_steer, input too_fast, input batt_low, output piezo, output piezo_n);
parameter fast_sim = 1'b1;

logic [24:0] note_tmr, note_dur; //note_duration can be up to 2^25 clocks
logic [12:0] freq_tmr, freq; //13 bits so it can accept vals up to 7kHz
logic [27:0] repeat_tmr; //28 bits for 3 sceonds @ 50 MHz
logic note_tmr_full, repeat_full, rst_note_dur; //signals for when each of the timers is full 
logic[6:0] increment;//signal used to increment counters

typedef enum reg[2:0] {IDLE, NOTE1, NOTE2, NOTE3, NOTE4, NOTE5, NOTE6} state_nm;
state_nm state, nxt_state;

generate //fast sim parameter block
if(fast_sim) 
	increment = 7'h40;
else
	increment = 7'h01;
endgenerate

assign repeat_full = (repeat_tmr == 28'h8F0D180); //hex value for 3 sceonds at 50 MHz
assign note_tmr_full = (note_tmr == note_dur);

always_ff @(posedge clk, negedge rst_n) begin //3 second repeat timer
	if(!rst_n)
		repeat_tmr <= '0;
	else if(repeat_full) //reset timer when full
		repeat_tmr <= '0; 
	else
		repeat_tmr <= repeat_tmr + increment;
end

always_ff @(posedge clk, negedge rst_n) begin
	if(!rst_n)
		note_tmr <= '0;
	else if(rst_note_dur) //reset signal from state machine
		note_tmr <= '0;
	else if(note_tmr_full)
		note_tmr <= '0;
	else
		note_tmr <= note_tmr + increment;
end

always_ff @(posedge clk, negedge rst_n) begin
	if(!rst_n)
		freq_tmr <= '0;
	else if (freq_tmr == freq) //when full, reset timer
		freq_tmr <= '0;
	else
		freq_tmr <= freq_tmr + increment;	
end
assign piezo = (freq_tmr > freq[12:1])? 1:0;
assign piezo_n = ~piezo;

always_ff @(posedge clk, negedge rst_n) begin
	if(!rst_n) 
		state <= IDLE;
	else
		state <= nxt_state;
end

//need to add conditional statements for when timers are full
//en_steer and batt_low should only go through their cycles once every 3 seconds
always_comb begin
	note_dur = 25'h0800000;
	freq = 13'h0A4D;
	nxt_state = state;
	rst_note_dur = 1'b0; //only really needed for idle state
	
	case(state)
		IDLE: begin
			if(too_fast)
				nxt_state = NOTE1;
			else if(repeat_full) begin //full 3 second timer has run
				if(en_steer)
					nxt_state = NOTE1;
				else if(batt_low)
					nxt_state = NOTE6;
			end
			rst_note_dur = 1'b1; //reset note note_duration for transition to first note
		end
		NOTE1: begin
			freq = 13'h0620;
			if(note_tmr_full) begin
				if(too_fast)
					nxt_state = NOTE2;
				else if(batt_low)
					nxt_state = IDLE;
				else if(en_steer)
					nxt_state = NOTE2;
			end
		end
		NOTE2: begin
			freq = 13'h082D;
			if(note_tmr_full) begin
				if(too_fast)
					nxt_state = NOTE3;
				else if(batt_low)
					nxt_state = NOTE1;
				else if(en_steer)
					nxt_state = NOTE3;
				else 
					nxt_state = IDLE;
			end
		end
		NOTE3: begin
			if(note_tmr_full) begin
				if(too_fast)
					nxt_state = NOTE1;
				else if(batt_low)
					nxt_state = NOTE2;
				else if(en_steer)
					nxt_state = NOTE4;
				else 
					nxt_state = IDLE;
			end
		end
		NOTE4: begin
			freq = 13'h0C40;
			note_dur = 25'h0C00000;
			if(note_tmr_full) begin
				if(batt_low)
					nxt_state = NOTE3;
				else if(en_steer)
					nxt_state = NOTE5;
				else 
					nxt_state = IDLE;
			end
		end
		NOTE5: begin
			note_dur = 25'h0400000;
			if(note_tmr_full) begin
				if(batt_low)
					nxt_state = NOTE4;
				else if(en_steer)
					nxt_state = NOTE6;
				else 
					nxt_state = IDLE;
			end
		end
		NOTE6: begin
			note_dur = 25'h1000000;
			freq = 13'h0C40;
			if(note_tmr_full) begin
				if(batt_low)
					nxt_state = NOTE5;
				else
					nxt_state = IDLE;
			end
		end
	endcase
end
endmodule