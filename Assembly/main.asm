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

.INCLUDE    "tn26def.inc"               ; Labels and identifiers for tiny26L

.def temp = r17                         ; Scratch register
.def loop_count = r18                   ; Accumulator Scratch register 

.equ LCD = PORTA
.equ RS = PA4
.equ EN = PA5

.org $0000                              ; Reset Vector
    rjmp RESET


RESET:
    ldi r16, RAMEND                     ; Main program start
    out SP, r16                        
    ser temp
    out DDRA, temp                      ; DDRA LCD -> Outputs
    ser temp
    out DDRB, temp                      ; DDRB LCD -> Outputs
    sbi PORTB, 0



.dseg
character: .byte 1

.cseg
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
    
    ldi temp, $01                      ; entry mode
    rcall LCD_INSTRUCTION              
    
   ldi temp, 'H'
   rcall WRITE_LCD

Main:

rjmp Main

LCD_INSTRUCTION:
    cbi LCD, RS                        ; Select instruction register
    swap temp
    push temp
    andi temp, $0F
    out LCD, temp
    pop temp
    rcall PULSE_EN
    swap temp
    andi temp, $0F
    out LCD, temp
    rcall PULSE_EN
ret

WRITE_LCD:
    swap temp
    sts character, temp
    andi temp, $0F
    out LCD, temp 
    sbi LCD, RS
    rcall PULSE_EN
    lds temp, character
    swap temp
    andi temp, $0F
    out LCD, temp
    sbi LCD, RS
    rcall PULSE_EN
ret


PULSE_EN:
    sbi LCD, EN
    rcall WAIT_1MS
    cbi LCD, EN
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

END:
    rjmp END





;A = &H20                                                      '4-bit interface
;P1 = A
;Call Nybble
;Com = &H28                                                    '4-bit, 2 lines
;Call Writecom
;Com = &H10                                                    'cursor shift
;Call Writecom
;Com = &H0F                                                    'display on
;Call Writecom
;Com = &H06                                                    'entry mode
;Call Writecom

;Com = &H01                                                    'home
;Call Writecom