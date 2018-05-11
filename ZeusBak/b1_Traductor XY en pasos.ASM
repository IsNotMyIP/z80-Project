; This is a basic template file for writing 48K Spectrum code.

AppFilename             equ "NewFile"                   ; What we're called (for file generation)

AppFirst                equ $8000                       ; First byte of code (uncontended memory)

                        zeusemulate "48K","ULA+"        ; Set the model and enable ULA+


; Start planting code here. (When generating a tape file we start saving from here)
                        org AppFirst                    ; Start of application


; Get screen address
; B = Y pixel position
; C = X pixel position
; Returns address in HL
AppEntry                LD B,7
                        LD C,10


Calculate_Pixel_Address:
                        LD A,B                          ; Calculate Y2,Y1,Y0
                        AND %00000111                   ; Mask out unwanted bits
                        OR %01000000                    ; Set base address of screen
                        LD H,A                          ; Store in H
                        LD A,B                          ; Calculate Y7,Y6
                        RRA                             ; Shift to position
                        RRA                             ;
                        RRA                             ;
                        AND %00011000                   ; Mask out unwanted bits
                        OR H                            ; OR with Y2,Y1,Y0
                        LD H,A                          ; Store in H
                        LD A,B                          ; Calculate Y5,Y4,Y3
                        RLA                             ; Shift to position
                        RLA                             ;
                        AND %11100000                   ; Mask out unwanted bits
                        LD L,A                          ; Store in L
                        LD A,C                          ; Calculate X4,X3,X2,X1,X0
                        RRA                             ; Shift into position
                        RRA                             ;
                        RRA                             ;
                        AND %00011111                   ; Mask out unwanted bits
                        OR L                            ; OR with Y5,Y4,Y3
                        LD L,A                          ; Store in L
                        RET                             ;
fin                     halt                            ; Replace these lines with your code
                        jp fin                     ;


; Stop planting code after this. (When generating a tape file we save bytes below here)
AppLast                 equ *-1                         ; The last used byte's address

; Generate some useful debugging commands

                        profile AppFirst,AppLast-AppFirst+1 ; Enable profiling for all the code

; Setup the emulation registers, so Zeus can emulate this code correctly

Zeus_PC                 equ AppEntry                    ; Tell the emulator where to start
Zeus_SP                 equ $FF40                       ; Tell the emulator where to put the stack

; These generate some output files

                        ; Generate a SZX file
                        output_szx AppFilename+".szx",$0000,AppEntry ; The szx file

                        ; If we want a fancy loader we need to load a loading screen
;                        import_bin AppFilename+".scr",$4000            ; Load a loading screen

                        ; Now, also generate a tzx file using the loader
                        output_tzx AppFilename+".tzx",AppFilename,"",AppFirst,AppLast-AppFirst,1,AppEntry ; A tzx file using the loader


