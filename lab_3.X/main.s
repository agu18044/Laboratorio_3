; Archivo:     main.S
; Dispositivo: PIC16F887
; Autor:       Diego Aguilar
; Compilador:  pic-as (v2.30), MBPLABX v5.40
;
; Programa:    contador 
; Hardware:    LEDs 
;
; Creado: 9 agosto, 2021
; Última modificación: 9 agosto, 2021

PROCESSOR 16F887
 #include <xc.inc>
 
;configuration word 1
    CONFIG FOSC=INTRC_NOCLKOUT  // Oscilador interno sin salidas
    CONFIG WDTE=OFF  // WDT disabled (reinicio repetitivo del pic)
    CONFIG PWRTE=ON  // PWRT enabled (espera de 72ms al iniciar)
    CONFIG MCLRE=OFF // El pin MCLR se utiliza como I/0
    CONFIG CP=OFF    // Sin proteccion de codigo
    CONFIG CPD=OFF   // Sin proteccion de datos
    
    CONFIG BOREN=OFF // Sin reinicio cuando el voltaje de alimentacion baja de 4V
    CONFIG IESO=OFF  // Reinicio sin cambio de reloj de interno a externo
    CONFIG FCMEN=OFF // Cambio de reloj externo a interno en caso de fallo
    CONFIG LVP=OFF    // Programacion en bajo voltaje permitida
    
;configuration word 2
    CONFIG WRT=OFF   // Proteccion de autoescritura por el programa desactivada
    CONFIG BOR4V=BOR40V  // Reinicio abajo de 4V, (BOR21V=2.1V)
    
PSECT udata_bank0  ;common memory
    reg:    DS 2
    cont:   DS 2
    
PSECT resVect, class=CODE, abs, delta=2
;-----------vector reset--------------;
ORG 00h     ;posicion 0000h para el reset
resetVec:
    PAGESEL main
    goto main
 
PSECT code, delta=2, abs
ORG 100h    ; posicion para le codigo
 tabla:
    clrf    PCLATH
    bsf	    PCLATH, 0   ;PCLATH = 01
    andlw   0x0f
    addwf   PCL         ;PC = PCLATH + PCL
    ; se configura la tabla para el siete segmentos
    retlw   00111111B  ;0
    retlw   00000110B  ;1
    retlw   01011011B  ;2
    retlw   01001111B  ;3
    retlw   01100110B  ;4
    retlw   01101101B  ;5
    retlw   01111101B  ;6
    retlw   00000111B  ;7
    retlw   01111111B  ;8
    retlw   01100111B  ;9
    retlw   01110111B  ;A
    retlw   01111100B  ;B
    retlw   00111001B  ;C
    retlw   01011110B  ;D
    retlw   01111001B  ;E
    retlw   01110001B  ;F
    
 ;-----------configuracion--------------;

main:
    call    config_io
    call    config_reloj
    call    config_tmr0
    banksel PORTA

loop:
    btfsc   PORTB, 0  
    call    inc_portc
    
    btfsc   PORTB, 1  
    call    dec_portc
    
    btfsc   T0IF
    call    reiniciar_tmr0
    
    movlw    10
    subwf   cont, W
    btfsc   STATUS, 2
    call    inc_portd
  
    movf    PORTD, W
    subwf   reg, W
    btfsc   STATUS, 2
    call    alarma
 
    goto    loop

 ;-----------sub rutinas--------------;    
config_reloj:
    banksel OSCCON
    bsf	    IRCF2
    bcf	    IRCF1
    bsf	    IRCF0	; 2 Mhz
    bsf	    SCS
    return
    
config_tmr0:
    banksel TRISA
    bcf	    T0CS	;reloj interno
    bcf	    PSA		;prescaler
    bsf	    PS2
    bsf	    PS1
    bsf	    PS0		;  PS = 111 = 1:256
    banksel PORTA
    call    reiniciar_tmr0
    return

reiniciar_tmr0:
    movlw   60
    movwf   TMR0
    bcf	    T0IF  
    incf    PORTA
    incf    cont
    return

inc_portc:
    btfsc	PORTB, 0
    goto	$-1
    incf	reg
    movf	reg, W
    call	tabla
    movwf	PORTC
    return
 
dec_portc:
    btfsc	PORTB, 1
    goto	$-1
    decfsz	reg
    movf	reg, W
    call	tabla
    movwf	PORTC
    return
    
inc_portd:
    incf    PORTD
    btfsc   PORTD, 4
    clrf    PORTD
    bcf	    PORTE, 1
    movlw   0
    movwf   cont
    return
    
/*alarma:
    movf    PORTD, W
    subwf   reg, W
    btfsc   STATUS, 2
    bsf	    PORTE, 1
    return*/
 
alarma:
    bsf	    PORTE, 1
    clrf    PORTD
    return
    
config_io:
    ; Configuracion de los puertos
    banksel ANSEL	; Se selecciona bank 3
    clrf    ANSEL	; Definir puertos digitales
    clrf    ANSELH
    
    banksel TRISA	; Banco 01
    clrf    TRISA
    clrf    TRISC	
    bsf	    TRISB, 0
    bsf	    TRISB, 1
    clrf    TRISD
    clrf    TRISE
  
    banksel PORTA	; Banco 00
    clrf    PORTB
    clrf    PORTA
    clrf    PORTC
    clrf    PORTD
    clrf    PORTE
    
    movlw   0
    movwf   cont
    return

end
