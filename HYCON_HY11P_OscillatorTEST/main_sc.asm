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
;GBK
;挂4MHZ震荡器(并联电阻1MΩ)实际测得起振时间，为VDD=2.2V下测试结果
;VDD=2.2V ~ 4MHZ震荡器起振时间约27.1mS
;VDD=3.6V ~ 4MHZ震荡器起振时间约22.5mS
;------------------------------------------
;
;编译器虚指令指令设定，设定晶振及时脉
Define	HAO_2MHz		=	0
Define	XTS_4MHz		=	0
Define	XTL_32768Hz		=	1

Define	CPUCK_1MHz		=	0
Define	CPUCK_2MHz		=	0
Define	CPUCK_4MHz		=	0
Define	CPUCK_32768Hz	=	0
Define	CPUCK_16384Hz	=	1
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
			MVL	00000001B		;启用内部HAO(2MHZ)
			MVF	MCKCN1, F, ACCE
;==========================================================================		

IF	HAO_2MHZ = 1					;设定内部2MHZ晶振起振
			CALL	2MHZ_CPUSET
ENDIF
;==========================================================================

IF	XTS_4MHZ	=	1			;设定外部4MHZ晶振起振
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

IF	XTL_32768HZ = 1					;设定外部32768HZ晶振起振
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

			CLRF	LVDCN, ACCE		;关闭电源侦测功能
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
			MVF     MCKCN2, F, ACCE   	;设置HS_CK为CPU_CK
ENDIF

IF	CPUCK_1MHZ	=	1 
			MVL     00000100B
			MVF     MCKCN2, F, ACCE   	;设置HSS_CK为CPU_CK
ENDIF
	RET

;==========================================================================

	4MHZ_CPUSET:
IF	CPUCK_4MHZ	=	1
			MVL	00010011B
			MVF	MCKCN2, F, ACCE		;将晶片频率源切换到外部4MHZ, OSC_CY
							;CPU_CK设定为4MHZ HS_CK
							;INTR_CK则为4M/4=1MHZ
							;参阅说明第三章
			MVL	00100110B
			MVF	MCKCN1, F, ACCE		;关闭内部2MHZ震荡器
							;设定ADCS=001B, ADC_CK=4M/2/2/4=250KHZ
ENDIF

IF	CPUCK_2MHZ	=	1
			MVL	00010100B
			MVF	MCKCN2, F, ACCE		;将晶片频率源切换到外部4MHZ, OSC_CY
							;CPU_CK设定为2MHZ HSS_CK
							;INTR_CK则为2M/4=500KHZ
			MVL	00000110B
			MVF	MCKCN1, F, ACCE		;关闭内部2MHZ震荡器
							;设定ADCS=000B, ADC_CK=2M/2/4=250KHZ
ENDIF

IF	CPUCK_1MHZ	=	1
			MVL	00010101B
			MVF	MCKCN2, F, ACCE		;将晶片频率源切换到外部4MHZ, OSC_CY
							;CPU_CK设定为1MHZ HS_DCK
							;INTR_CK则为1M/4=250KHZ
			MVL	00000110B
			MVF	MCKCN1, F, ACCE		;关闭内部2MHZ震荡器
							;设定ADCS=000B, ADC_CK=1M/4=250KHZ
ENDIF
	RET
;==========================================================================

	32768HZ_CPUSET:
IF	CPUCK_32768HZ	=	1
			MVL	00110010B
			MVF	MCKCN2, F, ACCE		;将晶片频率源切换到LS_CK 32768HZ
							;CPU_CK设定为32768HZ
							;INTR_CK则为32768/4=8192HZ
			MVL	00010010B
			MVF	MCKCN1, F, ACCE		;关闭内部2MHZ震荡器
							;ADC LS_CK
ENDIF

IF	CPUCK_16384HZ	=	1
			MVL	00110100B
			MVF	MCKCN2, F, ACCE		;将晶片频率源切换到LS_CK 32768HZ
							;CPU_CK设定为32768/2=16384
							;INTR_CK则为16384/4=4096HZ
			MVL	00010010B
			MVF	MCKCN1, F, ACCE		;关闭内部2MHZ震荡器
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