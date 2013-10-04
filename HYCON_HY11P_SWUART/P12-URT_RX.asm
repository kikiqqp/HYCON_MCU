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
;P12-URT_RX.obj �ݭn3�� RAM�Ȧs�BWREG�A�|����C���A(����)�A�e��28��
;����ɶ����j�v����A�A�ϥΤ��_�i�J�`�N�I�s�ɤ��i�o�ͤ��_
;�ݭn�Ѽ�:
;   rx_count        �Ȧs��1
;   rx_baudrate     �Ȧs��2  
;   rxreg_08B       �Ȧs��3
;   rx_baudrate_set �j�v
;   rx_fix          START BIT�j�v�ץ�(�̤��_��{�����e���ץ�)
;   rx_port1        ��J�Ȧs��(PT)
;   rx_port_bit     ��J��IO PORT
;   rx_bit          �ǿ�줸��
;   rx_intf         IO PORT�ҨϥΪ��X�мȦs��
;   rx_inte         IO PORT�ҨϥΪ��X��
;------------------------------------------------------
; V0.000 �쪩
; V0.001 �ץ�OBJ���L�k�ϥνsĶ���w����k�p�⤧BUG�A�G�s�Wrx_fix�ѼơC�s�W9�줸�ˬd�X�A��^��W��(����)�C
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