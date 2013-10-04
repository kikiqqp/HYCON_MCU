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
TEMP    EQU     080H
TEMP1    EQU     081H
TEMP2    EQU     082H

AUT1    EQU     083H
;MACRO
;------------------------------------------------------
MOVLW   MACRO   K
    MVL     K
ENDM
;
MOVFW   MACRO   F1
    MVF     F1, W, HIGH F1
ENDM
;
MOVWF   MACRO   F1
    MVF     F1, F, HIGH F1
ENDM
;
MOVLF   MACRO   D1, F1
    MOVLW   D1
    MOVWF   F1
ENDM
;------------------------------------------------------
;MAIN
ORG     000H
    NOP
    JMP     START
    NOP
ORG     004H
;------------------------------------------------------
    NOP

    BTSS    AUT1, 0, HIGH AUT1
    RET
    
    BTSZ    URSTA, 5, HIGH URSTA  ;PERR檢查資料是否正確
    JMP     RX_FAIL
    MVFF    RCREG, TEMP1 ;收到的資料
  RX_FAIL:
    NOP
    RETI
;------------------------------------------------------
START:
;CPU AND CLOCK
    MOVLF   00000001B, MCKCN1   ;啟用內部HAO(2MHZ)
    MOVLF   00000011B, MCKCN2   ;設置HS_CK為CPU_CK
;CLEAR MEM
    CALL    CLEARRAM
;IO SET
    CLRF    PT1, HIGH PT1
    CLRF    PT1PU, HIGH PT1PU
    CLRF    TRISC1, HIGH TRISC1
    CLRF    PT1DA, HIGH PT1DA
    CLRF    PT1M1, HIGH PT1M1
    CLRF    PT1M2, HIGH PT1M2

    BSF     TRISC1, BIT4, HIGH TRISC1   ;SET TX PIN: TX:PT1.4, OUTPUT
    BSF     PT1M2, BIT0, HIGH PT1M2     ;SELECT TX FUNCTION OOUTPUT
;      BCF        PT1PU, BIT3, HIGH PT1PU     ;SET RC PIN: RC:PT1.3, INPUT
    BSF     PT1PU, BIT0, HIGH PT1PU
    BSF     PT1, BIT0, HIGH PT1PU
    
;    BSF     INTE1, E0IE, HIGH INTE1

;EURT
;+-----+-------+------+------+------+------+------+------+------+------+
;| ADD | FNAME | BIT7 | BIT6 | BIT5 | BIT4 | BIT3 | BIT2 | BIT1 | BIT0 |
;+-----+-------+------+------+------+------+------+------+------+------+
;| 63H | URCON | ENSP | ENTX | TX9  | TX9D |PARITY|  --  |  --  |  --  |
;+-----+-------+------+------+------+------+------+------+------+------+
;| 64H | URSTA |  --  | RC9D | PERR | FERR | OERR | RCIDL| TRMT |ABDOVF|
;+-----+-------+------+------+------+------+------+------+------+------+
;| 65H |BAUDCON|  --  |  --  |  --  |  --  | ENCR |  RC9 | ENADD| ENABD|
;+-----+-------+------+------+------+------+------+------+------+------+
;| 66H | BRGRH |         --         |BAUD RATE GENERATOR REGISTER HIGH BYTE|
;+-----+-------+--------------------+----------------------------------+
;| 67H | TXREG | UART TRANSMIT REGISTER                                |
;+-----+-------+-------------------------------------------------------+
;| 67H | RCREG | UART RECEIVE REGISTER                                 |
;+-----+-------+-------------------------------------------------------+
    BCF     INTF2, TXIF, HIGH INTF2
