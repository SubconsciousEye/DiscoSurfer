includefrom "DiscoSurfer.asm"


;; TODO: Implement option to not force-loop
;;  through all sprite slots


DATA_01A40B:                    ;$01A40B    | How close sprites need to be vertically to interact with each other.
    db $02,$0A                              ; The first is for clipping values 00, 10, 20, or 30. The second is for all others.

ShellInteractSprite:
	txy
	ldx #!SprSize-1
CODE_01A417:                    ;```````````| Main loop here.
	LDA !14C8,X               ;$01A417    |\ 
	CMP #$08                  ;$01A41A    || Don't process interaction with dead sprites; loop and move to next slot.
	BCS CODE_01A421             ;$01A41C    ||
	JMP CODE_01A4B0             ;$01A41E    |/
CODE_01A421:                    ;```````````| Checking an alive sprite.
    LDA !1686,X               ;$01A421    |\ 
;   ORA !1686,Y               ;$01A424    ||
    AND #$08                  ;$01A427    || Move to the next slot if:
    ORA !1564,X               ;$01A429    ||  - either sprite doesn't interact with other sprites
;   ORA !1564,Y               ;$01A42C    ||  - either sprite has contact temporarily disabled
    ORA !15D0,X               ;$01A42F    ||  - the sprite being interacted with is being eaten
    ORA !1632,X               ;$01A432    ||  - the sprites are on two different layers (i.e. behind scenery)
    EOR !1632,Y               ;$01A435    ||
    BNE CODE_01A4B0             ;$01A438    |/
    STX !_d5                 ;$01A43A    |
    LDA !E4,X                   ;$01A43D    |\ 
    STA !_00                     ;$01A43F    ||
    LDA !14E0,X               ;$01A441    ||
    STA !_01                     ;$01A444    ||
    LDA !E4,Y               ;$01A446    ||
    STA !_02                     ;$01A449    ||
    LDA !14E0,Y               ;$01A44B    ||
    STA !_03                     ;$01A44E    ||
    REP #$20                    ;$01A450    || Move to the next slot if the sprites aren't horizontally within a tile of each other.
    LDA !_00                     ;$01A452    ||
    SEC                         ;$01A454    ||
    SBC !_02                     ;$01A455    ||
    CLC                         ;$01A457    ||
    ADC.w #$0010                ;$01A458    ||
    CMP.w #$0020                ;$01A45B    ||
    SEP #$20                    ;$01A45E    ||
    BCS CODE_01A4B0             ;$01A460    |/
    LDY.b #$00                  ;$01A462    |\ 
    LDA.w !1662,X               ;$01A464    ||
    AND.b #$0F                  ;$01A467    ||
    BEQ CODE_01A46C             ;$01A469    ||
    INY                         ;$01A46B    ||
CODE_01A46C:                    ;           ||
    LDA !D8,X                   ;$01A46C    || 
    CLC                         ;$01A46E    ||
    ADC.w DATA_01A40B,Y         ;$01A46F    ||
    STA !_00                     ;$01A472    ||
    LDA !14D4,X               ;$01A474    ||
    ADC.b #$00                  ;$01A477    ||
    STA !_01                     ;$01A479    ||
    LDY !sprite_slot                 ;$01A47B    ||
;   LDX.b #$00                  ;$01A47E    ||
;   LDA. !1662,Y               ;$01A480    ||
;   AND.b #$0F                  ;$01A483    ||
;   BEQ CODE_01A488             ;$01A485    ||
;   INX                         ;$01A487    || Move to the next slot if the sprites aren't vertically close to each other.
;CODE_01A488:                    ;           ||  Exactly how close they need to be depends on their sprite clipping values.
    LDA !D8,Y               ;$01A488    ||
;	wdm #$06
    CLC                         ;$01A48B    ||
;   ADC.w DATA_01A40B,X         ;$01A48C    ||
	adc #$02
    STA !_02                     ;$01A48F    ||
    LDA !14D4,Y               ;$01A491    ||
    ADC.b #$00                  ;$01A494    ||
    STA !_03                     ;$01A496    ||
;   LDX !_d5                 ;$01A498    ||
    REP #$20                    ;$01A49B    ||
    LDA !_00                     ;$01A49D    ||
    SEC                         ;$01A49F    ||
    SBC !_02                     ;$01A4A0    ||
    CLC                         ;$01A4A2    ||
    ADC.w #$000C                ;$01A4A3    ||
    CMP.w #$0018                ;$01A4A6    ||
    SEP #$20                    ;$01A4A9    ||
    BCS CODE_01A4B0             ;$01A4AB    |/
    JSR CODE_01A4BA             ;$01A4AD    | Process interaction.
