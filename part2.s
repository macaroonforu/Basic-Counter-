//LAB THREE PART TWO WITH KEY FUNCTIONALITY
.global _start

_start: LDR SP, =200000
        MOV R0, #0 
		MOV R2, #0 
        MOV R1, #0 
		MOV R3, #0
		MOV R5, #0
        LDR  R8, =0xFF200020 // base address of HEX3-HEX0
		LDR  R6, =0xFF20005c //Edge Capture Register of Keys 

COUNTER: MOV R0, R2 
	     CMP R0, #100 
	     BEQ COUNTER_RESET
		
		 PUSH {LR}
	     BL DIVIDE
		 POP {LR}
		 
		 MOV R9, R1 //Save the 10s digit for later
		 
		 PUSH {LR}
	     BL SEG7_CODE //Convert the ones digit into bit code
		 POP {LR} 
		 
	     MOV R3, R0  //Move the ones digit bit code into R3
		 
		 PUSH {R9}
	     MOV R0, R9 //Move the 10s digit into R0 
		 
		 PUSH {LR} 
	     BL SEG7_CODE
		 POP {LR} 
		 
	     LSL R0, #8  //Shift 10s digit 8 bits over 
		
	     ORR  R0, R3 //Combine the two together 

	     STR R0, [R8] //Display the number 
	  
	     ADD R2, #1
		 
		 PUSH {LR}
		 BL DO_DELAY
         POP {LR} 
		 
		 POP {R9}
		 B COUNTER
		 		 
COUNTER_RESET: MOV R0, #0 
			   MOV R2, #0 
			   B COUNTER
			   
DO_DELAY: PUSH {R5-R7}
		  LDR R7, =500000
		  B SUB_LOOP
		  
SUB_LOOP: LDR R5, [R6] //Load the edge capture register into R5 
		  ANDS R5, #15  
		  BGT ECR_RESET_1  //Check if a key was pressed. If so, branch to reset and wait
		  
		  SUBS R7, R7, #10 
		  BNE SUB_LOOP
		  POP {R5-R7}
		  MOV PC, LR 
	  
ECR_RESET_1: MOV R5, #15 
             STR R5, [R6] //Store ones into ECR to reset it 
			 B WAIT  //Branch to wait loop where we will stay until another key is pressed

WAIT:        LDR R5, [R6]  //Again, load the ECR into R5
			 ANDS R5, #15  //Check if a key was presed, if so, go back to sub loop 
			 BGT ECR_RESET_2
			 B WAIT

ECR_RESET_2: MOV R5, #15  
			 STR R5, [R6]   //Store ones into ECR to reset it 
			 B SUB_LOOP  

DIVIDE: 	PUSH {R2}
			MOV R2, #0

CONT: 		CMP R0, #10
	  		BLT DIV_END
	  		SUB R0, #10
	  		ADD R2, #1
	  		B CONT

DIV_END: 	MOV R1, R2 // quotient in R1 (remainder in R0)
			POP {R2}
			MOV PC, LR 

SEG7_CODE:  MOV     R1, #BIT_CODES  
            ADD     R1, R0         // index into the BIT_CODES "array"
            LDRB    R0, [R1]       // load the bit pattern (to be returned)
            MOV     PC, LR              

BIT_CODES:  .byte   0b00111111, 0b00000110, 0b01011011, 0b01001111, 0b01100110
            .byte   0b01101101, 0b01111101, 0b00000111, 0b01111111, 0b01100111
            .skip   2   
//0 =3f        //1=6			   //2=5b 				  //3=4f 
//4=66		  //5=6d              //6=7d 		         //7=7 
//8=7f       //9=67 

// pad with 2 bytes to maintain word alignment