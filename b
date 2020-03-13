
;---------Dirección del puerto E-------------------
GPIO_PORTE_DATA		EQU	0x400243FC;
;---------Dirección del puerto F-------------------
GPIO_PORTF_DATA		EQU 0x400253FC;	
;--------------------------------------------------
;---------Declaración de las variables para Timer--
;--------------------------------------------------
;---------Modulo de Timer--------------------------
GPTM_RCGCTIMER_R			EQU 0x400FE604;
;---------Configuración de registro----------------
GPTM_TIMER0_CFG_R			EQU 0x40030000;
;---------Registro de Control----------------------
GPTM_TIMER0_CTL_R			EQU 0x4003000C;
;---------Indica si será periodica la interrupción-
GPTM_TIMER0_TIMAMODE_R		EQU 0x40030004;
;---------Registro de interrupción-----------------
GPTM_TIMER0_INTMASK_R		EQU 0x40030018;
;---------Limpia la bandera del registro-----------
GPTM_TIMER0_MICLR_R			EQU	0x40030024;
;-----------Registro de interrupción--------------
GPTM_TIMER0_RIS_R			EQU 0x4003001C;
;-----------Carga el  valor inicial al timer-------
GPTM_TIMER0_TIMAILR_R		EQU 0x40030028;

Tiempo						EQU 15999999

		AREA    |.text|, CODE, READONLY, ALIGN=2
        THUMB
        EXPORT  Start
				IMPORT Inicializarpuertos
Start	
;-----------Subrutina de inicialización de puertos.-
	BL Inicializarpuertos ;
;-----------Subrutina de configuración del Timer----
	BL ConfTimer
;-----------Ciclo de espera de la interrupción------
	B Ciclo

ConfTimer
;--------Se activa el modulo del Timer--------------
	LDR R1, =GPTM_RCGCTIMER_R
	LDR R0, [R1]
	ORR R0, R0, #0x1
	STR R0, [R1]
;--------Permite configurar el timer---------------
	LDR R1, =GPTM_TIMER0_CFG_R
	MOV R0, #0
	STR R0, [R1]
;--------Se establece la función periódica---------
	LDR R1, =GPTM_TIMER0_TIMAMODE_R
	MOV R0, #0x2
	STR R0, [R1]
;--------Carga el vamor del timer------------------
	LDR R1, =GPTM_TIMER0_TIMAILR_R
	LDR R0, [R1]
;--------Tiempo en alto----------------------------
	LDR R2, =Tiempo
	STR R2, [R1]	
;--------Permite que se activen/desactiven las interrupciones.
	LDR R1, =GPTM_TIMER0_INTMASK_R
	LDR R0, [R1]
	ORR R0, R0, #0x1
	STR R0, [R1]
;--------Registro de control que inicia el conteo-------
	LDR R1, =GPTM_TIMER0_CTL_R
	LDR R0, [R1]
	ORR R0,R0, #0x1
	STR R0, [R1]
;---------Valores del puerto E---------------------	
	LDR R1, =GPIO_PORTE_DATA
	MOV R0, #0x10
	STR R0, [R1]
	
	
	
Ciclo
;---------Realiza una interrupcion si se ha realizado otra interrupcion---------
	LDR R1, =GPTM_TIMER0_RIS_R
	LDR R0, [R1]
	CMP R0, #0x1
	BEQ	LedE4
	B Ciclo

LedE4
;--------------Enciende el led E4---------------
	LDR R1, =GPIO_PORTE_DATA
	LDR R0, [R1]
	CMP R0, #0x10
	BEQ LedF1
	MOV R0, #0x10
	STR R0, [R1]	
;---------Apaga Led F1-----------------------------
	LDR R1, =GPIO_PORTF_DATA
	MOV R0, #0x0
	STR R0, [R1]
;---------Limpia el contador interno del timer-------
	LDR R1, =GPTM_TIMER0_MICLR_R
	LDR R0, [R1]
	ORR R0, R0, #0x1
	STR R0, [R1]
	B	Ciclo

;------Se enciende el LED F1 y se apaga el LED E4--
LedF1	
;---------Apaga Led E4-----------------------------
	LDR R1, =GPIO_PORTE_DATA
	MOV R0, #0x0
	STR R0, [R1]		
;---------Enciende Led F1--------------------------
	LDR R1, =GPIO_PORTF_DATA
	MOV R0, #0x2
	STR R0, [R1]
;---------Limpia el contador interno del timer-------
	LDR R1, =GPTM_TIMER0_MICLR_R
	LDR R0, [R1]
	ORR R0, R0, #0x01
	STR R0, [R1]
	B	Ciclo
	ALIGN
	END