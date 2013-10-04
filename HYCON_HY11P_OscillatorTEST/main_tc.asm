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
;PAMERS Hank Wei (hank_wei@pamers.com.tw)
;BIG-5
;掛4MHZ震盪器(並聯電阻1MΩ)實際測得起振時間，為VDD=2.2V下測試結果
;VDD=2.2V ~ 4MHZ震盪器起振時間約27.1mS
;VDD=3.6V ~ 4MHZ震盪器起振時間約22.5mS
;------------------------------------------
;
;編譯器虛指令指令設定，設定晶振及時脈
Define	HAO_2MHz		=	0
Define	XTS_4MHz		=	1
Define	XTL_32768Hz		=	0

Define	CPUCK_1MHz		=	1
Define	CPUCK_2MHz		=	0
Define	CPUCK_4MHz		=	0
Define	CPUCK_32768Hz	=	0
Define	CPUCK_16384Hz	=	0
;==========================================================================

TEMP	EQU	80H
TEMP1	EQU	81H
TEMP3	EQU	82H
;--------------------------------------------------------------------------

	ORG 00H

			JMP	CHIPSTART
	
	ORG 04H
;--------------------------------------------------------------------------

	CHIPSTART:
			MVL	00000001B		;啟用內部HAO(2MHZ)
			MVF	MCKCN1, F, ACCE
;==========================================================================		

IF	HAO_2MHZ = 1					;設定內部2MHZ晶振起振
			CALL	2MHZ_CPUSET
ENDIF
;==========================================================================

IF	XTS_4MHZ	=	1			;設定外部4MHZ晶振起振
			CLRF	TRISC2, ACCE
			CLRF	PT2PU, ACCE
			MVL	00000111B
			MVF	MCKCN1, F, ACCE
			MVL	00000011B
			MVF	TEMP3, F, ACCE
	DELAY30:
			CALL	DELAY10MS
			DCSZ	TEMP3, F, ACCE
			JMP	DELAY30
			CALL	4MHZ_CPUSET
			NOP
ENDIF
;==========================================================================

IF	XTL_32768HZ = 1					;設定外部32768HZ晶振起振
			CLRF	TRISC2, ACCE
			CLRF	PT2PU, ACCE
			MVL	00000011B
			MVF	MCKCN1, F, ACCE
			MVL	00000110B
			MVF	TEMP3, F, ACCE
	DELAY60:
			CALL	DELAY10MS
			DCSZ	TEMP3, F, ACCE
			JMP	DELAY60
			CALL	32768HZ_CPUSET
			NOP
ENDIF
;==========================================================================

			CLRF	LVDCN, ACCE		;關閉電源偵測功能
;			LDPR	080H, FSR0		;抹除80H-FFH的寄存器
;			MVL     080H
;	CLEARM:   
;			CLRF	POINC0, ACCE
;			DCSZ	WREG, F, ACCE
;			JMP	CLEARM
	OFF_BLOCK:
			CLRF	PWRCN, ACCE
			CLRF	LCDCN1, ACCE
			CLRF	TMACN, ACCE
			CLRF	TMBCN, ACCE
			CLRF	TMCCN, ACCE
			CLRF	ADCCN1, ACCE
			CLRF	ADCCN2, ACCE
			CLRF	ADCCN3, ACCE
			CLRF	AINET1, ACCE
			CLRF	AINET2, ACCE
			CLRF	PWMCN, ACCE
			NOP
			NOP
			SETF	TRISC1, ACCE
			SETF	PT1PU, ACCE
			SETF	PT1, ACCE
			CLRF	PT1M1, ACCE
;===========================

IF	HAO_2MHZ = 1   
			SETF	TRISC2, ACCE
			CLRF	PT2PU, ACCE
