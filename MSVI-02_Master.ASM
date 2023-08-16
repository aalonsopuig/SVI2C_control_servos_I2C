; msvi-02
; Master para control del módulo SvI2C
; Por: Alejandro Alonso Puig - mundobot.com
; Fecha: 11/10/2003
; Controlador: 16F876 4Mhz
; Función: 
; Controla por I2C el módulo slave de control de servos y puertos analógicos SvI2C
;
; Las subrutinas definidas para el intercambio de datos con el módulo SvI2C 
; son los siguientes:
;
; 
; ESCRITURA DE REGISTROS
; ----------------------
;
; SetPosSvI2C		Ordena por i2c al módulo SvI2C la actualización del registro
;			de posición del servo "ServoSvI2C" según el valor de
;			"PosSvI2C". 
;
; SetOffsetSvI2C	Ordena por i2c al módulo SvI2C la actualización del registro
;			de Offset del servo "ServoSvI2C" según el valor de
;			"OffsetSvI2C". 
;
; SetModoSvI2C		Ordena por i2c al módulo SvI2C la actualización del registro
;			Mode que establece el sentodo de giro de los servos 
;			según el valor de "ModoSvI2C". 


; LECTURA DE REGISTROS
; ----------------------
;
; ReadVerSvI2C		Obtiene por i2c la versión de firmware del módulo SvI2C  
;			y la deja en la variable "VerSvI2C"
;
; ReadAnalogSvI2C	Obtiene por i2c el valor digital (8bits) de la señal analógica
;			presente en el puerto "APortSvI2C" del módulo SvI2C y lo
;			deja en "AnalogSvI2C"



	list 		p=16F876
	include		"P16F876.INC"


;Definición de constantes

	#define	ClockValue 	d'9' 	;(100khz) valor para cálculo de vel. I2C que pasará a SSPADD
	#define DirSvI2C	b'01110000'	;Dirección Módulo SvI2C (01110000)

	;Códigos de registro del módulo SvI2C
	#define SvI2CModo	d'1'	;Modo de funcionamiento de servo (normal=0 o reverse=1)
	#define SvI2COffset	d'2'	;Offset
	#define SvI2CPos	d'3'	;Posicion
	#define SvI2CAnalog	d'4'	;Entrada analógica
	#define SvI2CVer	d'7'	;Versión Firmware


;Definición de variables

	cblock	0x20	
	MensajeIn	;Contendrá el dato recibido por I2C del slave
	MensajeOut	;Contendrá el dato a enviar por I2C al slave
	DirSlave	;Dirección del Slave	
	BkStatus	;Backup del registro STATUS 
	BkW		;Backup W

	BDel0		;Usada en retardos		
	BDel1		;Usada en retardos		
	BDel2		;Usada en retardos		
	Pausa		;Usada en para hacer pausas con subr "HacerTiempo"


	;Dispositivos del módulo SvI2C
	ServoSvI2C	;Servo cuyo registro se accederá por i2c
	APortSvI2C	;Puerto analógico

	;Registros del módulo SvI2C
	PosSvI2C	;Posición que se desea que tenga la servo
	OffsetSvI2C	;Offset que se desea que tenga el servo
	ModoSvI2C	;Registro de modo (normal/reverse)
	VerSvI2C	;Versión Firmware
	AnalogSvI2C	;Valor puerto analógico


	endc		;Fin de definiciones


	org	0
	goto	INICIO
	org	5		



;-------------------------------------------------------------------------------




INICIO		;Inicio del cuerpo del programa

	banksel	TRISA		;Apunta a banco 1
	movlw	b'00011111'	;Entrada (switches). Solo 5 inferiores
	movwf	TRISA		;
	movlw	b'00000000'	;Salida (Leds)
	movwf	TRISB		;
	banksel	PORTB		;Apunta a banco 0
	clrf	PORTB		;Limpia puerto B
	clrf	PORTA		;Limpia puerto A

	call	init_i2c_Master	;Configuración para uso de i2c

	clrf	MensajeIn
	clrf	MensajeOut

	movlw	d'10'		;Pausa de 10 centésimas de segundo para que en...
	movwf	Pausa		;...el arranque de tiempo a los slaves a quedar...
	call	HacerTiempo	;..configurados adecuadamente.


	movlw	d'220'		;posición
	movwf	PosSvI2C


