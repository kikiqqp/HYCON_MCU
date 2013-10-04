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
    call rx_read
    nop
    reti

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
    clrf    trisc1, high trisc1
    clrf    pt1pu, high pt1pu
;    clrf    pt1da, high pt1da
    clrf    pt1m1, high pt1m1
    clrf    pt1m2, high pt1m2
    clrf    pt2, high pt2
    clrf    trisc2, high trisc2
    clrf    pt2pu, high pt2pu   
    bsf     trisc1, bit4, high trisc1   ;set tx pin: tx:pt1.4, output TX stop bit
    bsf     pt1, bit4, high pt1
    bsf     inte1, gie, high gie
    bsf     inte1, e1ie, high gie
;delay

;------------------------------------------------------
main:
    mvl     048h        ;H
    call    send_data
    mvl     059h        ;Y
    call    send_data
    mvl     043h        ;C
    call    send_data
    mvl     04fh        ;O
    call    send_data
    mvl     04eh        ;N
    call    send_data
    mvl     020h        ;
    call    send_data
    mvl     045h        ;E
    call    send_data
    mvl     055h        ;U
    call    send_data
    mvl     052h        ;R
    call    send_data
    mvl     054h        ;T
    call    send_data
    mvl     02eh        ;.
    call    send_data
    mvl     02eh        ;.
    call    send_data
    mvl     02eh        ;.
    call    send_data
    mvl     04fh        ;O
    call    send_data
    mvl     04bh        ;K
    call    send_data
    mvl     0dh
    call    send_data
    mvl     0ah
    call    send_data
    ;NOP
    mvl     1
    mvf     wreg, f, high wreg
main2:
    ;NOP
    tfsz    wreg, high wreg
    jmp     main2
    mvf     rxreg_08B, w, high rxreg_08B
    call    send_data
    mvl     020h
    call    send_data
    mvl     02eh        ;.
    call    send_data
    mvl     02eh        ;.
    call    send_data
    mvl     02eh        ;.
    call    send_data
    mvl     04fh        ;O
    call    send_data
    mvl     04bh        ;K
    call    send_data
    mvl     0dh
    call    send_data
    mvl     0ah
    call    send_data
    ;NOP
    mvl     1
    mvf     wreg, f, high wreg
    jmp     main2
;------------------------------------------------------
send_data:
    bcf     inte1, gie, high gie
    call    tx_send
    bsf     inte1, gie, high gie
ret
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
;------------------------------------------------------
;非同步1byte UART傳輸接收
;P12-URT_TX.obj 需要3個 RAM暫存、WREG，會改變C狀態，占用26行
;執行時間受鮑率限制，注意呼叫時不可發生中斷
;需要參數:
;   tx_count        暫存器1
;   tx_baudrate     暫存器2  
;   txreg_08B       暫存器3
;   tx_baudrate_set 鮑率
;   tx_port1        輸出暫存器(PT)
;   tx_port_bit     輸出的IO PORT
;   tx_bit          傳輸位元數
baudrate_set    equ             00FH ;(((cpu_clock/4)/bps)/3)-2 9600bps
tx_count        equ             090H
tx_baudrate     equ             091H
txreg_08B       equ             092H
tx_port1        equ             PT1
tx_port_bit     equ             4
tx_bit          equ             8
ENDIF
include    P12-URT_TX.obj
;------------------------------------------------------
;P12-URT_RX.obj 需要3個 RAM暫存、WREG，會改變C狀態(極少)，占用28行
;執行時間受鮑率限制，，使用中斷進入注意呼叫時不可發生中斷
;需要參數:
;   rx_count        暫存器1
;   rx_baudrate     暫存器2  
;   rxreg_08B       暫存器3
;   rx_baudrate_set 鮑率
;   rx_fix          START BIT鮑率修正(依中斷後程式內容做修正)
;   rx_port1        輸入暫存器(PT)
;   rx_port_bit     輸入的IO PORT
;   rx_bit          傳輸位元數
;   rx_intf         IO PORT所使用的旗標暫存器
;   rx_inte         IO PORT所使用的旗標 
rx_baudrate_set equ             baudrate_set
rx_count        equ             tx_count
rx_baudrate     equ             tx_baudrate
rxreg_08B       equ             txreg_08B
rx_fix          equ             baudrate_set-8
rx_port         equ             PT1
rx_port_bit     equ             1               ;使用PT1.1
rx_bit          equ             8
rx_intf         equ             intf1
rx_inte         equ             e1if
include    P12-URT_RX.obj
;------------------------------------------------------
end