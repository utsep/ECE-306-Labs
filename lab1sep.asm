.ORIG x3000

; Name: Samantha Preston 
; Date: 2.28.2024
; Lab #1

; BLOCK 1
    LD  R0, PTR          ; Load the address of the first number into R0
    LDR R1, R0, #0       ; Load the first number into R1
    LDR R2, R0, #1       ; Load the second number into R2

; BLOCK 2
    LD R4, MASK1         ; Load mask for isolating high 8 bits
    AND R1, R1, R4       ; Isolate high byte of first number
    AND R2, R2, R4       ; Isolate high byte of second number
    ADD R3, R1, R2       ; Add the two numbers, result in R3

    
; BLOCK 3
; Check for overflow of the 2's complement integer addition.
; The signs of the two numbers and the sign of the calculated sum are checked. 
; A mismatch indicates an overflow.
    LD R4, CHECKSIGN     ; Load bit mask to check sign of operand 1
    AND R5, R4, R1       ; Check sign of operand 1
    BRZ CHECKNEXTPOS     ; If positive, then check the sign of operand 2
    BRN CHECKNEXTNEG     ; If negative, then check the sign of operand 2
    STR R3, R0, #3       ; If neither positive nor negative, then operand 1 must be 0, so store the sum
    BR DONE

CHECKNEXTPOS
    AND R5, R4, R2       ; Check sign of operand 2
    BRZ CHECKSUMPOS      ; If operand 2 is also positive, check if sum if also positive
    STR R3, R0, #3       ; If operand 2 is negative or 0, store the sum
    BR DONE

CHECKNEXTNEG
    AND R5, R4, R2       ; Check sign of operand 2
    BRN CHECKSUMNEG      ; If operand 2 is also negative, check if sum if also negative
    STR R3, R0, #3       ; If operand 2 is positive or 0, store the sum
    BR DONE

CHECKSUMPOS
    AND R5, R4, R3       ; Check sign of the sum
    BRN OVERFLOW         ; If both the operands are positive but sum is negative, overflow has occurred
    STR R3, R0, #3       ; Else if the sum is positive, store the sum
    BR DONE

CHECKSUMNEG
    AND R5, R4, R3       ; Check sign of the sum
    BRZ OVERFLOW         ; If both the operands are negative but sum is positive, overflow has occurred
    STR R3, R0, #3       ; Else if the sum is negative, store the sum
    BR DONE

OVERFLOW
    LD R4, OVERFLOWVAL
    STR R4, R0, #3       ; Store xFFFF

DONE
; BLOCK 4
    ; Adjusting for correct storage in x6002 for unsigned integers
    LD R0, PTR           ; Reload the pointer to x6000
    LDR R1, R0, #0       ; Reload the first number into R1
    LDR R2, R0, #1       ; Reload the second number into R2
    LD R4, MASK2         ; Load mask for isolating low 8 bits
    AND R1, R1, R4       ; Isolate low byte of first number
    AND R2, R2, R4       ; Isolate low byte of second number
    ADD R3, R1, R2       ; Add the two numbers, result in R3

; BLOCK 5
    ; Correctly store or handle overflow for unsigned integers in x6002
    LD R4, MASK3         ; Load mask for checking overflow (bit 8)
    AND R5, R3, R4       ; Check for overflow
    BRz STORE_UNSIGNED   ; If zero, no overflow, so we can store the sum
    LD R3, OVERFLOWVAL   ; Load xFFFF into R3 in case of overflow

STORE_UNSIGNED:
    ; Decision to store result or overflow value in x6002
    ST R3, PRT2          ; Store the result or overflow value in x6002

    HALT  ; End of program

PTR         .FILL x6000
PRT2        .FILL X6002  ; Correct label for unsigned result storage location
CHECKSIGN   .FILL x8000
OVERFLOWVAL .FILL XFFFF
MASK1       .FILL XFF00
MASK2       .FILL x00FF
MASK3       .FILL x0100
NEGONE      .FILL xFFFF  

.END