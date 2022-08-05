module WashingMachine_TopModule (
input	wire			rst_n,
input	wire			clk,
input	wire	[1:0]	clk_freq,
input	wire			coin_in,
input	wire			double_wash,
input	wire			timer_pause,

output	wire			fill_water_sig,
output	wire			washing_sig,
output	wire			rinse_sig,
output	wire			spin_sig,

output	wire			wash_done
);

wire 			run_timer, timer_restart, divided_clk;
wire 	[2:0]	timer_elapsed_minutes;

WashingMachineCU U1
(
.rst_n(rst_n),
.clk(divided_clk),

.coin_in(coin_in),
.double_wash(double_wash),
.timer_pause(timer_pause),
.timer_elapsed_minutes(timer_elapsed_minutes),

.fill_water_sig(fill_water_sig),
.washing_sig(washing_sig),
.rinse_sig(rinse_sig),
.spin_sig(spin_sig),


.run_timer(run_timer),

.state_timeout_flag(timer_restart),

.wash_done(wash_done)
);

Timer U2
(
.rst_n(rst_n),
.clk(divided_clk),
.clk_freq(clk_freq),
.run_timer(run_timer),
.timer_restart(timer_restart),


.timer_elapsed_minutes(timer_elapsed_minutes)
);

SimpleClkDivider U3
(
.rst_n(rst_n),
.clk(clk),
.clk_freq(clk_freq),
.divided_clk(divided_clk)
);
endmodule