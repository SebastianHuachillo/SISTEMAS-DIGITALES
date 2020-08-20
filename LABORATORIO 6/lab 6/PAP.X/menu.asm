

;******************************************************************************
;   This file is a basic template for assembly code for a PIC18F4550. Copy    *
;   this file into your project directory and modify or add to it as needed.  *
;                                                                             *
;   Refer to the MPASM User's Guide for additional information on the         *
;   features of the assembler.                                                *
;                                                                             *
;   Refer to the PIC18Fx455/x550 Data Sheet for additional                    *
;   information on the architecture and instruction set.                      *
;                                                                             *
;******************************************************************************
;                                                                             *
;    Filename:                                                                *
;    Date:                                                                    *
;    File Version:                                                            *
;                                                                             *
;    Author:                                                                  *
;    Company:                                                                 *
;                                                                             * 
;******************************************************************************
;                                                                             *
;    Files Required: P18F4550.INC                                             *
;                                                                             *
;******************************************************************************

	LIST P=18F4550		;directive to define processor
	#include <P18F4550.INC>	;processor specific variable definitions

;******************************************************************************
;Configuration bits
;Microchip has changed the format for defining the configuration bits, please 
;see the .inc file for futher details on notation.  Below are a few examples.



;   Oscillator Selection:
    ; CONFIG1L
      CONFIG  PLLDIV = 1            ; PLL Prescaler Selection bits (No prescale (4 MHz oscillator input drives PLL directly))
      CONFIG  CPUDIV = OSC1_PLL2    ; System Clock Postscaler Selection bits ([Primary Oscillator Src: /1][96 MHz PLL Src: /2])
      CONFIG  USBDIV = 1            ; USB Clock Selection bit (used in Full-Speed USB mode only; UCFG:FSEN = 1) (USB clock source comes directly from the primary oscillator block with no postscale)

    ; CONFIG1H
      CONFIG  FOSC = HS             ; Oscillator Selection bits (HS oscillator (HS))
      CONFIG  FCMEN = ON            ; Fail-Safe Clock Monitor Enable bit (Fail-Safe Clock Monitor enabled)
      CONFIG  IESO = ON             ; Internal/External Oscillator Switchover bit (Oscillator Switchover mode enabled)

    ; CONFIG2L
      CONFIG  PWRT = ON             ; Power-up Timer Enable bit (PWRT enabled)
      CONFIG  BOR = OFF             ; Brown-out Reset Enable bits (Brown-out Reset disabled in hardware and software)
      CONFIG  BORV = 3              ; Brown-out Reset Voltage bits (Minimum setting 2.05V)
      CONFIG  VREGEN = OFF          ; USB Voltage Regulator Enable bit (USB voltage regulator disabled)

    ; CONFIG2H
      CONFIG  WDT = OFF             ; Watchdog Timer Enable bit (WDT disabled (control is placed on the SWDTEN bit))
      CONFIG  WDTPS = 32768         ; Watchdog Timer Postscale Select bits (1:32768)

    ; CONFIG3H
      CONFIG  CCP2MX = ON           ; CCP2 MUX bit (CCP2 input/output is multiplexed with RC1)
      CONFIG  PBADEN = OFF          ; PORTB A/D Enable bit (PORTB<4:0> pins are configured as digital I/O on Reset)
      CONFIG  LPT1OSC = OFF         ; Low-Power Timer 1 Oscillator Enable bit (Timer1 configured for higher power operation)
      CONFIG  MCLRE = ON            ; MCLR Pin Enable bit (MCLR pin enabled; RE3 input pin disabled)

    ; CONFIG4L
      CONFIG  STVREN = ON           ; Stack Full/Underflow Reset Enable bit (Stack full/underflow will cause Reset)
      CONFIG  LVP = OFF             ; Single-Supply ICSP Enable bit (Single-Supply ICSP disabled)
      CONFIG  ICPRT = OFF           ; Dedicated In-Circuit Debug/Programming Port (ICPORT) Enable bit (ICPORT disabled)
      CONFIG  XINST = OFF           ; Extended Instruction Set Enable bit (Instruction set extension and Indexed Addressing mode disabled (Legacy mode))

    ; CONFIG5L
      CONFIG  CP0 = OFF             ; Code Protection bit (Block 0 (000800-001FFFh) is not code-protected)
      CONFIG  CP1 = OFF             ; Code Protection bit (Block 1 (002000-003FFFh) is not code-protected)
      CONFIG  CP2 = OFF             ; Code Protection bit (Block 2 (004000-005FFFh) is not code-protected)
      CONFIG  CP3 = OFF             ; Code Protection bit (Block 3 (006000-007FFFh) is not code-protected)

    ; CONFIG5H
      CONFIG  CPB = OFF             ; Boot Block Code Protection bit (Boot block (000000-0007FFh) is not code-protected)
      CONFIG  CPD = OFF             ; Data EEPROM Code Protection bit (Data EEPROM is not code-protected)

    ; CONFIG6L
      CONFIG  WRT0 = OFF            ; Write Protection bit (Block 0 (000800-001FFFh) is not write-protected)
      CONFIG  WRT1 = OFF            ; Write Protection bit (Block 1 (002000-003FFFh) is not write-protected)
      CONFIG  WRT2 = OFF            ; Write Protection bit (Block 2 (004000-005FFFh) is not write-protected)
      CONFIG  WRT3 = OFF            ; Write Protection bit (Block 3 (006000-007FFFh) is not write-protected)

    ; CONFIG6H
      CONFIG  WRTC = OFF            ; Configuration Register Write Protection bit (Configuration registers (300000-3000FFh) are not write-protected)
      CONFIG  WRTB = OFF            ; Boot Block Write Protection bit (Boot block (000000-0007FFh) is not write-protected)
      CONFIG  WRTD = OFF            ; Data EEPROM Write Protection bit (Data EEPROM is not write-protected)

    ; CONFIG7L
      CONFIG  EBTR0 = OFF           ; Table Read Protection bit (Block 0 (000800-001FFFh) is not protected from table reads executed in other blocks)
      CONFIG  EBTR1 = OFF           ; Table Read Protection bit (Block 1 (002000-003FFFh) is not protected from table reads executed in other blocks)
      CONFIG  EBTR2 = OFF           ; Table Read Protection bit (Block 2 (004000-005FFFh) is not protected from table reads executed in other blocks)
      CONFIG  EBTR3 = OFF           ; Table Read Protection bit (Block 3 (006000-007FFFh) is not protected from table reads executed in other blocks)

    ; CONFIG7H
      CONFIG  EBTRB = OFF           ; Boot Block Table Read Protection bit (Boot block (000000-0007FFh) is not protected from table reads executed in other blocks)
