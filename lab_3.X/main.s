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
    CONFIG LVP=ON    // Programacion en bajo voltaje permitida
    
;configuration word 2
    CONFIG WRT=OFF   // Proteccion de autoescritura por el programa desactivada
    CONFIG BOR4V=BOR40V  // Reinicio abajo de 4V, (BOR21V=2.1V)
    
PSECT udata_bank0  ;common memory
    

PSECT resVect, class=CODE, abs, delta=2
;-----------vector reset--------------;
ORG 00h     ;posicion 0000h para el reset
resetVec:
    PAGESEL main
    goto main
 
PSECT code, delta=2, abs
ORG 100h    ; posicion para le codigo
 
 ;-----------configuracion--------------;

main:
    call    config_io
    call    config_reloj
    call    config_tmr0
    banksel PORTA

loop:
    btfss   T0IF
    goto    $-1
    call    reiniciar_tmr0
    incf    PORTA
    
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
    movlw   50
    movwf   TMR0
    bcf	    T0IF   
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
  
    banksel PORTA	; Banco 00
    clrf    PORTB
    clrf    PORTA
    clrf    PORTC
    clrf    PORTD
    
    return


end
