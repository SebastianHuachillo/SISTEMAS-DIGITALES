;*********
;Programa que cuenta los pulsos ingresados desde S0 conectado al bit0 del
;PortA desde 0 hasta 30 mostrando en los leds en formato binario conectados en
;el PortB del microcontrolador. Cuando alcanza 30 pulsos termina.  
;Autor: Javier Barriga Hoyle    
;*********   
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

;Declaramos las variables a partir de la dirección 0x30
 CBLOCK	0x30
    X1, X2, X3			;variables usadas en la subrutina delay_50ms
    cont, max	
    UNIDAD ;variable como contador 		    
 ENDC
;*********
    ORG 0x0000			; Reset Vector				
    GOTO main
;*********
    ORG 0x0020			;Zona de programa de usuario
main:
    CLRF    TRISD
    CLRF    TRISC
    CLRF    TRISB
    MOVLW   0x01
    MOVWF   TRISA
    MOVLW   0x0F
    MOVWF   ADCON1,0
    MOVLW   0x00
    MOVWF   ADCON0,0
    MOVLW   0x91
    MOVWF   ADCON2,0
;******
  INICIO
    CLRF	    PORTD
    CLRF	    PORTC
    BCF		    PORTA,1;RS
    BCF		    PORTA,2
    BCF		    PORTA,3;ENABLE
 INICIANDO
    CALL    INICIO_LCD
 ;TEXTO
    MOVLW   '6'
    MOVWF   LATD
    CALL    IMPRIME
    MOVLW   ';'
    MOVWF   LATD
    CALL    IMPRIME
    MOVLW   '9'
    MOVWF   LATD
    CALL    IMPRIME
    MOVLW   ';'
    MOVWF   LATD
    CALL    IMPRIME
    MOVLW   '1'
    MOVWF   LATD
    CALL    IMPRIME
    MOVLW   ';'
    MOVWF   LATD
    CALL    IMPRIME
    MOVLW   '5'
    MOVWF   LATD
    CALL    IMPRIME
    MOVLW   ';'
    MOVWF   LATD
    CALL    IMPRIME
    MOVLW   '3'
    MOVWF   LATD
    CALL    IMPRIME
    MOVLW   ';'
    MOVWF   LATD
    CALL    IMPRIME
    MOVLW   '2'
    MOVWF   LATD
    CALL    IMPRIME
    MOVLW   ';'
    MOVWF   LATD
    CALL    IMPRIME
    MOVLW   '4'
    MOVWF   LATD
    CALL    IMPRIME
    MOVLW   ';'
    MOVWF   LATD
    CALL    IMPRIME
    MOVLW   '0'
    MOVWF   LATD
    CALL    IMPRIME
    
;#################################################333
  
VERIFICA
    BTFSC   PORTA,0
    GOTO    VERIFICA
    XX
    BTFSS   PORTA,0
    GOTO    XX
    
    CALL    LINEA2
    MOVLW   '0'
    MOVWF   LATD
    CALL    IMPRIME
    MOVLW   ';'
    MOVWF   LATD
    CALL    IMPRIME
    MOVLW   '1'
    MOVWF   LATD
    CALL    IMPRIME
    MOVLW   ';'
    MOVWF   LATD
    CALL    IMPRIME
    MOVLW   '2'
    MOVWF   LATD
    CALL    IMPRIME
    MOVLW   ';'
    MOVWF   LATD
    CALL    IMPRIME
    MOVLW   '3'
    MOVWF   LATD
    CALL    IMPRIME
    MOVLW   ';'
    MOVWF   LATD
    CALL    IMPRIME
    MOVLW   '4'
    MOVWF   LATD
    CALL    IMPRIME
    MOVLW   ';'
    MOVWF   LATD
    CALL    IMPRIME
    MOVLW   '5'
    MOVWF   LATD
    CALL    IMPRIME
    MOVLW   ';'
    MOVWF   LATD
    CALL    IMPRIME
    MOVLW   '6'
    MOVWF   LATD
    CALL    IMPRIME
    MOVLW   ';'
    MOVWF   LATD
    CALL    IMPRIME
    MOVLW   '9'
    MOVWF   LATD
    CALL    IMPRIME    
    GOTO    $    
 ;*********
    
  INICIO_LCD
  BCF	    PORTA,1
  MOVLW	    0x01
  MOVWF	    LATD
  CALL	    ENABLE
  MOVLW	    0x38
  MOVWF	    LATD
  CALL	    ENABLE
  MOVLW	    0x0E
  MOVWF	    LATD
  CALL	    ENABLE
  MOVLW	    0x06
  MOVWF	    LATD
  CALL	    ENABLE
  MOVLW	    0x02
  MOVWF	    LATD	
  CALL	    ENABLE
  RETURN
  
 LIMPIA
    BCF	    PORTA,1
    MOVLW   0x01
    MOVWF   LATD
    CALL    ENABLE
    RETURN
    
 ENABLE
    BCF	    PORTA,3
    CALL    RETARDO_1MS
    BSF	    PORTA,3
    CALL    RETARDO_1MS
    BCF	    PORTA,3
    RETURN
    
 IMPRIME
    BSF	    PORTA,1
    CALL    RETARDO_1MS
    CALL    ENABLE
    BCF	    PORTA,1
    RETURN
    
 LINEA2
    BCF	    PORTA,1
    MOVLW   0xC0
    MOVWF   LATD   
    CALL    ENABLE
    RETURN
 
 ;*********
 RETARDO_500MS
 
    MOVLW	b'00010011'
    MOVWF	T0CON,0
    MOVLW	0x67
    MOVWF	TMR0H,0
    MOVLW	0x69
    MOVWF	TMR0L,0
    BSF		T0CON,7
 L1  
    BTFSS	INTCON,2,0
    GOTO	L1
    BCF		INTCON,2,0
    
    RETURN
    
 RETARDO_1MS
    MOVLW	b'01010011'
    MOVWF	T0CON,0
    MOVLW	0xB1
    MOVWF	TMR0L,0
    BSF		T0CON,7
 L2
    BTFSS	INTCON,2,0
    GOTO	L2
    BCF		INTCON,2,0
    
    RETURN
    
    
    
    END