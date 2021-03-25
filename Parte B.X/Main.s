PROCESSOR 16F877A

#include <xc.inc>

; CONFIGURATION WORD PG 144 datasheet

CONFIG CP=OFF ; PFM and Data EEPROM code protection disabled
CONFIG DEBUG=OFF ; Background debugger disabled
CONFIG WRT=OFF
CONFIG CPD=OFF
CONFIG WDTE=OFF ; WDT Disabled; SWDTEN is ignored
CONFIG LVP=ON ; Low voltage programming enabled, MCLR pin, MCLRE ignored
CONFIG FOSC=XT
CONFIG PWRTE=ON
CONFIG BOREN=OFF
PSECT udata_bank0

max:
DS 1 ;reserve 1 byte for max

tmp:
DS 1 ;reserve 1 byte for tmp
PSECT resetVec,class=CODE,delta=2

resetVec:
    PAGESEL INISYS ;jump to the main routine
    goto INISYS

#define PUMP_LVL PORTD,0 ;SALIDA BOMBA NIVEL 
#define HEATING PORTD,1 ;SALIDA CALEFACCION     
#define PUM_OXYGEN PORTD,2 ;SALIDA BOMBA OXIGENO
    
#define S_LVL PORTC,0 ;ENTRADA  NIVEL 
#define S_TEMP PORTC,1 ;ENTRADA TEMPERATURA 

 
    
PSECT code
;//////////////////////////////////////////////////////////////////////
LLENADO:
    
BSF  PUMP_LVL
BCF  HEATING
BCF  PUM_OXYGEN
GOTO RENEW
    
CALENTAR:

BCF  PUMP_LVL
BSF  HEATING
BCF  PUM_OXYGEN
GOTO RENEW
    
OXIGENAR:
 
BCF  PUMP_LVL
BCF  HEATING
BSF  PUM_OXYGEN
GOTO RENEW
    
RENEW:
BCF  PUMP_LVL
BCF  HEATING
BCF  PUM_OXYGEN
GOTO MAIN
    
;///////////////////////////////////////////////////////////////////////////////

INISYS:  
    BCF STATUS,6 ;BK1
    BSF STATUS,5

    BSF TRISC, 0 ;Sensor control nivel 
    BSF TRISC, 1 ;Sensor control temperatura 
    BSF TRISC, 2 ;Bit 1 sensor oxigeno
    BSF TRISC, 3 ;Bit 2 sensor oxigeno
    
  
    BCF TRISD, 0 ;BOMBA NIVEL
    BCF TRISD, 1 ;CALEFACCION
    BCF TRISD, 2 ;BOMBA DE OXIGENO
 
    BCF STATUS, 5 ; BK0
    CLRF PORTD

MAIN:

BTFSS S_LVL
GOTO TEST_TEMP
GOTO TEST_LVL

TEST_LVL:
BTFSS S_LVL
GOTO TEST_TEMP
CALL LLENADO
    
TEST_TEMP:
BTFSS S_TEMP
GOTO TEST_OX
CALL CALENTAR
    
TEST_OX: 
BTFSS TRISC, 2
GOTO ON_PUMP_OX
GOTO ON_PUMP_OX1
    
ON_PUMP_OX:
BTFSS TRISC, 3
CALL OXIGENAR
CALL OXIGENAR
    
ON_PUMP_OX1:
BTFSS TRISC, 3
GOTO MAIN
GOTO RENEW

END resetVec