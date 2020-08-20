;*****************************************************************************
;LCD_MENSAJE_ASM:
;Programa que muestra mensajes en un LCD de 20x2 usando macros.
;cuenta desde 0 hasta 99 mostrando en 2 displays conectados en el    
;puerto D del microcontrolador a intervalos de 0.5 segundos.   
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
    X1, X2, X3		    ;variables usadas en la subrutina delay
    AUX1, AUX2, CMD, DAT    ;variable contador, aux y max
    CTRL
 ENDC
 
;---------------------------------------------------------------------------
;MACRO: LCD_Gotoxy MACRO fila, columna
; Posiciona el cursor en la posicion especificada por fila,
; columna. Coordenadas validas: fila  = 1..2, columna = 1..20
;---------------------------------------------------------------------------
LCD_Gotoxy MACRO fila, col
    LOCAL columna, posicion
    MOVLW	col
    MOVWF	columna,0	
    if(fila==1)
	MOVLW	0x80
	ADDWF	columna,0,0	; W= (W) or (COLUMNA)
	CALL	LCD_Comando 
    else			; Fila= 2
	MOVLW   0xC0
        ADDWF   columna,0,0	; W= (W) or (COLUMNA)
	CALL	LCD_Comando 
    endif
    ENDM
    
;---------------------------------------------------------------------------
;MACRO: LCD_String MACRO texto
; Posiciona el cursor en la posicion especificada por fila,
; columna. Coordenadas validas: fila  = 1..2, columna = 1..20
;---------------------------------------------------------------------------
LCD_String MACRO texto  
    local   leeTabla, print, salir
;Establezco puntero a los mensajes
    MOVLW   UPPER texto    ;Para apuntar puntero TBLPTR hacia "Mensaje1"
			    ;(TBLPTRU:TBLPTRH:TBLPTRL) -> 21 bits
    MOVWF   TBLPTRU	    ;TBLPTRU= 0x00 = b'00000'    = 5 bits
    MOVLW   HIGH texto
    MOVWF   TBLPTRH	    ;TBLPTRH= 0x02 = b'00000010' = 8 bits
    MOVLW   LOW texto
    MOVWF   TBLPTRL	    ;TBLPTRL= 0x00 = b'00000000' = 8 bits
    MOVLW   '$'		    ;W= '$'fin de cadena
    MOVWF   CTRL,0	    ;CTRL= '$'
leeTabla
    TBLRD*+
    MOVF    TABLAT, W	    ;El contenido de TABLAT lo pasa a W
    CPFSEQ  CTRL,0	    ;Es W= $, fin de cadena?
    GOTO    print
    GOTO    salir
print
    CALL    LCD_DATA
    GOTO    leeTabla    
salir
    ENDM

;---------------------------------------------------------------------------
;MACRO: LCD_String_xy MACRO texto
; Posiciona el cursor en la posicion especificada por fila,
; columna. Coordenadas validas: fila  = 1..2, columna = 1..20
;---------------------------------------------------------------------------
LCD_String_xy MACRO fila, columna, texto  
    local   leeTabla, print, salir
;Establezco puntero a los mensajes
    MOVLW   UPPER texto	    ;Para apuntar puntero TBLPTR hacia "Mensaje1"
			    ;(TBLPTRU:TBLPTRH:TBLPTRL) -> 21 bits
    MOVWF   TBLPTRU	    ;TBLPTRU= 0x00 = b'00000'    = 5 bits
    MOVLW   HIGH texto
    MOVWF   TBLPTRH	    ;TBLPTRH= 0x02 = b'00000010' = 8 bits
    MOVLW   LOW texto
    MOVWF   TBLPTRL	    ;TBLPTRL= 0x00 = b'00000000' = 8 bits
    MOVLW   '$'		    ;W= '$'fin de cadena
    MOVWF   CTRL,0	    ;CTRL= '$'
    LCD_Gotoxy fila,columna    ;Macro que posiciona cursor en fila 1, columna 0
leeTabla
    TBLRD*+
    MOVF    TABLAT, W	    ;El contenido de TABLAT lo pasa a W
    CPFSEQ  CTRL,0	    ;Es W= $, fin de cadena?
    GOTO    print
    GOTO    salir
print
    CALL    LCD_DATA
    GOTO    leeTabla    
salir
    ENDM
    
    
;********************* Area de mensajes ****************************************
   ORG 0x05000			; Dirección memoria de programas	
Mensaje1    db	"ESPEJO TORRES         $"   
Mensaje2    db	"HUACHILLO SEBASTIAN       $" 
Mensaje3    db	"ESPEJO TORRES         $"
Mensaje4    db	"HUACHILLO SEBASTIAN             $"
   
;*******************************************************************************
    ORG 0x0000			; Reset Vector				
    GOTO main
;*******************************************************************************
    ORG 0x0020			;Zona de programa de usuario
main:
;Configuro Puerto D como salida e inicio contador en 0
    CLRF    TRISD		;Port D como salida  