MLoop

	;Proceso para resetear el slave en caso de bloqueo de algún tipo
	call Send_RStart
	call Send_Stop
	banksel	PORTB

	;lee versión firmware y la muestra por PORTB
;	call	ReadVerSvI2C
;	movf	VerSvI2C,W
;	movwf	PORTB


	;Ordena funcionamiento servo 2 y 4 en sentido reverse. Resto normal
;	movlw	b'00010100'
;	movwf	ModoSvI2C
;	call	SetModoSvI2C

	;lee valor analógico puerto 0 y la muestra por PORTB
	movlw	d'0'
	movwf	APortSvI2C
	call	ReadAnalogSvI2C
	movf	AnalogSvI2C,W
	movwf	PORTB


	;Ordena movimiento a posición concreta
	movlw	d'1'		;Servo
	movwf	ServoSvI2C
	movlw	d'10'		;posición
	movwf	PosSvI2C
	call	SetPosSvI2C

	;pausa de 10 centésimas de segundo 
	movlw	d'10'
	movwf	Pausa
	call	HacerTiempo

	;Ordena movimiento a posición concreta
	movlw	d'6'		;Servo
	movwf	ServoSvI2C
	movlw	d'180'		;posición
	movwf	PosSvI2C
	call	SetPosSvI2C

	;pausa de 10 centésimas de segundo 
	movlw	d'10'
	movwf	Pausa
	call	HacerTiempo


;-----Ciclo2-------


	;Ordena movimiento a posición concreta
	movlw	d'1'		;Servo
	movwf	ServoSvI2C
	movlw	d'200'		;posición
	movwf	PosSvI2C
	call	SetPosSvI2C

	;pausa de 10 centésimas de segundo 
	movlw	d'10'
	movwf	Pausa
	call	HacerTiempo

	;Ordena movimiento a posición concreta
	movlw	d'6'		;Servo
	movwf	ServoSvI2C
	movlw	d'10'		;posición
	movwf	PosSvI2C
	call	SetPosSvI2C

	;pausa de 10 centésimas de segundo 
	movlw	d'10'
	movwf	Pausa
	call	HacerTiempo

	goto	MLoop






;*********************************************************************************
; SUBRUTINAS
;*********************************************************************************





;-------------------------------------------------------------------------------
SetPosSvI2C		;Ordena por i2c al módulo SvI2C la actualización del registro
			;de posición del servo "ServoSvI2C" según el valor de
			;"PosSvI2C". 
;-------------------------------------------------------------------------------

	banksel	DirSlave
	movlw	DirSvI2C
	movwf	DirSlave
	movlw	SvI2CPos	;Código de registro a acceder	
	movwf	MensajeOut
	call	Send_Start	;Envía condición de inicio
	banksel	DirSlave
	call	Enviar		;Envía por I2C dirección de Slave y nº registro
	movf	ServoSvI2C,W	;Se deja el nº de servo en W para que...	
	call	Send_Byte	;...Send_Byte lo envíe por i2c
	movf	PosSvI2C,W	;Se deja el valor de posición en W para que...	
	call	Send_Byte	;...Send_Byte lo envíe por i2c
	call	Send_Stop	;Envía condición de stop
	banksel	DirSlave
	return



;-------------------------------------------------------------------------------
SetOffsetSvI2C		;Ordena por i2c al módulo SvI2C la actualización del registro
			;de Offset del servo "ServoSvI2C" según el valor de
			;"OffsetSvI2C". 
;-------------------------------------------------------------------------------

	banksel	DirSlave
	movlw	DirSvI2C
	movwf	DirSlave
	movlw	SvI2COffset	;Código de registro a acceder	
	movwf	MensajeOut
	call	Send_Start	;Envía condición de inicio
	banksel	DirSlave
	call	Enviar		;Envía por I2C dirección de Slave y nº registro
	movf	ServoSvI2C,W	;Se deja el nº de servo en W para que...	
	call	Send_Byte	;...Send_Byte lo envíe por i2c
	movf	OffsetSvI2C,W	;Se deja el valor de Offset en W para que...	
	call	Send_Byte	;...Send_Byte lo envíe por i2c
	call	Send_Stop	;Envía condición de stop
	banksel	DirSlave
	return