CODE_01A4B0:                    ;           |
    DEX                         ;$01A4B0    |\ 
    BMI CODE_01A4B6             ;$01A4B1    || Move to next slot and loop. If all slots are done, return.
	cpx !sprite_slot
	bne + : dex : +
    JMP CODE_01A417             ;$01A4B3    |/

CODE_01A4B6:                    ;```````````| Return the routine.
    LDX !sprite_slot                 ;$01A4B6    |
    RTS                         ;$01A4B9    |


CODE_01A4BA:                    ;```````````| Sprites are touching; decide what the actual interaction is.
    LDA.w !14C8,Y               ;$01A4BA    |
    CMP.b #$0A                  ;$01A4C5    |
    BEQ CODE_01A506             ;$01A4C7    |

CODE_01A4E2:                    ;```````````| Sprite A is in carryable status (09).
	LDA.w !1588,Y               ;$01A4E2    |
	AND.b #$04                  ;$01A4E5    |
	beq CODE_01A506

CODE_01A4F2:                    ;```````````| Sprite A is carryable and on the ground.
    LDA.w !14C8,X               ;$01A4F2    |
    CMP.b #$08                  ;$01A4F5    |
    BEQ CODE_01A540             ;$01A4F7    |
;   CMP.b #$09                  ;$01A4F9    |
;   BEQ CODE_01A555             ;$01A4FB    |
;   CMP.b #$0A                  ;$01A4FD    |
;   BEQ ADDR_01A53A             ;$01A4FF    |
;   CMP.b #$0B                  ;$01A501    |
;   BEQ CODE_01A534             ;$01A503    |
    RTS                         ;$01A505    |

CODE_01A506:                    ;```````````| Sprite A is in thrown status (0A).
    LDA.w !14C8,X               ;$01A506    |
    CMP.b #$08                  ;$01A509    |
;   BEQ CODE_01A52E             ;$01A50B    |
	bne +
	jmp CODE_01A625
;   CMP.b #$09                  ;$01A50D    |
;   BEQ CODE_01A531             ;$01A50F    |
;   CMP.b #$0A                  ;$01A511    |
;   BEQ CODE_01A531             ;$01A513    |
;   CMP.b #$0B                  ;$01A515    |
;   BEQ CODE_01A531             ;$01A517    |
+	cmp #$0c
	beq +
	jmp CODE_01A642
+   RTS                         ;$01A519    |


;CODE_01A52E:                    ;```````````| Sprite A is thrown (0A) and sprite B is normal (08).
;   JMP CODE_01A625             ;$01A52E    | Generally, kills sprite B.

;CODE_01A531:                    ;```````````| Sprite A is thrown (0A) and sprite B is carryable (09).
;   JMP CODE_01A642             ;$01A531    | Kills either sprite B or both sprites, depending on whether B is on the ground.

;CODE_01A534:                    ;```````````| Either sprite A or B are being carried (0B), both are thrown (0A), or sprite A is a carryable Goomba (09).
;   JMP CODE_01A685             ;$01A524    | Generally, kills both sprites.

;CODE_01A537:                    ;```````````| Sprite A is normal (08) and sprite B is thrown (0A).
;   JMP CODE_01A5C4             ;$01A537    | Generally, kills sprite A.

;ADDR_01A53A:                    ;```````````| Unused.
;   JMP CODE_01A5C4             ;$01A53A    |

;CODE_01A53D:                    ;```````````| Both sprites are in normal status (08).
;   JMP CODE_01A56D             ;$01A53D    | Bumps the two sprites off each other.



CODE_01A540:                    ;```````````| Either sprite is in normal status (08) and the other sprite is carryable (09).
;   JSR CODE_01A6D9             ;$01A540    |\ 
CODE_01A6D9:					;-----------| Subroutine to handle one sprite hopping into or kicking the other (Koopas).
;	STY !_00						;$01A6D9	|
	lda !1588,x : and #$04				;$01A6DB	|\ 
	BEQ Return01A72D			;$01A6DE	||
	LDA !1588,Y				;$01A6E0	||
	AND.b #$04					;$01A6E3	|| Return if:
	BEQ Return01A72D			;$01A6E5	||  - either sprite is not on the ground
	LDA !1656,X				;$01A6E7	||  - the sprite is not set to hop in/kick shells
	AND.b #$40					;$01A6EA	||  - either sprite is already hopping into/kicking a shell
	BEQ Return01A72D			;$01A6EC	||
