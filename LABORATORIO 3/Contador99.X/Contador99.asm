;*****************************************************************************
;Programa que cuenta desde 0 hasta 99 mostrando en 2 displays conectados en el    
;puerto D del microcontrolador a intervalos de 0.5 segundos.   
;Autor: Javier Barriga Hoyle    
;*****************************************************************************    
    
    list p =18f4550		;Modelo del microcontrolador
#include<p18f4550.inc>		;Llamo a la librería de nombre de los regs

;Zona de los bits de configuración
 CONFIG  PLLDIV = 5          ; PLL Prescaler Divide by 5 (20 MHz/5 = 4 MHZ)
 CONFIG  CPUDIV = OSC4_PLL6  ; System Clock Postscaler (20 MHz/4 = 5 MHz)
 CONFIG  USBDIV = 2          ; USB Clock Full-Speed (96 MHz/2 = 48 MHz)
 CONFIG  FOSC = HS           ; Oscillator Selection bits (HS oscillator)
 CONFIG  PWRT = ON           ; Power-up Timer Enable bit (PWRT enabled)
 CONFIG  BOR = OFF           ; Brown-out Reset disabled
 CONFIG  BORV = 3            ; Brown-out Reset Voltage (Minimum 2.05V)
 CONFIG  WDT = OFF           ; Watchdog Timer disabled
 CONFIG  CCP2MX = OFF        ; CCP2 MUX bit (CCP2 is multiplexed with RB3)
 CONFIG  PBADEN = OFF        ; PORTB A/D (PORTB<4:0> configured as digital I/O)
 CONFIG  MCLRE = ON          ; MCLR Pin Enable bit (MCLR pin enabled)
 CONFIG  STVREN = ON         ; Stack Full/Underflow will cause Reset
 CONFIG  LVP = OFF           ; Single-Supply ICSP disabled

;Reserva memoria para variables a partir de la dirección 0x30
 CBLOCK	0x30
    X1, X2, X3		;variables usadas en la subrutina delay_50ms
    cont, aux, max	;variable contador, aux y max		    
 ENDC
;*******************************************************************************
    ORG 0x0000			; Reset Vector				
    GOTO main
;*******************************************************************************
    ORG 0x0020			;Zona de programa de usuario
main:
;Configuro Puerto D como salida e inicio contador en 0
    CLRF    TRISD	;Port D como salida
    CLRF    cont	;cont = 0x00
    CLRF    LATD	;LATD = 0x00 (displays en CERO)
    
;inicializo variables de comparacion    
    MOVLW   9		; W <= 9
    MOVWF   aux		; aux <= W (para comparar BCD)
    MOVLW   0x99	; W <= 0x99
    MOVWF   max		; max <= 0x99
;codigo del contador
sigue
    INCF    cont,1	; cont <= cont+1
    MOVF    cont,0	; W <= cont    
    ANDLW   0x0F	; W <= W & (00001111)
    CPFSLT  aux,0	; ¿aux < W? (9 < W?)
    GOTO    nomenor	; NO, salta a nomenor
    MOVLW   0x06	; SI, le sumo 6
    ADDWF   cont,1	; cont <= cont + 6 (BCD)
nomenor
    MOVFF   cont,LATD	; display <= cont
    MOVLW   .10		; llama un retardo de 10*50ms = 500ms
    CALL    delay_50ms
;consulto si llego a la cuenta maxima de 99
    MOVF   cont,0	; W <= cont
    CPFSEQ  max,0	; ¿max = W? (max = 99?)
    GOTO    sigue	; NO, regresa a seguir contando
    CLRF    cont	; SI, entonces cont = 0
    GOTO    sigue	; empieza de nuevo la cuenta

fin GOTO    fin		;fin del programa (bucle infinito)

;*****************************************************************
;area de subrutinas o procedimientos
;*****************************************************************
delay_50ms:		    ;inicio de subrutina
			    ;1C = 0.8uS
    MOVWF   X1		    ;tiempo de retardo = X1 * 50ms		
LX1
	MOVLW   .50	    ;1C 
	MOVWF   X2	    ;1C 
LX2			    ;tiempo XL2 = 50*1ms = 50ms
	    MOVLW   .250	
	    MOVWF   X3	
LX3			;tiempo bucle XL3 = 250*5*C = 1250*0.8us= 1000uS=1ms
	    NOP		    ;1C
	    NOP		    ;1C
	    DECFSZ  X3,1    ;1C   
	    GOTO    LX3	    ;2C
	DECFSZ  X2,1	    ;1C    
	GOTO    LX2	    ;2C 
    DECFSZ  X1,1	    ;1C    
    GOTO    LX1		    ;2C 	
    RETURN		

;*****************************************************************
    END			;fin de programa


    END