;-------------------------------------------------------------------------------
SetModoSvI2C		;Ordena por i2c al módulo SvI2C la actualización del registro
			;Mode que establece el sentodo de giro de los servos 
			;según el valor de "ModoSvI2C". 
;-------------------------------------------------------------------------------

	banksel	DirSlave
	movlw	DirSvI2C
	movwf	DirSlave
	movlw	SvI2CModo	;Código de registro a acceder	
	movwf	MensajeOut
	call	Send_Start	;Envía condición de inicio
	banksel	DirSlave
	call	Enviar		;Envía por I2C dirección de Slave y nº registro
	movlw	d'0'		;Se deja cualquier valor de nºDispositivo porque..	
	call	Send_Byte	;...este dato no es tomado en cuenta por Slave
	movf	ModoSvI2C,W	;Se deja el valor de Offset en W para que...	
	call	Send_Byte	;...Send_Byte lo envíe por i2c
	call	Send_Stop	;Envía condición de stop
	banksel	DirSlave
	return


;-------------------------------------------------------------------------------
ReadVerSvI2C		;Obtiene por i2c la versión de firmware del módulo SvI2C  
			;y la deja en la variable "VerSvI2C"
;-------------------------------------------------------------------------------

	banksel	DirSlave
	movlw	DirSvI2C
	movwf	DirSlave
	movlw	SvI2CVer	;Código de registro a acceder 	
	movwf	MensajeOut
	call	Send_Start	;Envía condición de inicio
	banksel	DirSlave
	call	Enviar		;Envía por I2C dirección de Slave y nº registro
	movlw	d'0'		;Se deja cualquier valor de nºDispositivo porque..	
	call	Send_Byte	;...este dato no es tomado en cuenta por Slave
	call	Send_RStart	;Envía condición de reinicio
	banksel	DirSlave
	call	Recibir		;Toma dato del Slave...
	movf	MensajeIn,W	;...y lo guarda en...
	movwf	VerSvI2C	;...la variable de registro correspondiente
	call	Send_Stop	;Envía condición de stop
	banksel	DirSlave

	return



;-------------------------------------------------------------------------------
ReadAnalogSvI2C		;Obtiene por i2c el valor digital (8bits) de la señal analógica
			;presente en el puerto "APortSvI2C" del módulo SvI2C y lo
			;deja en "AnalogSvI2C"
;-------------------------------------------------------------------------------

	banksel	DirSlave
	movlw	DirSvI2C
	movwf	DirSlave
	movlw	SvI2CAnalog	;Código de registro a acceder  	
	movwf	MensajeOut
	call	Send_Start	;Envía condición de inicio
	banksel	DirSlave
	call	Enviar		;Envía por I2C dirección de Slave y nº registro
	movf	APortSvI2C,W	;Se envía el número de puerto analógico..	
	call	Send_Byte	;...a leer del slave
	call	Send_RStart	;Envía condición de reinicio
	banksel	DirSlave
	call	Recibir		;Toma dato del Slave...
	movf	MensajeIn,W	;...y lo guarda en...
	movwf	AnalogSvI2C	;...la variable de registro correspondiente
	call	Send_Stop	;Envía condición de stop
	banksel	DirSlave

	return



;-------------------------------------------------------------------------------
init_i2c_Master		;Inicializa valores para uso de I2C en Master
			;Ha de ser llamado tras definir TRISC y un valor para
			;ClockValue. Para frecuencia SCL=Fosc/(4x(ClockValue+1))
;-------------------------------------------------------------------------------

	;Guardamos copia de algunos registros
	movwf	BkW		;Hace copia de W
	movf	STATUS,W	;Hace copia de registro de estado
	banksel	PORTA
	movwf	BkStatus

	;Configuramos I2C
	banksel TRISC		; Pasamos a direccionar Banco 1
	movlw 	b'00011000'	; Establece líneas SDA y SCL como entradas...
	iorwf 	TRISC,f		;..respetando los valores para otras líneas.
	movlw 	ClockValue 	; Establece velocidad I2C segun...
	movwf 	SSPADD 		; ...valor de ClockValue 	
	bcf 	SSPSTAT,6 	; Establece I2C input levels
	bcf 	SSPSTAT,7 	; Habilita slew rate
	banksel SSPCON 		; Pasamos a direccionar Banco 0
	movlw 	b'00111000'	; Master mode, SSP enable, velocidad segun...
	movwf 	SSPCON 		; ... Fosc/(4x(SSPADD+1))
	bcf	PIR1,SSPIF	; Limpia flag de eventos SSP
	bcf	PIR1,7		; Limpia bit. Mandatorio por Datasheet

	;Restauramos las copias de los registros
	movf	BkStatus,W	;Restaura las copias de registros
	movwf	STATUS		;registro de estado
	movf	BkW,W		;registro W

	return


