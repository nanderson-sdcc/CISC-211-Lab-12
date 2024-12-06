/*** asmSort.s   ***/
#include <xc.h>
.syntax unified

@ Declare the following to be in data memory
.data
.align    

@ Define the globals so that the C code can access them

.if 0    
@ left these in as an example. Not used.
.global fMax
.type fMax,%gnu_unique_object
 fMax: .word 0
.endif 

@ Tell the assembler that what follows is in instruction memory    
.text
.align

/********************************************************************
function name: asmSwap(inpAddr,signed,elementSize)
function description:
    Checks magnitude of each of two input values 
    v1 and v2 that are stored in adjacent in 32bit memory words.
    v1 is located in memory location (inpAddr)
    v2 is located at mem location (inpAddr + M4 word dize)
    
    If v1 or v2 is 0, this function immediately
    places 0 in r0 and returns to the caller.
    
    Else, if v1 <= v2, this function 
    does not modify memory, and returns 0 in r0. 

    Else, if v1 > v2, this function 
    swaps the values and returns 1 in r0

Inputs: r0: inpAddr: Address of v1 to be examined. 
	             Address of v2 is: inpAddr + M4 word size
	r1: signed: 1 indicates values are signed, 
	            0 indicates values are unsigned
	r2: size: number of bytes for each input value.
                  Valid values: 1, 2, 4
                  The values v1 and v2 are stored in
                  the least significant bits at locations
                  inpAddr and (inpAddr + M4 word size).
                  Any bits not used in the word may be
                  set to random values. They should be ignored
                  and must not be modified.
Outputs: r0 returns: -1 If either v1 or v2 is 0
                      0 If neither v1 or v2 is 0, 
                        and a swap WAS NOT made
                      1 If neither v1 or v2 is 0, 
                        and a swap WAS made             
             
         Memory: if v1>v2:
			swap v1 and v2.
                 Else, if v1 == 0 OR v2 == 0 OR if v1 <= v2:
			DO NOT swap values in memory.

NOTE: definitions: "greater than" means most positive number
********************************************************************/     
.global asmSwap
.type asmSwap,%function     
asmSwap:

    /* YOUR asmSwap CODE BELOW THIS LINE! VVVVVVVVVVVVVVVVVVVVV  */
    PUSH {r4-r11, LR}

    MOV r11, r0 /* This is used later to have a reference to the original memory value */

    /* First, lets load the values into the registers. To do this, we only
    want to load the necessary data. So we need to check the size, as well as the
    sign. */

    /* Easy case is for a size of 4 bytes, since the signed or unsigned versions are identical. */
    CMP r2, 4
    BEQ four_bytes_case

    /* At this point, we know it isn't 4 bytes, so the choice is between signed or unsigned 1 or 2 bytes.
    One of the easy cases to check is if both r1 and r2 are 1, meaning a signed 1 byte value. */
    CMP r1, r2
    BEQ signed_one_byte_case

    /* Now we can check the remaining case for signed 2 bytes */
    CMP r1, 0
    BNE signed_two_byte_case

    /* Remaining cases are unsigned 1 byte or 2 byte. We simply check size then. */
    CMP r2, 1
    BEQ unsigned_one_byte_case

    /* Final case is 2 byte unsigned */
    LDRH r4, [r0], 4
    LDRH r5, [r0]

    /* At this point, we know its unsigned, so we do our comparison and return the function. */
    CMP r4, r5
    MOVHI r0, 1
    MOVLS r0, 0

    /* Check if either is zero and override our return value if so. */
    CMP r4, 0
    MOVEQ r0, -1
    CMP r5, 0
    MOVEQ r0, -1

    /* Finally, we determine if a swap in neccessary. */
    CMP r0, 1
    BEQ swap

    POP {r4-r11, LR}
    MOV PC, LR  

four_bytes_case:
    /* We know the value is 4 bytes, so we can use a regular load regardless of sign */
    LDR r4, [r0], 4
    LDR r5, [r0]

    /* Since we didn't determine if this case is signed or unsigned, we need to check the sign and then branch accordingly. */
    CMP r1, 0
    BNE four_bytes_signed_comparison

    /* At this point, we know its unsigned, so we do our comparison and return the function. */
    CMP r4, r5
    MOVHI r0, 1
    MOVLS r0, 0

    /* Check if either is zero and override our return value if so. */
    CMP r4, 0
    MOVEQ r0, -1
    CMP r5, 0
    MOVEQ r0, -1

    /* Finally, we determine if a swap in neccessary. */
    CMP r0, 1
    BEQ swap

    POP {r4-r11, LR}
    MOV PC, LR  

signed_one_byte_case:
    /* Load the values */
    LDRSB r4, [r0], 4
    LDRSB r5, [r0]

    /* Do the proper comparison for this case. */
    CMP r4, r5
    MOVGT r0, 1
    MOVLE r0, 0

    /* Check if either is zero and override our return value if so. */
    CMP r4, 0
    MOVEQ r0, -1
    CMP r5, 0
    MOVEQ r0, -1

    /* Finally, we determine if a swap in neccessary. */
    CMP r0, 1
    BEQ swap

    POP {r4-r11, LR}
    MOV PC, LR

