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
SYSLVD:
    MVL     00000001B
    MVF     LVDCN, F, HIGH LVDCN
    CALL    DELAY2MS
LVDSTABLE:
    CWDT
    BTSS    LVDCN, LVDON, HIGH LVDCN
    JMP     LVDSTABLE
    BCF     LVDCN , LVDFG, HIGH LVDCN
    BCF     LVDCN, LVD, HIGH LVDCN
    CALL    DELAY2MS
    
    MVL     0FFH 
LVDRT:
    CWDT
    DCSUZ   WREG, F, HIGH WREG
    JMP     MAIN 
    BTSZ    LVDCN, LVD, HIGH LVDCN
    JMP     LVDRT ;電源不正常不給啟動
    MVL     00001010B
    MVF     LVDCN, F, HIGH LVDCN
    BCF     LVDCN, LVD, HIGH LVDCN
    BCF     LVDCN, LVDFG, HIGH LVDCN
    CWDT
RET
;------------------------------------------------------------------------------
MLVD:
    MVL     0FH
    MVF     LVD_FLG, F, HIGH LVD_FLG
    BTSS    LVDCN, LVD, HIGH LVDCN
    JMP     LVDEND
    BTSS    LVDCN, LVDON, HIGH LVDCN
    JMP     LVDEND
MLVDCK:
    MVL     07H
    MVF     LVD_FLG, F, HIGH LVD_FLG
    MVL     00001000B
    MVF     LVDCN, F, HIGH LVDCN
    MVL     15
    CALL    DLOOP05
    CALL    CHKLVD
    BTSS    WREG, 0, HIGH   WREG
    JMP     LVDEND
    LVDCK2:
    MVL     03H
    MVF     LVD_FLG, F, HIGH LVD_FLG
    MVL     00000111B
    MVF     LVDCN, F, HIGH LVDCN
    MVL     15
    CALL    DLOOP05
    CALL    CHKLVD
    BTSS    WREG, 0, HIGH   WREG
    JMP     LVDEND
    LVDCK3:
    MVL     01H
    MVF     LVD_FLG, F, HIGH LVD_FLG
    BSF     SYS_FLAG, LOB, HIGH SYS_FLAG
LVDEND:
    BTSS    SYS_FLAG, LOB, HIGH SYS_FLAG
    BCF     LCDCN2, LCDBL, HIGH LCDCN2
    MVL     00001010B
    MVF     LVDCN, F, HIGH LVDCN
    MVFF    LVD_FLG , WREG
    BTSZ    PT2, 0, HIGH PT2
    MVL     00H
    BTSZ    SYS_FLAG, LOB, HIGH SYS_FLAG
    MVFF    LVD_FLG , WREG
    MVFF    WREG , LCD6
    MVL     15
    CALL    DLOOP05
RET
;------------------------------------------------------------------------------
CHKLVD:
    BTSS    LVDCN, LVD, HIGH LVDCN
    RETL    0
    BTSS    LVDCN, LVDON, HIGH LVDCN
    JMP     CHKLVD
    RETL    1
;------------------------------------------------------------------------------