;******************************************************************************
;Variable definitions
; These variables are only needed if low priority interrupts are used. 
; More variables may be needed to store other special function registers used
; in the interrupt routines.

	CBLOCK	0x080
	WREG_TEMP	;variable used for context saving 
	STATUS_TEMP	;variable used for context saving
	BSR_TEMP	;variable used for context saving
	T1,T2,T3,T4
	ENDC

#DEFINE BOT1	PORTD,4
#DEFINE BOT2	PORTD,5
#DEFINE M1	LATD,0
#DEFINE M2	LATD,1
#DEFINE M3	LATD,2
#DEFINE M4	LATD,3
;Reset vector
	ORG	0x0000
	GOTO	Main		;go to start of main code
;******************************************************************************
;High priority interrupt vector
	ORG	0x0008
	BRA	HighInt		;go to high priority interrupt routine
;******************************************************************************
;Low priority interrupt vector and routine
	ORG	0x0018
LowInt:
	movff	STATUS,STATUS_TEMP	;save STATUS register
	movff	WREG,WREG_TEMP		;save working register
	movff	BSR,BSR_TEMP		;save BSR register
;	*** low priority interrupt code goes here ***
	movff	BSR_TEMP,BSR		;restore BSR register
	movff	WREG_TEMP,WREG		;restore working register
	movff	STATUS_TEMP,STATUS	;restore STATUS register
	retfie
;******************************************************************************
;High priority interrupt routine
HighInt:
;	*** high priority interrupt code goes here ***
	retfie	FAST
;******************************************************************************
;Start of main program	
	ORG	0X0100
Main:
	CLRF	PORTD
	CLRF	LATD
	MOVLW	B'00110000'
	MOVWF	TRISD
	CLRF	PORTD
	CLRF	LATD
TRABAJO:
	BTFSC	BOT1
	RCALL	MOV1
	RCALL	T250MS
	BTFSC	BOT2
	RCALL	MOV2
	RCALL	T250MS
	BRA	TRABAJO
MOV1:
	BSF	M1
	RCALL	T250MS
	BCF	M4
	RCALL	T250MS
	BSF	M2
	RCALL	T250MS
	BCF	M1
	RCALL	T250MS
	BSF	M3
	RCALL	T250MS
	BCF	M2
	RCALL	T250MS
	BSF	M4
	RCALL	T250MS
	BCF	M3
	RCALL	T250MS
	
	BTFSC	BOT1
	BRA	MOV1
	RETURN
	
MOV2:	BSF	M4
	RCALL	T250MS
	BCF	M1
	RCALL	T250MS
	BSF	M3
	RCALL	T250MS
	BCF	M4
	RCALL	T250MS
	BSF	M2
	RCALL	T250MS
	BCF	M3
	RCALL	T250MS
	BSF	M1
	RCALL	T250MS
	BCF	M2
	RCALL	T250MS
	
	BTFSC	BOT2
	BRA	MOV2
	RETURN
	
	
TXS:	MOVWF	T4
Txs_	RCALL	T250MS
	RCALL	T250MS
	RCALL	T250MS
	RCALL	T250MS
	DECFSZ	T4,1,1
	BRA	Txs_
	RETURN
T250MS:	MOVLW	.250
	MOVWF	T3
T250ms_	RCALL	T1MS
	DECFSZ	T3,1,1
	BRA	T250ms_
	RETURN	

T20MS:	MOVWF	T3
T20ms_	RCALL	T1MS
	DECFSZ	T3,1,1
	BRA	T20ms_
	RETURN	
	
TXMS:	MOVWF	T3
Txms_	RCALL	T1MS
	DECFSZ	T3,1,1
	BRA	Txms_
	RETURN	
T1MS:	MOVLW	.100
	MOVWF	T2
T1ms_	RCALL	T10US
	DECFSZ	T2,1,1
	BRA	T1ms_
	RETURN
T10US:	MOVLW	.15	
	MOVWF	T1	
T10us_	DECFSZ	T1,1,1
	BRA	T10us_	
	RETURN
	
	END
	
