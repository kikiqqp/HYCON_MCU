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
; HY11P PS/2 纜線檢查程式
Include  inc\H08.INC
Include  inc\def_mem.inc
Include  inc\macro.asm

org     000H
    jmp     system
org     004H
; 中斷向量點


; 主程式點
system:
    Include  lib\system.asm
    bsf     PT2, 0, HIGH PT2
main:
    call    DELAY50MS
    call    DELAY50MS
    call    DELAY50MS
    btsz    pt1, 0, high pt1
    CALL    DELAY_KEY
    RLF     PT2, F, HIGH PT2
    jmp     main

DELAY_KEY:
    CALL    DELAY250MS
    CALL    DELAY250MS
RET

Include  lib\delay.asm
