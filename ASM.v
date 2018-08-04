module ASM (input clk,
	input rst,
	input clr,
	input ent,
	input change,
  input [3:0] sw,
 output reg [5:0] led,
 output [3:0] an,
 output [6:0] c
	);

//registers
 reg [15:0] password;
 reg [15:0] inpassword;
 reg [5:0] current_state;
 reg [5:0] next_state; 
 //reg [1:0] entcount;
 reg iflock;
 
 wire newclk,newrst,newent,newchange,newclr;
 reg [19:0] ssd;
// parameters for States, you will need more states obviously
parameter LOCKED = 6'b000000; //idle state
parameter GETFIRSTDIGIT = 6'b000001; // get_first_input_state // this is not a must, one can use counter instead of having another step, design choice
parameter GETSECONDDIGIT = 6'b000010; //get_second input state
parameter GETTHIRDDIGIT = 6'b000011;
parameter GETFOURTHDIGIT = 6'b000100;
parameter UNLOCKED = 6'b000101;
parameter CHANGEFIRSTDIGIT = 6'b000110;
parameter CHANGESECONDDIGIT = 6'b000111;
parameter CHANGETHIRDDIGIT = 6'b001000;
parameter CHANGEFOURTHDIGIT = 6'b001001;

// parameters for output, you will need more obviously
parameter O = 5'b00000;
parameter one = 5'b00001;
parameter two = 5'b00010;
parameter three = 5'b00011;
parameter four = 5'b00100;
parameter five = 5'b00101;
parameter six = 5'b00110;
parameter seven = 5'b00111;
parameter eight = 5'b01000;
parameter nine = 5'b01001;
parameter A = 5'b01010;
parameter B = 5'b01011;
parameter C = 5'b01100;
parameter D = 5'b01101;
parameter E = 5'b01110;
parameter F = 5'b01111;
parameter blank = 5'b10000;
parameter U = 5'b10001;
parameter down = 5'b10010;
parameter tire=5'b10011;
parameter L = 5'b10100;
parameter P = 5'b10101;
parameter n = 5'b10110;
parameter dash = 5'b10111;
reg [4:0] b1, b2, b3, b4;
clk_divider cld1(clk,rst,newclk);
debouncer db1(newclk,rst,ent,newent);
debouncer db2(newclk,rst,clr,newclr);
debouncer db3(newclk,rst,change,newchange);
//Sequential part for state transitions
 always @ (posedge newclk or posedge rst)
 begin
  // your code goes here
  if(rst==1)
  current_state<= LOCKED;
  else
  current_state<= next_state;
 end

 // combinational part - next state definitions
 always @ (*)
 begin
  if(current_state == LOCKED) //locked state   1
  begin
   if(newent == 1)
    next_state = GETFIRSTDIGIT;
   else
    next_state = current_state;
  end
 
  else if (current_state == GETFIRSTDIGIT)  // getfirstdigit state 2
  begin
	if (newent == 1)
	 next_state = GETSECONDDIGIT;
	else
	 next_state = current_state;
    
  end
  
  else if (current_state == GETSECONDDIGIT)  // getseconddigit state 3
  begin
	if(clr == 1)
    next_state = GETFIRSTDIGIT;
	else if (newent == 1)
	 next_state = GETTHIRDDIGIT;
	else
	 next_state = current_state;
    
  end
  
  else if (current_state == GETTHIRDDIGIT)  // getseconddigit state 4
  begin
   if(clr == 1)
     next_state = GETFIRSTDIGIT;
   else if (newent == 1)
	 next_state = GETFOURTHDIGIT;
	else
	 next_state = current_state;
    
  end
  
  
  else if (current_state == GETFOURTHDIGIT)  // getfourthdigit state 5
  begin
   
   if(clr == 1)
    next_state = GETFIRSTDIGIT;
   else if (newent == 1)
    begin
     if(iflock==1)
     begin
       if(inpassword == password)
        next_state = LOCKED;
       else
        next_state = UNLOCKED;
     end
     else if(inpassword == password)
      next_state = UNLOCKED;
     else
      next_state = LOCKED;
    end
    
	else
	 next_state = current_state;
    
  end
  
  
  else if(current_state == UNLOCKED) // unlocked state 6
  begin
   if(newent==1)
    next_state = GETFIRSTDIGIT;
   else if(newchange==1)   
    next_state = CHANGEFIRSTDIGIT;
   else
    next_state = current_state;
  end
    
    
  else if (current_state == CHANGEFIRSTDIGIT)  // getseconddigit state 7
  begin
	if (newent == 1)
	 next_state = CHANGESECONDDIGIT;
	else
	 next_state = current_state;
    
  end 
  
  else if (current_state == CHANGESECONDDIGIT)  // getseconddigit state 8
  begin
	if(clr == 1)
    next_state = CHANGEFIRSTDIGIT;
	else if (newent == 1)
	 next_state = CHANGETHIRDDIGIT;
	else
	 next_state = current_state;
    
  end
  
  else if (current_state == CHANGETHIRDDIGIT)  // getseconddigit state  9
  begin
	if(clr == 1)
    next_state = CHANGEFIRSTDIGIT;
	else if (newent == 1)
	 next_state = CHANGEFOURTHDIGIT;
	else
	 next_state = current_state;
    
  end
  
  
  else if (current_state == CHANGEFOURTHDIGIT)  // getseconddigit state 10
  begin
	if(clr == 1)
    next_state = CHANGEFIRSTDIGIT;
	else if (newent == 1)
	 next_state = UNLOCKED;
	else
	 next_state = current_state;
    
  end
    
  
    
  /*
  you have to complete the rest, in this combinational part, DO NOT ASSIGN VALUES TO OUTPUTS DO NOT ASSIGN VALUES TO REGISTERS
  just determine the next_state, that is all. password = 0000 -> this should not be there for instance or LED = 1010 this should not be there as well
  else if
  else if

  */
  else
   next_state = current_state;
 end

  //Sequential part for control registers, this part is responsible from assigning control registers or stored values
 always @ (posedge newclk or posedge rst)
 begin
  if(rst)
  begin
   inpassword[15:0]<=0; // password which is taken coming from user,
   password[15:0]<=0;
   iflock = 0;
  end
  else
   if(current_state == LOCKED)
   begin
    iflock = 0;
	 inpassword[15:0] <= 16'b0000000000000000; // Built in reset is 0, when user in IDLE state.
 	// you may need to add extra things here.
   end
  
   else if(current_state == GETFIRSTDIGIT)
   begin
    if(newent==1)
     inpassword[15:12]<=sw[3:0]; // inpassword is the password entered by user, first 4 digin will be equal to current switch values
   end
   else if (current_state == GETSECONDDIGIT)
   begin
    if(newent==1)
     inpassword[11:8]<=sw[3:0]; // inpassword is the password entered by user, second 4 digit will be equal to current switch values
    
   end
   else if (current_state == GETTHIRDDIGIT)
   begin
    if(newent==1)
     inpassword[7:4]<=sw[3:0]; // inpassword is the password entered by user, second 4 digit will be equal to current switch values
    
   end
   
   else if (current_state == GETFOURTHDIGIT)
   begin
    if(newent==1)
     inpassword[3:0]<=sw[3:0]; // inpassword is the password entered by user, second 4 digit will be equal to current switch values
   end
   else if (current_state == UNLOCKED)
   begin
    if(newent==1)
     iflock = 1;
   end
   else if (current_state == CHANGEFIRSTDIGIT)
   begin
    if(newent==1)
     password[15:12]<=sw[3:0]; // inpassword is the password entered by user, second 4 digit will be equal to current switch values
   end
   
   else if (current_state == CHANGESECONDDIGIT)
   begin
    if(newent==1)
     password[11:8]<=sw[3:0]; // inpassword is the password entered by user, second 4 digit will be equal to current switch values
   end
   
   else if (current_state == CHANGETHIRDDIGIT)
   begin
    if(newent==1)
     password[7:4]<=sw[3:0]; // inpassword is the password entered by user, second 4 digit will be equal to current switch values
   end
   else if (current_state == CHANGEFOURTHDIGIT)
   begin
    if(newent==1)
     password[3:0]<=sw[3:0]; // inpassword is the password entered by user, second 4 digit will be equal to current switch values
   end
   
   
  /*
  Complete the rest of ASM chart, in this section, you are supposed to set the values for control registers, stored registers(password for instance)
  number of trials, counter values etc...
  */
 end

 // Sequential part for outputs; this part is responsible from outputs; i.e. SSD and LEDS

 always @(posedge newclk)
 begin
 
  led = current_state;
  if(current_state == LOCKED)
  begin
  ssd <= {D,five,L,C}; //CLSD
  end
  else if(current_state == GETFIRSTDIGIT)
  begin
  ssd <= {blank,blank,blank,sw[3:0]}; // you should modify this part slightly to blink it with 1Hz. The 0 is at the beginning is to complete 4bit SW values to 5 bit.
  end
  else if(current_state == GETSECONDDIGIT)
  begin
  ssd <= {blank,blank,sw[3:0],dash}; // you should modify this part slightly to blink it with 1Hz. 0 after tire is to complete 4 bit sw to 5 bit. Padding 4 bit sw with 0 in other words. 
  end
  
  else if(current_state == GETTHIRDDIGIT)
  begin
  ssd <= {blank,sw[3:0],dash,dash};
  end
  
  else if(current_state == GETFOURTHDIGIT)
  begin
  ssd <= {sw[3:0],dash,dash,dash};
  end
  
  else if(current_state == UNLOCKED)
  begin
  ssd <= {n,E,P,O};
  end
  
  else if(current_state == CHANGEFIRSTDIGIT)
  begin
  b1 = sw[3:0];
  ssd <= {blank,blank,blank,b1};
  end
  
  else if(current_state == CHANGESECONDDIGIT)
  begin
  b2 = sw[3:0];
  ssd <= {blank,blank,b2,b1};
  end
  
  else if(current_state == CHANGETHIRDDIGIT)
  begin
  b3 = sw[3:0];
  ssd <= {blank,b3,b2,b1};
  end
  
  else if(current_state == CHANGEFOURTHDIGIT)
  begin
  b4 = {0,sw[3:0]};
  ssd <= {b4,b3,b2,b1};
  end
  
  
 end
 
 seven_segment s1(newclk,ssd,an,c);
 
endmodule

