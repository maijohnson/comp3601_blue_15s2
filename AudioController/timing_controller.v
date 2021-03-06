/*
 * This module handles duration of note, style of play (i.e. normal, staccato or slurred) and BPM control.
 */
 
module timing_controller (CLK, BPM, MODE, NOTE, START, EN, DONE);
	input 				 CLK; 	// 100 MHz clock
	input [1:0]		   MODE;		// Note style
	input [3:0]			NOTE;		// Note type, e.g. crotchet
	input 			  START;    // Start flag to enable playback
	input [7:0] 	 	 BPM;		// 8-bit BPM value

	output reg 			  EN;		// Output enable (to control duration)
	wire [15:0]	  DURATION;		// Note duration
	output reg 			DONE;		// Flag to request the next note
	
	reg [15:0] counter;
	
	parameter
		NORMAL   = 2'b00,
		STACCATO = 2'b01,
		SLURRED  = 2'b10,
		BPM_COMM = 2'b11;
	
	duration_lut dur_lut_blk (NOTE[3:0],  DURATION);
	BPM_prescaler bpm_pre_blk (CLK, BPM, slowCLK);
	initial begin
		EN 	  <= 1;
		counter <= 0;
		DONE 	  <= 0;
	end
	// Do something so that all the notes start at the beginning of a tone
	// Perhaps an output to the top module to draw notes from.
	// OR: Just have a slower build up in volume
	always @ (posedge slowCLK) begin
		if (START) begin
			DONE <= 0;
			counter <= counter + 1;
			case (MODE) 
				NORMAL  : begin if (counter <= DURATION/128*125) EN <= 1; else EN <= 0; end
				STACCATO: begin if (counter <= DURATION/128*102) EN <= 1; else EN <= 0; end
				SLURRED : begin if (counter <= DURATION)         EN <= 1; end
			endcase
			// Reset counter once duration reached
			if (counter == DURATION) begin
				counter <= 0;
				DONE <= 1;
			end
		end
	end
endmodule
 