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
movlw   macro   k
    mvl    k
endm
;-----------------------------------
movfw   macro   f1
    mvf f1, w, high f1
endm
;-----------------------------------
movwf   macro   f1
    mvf f1, f, high f1
endm
;-----------------------------------
movlf   macro   d1, f1
    movlw   d1
    movwf   f1
endm
;-----------------------------------
delay_3x    macro   n ;延時=1+3*(n-1)+2=3n指令週期,影響wreg
    movlw  n ;1
dloop:
    dcsz  wreg, f, high wreg ;3*(n-1)
    jmp   dloop ;2
endm
;-----------------------------------
bz_on    macro
    bsf    bz_porten, bz, high bz_porten ;蜂鳴器端口設為輸出
endm
;-----------------------------------
bz_off    macro
    bcf    bz_porten, bz, high bz_porten  ;蜂鳴器端口設為輸入
endm
