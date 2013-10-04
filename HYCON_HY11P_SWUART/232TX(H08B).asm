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
tx_count        equ             090H
tx_baudrate     equ             091H
txreg_08B       equ             092H

baudrate_set    equ             00FH ;(((cpu_clock/4)/bps)/3)-2 9600bps
;macro
;------------------------------------------------------
movlw   macro   k
    mvl     k
endm
;
movfw   macro   f1
    mvf     f1, w, high f1
endm
;
movwf   macro   f1
    mvf     f1, f, high f1
endm
;
movlf   macro   d1, f1
    movlw   d1
    movwf   f1
endm
;------------------------------------------------------
;main
org     000h
    nop
    jmp     start
    nop
org     004h
;------------------------------------------------------
start:
;cpu and clock
    movlf   00000001b, mckcn1   ;啟用內部hao(2mhz)
    movlf   00000011b, mckcn2   ;設置hs_ck為cpu_ck(2mhz)
;clear mem
    call    clearram
;lcd set
    movlf   00000000b, mckcn3   ;LCD clock pre-scaler 000:/1
                                ;LCD clock=LS_CK=LPO
    call    clearlcd            ;clear LCD register
    movlf   11011100b, lcdcn1   ;enable LCD function
                                ;enable LCD charge pump voltage, and set VLCD=3.05V level
                                ;LCDBI=10b, 1/3bias
    movlf   01100000b, lcdcn2   ;light SEG and COM
                                ;LCDMx=11b, 1/4duty
;io set
    clrf    pt1, high pt1
    clrf    pt1, high pt1
    clrf    pt1pu, high pt1pu
    clrf    pt1da, high pt1da
    clrf    pt1m1, high pt1m1
    clrf    pt1m2, high pt1m2
    clrf    pt2, high pt2
    clrf    trisc2, high trisc2
    clrf    pt2pu, high pt2pu   
    bsf     trisc1, bit4, high trisc1   ;set tx pin: tx:pt1.4, output TX stop bit
    bsf     pt1, bit4, high pt1
;delay

;------------------------------------------------------
main:
    mvl     030h        ;H
    call    tx_send
    jmp     main
;------------------------------------------------------
;UART TX   
tx_send:
    movwf   txreg_08B                           ;wreg to txreg_08B
    bcf     status, c, high status              ;clear C
    movlf   baudrate_set, tx_baudrate
  tx_wait1:
    dcsz    tx_baudrate, f, high tx_baudrate
    jmp     tx_wait1
    movlf   baudrate_set, tx_baudrate
    bcf     pt1, bit4, high pt1                 ;send start bit 0
    movlf   08H+1, tx_count
  tx_wait2:
    dcsz    tx_baudrate, f, high tx_baudrate
    jmp     tx_wait2
    movlf   baudrate_set, tx_baudrate
    dcsz    tx_count, f, high tx_count
    jmp     send_bit
    bsf     pt1, bit4, high pt1                 ;send stop bit 1
    ret
    
  send_bit:
    rrfc    txreg_08B, f, high txreg_08B
    btss    status, c, high status              ;check next bit to tx
    jmp     set_low
    bsf     pt1, bit4, high pt1                 ;send a high bit
    jmp     tx_wait2
  set_low:
    bcf     pt1, bit4, high pt1                 ;send a low bit
    jmp     tx_wait2
;------------------------------------------------------
clearram:
    movlf   080h, fsr0L ;clear ram 080h~0ffh
    mvl     0128
  mem_clr:
    clrf    indf0, high indf0
    inf     fsr0L, f, high fsr0L
    dcsz    wreg, f, high wreg
    jmp     mem_clr
ret
;------------------------------------------------------

clearlcd:
    movlf   lcd0, fsr0L    ;clear ram LCD0~LCD5
    mvl     lcd5
    jmp     mem_clr
;------------------------------------------------------  
include    h08.inc
end