;Configuro LCD    
    CALL    LCD_Inicio		; Inicializo LCD
    LCD_Gotoxy 1,1		; Posiciono cursor en fila= 1, columna= 1
    LCD_String	Mensaje1	; Macro imprime en LCD mensaje1
    MOVLW   .20
    CALL    delayTimer_50ms	; retardo de 5*50ms= 250ms
    LCD_String_xy 2,1,Mensaje2	; Macro que posiciona cursor e imprime 
    MOVLW   .40
    CALL    delayTimer_50ms	; retardo de 20*50ms= 1s    
    CALL    LCD_Borra		; Borra o limpia el LCD
    LCD_String_xy 1,5,Mensaje3	; Macro que posiciona cursor e imprime
    LCD_String_xy 2,6,Mensaje4	; Macro que posiciona cursor e imprime
fin GOTO fin			;fin de main
    
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

;--------------------------------------------------------------------
;Subrutina: LCD_inicio
;Inicializa el display LCD.
;--------------------------------------------------------------------
LCD_Inicio:
	MOVLW	.15
	CALL	delayTimer_1ms		; Retardo de 15*1ms
	MOVLW	0x30
	MOVWF	LATD			; DB[7..4] X EN RW RS
	BSF	LATD,2			; Genero pulso en EN (1-to-0)
	NOP				; Retarda un ciclo
	BCF	LATD,2			; EN=0
	MOVLW	.5
	CALL	delayTimer_1ms		; Retardo de 5*1ms (superior a 4.1ms)
	MOVLW	0x30
	MOVWF	LATD			; DB[7..4] X EN RW RS
	BSF	LATD,2			; Genero pulso en EN (1-to-0)
	NOP				; Retarda un ciclo
	BCF	LATD,2			; EN=0
	CALL	delayTimer_100us	; Demora superior a 100 useg	
	MOVLW	0x30
	MOVWF	LATD			; DB[7..4] X EN RW RS
	BSF	LATD,2			; Genero pulso en EN (1-to-0)
	NOP				; Retarda un ciclo
	BCF	LATD,2			; EN=0
	CALL	delayTimer_100us	; Demora superior a 100 useg	
; Tras esta inicialización el display configuramos LCD en modo 4 bits
	MOVLW	0x02			; Configuro en modo 4 bits
	call LCD_Comando
	MOVLW	0x28			; Usa 2 lineas y matriz de 5x8
	call LCD_Comando
	MOVLW	0x01			; Borra display
	call LCD_Comando
	MOVLW	0x0C			; Display ON, cursor OFF
	call LCD_Comando
	MOVLW	0x06			; Incrementa cursor y desplaza a la derecha
	call LCD_Comando
	return

;---------------------------------------------------------------------------
;Funcion: LCD_Comando
;Envia al display LCD un comando para acceder al registro de instrucciones.
;Se debe enviar a traves de W el comando
;-----------------------------------------------------------------------------*/
LCD_Comando:
	MOVWF	CMD,0			; CMD= W
	MOVWF	AUX1,0			; AUX1= CMD	
;se envía nible alto
	MOVLW	0xF0
	ANDWF	AUX1,1,0		; AUX1=  (CMD) and (0xF0)
	MOVLW	b'00000100'		; RS=0, EN=1			
	IORWF	AUX1,0,0		; W= (W) or (AUX1)
	MOVWF	LATD			; LATD= W
	BCF	LATD,2			; EN=0
;se envía nible bajo
	SWAPF	CMD,1,0
	MOVLW	0xF0
	ANDWF	CMD,1,0			; CMD= (CMD) and (0xF0) 
	MOVLW	b'00000100'		; RS=0, EN=1
	IORWF	CMD,0,0			; W= (W) or (CMD)
	MOVWF	LATD			; LATD= W	
	BCF	LATD,2			; EN=0
	MOVLW	.3
	CALL	delayTimer_1ms		; Retardo de 3*1ms 
	RETURN
	
;---------------------------------------------------------------------------
;Macro: LCD_Data dato
;Envia al display LCD un dato para acceder al registro de datos.
;---------------------------------------------------------------------------
LCD_DATA:
	MOVWF	DAT,0			; DAT= W
	MOVWF	AUX1,0			; AUX1= dato	
;envia nibble alto
	MOVLW	0xF0
	ANDWF	AUX1,1,0		; AUX1=  (AUX1) and (0xF0)
	MOVLW	b'00000101'		; RS=1, EN=1
	IORWF	AUX1,0,0		; W= (W) or (AUX1)
	MOVWF	LATD			; LATD= W
	BCF	LATD,2			; EN=0
;envia nibble bajo
	SWAPF	DAT,1,0
	MOVLW	0xF0
	ANDWF	DAT,1,0			; DAT= (DAT) and (0xF0) 
	MOVLW	b'00000101'	    	; RS=1, EN=1
	IORWF	DAT,0,0			; W= (W) or (DAT)
	MOVWF	LATD		    	; LATD= W	
	BCF	LATD,2		    	; EN=0
	MOVLW	.3
	CALL	delayTimer_1ms 	    ; Retardo de 3*1ms 
	RETURN
	
;--------------------------------------------------------------------
;Funcion:  void LCD_Borra(void)
;	Limpia pantalla y pone el cursor en el origen.
;--------------------------------------------------------------------*/
LCD_Borra:
	MOVLW	0x01
	CALL	LCD_Comando
	CALL	delayTimer_1ms	    ; Retardo de *1ms 
	return
;*****************************************************************************
	
	END			;fin de programa

