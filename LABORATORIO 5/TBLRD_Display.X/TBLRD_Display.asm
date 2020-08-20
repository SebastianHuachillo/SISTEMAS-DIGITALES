;*****************************************************************************
;TBLRD_DISPLAY:
;Programa que muestra como leer datos de una tabla y luego enviarlos a un 
;a un display conectado al PortD a intervalos de 250 msegundos.   
;Autor: Javier Barriga Hoyle    
;*****************************************************************************    
    list p =18f4550		;Modelo del microcontrolador
#include <p18f4550.inc>		;Llamo a la librería de nombre de los regs
    
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
    X1,X2,X3,CTRL
 ENDC

;********************* Area de mensajes ****************************************
   ORG 0x5000			; Dirección memoria de programas	
TablaBCD    db	0,1,2,3,4,5,6,7,8,9,'$'   

;*******************************************************************************
    ORG 0x0000			; Reset Vector				
    GOTO main
;*******************************************************************************
    ORG 0x0020			;Zona de programa de usuario
main:
;Configuro Puerto D como salida e inicio contador en 0
    CLRF    TRISD	;Port D como salida  
;Inicializo puntero a TABLABCD
    MOVLW   UPPER TablaBCD  ;Para apuntar puntero TBLPTR hacia "Mensaje1"
			    ;(TBLPTRU:TBLPTRH:TBLPTRL) -> 21 bits
    MOVWF   TBLPTRU	    ;TBLPTRU= 0x00 = b'00000'    = 5 bits
    MOVLW   HIGH TablaBCD
    MOVWF   TBLPTRH	    ;TBLPTRH= 0x02 = b'00000010' = 8 bits
    MOVLW   LOW TablaBCD
    MOVWF   TBLPTRL	    ;TBLPTRL= 0x00 = b'00000000' = 8 bits
    MOVLW   '$'		    ;W= '$'fin de cadena
    MOVWF   CTRL,0	    ;CTRL= '$'
leeTabla
    TBLRD*+
    MOVF    TABLAT, W	    ;El contenido de TABLAT lo pasa a W
    CPFSEQ  CTRL,0	    ;Es W= $, fin de cadena?
    GOTO    print
    GOTO    fin
print
    MOVWF   LATD,0
    MOVLW   .10
    CALL    delayTimer_50ms    
    GOTO    leeTabla    
   
fin GOTO    fin		    ;fin de main
    
;*****************************************************************
;area de subrutinas o procedimientos
;*****************************************************************
;--------------------------------------------------------------------------
;Subrutina para programar el Timer3 y generar un retardo de 100uS, 1ms, 50ms
;Fosc/4= 5MHz => preescaler/4= 1.25MHz ==> T= 0.8uS cada ciclo
;T3CON.7= 0; R/W registros en 2 operaciones de 8 bits
;T3CON.6.3=00; No se usa	    T3CON.5.4=10; Preescaler 1/4   
;T3CON.2=0; Este bit es ignorado    T3CON.1=0; selecciona Fosc/4  
;T3CON.0=0; Se inicia en OFF    
;--------------------------------------------------------------------------
delayTimer_100us:	    ; Inicio de subrutina 100us
    MOVLW   b'00100000'	     
    MOVWF   T3CON,0	    ; Configuro T3CON
    MOVLW   0x82
    MOVWF   TMR3L,0	    ; Valor inicial del TMR3L
    MOVLW   0xFF  
    MOVWF   TMR3H,0	    ; Valor inicial del TMR3H
    BSF	    T3CON,0	    ; Arranco el temporizador TMR3=ON		
LT1 
    BTFSS   PIR2,1,0	    ; Se activo el flag TMR3IF?
    GOTO    LT1		    ; NO, se activo
    BCF	    PIR2,1,0	    ; Restablesco el flag TMR3IF=0
    RETURN		    

delayTimer_1ms:		    ; Inicio de subrutina 1ms
    MOVWF   X1		    ; tiempo de retardo = X1 * 1ms		
    MOVLW   b'00100000'	     
    MOVWF   T3CON,0	    ; Configuro T3CON
LTX2
    MOVLW   0x1D
    MOVWF   TMR3L,0	    ; Valor inicial del TMR3L
    MOVLW   0xFB  
    MOVWF   TMR3H,0	    ; Valor inicial del TMR3H
    BSF	    T3CON,0	    ; Arranco el temporizador TMR3		
LT2 
    BTFSS   PIR2,1,0	    ; Se activo el flag TMR3IF?
    GOTO    LT2		    ; NO, se activo
    BCF	    PIR2,1,0	    ; Restablesco el flag TMR3IF=0
    BCF	    T3CON,0	    ; Apago el temporizador TMR3	    
    DECFSZ  X1,1	    ; X1= X1-1    
    GOTO    LTX2	    ; Si no es CERO, regresa a LTX2 
    RETURN

delayTimer_50ms:	    ; Inicio de subrutina 50ms
    MOVWF   X1		    ; tiempo de retardo = X1 * 50ms		
    MOVLW   b'00100000'	     
    MOVWF   T3CON,0	    ; Configuro T3CON
LTX3
    MOVLW   0x0B
    MOVWF   TMR3L,0	    ; Valor inicial del TMR3L
    MOVLW   0xDB  
    MOVWF   TMR3H,0	    ; Valor inicial del TMR3H
    BSF	    T3CON,0	    ; Arranco el temporizador TMR3		
LT3 
    BTFSS   PIR2,1,0	    ; Se activo el flag TMR3IF?
    GOTO    LT3		    ; NO, se activo
    BCF	    PIR2,1,0	    ; Restablesco el flag TMR3IF=0
    BCF	    T3CON,0	    ; Apago el temporizador TMR3	    
    DECFSZ  X1,1	    ; X1= X1-1    
    GOTO    LTX3	    ; Si no es CERO, regresa a LTX3 
    RETURN    

;------------------------------------------------------------------------------
    END