;	LDA !1558,Y				;$01A6EE	||
;	ORA !1558,X				;$01A6F1	||
	lda !1558,x
	BNE Return01A72D			;$01A6F4	|/
	STZ !_02						;$01A6F6	|\ 
	LDA !E4,X					;$01A6F8	||
	SEC							;$01A6FA	||
	SBC !E4,Y				;$01A6FB	||
	BMI CODE_01A702				;$01A6FE	||
	INC !_02						;$01A700	||
CODE_01A702:					;			|| Return if the sprites aren't within half a tile of each other,
	CLC							;$01A702	||  or if the Koopa is walking away from the shell.
	ADC.b #$08					;$01A703	||
	CMP.b #$10					;$01A705	||
	BCC Return01A72D			;$01A707	||
	LDA !157C,X				;$01A709	||
	CMP !_02						;$01A70C	||
	BNE Return01A72D			;$01A70E	|/
	LDA !9E,X					;$01A710	|\ 
	CMP.b #$02					;$01A712	|| If not sprite 02 (blue Koopa), hop into the shell. Else, kick the shell.
	BNE Return01A72D			;$01A714	|/
	LDA.b #$20					;$01A716	|\ 
	STA !163E,X				;$01A718	||
	STA !1558,X				;$01A71B	||
	LDA.b #$23					;$01A71E	|| Prepare to kick the sprite; set timers and lock sprite slot for interaction.
	STA !1564,X				;$01A720	||
	TYA							;$01A723	||
	STA !160E,X				;$01A724	|/
Return01A72D:
    LDA !1558,X               ;$01A54D    ||
    ORA !1558,Y               ;$01A550    ||
    BNE Return01A5C3            ;$01A553    |/
CODE_01A555:                    ;           |
Return01A5C3:                   ;           |
    RTS                         ;$01A5C3    |

DATA_01A61E:                    ;$01A61E    | SFX for jumping on enemies in a row. Also for hits by a shell and by star power.
    db $13,$14,$15,$16,$17,$18,$19


