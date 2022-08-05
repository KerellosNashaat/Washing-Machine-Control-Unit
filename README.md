# Washing-Machine-Control-Unit

The architecture consists of three main blocks : 

1. Main Module: FSM (Five states: idle, Filling water, Washing, Rinsing, Spinning). 

2. Timer Module that control the transition between the FSM states (i.e each FSM state has a specific time then the FSM transfer to the following state). 

3. Clock Divider Module. (it was a requirement on the system just for practicing)



![shapes11111111111pptx](https://user-images.githubusercontent.com/87245386/182995872-9010b851-eabe-4ae8-ad03-4dde1cc3acdb.jpg)

# State diagram of the FSM


![Picture1](https://user-images.githubusercontent.com/87245386/183000334-b8fd2d6f-9d73-425f-a915-1cc277aacb1a.png)

The washing machine control unit transfers from ideal state when inserting a coin supports two modes :

1. Normal mode (single wash) :

Filling Water (2 minutes) then Washing (5 minutes) then Rinsing (2 minutes) then Spinning (1 minute).

2. Double wash mode :

Filling Water (2 minutes) then Washing (5 minutes) then Rinsing (2 minutes) then repeating the Washing and Rinsing cycle "Washing (5 minutes) then Rinsing (2 minutes)" then Spinning (1 minute).




