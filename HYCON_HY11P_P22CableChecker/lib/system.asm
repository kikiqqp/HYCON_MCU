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
    ;晶振起振
    MOVLF   00000001B, MCKCN1    ;啟用內部HAO(2MHZ)，起動外振
    MOVLF   00000011B, MCKCN2    ;CPU使用內部HAO(2MHZ)
    ;CLEAR
CLRRAM:
    LDPR    0FFH, FSR0
CLRRAM01_1: ;80H ~ FFH
    CLRF    PODEC0, HIGH POINC0
    MVL     07FH
    CPSE    FSR0L, HIGH FSR0L
    JMP     CLRRAM01_1
    ;PT1
    CLRF    PT1PU, HIGH PT1PU
    CLRF    PT1, HIGH PT1
    CLRF    TRISC1, HIGH TRISC1
    CLRF    PT1PU, HIGH PT1PU
    CLRF    PT1M1, HIGH PT1M1
    CLRF    PT1M2, HIGH PT1M2
    BSF     PT1PU, 0, HIGH PT1PU
    BSF     PT1, 0, HIGH PT1
    ;PT2
    CLRF    PT2PU, HIGH PT2PU
    CLRF    PT2, HIGH PT2
    SETF    TRISC2, HIGH TRISC2
    CLRF    PT2M1, HIGH PT2M1
    CLRF    PT2M2, HIGH PT2M2
    SETF    PT2, HIGH PT2
    CALL    DELAY250MS
    CALL    DELAY250MS
    CLRF    PT2, HIGH PT2
    CWDT
    