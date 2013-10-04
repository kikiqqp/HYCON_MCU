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
temp    equ     080h
temp1    equ     081h
temp2    equ     082h
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
    nop
    mvff    rcreg, temp1 ;收到的資料
    btsz    ursta, 5, high ursta  ;PERR檢查資料是否正確
    jmp     rx_fail
    reti
  rx_fail:
    clrf    temp1, high temp1
    nop
    reti
;------------------------------------------------------
start:
;cpu and clock
    movlf   00000001b, mckcn1   ;啟用內部hao(2mhz)
    movlf   00000011b, mckcn2   ;設置hs_ck為cpu_ck
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
    clrf    pt1pu, high pt1pu
    clrf    trisc1, high trisc1
    clrf    pt1da, high pt1da
    clrf    pt1m1, high pt1m1
    clrf    pt1m2, high pt1m2

    bsf     trisc1, bit4, high trisc1   ;set tx pin: tx:pt1.4, output
    bsf     pt1m2, bit0, high pt1m2     ;select tx function ooutput
;  	bcf		pt1pu, bit3, high pt1pu     ;set rc pin: rc:pt1.3, input
    bsf     pt1pu, bit0, high pt1pu
    bsf     pt1, bit0, high pt1pu
    
;    bsf     inte1, e0ie, high inte1

;EURT
;+-----+-------+------+------+------+------+------+------+------+------+
;| ADD | FName | Bit7 | Bit6 | Bit5 | Bit4 | Bit3 | Bit2 | Bit1 | Bit0 |
;+-----+-------+------+------+------+------+------+------+------+------+
;| 63H | URCON | ENSP | ENTX | TX9  | TX9D |PARITY|  --  |  --  |  --  |
;+-----+-------+------+------+------+------+------+------+------+------+
;| 64H | URSTA |  --  | RC9D | PERR | FERR | OERR | RCIDL| TRMT |ABDOVF|
;+-----+-------+------+------+------+------+------+------+------+------+
;| 65H |BAUDCON|  --  |  --  |  --  |  --  | ENCR |  RC9 | ENADD| ENABD|
;+-----+-------+------+------+------+------+------+------+------+------+
;| 66H | BRGRH |         --         |Baud Rate Generator Register High Byte|
;+-----+-------+--------------------+----------------------------------+
;| 67H | TXREG | UART Transmit Register                                |
;+-----+-------+-------------------------------------------------------+
;| 67H | RCREG | UART Receive Register                                 |
;+-----+-------+-------------------------------------------------------+
    bcf     intf2, txif, high intf2
;    clrf    brgrh, high brgrh ;9600bps(2MHz)
;    movlf   033h, brgrl
    clrf    brgrh, high brgrh ;19200bps(2MHz)
    movlf   019h, brgrl
;    clrf    brgrh, high brgrh ;19200bps(1MHz)
;    movlf   0Ch, brgrl
    movlf   0f0h, urcon         ;tx開啟, 傳送同位檢查碼
    movlf   008h, baudcon       ;rx開啟, 關閉同位檢查碼

    bcf     intf2, rcif, high intf2   
    bsf     inte1, gie, high intf2
    bsf     inte2, rcie, high intf2

    call    clearlcd
u_data_mess:
    mvl     04fh        ;O
    call    euart_data
    mvl     04bh        ;K
    call    euart_data
    mvl     0dh
    call    euart_data
    mvl     0ah
    call    euart_data
    
u_data1:
    mvff    temp1, wreg
    swpf    wreg, f, high wreg
    call    lcd_CODE
    mvff    wreg, lcd2
    mvff    temp1, wreg
    call    lcd_CODE
    mvff    wreg, lcd3
    nop
    nop
    idle    ;<----- idle
    nop
    nop
    jmp     u_data1
    nop

;------------------------------------------------------  
;library
euart_data:
    mvf     txreg, f, high txreg            ;txreg    ;uart transmit register
  trmtck:
    btsz    ursta, trmt, high ursta        ;transmit on going
    jmp     trmtck
  trmtok:      
    btss    ursta, trmt, high ursta        ;check transmit ok    
    jmp     trmtok
    bcf     intf2, txif, high intf2
ret
;------------------------------------------------------
clearram:
    ldpr    080h, fsr0            ;clear ram 080h~0ffh
  clearram_1:    
    clrf    poinc0, high poinc0
    tfsz    fsr0l, high fsr0l
    jmp     clearram_1
    nop    
ret

clearlcd:
    ldpr    lcd0,fsr0
  lcdcr1:  
    clrf    poinc0, high poinc0
    mvl     lcd9
    cpse    fsr0l, high fsr0l
    jmp     lcdcr1
ret 
;------------------------------------------------------
d01ms:            ; cpu_ck= 2mhz
    mvl     060h
    jmp     dly_00
  dly_00:
    nop
    nop
    dcsz    wreg, f, high wreg
    jmp     dly_00
ret
;------------------------------------------------------
;ASCII
LCDNUM0     EQU     01111101B
LCDNUM1     EQU     01100000B
LCDNUM2     EQU     00111110B
LCDNUM3     EQU     01111010B
LCDNUM4     EQU     01100011B
LCDNUM5     EQU     01011011B
LCDNUM6     EQU     01011111B
LCDNUM7     EQU     01110001B
LCDNUM8     EQU     01111111B
LCDNUM9     EQU     01111011B
LCDNUMA     EQU     01110111B
LCDNUMB     EQU     01001111B
LCDNUMC     EQU     00011101B
LCDNUMD     EQU     01101110B
LCDNUME     EQU     00011111B
LCDNUMF     EQU     00010111B

LCD_CODE:
    andl       0fh                    ;傳入限制
    mvf        tbldl, f, high tbldl   ;暫存參數    
    
    mvlp       LCD_TABLE
    
    bcf        status, c, high status
    rrfc       tbldl, w, high tbldl   ;存儲以word為單元，傳入參數需除以2
    addf       tblptrl, f, high tblptrl
    btsz       status, c, high status
    inf        tblptrh, f, high tblptrh
    rrfc       tbldl, f, high tbldl   ;參數最低位放入status,c
    tblr       *
    mvf           tbldl, w, high tbldl  ;奇數在低字節
    btss       status, c, high status
    mvf           tbldh, w, high tbldh  ;偶數在高字節
RET


LCD_TABLE:
    DB        LCDNUM0,LCDNUM1      
    DB        LCDNUM2,LCDNUM3      
    DB        LCDNUM4,LCDNUM5      
    DB        LCDNUM6,LCDNUM7      
    DB        LCDNUM8,LCDNUM9      
    DB        LCDNUMA,LCDNUMB      
    DB        LCDNUMC,LCDNUMD      
    DB        LCDNUME,LCDNUMF 
;------------------------------------------------------
include    h08.inc
end    