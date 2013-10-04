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
; ���ﾹ�B�z
; �n���Ǧ����TimerA 4ms
;-----------------------------------
;PT1M2: 6-��X�Ҧ���� 1=pt1.7 bZ
;MCKCN3:[2:0]-BZS[2:0]BZ�W�v�]�m
;    111=PER_CK/128 110=PER_CK/64...000=PER_CK
;    �@��PER_CK=32K ��X2K�]100    
buzz_servie:
    btss    sys_flag, buzz, high sys_flag
    jmp     buzz_servie_end
    inf     buzz_cnt, f, high buzz_cnt
    movfw   buzz_time
    cpsg    buzz_cnt, high buzz_cnt
    jmp     buzz_servie_end
    clrf    buzz_cnt, high buzz_cnt
    btgf    PT1M2, 6, high PT1M2
    BCF     PT1, 7, high PT1
    dcsz    buzz_times, f, high buzz_times
    jmp     buzz_servie_end
    bcf     sys_flag, buzz, high sys_flag
    BCF     PT1M2, 6, high PT1M2
    jmp     buzz_servie_end

;buzz_time  = �ɶ� / 4
;buzz_times = 2 x (�s�n����) - 1
buzz_vshort:
    movlf   13, buzz_time
    movlf   1, buzz_times
    jmp     buzz_com
buzz_short:  ;250ms
    movlf   63, buzz_time
    movlf   1, buzz_times
    jmp     buzz_com
buzz_long:   ;500ms
    movlf   125, buzz_time
    movlf   1, buzz_times    
    jmp     buzz_com
buzz_vshort4: ;9ms�s�|�n
    movlf   18, buzz_time
    movlf   7, buzz_times
    jmp     buzz_com
buzz_short3: ;250ms�s�T�n
    movlf   63, buzz_time
    movlf   5, buzz_times
buzz_com:
    bsf     sys_flag, buzz, high sys_flag
    clrf    buzz_cnt
    bsf     PT1M2, 6, high PT1M2
    ret

buzz_servie_end:
  