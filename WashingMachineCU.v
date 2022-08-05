module WashingMachineCU (

input	wire			rst_n, //The Asynchronous Reset
input	wire			clk,  //The output clock from the clock divider
input	wire			coin_in,
input	wire			double_wash,
input	wire			timer_pause,

//The Following input is comming from the Timer "i.e: it's the output of the timer"
input	wire	[2:0]	timer_elapsed_minutes, //this signal informs the CU with output time from the timer

output 	reg				wash_done,  

//Aditional Signals For debugging in the testbench
output	reg				fill_water_sig, 
output	reg				washing_sig,
output	reg				rinse_sig,
output	reg				spin_sig,

//The following signals are control signals to the timer
output	reg				run_timer,  //this signal runs the timer if high, and pauses it if low
output 	wire			state_timeout_flag  //this signal goes high current state duration is elapsed, so it's used to restart the timer in order to start to count over again for the new state, 
											//also this signal is used internally in the control unit in the transition condition between the FSM states.
);
 
//states encoded by gray code, For less switching power
localparam          Idle  = 3'b000 ,
                    Filling_Water = 3'b001 ,                    
                    Washing = 3'b011 ,
					Rinsing = 3'b010 ,
					Spinning = 3'b110 ;
					

reg     [2:0]       current_state ,
                    next_state ;
					
reg		[2:0]		current_state_duration ; //it's assigned with the current state duration.	

reg		[1:0]		wash_rinse_count ;  //This is a Counter that counts the number of "wash tnen rise" cycles, it helps in deciding the next state in both case double wash and single wash 

reg					increment_wash_rinse_count ; //Used to trigger the above wash_rinse counter
 
 assign state_timeout_flag = (timer_elapsed_minutes == current_state_duration) ? 1'b1 : 1'b0 ;  //this flag goes high when the timer reaches the required current state time 
 //(example: if rinsing state "which has 2 minutes duration" is the current state, So when the timer reaches 2 minutes the state_timeout_flag goes high
 
////////////////////////////////////////////////////////
///////////////////////  FSM  //////////////////////////
////////////////////////////////////////////////////////

//We will write the FSM in 3 always blocks

//state transition
always @ (posedge clk or negedge rst_n)
 begin
  if(!rst_n)
   begin
    current_state <= Idle ;
   end
  else
   begin
    current_state <= next_state ;
   end
 end
 
 //next state logic
 always @ (*)
  begin
	case (current_state)
	Idle		:	
				begin
	
				 if ( coin_in )
				  begin
				   next_state = Filling_Water ;
				  end
				 else
				  begin
				   next_state = Idle ;
				  end
				  
				end

	Filling_Water:
				begin
	
				 if ( state_timeout_flag )
				  begin
				   next_state = Washing ;
				  end
				 else
				  begin
				   next_state = Filling_Water ;
				  end
				  
				end
				
	Washing		:
				begin
	
				 if ( state_timeout_flag )
				  begin
				   next_state = Rinsing ;
				  end
				 else
				  begin
				   next_state = Washing ;
				  end
				  
				end
	
	Rinsing		:
				begin
				
				 if ( state_timeout_flag && double_wash && wash_rinse_count == 2'd1 )
				  begin
				   next_state = Washing ;
				  end
				 else if ( (state_timeout_flag && !double_wash) || (state_timeout_flag && double_wash && (wash_rinse_count == 2'd2) ) )
				  begin
				   next_state = Spinning ;
				  end
				 else 
				  begin
				   next_state = Rinsing ;
				  end
				  
				end
		
	Spinning	:
				begin
	
				 if ( state_timeout_flag )
				  begin
				   next_state = Idle ;
				  end
				 else
				  begin
				   next_state = Spinning ;
				  end
				  
				end
				
	default 	: 
				begin
                 next_state = Idle  ;
				end  
    endcase 
  end
  
  //output logic
always @ (*)
 begin
  wash_done  = 1'b0 ;
  current_state_duration  = 3'b0 ;
  run_timer = 1'b0 ;
  
  fill_water_sig = 1'b0 ;
  washing_sig = 1'b0 ;
  rinse_sig = 1'b0 ;
  spin_sig = 1'b0 ;

  increment_wash_rinse_count = 1'b0;
  
   case (current_state)
	Idle   	:  
			begin
             wash_done = 1'b1 ;
			 current_state_duration  = 3'd0 ;
			 run_timer = 1'b0 ;
			 
			 fill_water_sig = 1'b0 ;
			 washing_sig = 1'b0 ;
			 rinse_sig = 1'b0 ;
			 spin_sig = 1'b0 ;
			 increment_wash_rinse_count = 1'b0;
             end
			 
  Filling_Water:
			begin
			 wash_done = 1'b0 ;
			 current_state_duration  = 3'd2 ;
			 run_timer = 1'b1 ;
			 
			 fill_water_sig = 1'b1 ;
			 washing_sig = 1'b0 ;
			 rinse_sig = 1'b0 ;
			 spin_sig = 1'b0 ;
			 increment_wash_rinse_count = 1'b0;
			end
				
	Washing	:
			begin
			 wash_done = 1'b0 ;
			 current_state_duration  = 3'd5 ;
			 run_timer = 1'b1 ;
			 
			 fill_water_sig = 1'b0 ;
			 washing_sig = 1'b1 ;
			 rinse_sig = 1'b0 ;
			 spin_sig = 1'b0 ;
			 increment_wash_rinse_count = 1'b0;
			end
			
	Rinsing	:
			begin
			 wash_done = 1'b0 ;
			 current_state_duration  = 3'd2 ;
			 run_timer = 1'b1 ;
			 
			 fill_water_sig = 1'b0 ;
			 washing_sig = 1'b0 ;
			 rinse_sig = 1'b1 ;
			 spin_sig = 1'b0 ;
			 increment_wash_rinse_count = 1'b1;
			end
			
	Spinning :
			begin
			 wash_done = 1'b0 ;
			 current_state_duration  = 3'd1 ;
			 run_timer = 1'b1 ;
			 
			 fill_water_sig = 1'b0;
			 washing_sig = 1'b0 ;
			 rinse_sig = 1'b0 ;
			 increment_wash_rinse_count = 1'b0;
			 if (timer_pause)	//if this condition is true, The timer is paused by setting the run_timer signal to low and also the the machine stops spinning "spin_sig = 0", this only can happen in the spinning state
			  begin
				run_timer = 1'b0 ;
				spin_sig = 1'b0 ;
			  end
			 else
			  begin
				run_timer = 1'b1 ;
				spin_sig = 1'b1 ;
			  end
			end

   default :
			begin
             wash_done = 1'b0 ;
			 current_state_duration  = 3'd0 ;
			 run_timer = 1'b0 ;
			 
			 fill_water_sig = 1'b0 ;
			 washing_sig = 1'b0 ;
			 rinse_sig = 1'b0 ;
			 spin_sig = 1'b0 ;
			 increment_wash_rinse_count = 1'b0;
             end  
   endcase  
   
 end
 
 //Counter that increments every time the signal "increment_wash_rinse_count" is high and resets to zero when the wash is done
always @ (posedge increment_wash_rinse_count or posedge wash_done or negedge rst_n )
 begin
  if(!rst_n)
   begin
	wash_rinse_count <= 2'd0 ;
   end
  else if (wash_done)
   begin
    wash_rinse_count <= 2'd0 ;
   end
  else 
   begin 
	wash_rinse_count <= wash_rinse_count + 2'd1;
   end
 end

endmodule