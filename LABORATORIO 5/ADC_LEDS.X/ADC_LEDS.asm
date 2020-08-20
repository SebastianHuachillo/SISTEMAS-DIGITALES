
    list p=18f4550		;Modelo del microcontrolador
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

;Declaramos las variables a partir de la dirección 0x30
 CBLOCK	0x30
    X1, X2, X3			;variables usadas en la subrutina delay_50ms
    veces			;variable como contador 		    
 ENDC
;*******************************************************************************
    ORG 0x0000			; Reset Vector				
    GOTO main
;*******************************************************************************
    ORG 0x0020			;Zona de programa de usuario
main:
;Configuro PortA (canal0) y PortD= out, PortC= out
    CLRF    TRISD,0		;PortD= (8 bits) out
    CLRF    TRISC,0		;PortC= (2 bits) out    
    MOVLW   0xFF
    MOVWF   TRISA		;PortA= in
    MOVLW   0x0E
    MOVWF   ADCON1,0		;Se selecciona RA0 (analogico)
    MOVLW   0x00
    MOVWF   ADCON0,0		;Se selecciona RA0 como entrada analogica
    MOVLW   0x91		;4TAD, FOSC/8, justificación derecha
    MOVWF   ADCON2,0
;Apago leds para visualizar en digital la conversión
    CLRF    LATD,0		;leds OFF
    CLRF    LATC,0		;Leds OFF
;Habilito al conversor analogo digital
    BSF	    ADCON0,ADON		; Habilito convertidor ADC
;Captura valores analógicos
muestreo
    BSF	    ADCON0,GO		;Bit GO= 1; arranco la conversión
espera
    BTFSC   ADCON0,GO		;Bit GO= 0?
    GOTO    espera		;NO, regresa a "espera"
    MOVFF   ADRESH,LATC		;Muestro los 2 bits mas significativos
    MOVFF   ADRESL,LATD		;Muestro los 8 bits menos significativos
    MOVLW   .20
    CALL    delay_50ms		;llamo a retardo de 20*50 ms = 1 seg
    GOTO    muestreo		;vuelve a capturar otra muestra (bucle infinito)

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