CODE_01A625:                    ;```````````| Sprite collision: sprite A thrown into sprite B (kills sprite B in most cases).
    LDA !9E,X                   ;$01A625    |\ 
    SEC                         ;$01A627    ||
    SBC.b #$83                  ;$01A628    ||
    CMP.b #$02                  ;$01A62A    ||
    BCS CODE_01A63D             ;$01A62C    ||
;   TYX                         ;$01A62F    || If sprite B is the flying ? blocks, set misc RAM to mark as hit and clear sprite A's Y speed.
;FlipSpriteDir:					;-----------| Subroutine to change the direction of a sprite's movement.
	LDA !15AC,y				;$019098	|\ If it's already turning, return.
	BNE Return0190B1			;$01909B	|/
	LDA.b #$08					;$01909D	|\ Set the turning timer.
	STA !15AC,y				;$01909F	|/
CODE_0190A2:					;			|
	LDA !B6,y					;$0190A2	|\ 
	EOR.b #$FF					;$0190A4	||
	INC A						;$0190A6	||
	STA !B6,y					;$0190A7	|| Invert the sprite's speed.
	LDA !157C,y				;$0190A9	||
	EOR.b #$01					;$0190AC	||
	STA !157C,y				;$0190AE	|/
Return0190B1:					;			|
    LDA.b #$00                  ;$01A634    ||
    STA !AA,Y               ;$01A636    ||
;   JSR CODE_01B4E2             ;$01A639    ||
;CODE_01B4E2:					;			||
	LDA.b #$0F					;$01B4E2	||\ Disable contact with other sprites.
	STA !1564,X				;$01B4E4	||/
	LDA !C2,X					;$01B4E7	||\ 
	BNE +				;$01B4E9	|||
	INC !C2,X					;$01B4EB	||| Set the bounce timer for the sprite if it hasn't already been hit.
	LDA.b #$10					;$01B4ED	|||
	STA !1558,X				;$01B4EF	|//
+					;			|
	LDA.b #$01					;$01B4F2	|\ SFX for hitting a sprite block.
	STA $1DF9|!addr					;$01B4F4	|/
    RTS                         ;$01A63C    |/

CODE_01A63D:
;   JSR CODE_01A77C             ;$01A63D    | Handle blue Koopas catching shells and throwblocks.
;   BRA CODE_01A64A             ;$01A640    |
CODE_01A77C:					;-----------| Subroutine to handle blue Koopas catching shells and throwblocks (and some other sprites, though glitchily).
	LDA !9E,X					;$01A77C	|\ 
	CMP.b #$02					;$01A77E	||
	BNE CODE_01A7C2				;$01A780	|| Return if...
;	LDA !187B,Y				;$01A782	||  - Sprite A is not a blue Koopa.
;	BNE CODE_01A7C2				;$01A785	||  - Sprite B is a disco shell.
	LDA !157C,X				;$01A787	||  - The sprites are not moving in opposite directions (or at the very least, facing opposite directions).
	CMP !157C,Y				;$01A78A	||
	BEQ CODE_01A7C2				;$01A78D	|/
	STY !_01						;$01A78F	|
	LDY !1534,X				;$01A791	|\ Return the sprite interaction routine if the blue Koopa is already being pushed by the shell.
	BNE CODE_01A7C0				;$01A794	|/
	STZ !1528,X				;$01A796	|
	STZ !163E,X				;$01A799	|
	TAY							;$01A79C	|
	STY !_00						;$01A79D	|
	LDA !E4,X					;$01A79F	|\ 
	CLC							;$01A7A1	||
	ADC.w DATA_01A778,Y			;$01A7A2	||
	LDY !_01						;$01A7A5	||
	STA !E4,Y				;$01A7A7	|| Move the shell in front of the Koopa.
	LDA !14E0,X				;$01A7AA	||
	LDY !_00						;$01A7AD	||
	ADC.w DATA_01A77A,Y			;$01A7AF	||
	LDY !_01						;$01A7B2	||
	STA !14E0,Y				;$01A7B4	|/
	TYA							;$01A7B7	|
	STA !160E,X				;$01A7B8	|
	LDA.b #$01					;$01A7BB	|
	STA !1534,X				;$01A7BD	|
CODE_01A7C0:					;			|
;	PLA							;$01A7C0	|\ Return sprite interaction.
;	PLA							;$01A7C1	|/
	rts
CODE_01A7C2:					;			|

CODE_01A642:                    ;```````````| Sprite collision: Sprite A is thrown into a carryable sprite B.
;   lda !1588,x : and #$04      ;$01A642    |\ 
;   BNE CODE_01A64A             ;$01A645    || Kill sprite B if it's on the ground, and both sprites if not.
;   JMP CODE_01A685             ;$01A647    |/

CODE_01A64A:
    PHX                         ;$01A64A    |
    LDA !1626,Y               ;$01A64B    |\ 
    INC A                       ;$01A64E    ||
    STA !1626,Y               ;$01A64F    ||
    LDX !1626,Y               ;$01A652    || Get SFX for killing an enemy with a thrown sprite.
    CPX.b #$08                  ;$01A655    ||
    BCS CODE_01A65F             ;$01A657    ||
    LDA.w DATA_01A61E-1,X       ;$01A659    ||
    STA.w $1DF9|!addr           ;$01A65C    |/
CODE_01A65F:                    ;           |
    TXA                         ;$01A65F    |
    CMP.b #$08                  ;$01A660    |\ 
    BCC CODE_01A666             ;$01A662    ||
    LDA.b #$08                  ;$01A664    || Give corresponding points/1up.
CODE_01A666:                    ;           ||
    PLX                         ;$01A666    ||
    JSL !GivePoints              ;$01A667    |/
    LDA.b #$02                  ;$01A66B    |\ Kill sprite B.
    STA !14C8,X               ;$01A66D    |/
    JSL !DispContactSpr+3             ;$01A670    | Display a contact graphic.
    LDA !B6,Y               ;$01A674    |\ 
    ASL                         ;$01A677    ||
    LDA.b #$10                  ;$01A678    ||
    BCC CODE_01A67E             ;$01A67A    ||
    LDA.b #$F0                  ;$01A67C    || Send sprite B flying upwards and in the direction of sprite A.
CODE_01A67E:                    ;           ||
    STA !B6,X                   ;$01A67E    ||
    LDA.b #$D0                  ;$01A680    ||
    STA !AA,X                   ;$01A682    |/
    RTS                         ;$01A684    |

DATA_01A778:					;$01A778	| Low X position distances to shift a shell from a blue Koopa when it's catching one.
	db $10,$F0

DATA_01A77A:					;$01A77A	| High X position distances to shift a shell from a blue Koopa when it's catching one.
	db $00,$FF