; --------------------------------------------------------------------------------------
Enviar	;Envía un mensaje (comando) almacenado en "MensajeOut" al Slave cuya dirección
	;se ha de encontrarse en la variable "DirSlave"
;---------------------------------------------------------------------------------------


	;Guardamos copia de algunos registros
	movwf	BkW		;Hace copia de W
	movf	STATUS,W	;Hace copia de registro de estado
	banksel	PORTA
	movwf	BkStatus

StEnv
	banksel	DirSlave
	movf	DirSlave,W	;Dirección esclavo
	call	Send_Byte	;Envía dirección y orden de escritura
	call	WrtAckTest	;Verifica llegada ACK
	banksel SSPCON2 	
	bcf	SSPCON2,ACKSTAT	;limpia flag ACK
	xorlw	1
	btfss	STATUS,Z	;Chequea si llegó ACK
	goto	SigueEnv	;Si. Seguimos con envío dato
	call	Send_Stop	;No. Reintentamos envío
	call	Send_Start	
	goto	StEnv

SigueEnv		
	banksel MensajeOut	
	movf	MensajeOut,W	;Lo deja en W para que la subrutina Send_Byte lo envíe

	call	Send_Byte	;envía por i2c

	;Restauramos las copias de los registros
	movf	BkStatus,W	;Restaura las copias de registros
	movwf	STATUS		;registro de estado
	movf	BkW,W		;registro W

	return


; --------------------------------------------------------------------------------------
Recibir	;Solicita dato al Slave cuya dirección ha de encontrarse en la variable 
	;"DirSlave" y lo mete en "MensajeIn".
;---------------------------------------------------------------------------------------

	;Guardamos copia de algunos registros
	movwf	BkW		;Hace copia de W
	movf	STATUS,W	;Hace copia de registro de estado
	banksel	PORTA
	movwf	BkStatus

StRec	
	banksel	DirSlave
	movf	DirSlave,W	;Dirección esclavo
	iorlw	b'00000001'	;con orden de lectura
	call	Send_Byte	;Envía dirección y orden de lectura
	call	WrtAckTest	;Verifica llegada ACK
	banksel SSPCON2 	
	bcf	SSPCON2,ACKSTAT	;limpia flag ACK
	xorlw	1
	btfsc	STATUS,Z	;Chequea si llegó ACK
	goto	StRec		;No. Reintentamos envío
				;Si. Leemos dato
	call	Rec_Byte	;Recibe dato por i2c y lo mete en "MensajeIn"

	;Restauramos las copias de los registros
	movf	BkStatus,W	;Restaura las copias de registros
	movwf	STATUS		;registro de estado
	movf	BkW,W		;registro W

	return



; --------------------------------------------------------------------------------------
Send_Start	;Envía condición de start
;---------------------------------------------------------------------------------------

	banksel SSPCON2 		
	bsf 	SSPCON2,SEN 	; Envía Start
	call	CheckIdle	;Espera fin evento
	return 


; --------------------------------------------------------------------------------------
Send_RStart	;Envía condición de Repeated Start
;---------------------------------------------------------------------------------------

	banksel SSPCON2 		
	bsf 	SSPCON2,RSEN 	; Envía Repeated Start
	call	CheckIdle	;Espera fin evento
	return 


; --------------------------------------------------------------------------------------
Send_Ack	;Envía Ack
;---------------------------------------------------------------------------------------

	banksel SSPCON2 	
	bcf 	SSPCON2,ACKDT 	; acknowledge bit state to send (ack)
	bsf 	SSPCON2,ACKEN 	; Inicia secuencia de ack
	call	CheckIdle	;Espera fin evento
	return