; 手動計算
;    CLRF    BRGRH, HIGH BRGRH ;9600BPS(2MHZ)
;    MOVLF   033H, BRGRL
;    CLRF    BRGRH, HIGH BRGRH ;19200BPS(2MHZ)
;    MOVLF   019H, BRGRL
;    CLRF    BRGRH, HIGH BRGRH ;19200BPS(1MHZ)
;    MOVLF   0CH, BRGRL
    MOVLF   0F0H, URCON         ;TX開啟, 傳送同位檢查碼
    MOVLF   008H, BAUDCON       ;RX開啟, 關閉同位檢查碼
    
; 自動計算
AUTO_BRG:
    BCF     URSTA, ABDOVF, HIGH URSTA
    CLRF    AUT1, HIGH AUT1

    BCF     INTF2, RCIF, HIGH INTF2   
    BSF     INTE1, GIE, HIGH INTF2
    BSF     INTE2, RCIE, HIGH INTF2
AUTO_BRG2:
    CLRF    BRGRH, HIGH BRGRH
    CLRF    BRGRL, HIGH BRGRL
    BSF     BAUDCON, ENABD, HIGH BAUDCON
    NOP
    IDLE    ;<----- IDLE
    NOP 
    BCF     INTF2, RCIF, HIGH INTF2   
    BTSZ    URSTA, ABDOVF, HIGH URSTA        ;CHECK IF NO BRG ROLLOVER OCCURRED
    JMP     AUTO_BRG2
    BTSZ    BAUDCON,ENABD,HIGH BAUDCON   ;CHECK AUTO BAUDRATE OCCURRED? (WAIT FOR MASTER SEND 055H)
    JMP     AUTO_BRG2
    BTSS    INTF2,RCIF,A        ;CHECK RECEIVE
    JMP     AUTO_BRG2               
    MVF     RCREG, W, A            ;CLEAR RCIF FLAG
    BTSZ    INTF2, RCIF, A
    JMP     AUTO_BRG2
    MVL     01
    CPSG    BRGRL, HIGH BRGRL
    JMP     AUTO_BRG2
    BSF     AUT1, 0, HIGH AUT1
    BSF     INTE1, GIE, HIGH INTF2
U_DATA_MESS:
;    MVFF    TEMP, WREG
;    CALL    EUART_DATA
    MVL     048H        ;H
    CALL    EUART_DATA
    MVL     059H        ;Y
    CALL    EUART_DATA
    MVL     043H        ;C
    CALL    EUART_DATA
    MVL     04FH        ;O
    CALL    EUART_DATA
    MVL     04EH        ;N
    CALL    EUART_DATA
    MVL     020H        ;
    CALL    EUART_DATA
    MVL     045H        ;E
    CALL    EUART_DATA
    MVL     055H        ;U
    CALL    EUART_DATA
    MVL     041H        ;A
    CALL    EUART_DATA
    MVL     052H        ;R
    CALL    EUART_DATA
    MVL     054H        ;T
    CALL    EUART_DATA
    MVL     02EH        ;.
    CALL    EUART_DATA
    MVL     02EH        ;.
    CALL    EUART_DATA
    MVL     02EH        ;.
    CALL    EUART_DATA
    MVL     04FH        ;O
    CALL    EUART_DATA
    MVL     04BH        ;K
    CALL    EUART_DATA
    MVL     0DH
    CALL    EUART_DATA
    MVL     0AH
    CALL    EUART_DATA
    MVL     05DH        ;]
    CALL    EUART_DATA
    MVL     020H        ; 
    CALL    EUART_DATA
    
U_DATA1:
    NOP
    NOP
    IDLE    ;<----- IDLE
    NOP

    
    MVL     0DH
    CPSE    TEMP1, HIGH TEMP1
    JMP     KEY_CHK
    
    TFSZ    TEMP2, HIGH TEMP2
    JMP     KEY_CHK2
    
    MVL     0DH
    CALL    EUART_DATA
    MVL     0AH
    CALL    EUART_DATA
    MVL     0DH
    CALL    EUART_DATA
    MVL     0AH
    CALL    EUART_DATA
    JMP     U_DATA_MESS
