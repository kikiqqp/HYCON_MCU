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
;------------------------------------------------------
; V0.000 初版
; V0.001 修正OBJ中無法使用編譯器預先減法計算之BUG，故新增rx_fix參數。新增9位元檢查碼，返回為W值(未完)。
;------------------------------------------------------
extern rx_baudrate_set 
extern rx_count        
extern rx_baudrate     
extern rxreg_08B       
extern rx_fix          
extern rx_port         
extern rx_port_bit     
extern rx_bit          
extern rx_intf         
extern rx_inte         
global rx_read
;------------------------------------------------------
rx_read:
;UART RX
    btss    rx_intf, rx_inte, high rx_intf         ;2us
    ret
    NOP                                            ;2us
    bcf     rx_intf, rx_inte, high rx_intf         ;2us
    clrf    rxreg_08B, high rxreg_08B              ;2us
    mvl     rx_fix
    mvf     rx_baudrate, 1, high rx_baudrate
  rx_wait1:
    dcsz    rx_baudrate, 1, high rx_baudrate
    jmp     rx_wait1
    
    mvl     rx_bit
    mvf     rx_count, 1, high rx_count
  rx_wait_LOOP:
    btsz    rx_port, rx_port_bit, high rx_port
    bsf     rxreg_08B, 7, high rxreg_08B
    rrf     rxreg_08B, 1, high rxreg_08B
    mvl     rx_baudrate_set
    mvf     rx_baudrate, 1, high rx_baudrate
  rx_wait2:
    dcsz    rx_baudrate, 1, high rx_baudrate
    jmp     rx_wait2
    dcsz    rx_count, 1, high rx_count
    jmp     rx_wait_LOOP
  rx_wait3:
    mvl     rx_baudrate_set
    mvf     rx_baudrate, 1, high rx_baudrate
  rx_wait4:
    dcsz    rx_baudrate, 1, high rx_baudrate
    jmp     rx_wait4
    bcf     rx_intf, rx_inte, high rx_intf
    btss    rx_port, rx_port_bit, high rx_port
;   jmp     rx_wait3
    retl    1
;   NOP
    retl    0
;------------------------------------------------------