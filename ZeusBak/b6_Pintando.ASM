; Programa para imprimir en memoria de pantalla un caracter definido por el usuario.
; La posicion se indica mediante Fila (0 a 21) y Columna (0 a 31)

AppFilename             EQU "S8_FastPaint_UsrDefined_Char"                   ; What we're CALLed (for file generation)

AppFirst                EQU $8000                       ; First byte of code (uncontended memory)

                        zeusemulate "48K","ULA+"        ; Set the model and enable ULA+


; Start planting code here. (When generating a tape file we start saving from here)

                        org AppFirst                    ; Start of application
                        jp AppEntry

TercioSuperior          EQU  $4000                      ; direccion base de las filas 0 a 7
TercioMedio             EQU  $4800                      ; direccion base de las filas 8 a 15
TercioInferior          EQU  $5000                      ; direccion base de las fila 16 a 21
NumFila                 DEFW 0                          ; Fila en la que se imprime el caracter
NumColumna              DEFB 0                          ; Columna en la que se imprime el caracter
DirTercio               DEFW $0000                      ; direccion base en la memoria del tercio de pantalla
OffsetFila              DEFB $0                         ;
DirBaseCaracter         DW $0000                      ; direccion base en la memoria de pantalla del caracter
Cuadradito              DEFB $5A,$7E,$5A,$3C,$3C,$BD,$FF,$BD
Parrilla                DEFB $41,$7F,$41,$7F,$41,$7F,$41,$7F
Random                  DEFB $7C,$9D,$11,$0A,$F3,$BD,$BB,$FD
WhiteSnow               DEFB $00,$00,$00,$00,$00,$00,$00,$00
DirCaracterUsr          DEFW 0                          ; direccion de memoria donde empieza la definicion del caracter




AppEntry                NOP                             ;De esta forma cargamos la coordenada que queremos pintar.
                        LD HL,$05                        ;Añadimos la fila que queremos pintar en HL
                        LD (NumFila), HL                ; y lo cargamos a la "variable de fila"
                        LD HL,$04                        ;Mismo proceso con la coordenada columna.
                        LD (NumColumna), HL
                        LD HL, Cuadradito
                        LD (DirCaracterUsr), HL
                        CALL Pintar                     ;Llamamos a pintar, que pintará en la coordenada (NumFila) (Numcolumna)el caracter que comienza en (DirCaracterUsr)
                        LD HL,15                        ;Lo metemos en registro HL
                        LD (NumFila), HL                ; y lo cargamos a la "variable de fila"
                        LD HL, $10
                        LD (NumColumna), HL
                        LD HL, Random
                        LD (DirCaracterUsr), HL






Pintar                  CALL CalcDirTercio              ; Replace these lines with your code
                        CALL CalcOffSetFila             ;
                        CALL CalcByteDir                ;
                        CALL PaintChar
CalcDirTercio:                                           ; Calcula la direccion en memoria de pantalla del tercio
                                                         ; al que pertenece la fila
                        LD A,(NumFila)                   ;
                        CP 16                            ;
                        JP nc, TInf                      ; 15 < NumFila <= 22
                        CP 8
                        jp nc, TMedio
TSup                    LD HL,TercioSuperior             ;
                        LD (DirTercio),HL
                        RET
TMedio                  LD HL,TercioMedio                ;
                        LD (DirTercio),HL
                        RET
TInf                    LD HL,TercioInferior             ;
                        LD (DirTercio),HL
                        RET

CalcOffSetFila:                                          ; NumFila*$20 con NumFila entre 0 y 7
                        XOR A
                        LD (OffsetFila),A
                        LD A,(NumFila)                   ;
                        AND A,$07                        ; Nos quedamos con los tres ?ltimos bits del n?mero de fila
                        LD L,A                           ;
                        LD H,0                           ;
                                                         ; Multiplicar por $20 EQUivale a desplazar HL 5 bits a la izquierda
                        LD B,5                           ;
Bucle                   RLC L
                        DJNZ Bucle
                        LD (OffsetFila),HL
                        RET

CalcByteDir:                                             ; Calcula la direccion en memoria de pantalla del byte base
                        LD HL,(DirTercio)
                        LD DE,(OffsetFila)
                        LD D,0                           ; Solo hay que quedarse con el byte de menor peso, que es D
                        ADD HL,DE
                        LD DE,(NumColumna)
                        ADD HL,DE
                        LD (DirBaseCaracter),HL
                        RET

PaintChar:                                               ; Pinta el caracter
                        LD HL,(DirBaseCaracter)          ;
                        LD IX,(DirCaracterUsr)
                        LD A,(IX)                       ;
                        LD (HL),A                      ; Esto finalmente pinta en memoria
                        LD B,7
Otrasfilas              LD DE,$100
                        ADD HL,DE
                        INC IX
                        LD A,(IX)
                        LD (HL),A
                        DJNZ Otrasfilas
                        RET

Delay:                  LD B,$FF
Espera                  HALT
                        DJNZ Espera
                        RET


; Stop planting code after this. (When generating a tape file we save bytes below here)
AppLast                 EQU *-1                         ; The last used byte's address

; Generate some useful debugging commands

                        profile AppFirst,AppLast-AppFirst+1     ; Enable profiling for all the code

; Setup the emulation registers, so Zeus can emulate this code correctly

Zeus_PC                 EQU AppEntry                            ; Tell the emulator where to start
Zeus_SP                 EQU $FF40                               ; Tell the emulator where to put the stack

; These generate some output files

                        ; Generate a SZX file
                        output_szx AppFilename+".szx",$0000,AppEntry    ; The szx file

                        ; If we want a fancy loader we need to load a loading screen
;                        import_bin AppFilename+".scr",$4000            ; Load a loading screen

                        ; Now, also generate a tzx file using the loader
                        output_tzx AppFilename+".tzx",AppFilename,"",AppFirst,AppLast-AppFirst,1,AppEntry ; A tzx file using the loader



BucleBobo               LD A,1
                        LD (NumFila),A
                        LD A,15
                        LD (NumColumna),A
                        CALL CalcDirTercio                            ; Replace these lines with your code
                        CALL CalcOffSetFila             ;
                        CALL CalcByteDir                ;
                        LD HL,Parrilla                ; Guardar en HL la direccion de comienzo del caracter definido
                        LD (DirCaracterUsr),HL             ; Se la pasamos a la rutina por DirCaracter
                        CALL PaintChar
                        CALL Delay
                        LD A,1
                        LD (NumFila),A
                        LD A,15
                        LD (NumColumna),A
                        CALL CalcDirTercio                            ; Replace these lines with your code
                        CALL CalcOffSetFila             ;
                        CALL CalcByteDir                ;
                        LD HL,WhiteSnow                 ; Guardar en HL la direccion de comienzo del caracter definido
                        LD (DirCaracterUsr),HL             ; Se la pasamos a la rutina por DirCaracter
                        CALL PaintChar
                        CALL Delay
                        jp BucleBobo
                        ret






