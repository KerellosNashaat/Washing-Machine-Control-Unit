`timescale 1ms/100ns		
/***********Very important note: for lowering the simulation time, we will work with Frequencies in kHz rsnge to verify the functionality**********/

module WashingMachineCU_tb ();


/////////////////////////////////////////////////////////
///////////////////// Parameters ////////////////////////
/////////////////////////////////////////////////////////
parameter SYSTEM_CLK_PERIOD = 0.125 ;		//in ms units

parameter MINUTE_DELAY = 60000 ; //As the timescale is 1 ms, so 1 min = 60000 ms, Please note if the timescale changes, this parameter should be modified

//We assumed that the input clk frequency= 8 MHz   
//and we divide it internally to get the desired frequencies
//So the period of the 8 MHz input clock is 0.125 us 	"for lowering the simulation time we will work with 8 kHz frequency so its period = 0.125 ms, 
//if required to return to the Mhz range, change the SYSTEM_CLK_PERIOD to 0.125 us =  0.000125 msec and some minor modifications in Timer module written in the last lines there"


////////////////////////////////////////////////////////
/////////////////// DUT Signals //////////////////////// 
////////////////////////////////////////////////////////

reg				rst_n_tb;
reg				clk_tb;
reg		[1:0]	clk_freq_tb;
reg				coin_in_tb;
reg				double_wash_tb;
reg				timer_pause_tb;

wire			fill_water_sig_tb;
wire			washing_sig_tb;
wire			rinse_sig_tb;
wire			spin_sig_tb;



wire			wash_done_tb;


////////////////////////////////////////////////////////
////////////////// initial block /////////////////////// 
////////////////////////////////////////////////////////
initial
 begin

  // Save Waveform
  $dumpfile("Washing_MashineCU.vcd") ;       
  $dumpvars; 
  
  initialize();
  
  reset();
  

  
  $display("/****************************************************************************************/");
  $display("/*************************** Test Case 1: Start a normal wash ***************************/");
  $display("/****************************************************************************************/\n");
  double_wash_tb = 1'b0;
  timer_pause_tb = 1'b0;
  
  insert_coin();
  $monitor ("fill_water = %d, washing_sig = %d, rinse_sig = %d, spin_sig = %d, wash_done = %d, Current time = %dms = %d minutes",fill_water_sig_tb,washing_sig_tb,rinse_sig_tb,spin_sig_tb,wash_done_tb,$time, $time/60000);

  
  check_if_entered_fill_water_state();
  
  repeat(2) wait_one_min();
  check_if_entered_wash_state();
  
  repeat(5) wait_one_min();
  check_if_entered_rinse_state();
	
  repeat(2) wait_one_min();
  check_if_entered_spinning_state();
  
  wait_one_min();
  check_if_reterned_to_ideal_state();
  

  
  #5
  $display("/****************************************************************************************/");
  $display("/*************************** Test Case 2: Start a Double wash ***************************/");
  $display("/****************************************************************************************/\n");
  double_wash_tb = 1'b1;
  timer_pause_tb = 1'b0;
  
  insert_coin();
  

  check_if_entered_fill_water_state();
  
  repeat(2)
   begin
  
    repeat(2) wait_one_min();
    check_if_entered_wash_state();
  
    repeat(5) wait_one_min();
    check_if_entered_rinse_state();
   
   end
  
  repeat(2) wait_one_min();
  check_if_entered_spinning_state();
  
  wait_one_min();
  check_if_reterned_to_ideal_state();
  
  #5
  $display("/****************************************************************************************/");
  $display("/*************************** Test Case 3: Testing Timer Pause ***************************/");
  $display("/****************************************************************************************/\n");
  double_wash_tb = 1'b0;
  timer_pause_tb = 1'b1;	
  
  
  $display("The input timer_pause_tb signal is set to high at time = %dms = %d minutes\n",$time, $time/60000);
  
  #5
  insert_coin();
  
  check_if_entered_fill_water_state();
  repeat(1) wait_one_min();
  if (fill_water_sig_tb)
   $display("The timer_pause signal didn't affect the filling water state\n");
  else 
   $display("The timer_pause signal affected the fill water state and lowered the fil_water_signal\n");
  repeat(1) wait_one_min();
   
  check_if_entered_wash_state();
  repeat(2) wait_one_min();
  if (washing_sig_tb)
   $display("The timer_pause signal didn't affect the washing state\n");
  else 
   $display("The timer_pause signal affected the washing state and lowered the washing_sig\n");
  repeat(3) wait_one_min();
  
  check_if_entered_rinse_state();
  repeat(1) wait_one_min();
  if (rinse_sig_tb)
   $display("The timer_pause signal didn't affect the rinsing state\n");
  else 
   $display("The timer_pause signal affected the rinsing state and lowered the rinse_sig\n");
  #(0.5*MINUTE_DELAY)
	
  timer_pause_tb = 1'b0;		
  //we lowering the timer_pause_signal to give chance to the FSM to enter the spinning state, and then we will make it high again
  $display("The input timer_pause_tb signal lowered at time = %dms = %d minutes\n",$time, $time/60000);
  #(0.5*MINUTE_DELAY)
  
  check_if_entered_spinning_state();
  #(0.5*MINUTE_DELAY)
  timer_pause_tb = 1'b1; 
  $display("The input timer_pause_tb signal set to high at time = %dms = %d minutes\n",$time, $time/60000);
  #5
  if (spin_sig_tb)
   $display("\nThe timer_pause signal didn't affect the spinning state\n");
  else 
   $display("\nThe timer_pause signal affected the spinning state and lowered the spin_sig and the machine stopped spinning\n");
   
  #(0.5*MINUTE_DELAY)
  check_if_reterned_to_ideal_state();
  
  timer_pause_tb = 1'b0;
  $display("The input timer_pause_tb signal lowered at time = %dms = %d minutes\n",$time, $time/60000);
  
  #5
  if (spin_sig_tb)
   $display("\nThe timer resumed and the the machine resumed spinning\n\n");
  else 
   $display("\nThe timer_pause signal affected spin_sig and the machine didn't resume spinning\n");
  
 
  #(0.5*MINUTE_DELAY)
  check_if_reterned_to_ideal_state();
  #100
  $finish;
 end


////////////////////////////////////////////////////////
/////////////////////// TASKS //////////////////////////
////////////////////////////////////////////////////////
task initialize;
 begin
  clk_tb = 1'b0;
  clk_freq_tb = 2'b11; //8MHz
  coin_in_tb = 1'b0;
  double_wash_tb = 1'b0;
  timer_pause_tb = 1'b0;
 end
endtask 

task reset;
 begin
  rst_n_tb = 1'b1;
  #5
  rst_n_tb = 1'b0;
  #5
  rst_n_tb = 1'b1;
 end
endtask



task insert_coin;
 begin
  coin_in_tb = 1'b1;
  $display("		Coin Inserted and Machine Started at time = %dms = %d minutes\n",$time, $time/60000);
  #1
  coin_in_tb = 1'b0;
 end
endtask


task check_if_entered_fill_water_state;
 begin
  #1
  if (fill_water_sig_tb == 1'b1 && washing_sig_tb == 1'b0 && rinse_sig_tb == 1'b0 && spin_sig_tb == 1'b0 && wash_done_tb == 1'b0)
   begin
   $display("		/************ Entered the Filling State ************/\n");
   end
  else 
   $display("	Failed to enter Filling water state at the required time, Timer is maybe paused\n");
 end
 endtask

task check_if_entered_wash_state;
 begin
  #1
  if (fill_water_sig_tb == 1'b0 && washing_sig_tb == 1'b1 && rinse_sig_tb == 1'b0 && spin_sig_tb == 1'b0 && wash_done_tb == 1'b0)
   begin
   $display("		/************ Entered the Washing State ************/\n");
   end
  else 
   $display("	Failed to enter Washing state at the required time, Timer is maybe paused\n");
   
 end
endtask
 
task check_if_entered_rinse_state;
 begin
 
  #1
  if (fill_water_sig_tb == 1'b0 && washing_sig_tb == 1'b0 && rinse_sig_tb == 1'b1 && spin_sig_tb == 1'b0 && wash_done_tb == 1'b0)
   begin
   $display("		/************ Entered the Rinsing State ************/\n");
  end
  else 
   $display("	Failed to enter Rinsing state at the required time, Timer is maybe paused\n");
   
 end
endtask
 
task check_if_entered_spinning_state;
 begin
 
  #1
  if (fill_water_sig_tb == 1'b0 && washing_sig_tb == 1'b0 && rinse_sig_tb == 1'b0 && spin_sig_tb == 1'b1 && wash_done_tb == 1'b0)
   begin
   $display("		/************ Entered the Spinning State ************/\n");
   end
  else 
   $display("	Failed to enter Spinning state at the required time, Timer is maybe paused\n");
   
 end
endtask

task check_if_reterned_to_ideal_state();
 begin
 
  #1
  if (fill_water_sig_tb == 1'b0 && washing_sig_tb == 1'b0 && rinse_sig_tb == 1'b0 && spin_sig_tb == 1'b0 && wash_done_tb == 1'b1)
   begin
   $display("		/************ Wash Done and Returned to Ideal state ************/\n");
   end
  else 
   $display("Stuck in the Spinning state and didn't return to the Ideal state and , Timer is paused\n");
   
 end
endtask

task wait_one_min;
 begin
  #(MINUTE_DELAY); 
 end
endtask
////////////////////////////////////////////////////////
////////////////// Clock Generator  ////////////////////
////////////////////////////////////////////////////////
initial
 begin
	forever #(0.5*SYSTEM_CLK_PERIOD)  clk_tb = ~clk_tb ;
 end
  
////////////////////////////////////////////////////////
/////////////////// DUT Instantation ///////////////////
////////////////////////////////////////////////////////
WashingMachine_TopModule DUT 
(
.rst_n(rst_n_tb),
.clk(clk_tb),
.clk_freq(clk_freq_tb),
.coin_in(coin_in_tb),
.double_wash(double_wash_tb),
.timer_pause(timer_pause_tb),

.fill_water_sig(fill_water_sig_tb),
.washing_sig(washing_sig_tb),
.rinse_sig(rinse_sig_tb),
.spin_sig(spin_sig_tb),

.wash_done(wash_done_tb)
);

endmodule