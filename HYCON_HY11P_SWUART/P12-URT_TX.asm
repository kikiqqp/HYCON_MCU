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
;非同步1byte UART傳輸接收
;P12-URT_TX.obj 需要3個 RAM暫存、WREG，會改變C狀態，占用25行
;執行時間受鮑率限制，注意呼叫時不可發生中斷
;需要參數:
;   tx_count        暫存器1
;   tx_baudrate     暫存器2  
;   txreg_08B       暫存器3
;   tx_baudrate_set 鮑率
;   tx_port1        輸出暫存器(PT)
;   tx_port_bit     輸出的IO PORT
;   tx_bit          傳輸位元數
;------------------------------------------------------
; Pamers, Taiwan. by Hank Wei
; V0.000 初版
; V0.001 修改使其傳送完成後W返回0
; V0.002 取消一開始清除C的動作，少掉一行
;------------------------------------------------------
extern tx_count
extern tx_baudrate
extern txreg_08B
extern baudrate_set
extern tx_port1
extern tx_port_bit
extern status
extern tx_bit
global tx_send
;------------------------------------------------------
;UART TX
tx_send:
    mvf     txreg_08B, 1, high txreg_08B            ;wreg to txreg_08B
;   bcf     status, 4, high status                  ;clear C
    mvl     baudrate_set
    mvf     tx_baudrate, 1, high tx_baudrate
  tx_wait1:
    dcsz    tx_baudrate, 1, high tx_baudrate
    jmp     tx_wait1
    mvl     baudrate_set
    mvf     tx_baudrate, 1, high tx_baudrate
    bcf     tx_port1, tx_port_bit, high tx_port1             ;send start bit 0
    mvl     tx_bit+1
    mvf     tx_count, 1, high tx_count
  tx_wait2:
    dcsz    tx_baudrate, 1, high tx_baudrate
    jmp     tx_wait2
    mvl     baudrate_set
    mvf     tx_baudrate, 1, high tx_baudrate
    dcsz    tx_count, 1, high tx_count
    jmp     send_bit
    bsf     tx_port1, tx_port_bit, high tx_port1             ;send stop bit 1
    retl    0
    
  send_bit:
    rrfc    txreg_08B, 1, high txreg_08B
    btss    status, 4, high status                           ;check next bit to tx
    jmp     set_low
    bsf     tx_port1, tx_port_bit, high tx_port1             ;send a high bit
    jmp     tx_wait2
  set_low:
    bcf     tx_port1, tx_port_bit, high tx_port1             ;send a low bit
    jmp     tx_wait2
;------------------------------------------------------