ENDIF
;===========================

			CLRF	PT2PU, ACCE
			CLRF	PT2, ACCE
			CLRF	PT2M1, ACCE
			CLRF	PT2M2, ACCE

			CLRF    TRISC3, ACCE
			SETF	PT3PU, ACCE
			SETF	PT3, ACCE

			SETF	PT4DA, ACCE
			CLRF	PT4, ACCE
			CLRF	PT4PU, ACCE
	LOOP_MODE:
			CALL	DELAY10MS
			NOP
			NOP
			JMP	LOOP_MODE
			NOP
			NOP
			NOP
;==========================================================================

	2MHZ_CPUSET:
IF	CPUCK_2MHZ	=	1 
			MVL     00000011B
			MVF     MCKCN2, F, ACCE   	;設置HS_CK為CPU_CK
ENDIF

IF	CPUCK_1MHZ	=	1 
			MVL     00000100B
			MVF     MCKCN2, F, ACCE   	;設置HSS_CK為CPU_CK
ENDIF
	RET

;==========================================================================

	4MHZ_CPUSET:
IF	CPUCK_4MHZ	=	1
			MVL	00010011B
			MVF	MCKCN2, F, ACCE		;將晶片頻率源切換到外部4MHZ, OSC_CY
							;CPU_CK設定為4MHZ HS_CK
							;INTR_CK則為4M/4=1MHZ
							;參閱說明第三章
			MVL	00100110B
			MVF	MCKCN1, F, ACCE		;關閉內部2MHZ震盪器
							;設定ADCS=001B, ADC_CK=4M/2/2/4=250KHZ
ENDIF

IF	CPUCK_2MHZ	=	1
			MVL	00010100B
			MVF	MCKCN2, F, ACCE		;將晶片頻率源切換到外部4MHZ, OSC_CY
							;CPU_CK設定為2MHZ HSS_CK
							;INTR_CK則為2M/4=500KHZ
			MVL	00000110B
			MVF	MCKCN1, F, ACCE		;關閉內部2MHZ震盪器
							;設定ADCS=000B, ADC_CK=2M/2/4=250KHZ
ENDIF

IF	CPUCK_1MHZ	=	1
			MVL	00010101B
			MVF	MCKCN2, F, ACCE		;將晶片頻率源切換到外部4MHZ, OSC_CY
							;CPU_CK設定為1MHZ HS_DCK
							;INTR_CK則為1M/4=250KHZ
			MVL	00000110B
			MVF	MCKCN1, F, ACCE		;關閉內部2MHZ震盪器
							;設定ADCS=000B, ADC_CK=1M/4=250KHZ
ENDIF
	RET
;==========================================================================

	32768HZ_CPUSET:
IF	CPUCK_32768HZ	=	1
			MVL	00110010B
			MVF	MCKCN2, F, ACCE		;將晶片頻率源切換到LS_CK 32768HZ
							;CPU_CK設定為32768HZ
							;INTR_CK則為32768/4=8192HZ
			MVL	00010010B
			MVF	MCKCN1, F, ACCE		;關閉內部2MHZ震盪器
							;ADC LS_CK
ENDIF

IF	CPUCK_16384HZ	=	1
			MVL	00110100B
			MVF	MCKCN2, F, ACCE		;將晶片頻率源切換到LS_CK 32768HZ
							;CPU_CK設定為32768/2=16384
							;INTR_CK則為16384/4=4096HZ
			MVL	00010010B
			MVF	MCKCN1, F, ACCE		;關閉內部2MHZ震盪器
							;ADC LS_CK
ENDIF
	RET
;==========================================================================

	DELAY10MS:					; CPU_CK= 2MHZ
			MVL	060H
			MVF	TEMP, F, ACCE
		DELAY10MS_2:   
			MVL	010H
			MVF	TEMP1, F, ACCE
		DELAYS10MS_1:   
			DCSZ	TEMP1, F, ACCE
			JMP	DELAYS10MS_1
			DCSZ	TEMP, F, ACCE
			JMP	DELAY10MS_2
	RET

INCLUDE	HY11P35.INC
END