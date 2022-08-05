module SimpleClkDivider (
input	wire			rst_n, //The Asynchronous Reset
input 	wire			clk,  //The input system clock
input	wire	[1:0]	clk_freq, 

output	reg				divided_clk
);

reg     [2:0]       Counter;

////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
/////////////////////////////////////////////// Methodology ////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//Assume the system input clock frequency is 8 MHz, So we will use a 3 bit counter that counts up every positive edge
//So that its LSB gives the input frequency divided by 2, and the second bit gives the input frequency divided by 4
//and MSB gives the system input divided by 8, so that we will have all the required clock frequencies
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

always @ (posedge clk or negedge rst_n)
 begin
  if(!rst_n)
   begin
	Counter <= 3'b0 ;
   end
  else 
   begin 
    Counter <= Counter + 3'b1 ;
   end
 end


always @(*)
 begin
   case (clk_freq)
	2'b00		:	
		divided_clk = Counter[2] ;	//The 1 MHz frequency
	2'b01		:	
		divided_clk = Counter[1] ;	//The 2 MHz frequency
	2'b10		:	
		divided_clk = Counter[0] ;	//The 4 MHz frequency
	2'b11		:	
		divided_clk = clk ;			//The 8 MHz frequency "Input clock"
	default 	:
		divided_clk = clk ;
   endcase
   
 end
 
endmodule