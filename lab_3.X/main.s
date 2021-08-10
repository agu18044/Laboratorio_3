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
    cont_small: DS 1 ;1 byte
    cont_big:   DS 1

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

loop:
    
    ;boton para incrementar y decrementar el puerto A
    btfsc   PORTA, 0  
    call    inc_portb
    call    delay_small
    
    btfsc   PORTA, 1
    call    dec_portb
    call    delay_small
    
    ;boton para incrementar y decrementar el puerto C
    btfsc   PORTA, 2
    call    inc_portc
    call    delay_small
    
    btfsc   PORTA, 3
    call    dec_portc
    call    delay_small
    
    btfsc   PORTA, 4
    call    suma
    call    delay_small
    
    ;comprueba si hay un bit de carry
    btfsc   PORTD, 4
    bsf	    PORTE, 0
    btfss   PORTD,4
    bcf	    PORTE, 0
    
    goto    loop

config_io:
    ; Configuracion de los puertos
    banksel ANSEL	; Se selecciona bank 3
    clrf    ANSEL	; Definir puertos digitales
    clrf    ANSELH
    
    bsf	    STATUS, 5  ; banco 01
    bcf	    STATUS, 6
    bsf     TRISA, 0    ; se establecen como inputs para los pushbuttons
    bsf     TRISA, 1
    bsf     TRISA, 2
    bsf     TRISA, 3
    bsf     TRISA, 4
    clrf    TRISB	;outputs de los pushbuttons
    clrf    TRISC
    clrf    TRISD
    clrf    TRISE
  
    bcf	    STATUS, 5  ; banco 00
    bcf	    STATUS, 6
    clrf    PORTB
    clrf    PORTA
    clrf    PORTC
    clrf    PORTD
    clrf    PORTE
    return

