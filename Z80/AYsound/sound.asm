
; ODIN ZX Spectrum Next Z80 Assembly program
; example program to make a single beep (A above middle C)

        ORG 32768

        CALL selAY1                 ; activate AY1 and other setup
        CALL playnote               ; play music note A
        HALT                        ; wait a bit
        HALT
        HALT
        CALL stopnote               ; stop playing note
        RET                         ; return

playnote:
        LD HL, sounddata            ; point to note data
        LD E, 0                     ; AY register identifier

noteloop:
        LD D, (HL)                  ; get the note data
        LD A, E                     ; get the register identifier
        CP 14                       ; is it 14, writes complete?
        RET Z                       ; exit if so
        CALL writetoAY              ; write to AY chip
        INC HL                      ; point to next byte of note data
        INC E                       ; next register identifier
        JR noteloop                 ; and loop

stopnote:
        LD A, 8                     ; volume identifier for channel A
        LD D, 0                     ; volume value
        CALL writetoAY              ; write to AY chip and hence stop play
        RET                         ; return

writetoAY:
        LD BC, $fffd                ; turbo sound next control
        OUT (C), A                  ; write register identifier

        LD A, D                     ; get value to write
        LD BC, $bffd                ; sound chip register write
        OUT (C), A                  ; write the value
        RET                         ; return

selAY1:
        LD BC, $fffd                ; turbo sound next control
                                    ; bit 7   : always 1
                                    ; bit 6   : 1 = enable left audio
                                    ; bit 5   : 1 = enable right audio
                                    ; bit 4-2 : always 1
                                    ; bit 1-0 : 01 = AY3, 10 = AY2, 11 = AY1
        LD A, %11111111             ; as above, select AY1
        OUT (C), A

        NEXTREG $08, %00010010      ; Peripheral 3 Register
                                    ; bit 5   : AY stereo mode (0=ABC, 1=ACB)
                                    ; bit 4   : Enable internal speaker
                                    ; bit 1   : Enable Turbo Sound
        NEXTREG $09, %11100000      ; Peripheral 4 register
                                    ; bit 7   : enable AY3 mono
                                    ; bit 6   : enable AY2 mono
                                    ; bit 5   : enable AY1 mono

        RET                         ; return

sounddata:
        DB 252, 0, 0, 0, 0, 0       ; channel A,B,C tone periods
        DB 0                        ; noise period
        DB %11111110                ; mix flag, just use tone for A
        DB %00001111, 0, 0          ; channel A,B,C volume, envelope setting
        DB 0, 0, 0                  ; envelope period and shape

length EQU $ - 32768
SAVE "sound.bin", 32768, length

