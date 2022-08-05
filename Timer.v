module Timer (
input	wire			rst_n, //The Asynchronous Reset
input	wire			clk,  //The output clock from the clock divider
input	wire	[1:0]	clk_freq, 
input	wire			run_timer, //it's output signal from the Control Unit to run and pause the timer
input 	wire 			timer_restart,	//this signal is connected to the output of the Control Unit which is "state_time_flag" .
//so that when the Control unit finshes a state and goes to the next one, the timer restarts

output 	reg		[2:0]	timer_elapsed_minutes

);



////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
/////////////////////////////////////////////// Methodology ////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//We will implement the timer as a counter that increments every positive edge
//So for the timer to count up to one second time, the number of counts = the input clock frequency to the timer
//(example if the frequency is 1 MHz, the timer has to count 1000 000 counts for the 1 secound to elapse)
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

reg	 	[22:0]		timer_counts ;	//it counts up to 1 second
reg		[5:0]		timer_seconds ;  //it counts up to 1 minute
reg		[22:0]		one_second_counts ; 

wire				one_second_flag ;
wire				one_minute_flag ;




always @ (posedge clk or negedge rst_n)
 begin
  if(!rst_n) //Asynchronous Reset
   begin
    timer_counts <= 23'b0 ;	
	timer_seconds <= 6'b0 ;
	timer_elapsed_minutes <= 3'b0 ;
   end
  else if (timer_restart)  //timer_restart is asserted from the control unit, when a state is finished and it goes to the next state, so the timer restarts and counts over again
   begin
    timer_counts <= 23'b0 ;
	timer_seconds <= 6'b0 ;
	timer_elapsed_minutes <= 3'b0 ;
   end
  else 
   begin 
   if (run_timer)	//if run_timer signal is low, the timer is paused "this is only allowed in the Spinning state"
	 begin
		if ( one_second_flag && !one_minute_flag )		//if this condition is true, so one second has elapsed
		 begin
			
			timer_seconds <= timer_seconds + 6'b1 ;
			timer_counts <= 23'b0 ;
			
		 end
		 else if ( one_second_flag && one_minute_flag )	//if this condition is true, so one minute has elapsed
		 begin
			timer_elapsed_minutes <= timer_elapsed_minutes + 3'b1 ;
			timer_seconds <= 6'b0 ;
			timer_counts <= 23'b0 ;
			
		 end
		else timer_counts <= timer_counts + 23'b1 ;
	 end
   end
 end
 
 assign one_second_flag = (timer_counts == one_second_counts) ? 1'b1 : 1'b0 ;	//this flag is high when one second has elapsed
 
 assign one_minute_flag = (timer_seconds == 6'd59) ? 1'b1 : 1'b0 ;		//this flag is high when one minute has elapsed
 
 
   //The next Alawys block representa a mux to specify the number of counts for the timer to count to reach 1 second acoording to the input frequency.
   //as that number of counts to reach one second depends on the input frequency
  always @ (*) 
  begin
   case (clk_freq)			//Please note: for lowering the simulation time, we will work with Frequencies in kHz range to verify the functionality
	2'b00		:	
		one_second_counts = 23'd999 ;		//For the 1 Mhz Frequency "1 kHz here to lower the simulation time"
	2'b01		:	
		one_second_counts = 23'd1999 ;		//For the 2 Mhz Frequency "2 khz here to lower the simulation time"
	2'b10		:	
		one_second_counts = 23'd3999 ;		//For the 4 Mhz Frequency "4 khz here to lower the simulation time"
	2'b11		:	
		one_second_counts = 23'd7999 ;		//For the 8 Mhz Frequency "8 khz here to lower the simulation time"
	default 	:
		one_second_counts = 23'd7999 ;
   endcase
  end
  //Please note: if required to return to the Mhz range not the khz range, just add three more "nines" in each case in the previous always block 
  //and change the SYSTEM_CLK_PERIOD to  0.125 us =  0.000125 ms and change the accuaracy of the testbench timescale to 1ms/100ps
  
endmodule