;--------------------------------------------------------------------------------
; The MIT License (MIT)
; 
; Copyright (c) 2013 Hank Wei(Pamers, Inc.)
; 
; Permission is hereby granted, free of charge, to any person obtaining a copy
;;of this software and associated documentation files (the "Software"), to deal
; in the Software without restriction, including without limitation the rights
; to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
; copies of the Software, and to permit persons to whom the Software is
; furnished to do so, subject to the following conditions:
; 
; The above copyright notice and this permission notice shall be included in
; all copies or substantial portions of the Software.
; 
; THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
; IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
; FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
; AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
; LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
; OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
; THE SOFTWARE.
;--------------------------------------------------------------------------------
    C_DELAY_2MS     equ     5   ;2*500*2us=2ms
    C_DELAY_5MS     equ     10  ;5*500*2us=5ms
    C_DELAY_25MS    equ     25  ;25*500*2us=25ms
    C_DELAY_50MS    equ     50  ;50*500*2us=50ms
    C_DELAY_250MS   equ     250 ;250*500*2us=250ms

;============================================================
DELAY005MS:
    MOVLW       166
DLOOP05:
    DCSZ        WREG, F, HIGH WREG ;3*(n-1)
    JMP         DLOOP05 ;2
RET
;============================================================
DELAY2MS:
    MOVLW       C_DELAY_2MS
    MOVWF       DELAY_TMP
    JMP         DELAY_LP
;============================================================
DELAY5MS:
    MOVLW       C_DELAY_5MS
    MOVWF       DELAY_TMP
    JMP         DELAY_LP
;============================================================    
DELAY25MS:
    MOVLW       C_DELAY_25MS
    MOVWF       DELAY_TMP
    JMP         DELAY_LP
;============================================================    
DELAY50MS:
    MOVLW       C_DELAY_50MS
    MOVWF       DELAY_TMP
    JMP         DELAY_LP
;============================================================    
DELAY250MS:
    MOVLW       C_DELAY_250MS
    MOVWF       DELAY_TMP
DELAY_LP:
    CWDT
    DELAY_3X    165 ;166
    DCSZ        DELAY_TMP, F, HIGH DELAY_TMP
    JMP         DELAY_LP
RET