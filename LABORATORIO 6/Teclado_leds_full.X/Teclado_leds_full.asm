;Programa que lee el teclado conectado al PortB y lo visualiza en un display
;el equivalente a la tecla pulsada. Adicionalmente se visualiza en los 4 leds
;menos significativos la fila_columna
;Autor: Ing. Javier Barriga Hoyle
;*****************************************************************************
    
    list p=18f4550	      ;Modelo del microcontrolador
    #include <p18f4550.inc>    ;Llamo a la librería del PIC18F4550

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

 CBLOCK 0x30
    X1, X2, X3			;variables usadas en la subrutina delay_50ms
    scan,dato,fila,col,tecla    ;para el teclado
 ENDC  

    ORG	    0x000200	      ; memoria de programa
tabla1	db 0x07,0x08,0x09,0x0A,0x04,0x05,0x06,0x0B,0x01,0x02,0x03,0x0C,0x0F
	db 0x00,0x0E,0x0D
;Disp7seg:  7, 8, 9, A, 4, 5, 6, B, 1, 2, 3, C, F, 0, E, D
 
    ORG	    0x000000		;Vector de reset
    GOTO    MAIN
    
    ORG	    0x000020
MAIN:
; Configuro puerto B y D
    CLRF    TRISD	    ;Todo el puertoD como salida
    MOVLW   0xF0
    MOVWF   TRISB	    ;PB[7..4]= in, PB[3..0]= out
    BCF	    INTCON2,7	    ;activo pull-up
    MOVWF   TRISA	    ;PA[7..4]= in, PA[3..0]= out
    MOVLW   0x0F
    MOVWF   ADCON1
    
;configuro los punteros de tabla
    MOVLW   UPPER tabla1   ;Para apuntar puntero TBLPTR hacia "tabla7s"
			    ;(TBLPTRU:TBLPTRH:TBLPTRL) -> 21 bits
    MOVWF   TBLPTRU	    ;TBLPTRU= 0x00 = b'00000'    = 5 bits
    MOVLW   HIGH tabla1
    MOVWF   TBLPTRH	    ;TBLPTRH= 0x02 = b'00000010' = 8 bits
    MOVLW   LOW tabla1
    MOVWF   TBLPTRL	    ;TBLPTRL= 0x00 = b'00000000' = 8 bits
;inicializo mis variables
repite
    MOVLW   0xFE
    MOVWF   scan	    ;valor para testear fila 0
    CLRF    dato	    ;dato= 0
; Programa que testea el teclado y muestra en los leds
lee
    MOVFF   scan,LATB	    ;LATB <- scan
    CALL    delay_10ms
    MOVFF   PORTB,dato	    ;dato <- PORTB
    MOVF    dato,0	    ;W = dato
    CPFSEQ  scan,0	    ;dato=scan?
    GOTO    diferente	    ;no es igual, salta a diferente
    RLNCF   scan,1	    ;scan= 11111101
    MOVLW   0xEF
    CPFSEQ  scan,0	    ;scan=11101111? 
    GOTO    lee		    ;no, regresa
    GOTO    repite
;detecta la tecla pulsada (columna,fila)
diferente
    CALL    detec_tecla	    ;no igual
    MOVFF   tecla,LATD	    ;muestra en los leds fila_columna
;busco el equivalente del teclado
    CLRF    TBLPTRL	    ;Colocamos el TBLPTR en la primera posición de "tabla7s"
    MOVF    tecla,W	    ;Leemos el valor de tecla y lo almacenamos en W
    ANDLW   0x0F	    ;Enmascaramos los cuatro primeros bits
    ADDWF   TBLPTRL	    ;Sumamos el contenido leído y enmascarado hacia el TBLPTR
    TBLRD*		    ;Acción de lectura del puntero (lo leído lo almacena en TABLAT)
    MOVFF   TABLAT,LATA    ;El contenido de TABLAT lo enviamos al puerto RD
    GOTO    repite

;*****************************************************************
;area de subrutinas o procedimientos
;*****************************************************************
delay_10ms:		    ;inicio de subrutina
			    ;1C = 0.8uS
    MOVLW   .10	    ;1C 
    MOVWF   X2	    ;1C 
LX2			    ;tiempo XL2 = 10*1ms = 10ms
        MOVLW   .250	
        MOVWF   X3	
LX3			;tiempo bucle XL3 = 250*5*C = 1250*0.8us= 1000uS=1ms
        NOP		    ;1C
        NOP		    ;1C
        DECFSZ  X3,1    ;1C   
        GOTO    LX3	    ;2C
    DECFSZ  X2,1	    ;1C    
    GOTO    LX2	    ;2C 
    RETURN
    
;-----------------------------------------------------------------
detec_tecla:		    ;subrutina de codificar teclado
    MOVFF   dato,LATD	    ;Muestro en los leds
;capturo la fila
    MOVFF   dato,fila
    MOVFF   dato,col
    MOVLW   0x0F
    ANDWF   fila,1	    ;fila= b'0000????'
    MOVLW   0x0E
    CPFSEQ  fila,0	    ;fila=0x0E? 
    GOTO    fila1
    MOVLW   .0
    MOVWF   fila,0	    ;fila=0
    GOTO    columna
fila1
    MOVLW   0x0D
    CPFSEQ  fila,0	    ;fila=0x0D? 
    GOTO    fila2
    MOVLW   .1
    MOVWF   fila,0	    ;fila=1 
    GOTO    columna
fila2 
    MOVLW   0x0B
    CPFSEQ  fila,0	    ;fila=0x0B? 
    GOTO    fila3
    MOVLW   .2
    MOVWF   fila,0	    ;fila=2
    GOTO    columna
fila3
    MOVLW   0x07
    CPFSEQ  fila,0	    ;fila=0x07? 
    GOTO    columna
    MOVLW   .3
    MOVWF   fila,0	    ;fila=3  

columna:
    MOVLW   0xF0
    ANDWF   col,1	    ;col= b'????0000'
    MOVLW   0xE0
    CPFSEQ  col,0	    ;col=0xE0? 
    GOTO    col1
    MOVLW   .0
    MOVWF   col,0	    ;col=0
    GOTO    continua
col1
    MOVLW   0xD0
    CPFSEQ  col,0	    ;col=0xD0? 
    GOTO    col2
    MOVLW   .1
    MOVWF   col,0	    ;col=1 
    GOTO    continua
col2 
    MOVLW   0xB0
    CPFSEQ  col,0	    ;col=0xB0? 
    GOTO    col3
    MOVLW   .2
    MOVWF   col,0	    ;col=2
    GOTO    continua
col3
    MOVLW   0x70
    CPFSEQ  col,0	    ;col=0x70? 
    GOTO    continua
    MOVLW   .3
    MOVWF   col,0	    ;col=3  
continua
    RLNCF   fila,1	    ;fila= 000000ff
    RLNCF   fila,1	    ;fila= 0000ff00
    MOVF    fila,0	    ;W= fila
    ADDWF   col,1	    ;W= fila_col = 0000ffcc
    MOVFF   col,tecla	    ;tecla= tecla pulsada
    RETURN

;*****************************************************************
    END			;fin de programa

    
   