signed_two_byte_case:
    LDRSH r4, [r0], 4
    LDRSH r5, [r0]

    /* Do the proper comparison for this case. */
    CMP r4, r5
    MOVGT r0, 1
    MOVLE r0, 0

    /* Check if either is zero and override our return value if so. */
    CMP r4, 0
    MOVEQ r0, -1
    CMP r5, 0
    MOVEQ r0, -1

    /* Finally, we determine if a swap in neccessary. */
    CMP r0, 1
    BEQ swap

    POP {r4-r11, LR}
    MOV PC, LR

unsigned_one_byte_case:
    LDRB r4, [r0], 4
    LDRB r5, [r0]

    /* At this point, we know its unsigned, so we do our comparison and return the function. */
    CMP r4, r5
    MOVHI r0, 1
    MOVLS r0, 0

    /* Check if either is zero and override our return value if so. */
    CMP r4, 0
    MOVEQ r0, -1
    CMP r5, 0
    MOVEQ r0, -1

    /* Finally, we determine if a swap in neccessary. */
    CMP r0, 1
    BEQ swap

    POP {r4-r11, LR}
    MOV PC, LR  

four_bytes_signed_comparison:
    /* We know its signed, so we compare and return the function accordingly. */
    CMP r4, r5
    MOVGT r0, 1
    MOVLE r0, 0

    /* Check if either is zero and override our return value if so. */
    CMP r4, 0
    MOVEQ r0, -1
    CMP r5, 0
    MOVEQ r0, -1

    /* Finally, we determine if a swap in neccessary. */
    CMP r0, 1
    BEQ swap

    POP {r4-r11, LR}
    MOV PC, LR

swap:
    /* This directive swaps the values. We saved the address of v1 into r11 at the very beginning, so we will use that. */

    /* We check the size of the data and use the proper storing instruction. r4 contains v1 and r5 contains v2, so a swap
    puts the value from r5 into r11, increments the address by 4, then places the value of r4 into the new r11 pointer value.  */
    CMP r2, 1
    STRBEQ r5, [r11], 4
    STRBEQ r4, [r11]

    CMP r2, 2
    STRHEQ r5, [r11], 4
    STRHEQ r4, [r11]

    CMP r2, 4
    STREQ r5, [r11], 4
    STREQ r4, [r11]

    POP {r4-r11, LR}
    MOV PC, LR

    /* YOUR asmSwap CODE ABOVE THIS LINE! ^^^^^^^^^^^^^^^^^^^^^  */
    
    
/********************************************************************
function name: asmSort(startAddr,signed,elementSize)
function description:
    Sorts value in an array from lowest to highest.
    The end of the input array is marked by a value
    of 0.
    The values are sorted "in-place" (i.e. upon returning
    to the caller, the first element of the sorted array 
    is located at the original startAddr)
    The function returns the total number of swaps that were
    required to put the array in order in r0. 
    
         
Inputs: r0: startAddr: address of first value in array.
		      Next element will be located at:
                          inpAddr + M4 word size
	r1: signed: 1 indicates values are signed, 
	            0 indicates values are unsigned
	r2: elementSize: number of bytes for each input value.
                          Valid values: 1, 2, 4
Outputs: r0: number of swaps required to sort the array
         Memory: The original input values will be
                 sorted and stored in memory starting
		 at mem location startAddr
NOTE: definitions: "greater than" means most positive number    
********************************************************************/     
.global asmSort
.type asmSort,%function
asmSort:   

    /* Note to Profs: 
     */

    /* YOUR asmSort CODE BELOW THIS LINE! VVVVVVVVVVVVVVVVVVVVV  */
    PUSH {r4-r11, LR}

    /* We need to call the asmSwap function repeatedly, incrementing the starting address.
    We also need to keep track of the number of swaps made per cycle, since no swaps made means
    that we are done. The registers will contain this:

    r0: contains the address of our current element (this value gets incremented)
    r1: determines sign value (1=signed, 0=unsigned)
    r2: size of data values (1=byte, 2=halfword, 4=word)
    r9: determines if cycle is over (0=cycle stil going, 1=cycle is complete)
    r10: number of swaps made this cycle
    r11: beginning address of array (never incremented)

    We increment through the array, calling our sort function. We increment
    the number of swaps made per cycle. Once we hit the end of the array, we place
    1 in r9. We check if 0 swaps were made. If so, we are done. If not, we repeat the cycle
    and reset the swap counter.
    */

    /* Initialize the registers */
    MOV r11, r0
    MOV r9, 0
    MOV r10, 0

sort_loop:
    /* Call the swap function. */
    BL asmSwap

    /* It returns a value in r0, representing if a swap was made. We increment if a swap was made. */
    CMP r0, 1
    ADDEQ r10, r10, 1

    /* We check if we reached the end of the list. If we didn't, we loop again, but at
    the next address. */
    CMP r0, -1
    ADDNE r0, r11, 4
    BNE sort_loop

    /* If it didn't branch, then we know that we reached a 0 value. 
    We must check how many swaps have been made in this cycle. */
    CMP r10, 0
    POPEQ {r4-r11, LR}
    MOVEQ PC, LR

    /* Swaps were made, so we reset our counters and addresses and run the loop again. */
    MOV r0, r11
    MOV r9, 0
    MOV r10, 0
    B sort_loop

    /* YOUR asmSort CODE ABOVE THIS LINE! ^^^^^^^^^^^^^^^^^^^^^  */

   

/**********************************************************************/   
.end  /* The assembler will not process anything after this directive!!! */
           




