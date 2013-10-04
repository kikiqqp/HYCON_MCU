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
;------------------------------------------------------------------------------
INCLUDE INC\MACRO.ASM
;------------------------------------------------------------------------------
ORG     000H
    JMP     SYSTEMSET
ORG     004H

;------------------------------------------------------------------------------
    NOP
    BSF     SYS_FLAG, TIME4MS, HIGH SYS_FLAG
    INF     0FFH, F, ACCE
    INF     0FEH, F, ACCE
    CLRF    INTF1, HIGH INTF1
    RETI

;------------------------------------------------------------------------------
SYSTEMSET:
    ; Page切換
    BSF     BSRCN, 0, HIGH BSRCN ;ACCE = 0 = 0x000H ~ 0x0FFH, 1 = 0x100H ~ 0x1FFH
    ; CLOCK
    MVL     00000001B    ;啟用內部HAO(2MHZ)
    MVF     MCKCN1, F, HIGH MCKCN1

    ;CLEAR
    CLRRAM:
    LDPR    0FFH, FSR0
    CLRRAM01_1: ;80H ~ FFH
    CLRF    PODEC0, HIGH POINC0
    MVL     07FH
    CPSE    FSR0L, HIGH FSR0L
    JMP     CLRRAM01_1    
    
    ; PT1
    SETF    PT1PU, HIGH PT1PU
    CLRF    TRISC1, HIGH TRISC1
    BSF     TRISC1, 7, HIGH TRISC1
    CLRF    PT1, HIGH PT1
    
    ; PT2
    SETF    PT2PU, HIGH PT2PU
    CLRF    TRISC2, HIGH TRISC2
    CLRF    PT2, HIGH PT2
    
    ; POWER SYSTEM
    MVL     10000000B ;3.3V
    MVF     PWRCN, F, HIGH PWRCN ; 電源系統穩定，CAP充電時間延遲
    CALL    DELAY250MS
    CWDT
    
    ; Bz & LCD Clock
    MVL     00000100B
    MVF     MCKCN3, F, HIGH MCKCN3  ;MCKCN3[2:0]=100 頻率2K
    BCF     BZ_PORTPU, BZ, HIGH BZ_PORTPU ;上拉電阻關
    BCF     BZ_PORT, BZ, HIGH BZ_PORT ;輸出0
    BCF     PT1M2, 6, HIGH PT1M2 ;設為BZ模式
    
    ; LCD
    CLRF    LCD0, HIGH LCD0
    CLRF    LCD1, HIGH LCD1
    CLRF    LCD2, HIGH LCD2
    CLRF    LCD3, HIGH LCD3
    CLRF    LCD4, HIGH LCD4
    CLRF    LCD5, HIGH LCD5
    CLRF    LCD6, HIGH LCD6
    CLRF    LCD7, HIGH LCD7
    CLRF    LCD8, HIGH LCD8
    CLRF    LCD9, HIGH LCD9 
    MVL     11011100B
    MVF     LCDCN1, F, HIGH LCDCN1
    MVL     01100000B
    MVF     LCDCN2, F, HIGH LCDCN2
 
    ; 檢查供電系統
    CALL    SYSLVD
    
    ; TIME_A 4MS
    MVL     00000100B
    MVF     MCKCN3, F, HIGH MCKCN3
    MVL     11000000B
    MVF     TMACN, F, HIGH TMACN
    
    ; GIE
    CLRF    INTF1, HIGH INTF1
    MVL     10001000B
    MVF     INTE1, F, HIGH INTE1
;------------------------------------------------------------------------------
MAIN:
    BTSS    SYS_FLAG, TIME4MS, HIGH SYS_FLAG
    JMP     MAIN2
    INCLUDE LIB\BUZZER.ASM
    BCF     SYS_FLAG, TIME4MS, HIGH SYS_FLAG
    MAIN2:
    CALL    MLVD
    BTSS    PT1, 0, HIGH PT1
    CALL    buzz_vshort
    
    MVL     60
    CPSE    0FEH, ACCE
    JMP     MAIN3    
    BTSS    SYS_FLAG, LOB, HIGH SYS_FLAG
    JMP     MAIN
    BTGF    LCDCN2, LCDBL, HIGH LCDCN2
    CLRF    0FEH, ACCE
    MAIN3:
    MVL     250
    CPSE    0FFH, ACCE
    JMP     MAIN
    BTSS    SYS_FLAG, LOB, HIGH SYS_FLAG
    JMP     MAIN
    CALL    buzz_vshort4
    CLRF    0FFH, ACCE
    BCF     SYS_FLAG, LOB, HIGH SYS_FLAG
    JMP     MAIN
;------------------------------------------------------------------------------
INCLUDE     INC\H08.INC
INCLUDE     INC\DEF_MEM.INC
INCLUDE     LIB\DELAY.ASM
INCLUDE     LIB\BLVD.ASM

END