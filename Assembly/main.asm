; Copyright 2024 Matthew Higginson <mhigginson81@gmail.com>
;
; Permission is hereby granted, free of charge, to any person obtaining a copy of 
; this software and associated documentation files (the “Software”), to deal in the 
; Software without restriction, including without limitation the rights to use, copy, 
; modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, 
; and to permit persons to whom the Software is furnished to do so, subject to the following conditions:
;
; The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.
;
; THE SOFTWARE IS PROVIDED “AS IS”, WITHOUT WARRANTY OF ANY KIND, 
; EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES
; OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. 
; IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, 
; DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, 
; ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

; LCD 4-BIT MODE WIRING
;
; PA0 > LCD PIN 12 (DB4)
; PA1 > LCD PIN 11 (DB5)
; PA2 > LCD PIN 13 (DB6)
; PA3 > LCD PIN 14 (DB7)
; PA4 > LCD PIN 4 (RS)
; PA5 > LCD PIN 5 (EN)

.INCLUDE    "tn26def.inc"               ; Labels and identifiers for tiny26L

.def temp = r17                         ; Scratch register
.def loop_count = r18                   ; Accumulator Scratch register 

.equ LCD = PORTA
.equ RS = PA4
.equ EN = PA5

.DSEG
char:
 .byte 1
.CSEG
.org $0000                              ; Reset Vector
    rjmp RESET


RESET:
    ldi r16, RAMEND                     ; Main program start
    out SP, r16                         ; Init stack pointer (0x00df)                   
    ser temp
    out DDRA, temp                      ; DDRA LCD -> Outputs
    ser temp
    out DDRB, temp                      ; DDRB LCD -> Outputs

INIT_LCD:
    rcall WAIT_100ms                    ; Power on wait
    ldi temp, $03                       ; Function set (1st pass)
    out LCD, temp
    rcall PULSE_EN
    rcall WAIT_10ms
    rcall PULSE_EN                      ; Function set (2nd pass)
    rcall WAIT_1MS
    rcall PULSE_EN                      ; Function set (3rd pass)
    rcall WAIT_1MS
    
    ldi temp, $02                       ; Start 4 bit mode
    rcall PULSE_EN              
    
    ldi temp, $80                       ; 4-bit, 2 lines
    rcall LCD_INSTRUCTION              
    
    ldi temp, $10                       ; cursor shift
    rcall LCD_INSTRUCTION              
       
    ldi temp, $07                       ; display on
    rcall LCD_INSTRUCTION              
    
    ldi temp, $01                       ; clear screen
    rcall LCD_INSTRUCTION              
	
	ldi ZH, high(hello_msg<<1)
	ldi ZL, low(hello_msg<<1)
	lpm temp, Z+	
	sts char, temp
	rcall write_lcd
	lpm temp, Z+	
	sts char, temp
	rcall write_lcd
	lpm temp, Z+	
	sts char, temp
	rcall write_lcd
	lpm temp, Z+
	sts char, temp
	rcall write_lcd





Main:
rjmp Main


LCD_INSTRUCTION:
    ; Send an instuction to the LCD
    cbi PORTB, PB0                         ; Select instruction register
    swap temp                           ; Byte order High Low
    push temp                           ; Save swapped temp for low order bits
    andi temp, $0F
    out LCD, temp                       ; High nibble out
    rcall PULSE_EN
    pop temp                            ; Get swapped value of temp from the stack
    swap temp                           ; Swap in low order bits
    andi temp, $0F
    out LCD, temp                       ; Low nibble out
    rcall PULSE_EN
ret

WRITE_LCD:
    ; Send a charcter to the LCD
    sbi PORTB, PB0
	lds temp, char                      ; Save swapped temp for low order bits
    andi temp, $F0  
	swap temp
	out LCD, temp                       ; High nibble out
    rcall PULSE_EN
    lds temp, char                      ; Get swapped value of temp from the stack
    andi temp, $0F
	out LCD, temp                       ; Low nibble out
  	rcall PULSE_EN
ret


PULSE_EN:
    sbi PORTB, PB1
	rcall WAIT_1MS
	cbi PORTB, PB1
ret


WAIT_1MS:
; Assembly code auto-generated
; by utility from Bret Mulvey
; Delay 1 000 cycles
; 1ms at 1 MHz

    ldi  r18, 2
    ldi  r19, 75
L1_1: dec  r19
    brne L1_1
    dec  r18
    brne L1_1
    rjmp PC+1
ret

WAIT_10ms:
; Assembly code auto-generated
; by utility from Bret Mulvey
; Delay 10 000 cycles
; 10ms at 1 MHz

    ldi  r18, 13
    ldi  r19, 252
L1_10: dec  r19
    brne L1_10
    dec  r18
    brne L1_10
    nop
ret

WAIT_100ms:
; Assembly code auto-generated
; by utility from Bret Mulvey
; Delay 100 000 cycles
; 100ms at 1 MHz

    ldi  r18, 130
    ldi  r19, 222
L1_100: dec  r19
    brne L1_100
    dec  r18
    brne L1_100
    nop
ret


; Message Storage

hello_msg:
	.db 'S','A','T',':'

END:
    rjmp END
; ++eof