KEY_CHK:
    MVFF    TEMP1, WREG
    MVFF    TEMP1, TEMP2
    CALL    EUART_DATA
    JMP     U_DATA1
KEY_CHK2:

    MVL     056H ;當輸入V時
    CPSE    TEMP2, HIGH TEMP2
    JMP     KEY_CHK3
    CALL    BK_MESS
    CLRF    TEMP2, HIGH TEMP2
    JMP     U_DATA1    
KEY_CHK3:
    MVL     0DH
    CALL    EUART_DATA
    MVL     0AH
    CALL    EUART_DATA
    MVL     020H        ; 
    CALL    EUART_DATA
    MVL     03FH        ;?
    CALL    EUART_DATA
    MVL     0DH
    CALL    EUART_DATA
    MVL     0AH
    CALL    EUART_DATA
    MVL     05DH        ;]
    CALL    EUART_DATA
    MVL     020H        ; 
    CALL    EUART_DATA
    CLRF    TEMP2, HIGH TEMP2
    JMP     U_DATA1
    
    
BK_MESS:
    MVL     0DH
    CALL    EUART_DATA
    MVL     0AH
    CALL    EUART_DATA
    MVL     020H        ; 
    CALL    EUART_DATA
    MVL     052H        ;R
    CALL    EUART_DATA
    MVL     053H        ;S
    CALL    EUART_DATA
    MVL     02DH        ;-
    CALL    EUART_DATA
    MVL     030H        ;0
    CALL    EUART_DATA
    MVL     02EH        ;.
    CALL    EUART_DATA
    MVL     030H        ;0
    CALL    EUART_DATA
    MVL     031H        ;1
    CALL    EUART_DATA
    MVL     020H        ; 
    CALL    EUART_DATA
    MVL     042H        ; B
    CALL    EUART_DATA
    MVL     079H        ; Y
    CALL    EUART_DATA
    MVL     020H        ; 
    CALL    EUART_DATA
    MVL     050H        ; P
    CALL    EUART_DATA
    MVL     061H        ; A
    CALL    EUART_DATA
    MVL     06DH        ; M
    CALL    EUART_DATA
    MVL     065H        ; E
    CALL    EUART_DATA
    MVL     072H        ; R
    CALL    EUART_DATA
    MVL     073H        ; S
    CALL    EUART_DATA
    MVL     02EH        ; .
    CALL    EUART_DATA
    MVL     0DH
    CALL    EUART_DATA
    MVL     0AH
    CALL    EUART_DATA
    MVL     0DH
    CALL    EUART_DATA
    MVL     0AH
    CALL    EUART_DATA
    MVL     05DH        ;]
    CALL    EUART_DATA
    MVL     020H        ;
    CALL    EUART_DATA
RET    
;------------------------------------------------------  
;LIBRARY
EUART_DATA:
    MVF     TXREG, F, HIGH TXREG            ;TXREG    ;UART TRANSMIT REGISTER
  TRMTCK:
    BTSZ    URSTA, TRMT, HIGH URSTA        ;TRANSMIT ON GOING
    JMP     TRMTCK
  TRMTOK:      
    BTSS    URSTA, TRMT, HIGH URSTA        ;CHECK TRANSMIT OK    
    JMP     TRMTOK
    BCF     INTF2, TXIF, HIGH INTF2
RET
;------------------------------------------------------
CLEARRAM:
    LDPR    080H, FSR0            ;CLEAR RAM 080H~0FFH
  CLEARRAM_1:    
    CLRF    POINC0, HIGH POINC0
    TFSZ    FSR0L, HIGH FSR0L
    JMP     CLEARRAM_1
    NOP    
RET
;------------------------------------------------------
D01MS:            ; CPU_CK= 2MHZ
    MVL     060H
    JMP     DLY_00
  DLY_00:
    NOP
    NOP
    DCSZ    WREG, F, HIGH WREG
    JMP     DLY_00
RET
;------------------------------------------------------
INCLUDE    H08.INC
END    