; --------------------------------------------------------------------------------------
Send_Nack	;Envía Nack para finalizar recepción
;---------------------------------------------------------------------------------------

	banksel SSPCON2 	
	bsf 	SSPCON2,ACKDT 	; acknowledge bit state to send (not ack)
	bsf 	SSPCON2,ACKEN 	; Inicia secuencia de nack
	call	CheckIdle	;Espera fin evento
	return


; --------------------------------------------------------------------------------------
Send_Stop	;Envía condición de stop
;---------------------------------------------------------------------------------------

	banksel SSPCON2	
	bsf	SSPCON2,PEN	;Activa secuencia de stop
	call	CheckIdle	;Espera fin evento
	return				


; --------------------------------------------------------------------------------------
Send_Byte	;Envía el contenido de W por i2c
;---------------------------------------------------------------------------------------

	banksel SSPBUF 		; Cambia a banco 0
	movwf 	SSPBUF 		; inicia condicion de escritura
	call	CheckIdle	;Espera fin evento
	return	



; --------------------------------------------------------------------------------------
Rec_Byte	;Recibe dato por i2c y lo mete en "MensajeIn"
;---------------------------------------------------------------------------------------

	banksel SSPCON2 	; Cambia a banco 1
	bsf 	SSPCON2,RCEN 	; genera receive condition
	btfsc 	SSPCON2,RCEN	; espera a que llegue el dato
	goto 	$-1
	banksel SSPBUF		; Cambia a banco 0
	movf 	SSPBUF,w 	; Mueve el dato recibido ...
	movwf 	MensajeIn 	; ...  a MensajeIn
	call	CheckIdle	;Espera fin evento
	return


; --------------------------------------------------------------------------------------
CheckIdle	;Chequea que la operación anterior termino y se puede proceder con
		;el siguiente evento SSP
;---------------------------------------------------------------------------------------

	banksel SSPSTAT		; Cambia a banco 1
	btfsc 	SSPSTAT, R_W 	; Transmisión en progreso?
	goto 	$-1
	movf 	SSPCON2,W 		
	andlw 	0x1F 		; Chequeamos con mascara para ver si evento en progreso
	btfss 	STATUS, Z
	goto 	$-3 		; Sigue en progreso o bus ocupado. esperamos
	banksel PIR1		; Cambia a banco 0
	bcf 	PIR1,SSPIF	; Limpiamos flag
	return


;---------------------------------------------------------------------------------------
WrtAckTest	;Chequea ack tras envío de dirección o dato
		;Devuelve en W 0 o 1 dependiendo de si llegó (0) o no (1) ACK
;---------------------------------------------------------------------------------------

	banksel SSPCON2 	; Cambia a banco 1	
	btfss 	SSPCON2,ACKSTAT ;Chequea llegada ACK desde slave
	retlw	0		;llegó ACK
	retlw	1		;no llegó ACK


;---------------------------------------------------------------------------------------
HacerTiempo	;realiza una pausa del numero de centesimas de segundo especificadas en "Pausa"
		
;---------------------------------------------------------------------------------------

	movf	Pausa,W		;Coloca el valor de pausa en BDel2...
	movwf	BDel2		;...para no alterar su contenido
	
;............................................................
; Generado con PDEL ver SP  r 1.0  el 24/02/03 Hs 18:31:22
; Descripcion: Delay 10000 ciclos (1 centésima de segundo)
;............................................................
BCiclo  movlw     .8        ; 1 set numero de repeticion  (B)
        movwf     BDel0     ; 1 |
BLoop1  movlw     .249      ; 1 set numero de repeticion  (A)
        movwf     BDel1     ; 1 |
BLoop2  nop                 ; 1 nop   
        nop                 ; 1 ciclo delay
        decfsz    BDel1, 1  ; 1 + (1) es el tiempo 0  ? (A)
        goto      BLoop2    ; 2 no, loop
        decfsz    BDel0,  1 ; 1 + (1) es el tiempo 0  ? (B)
        goto      BLoop1    ; 2 no, loop
BDelL1  goto BDelL2         ; 2 ciclos delay
BDelL2  nop                 ; 1 ciclo delay
;............................................................
	decfsz	BDel2,F		;Repite tantas veces el ciclo de una decima de segundo...
	goto	BCiclo		;..como se lo indique ADel2
        return              ; 2+2 Fin.


END
