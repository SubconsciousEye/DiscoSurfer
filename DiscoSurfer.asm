

;; TODO: Clean up Code, fix Cape shenanigans


;; !1504 = Local Rider Flag

!_d5 = $d5		; used for backup of sprite interaction index
!_d6 = $d6		; "backup" controller byetULDR


;;;;; Surfer Defines


incsrc "DiscoDefines.asm"


;;;;; Status Pointers


print "INIT", hex(Init)
print "MAIN", hex(Main)

;print "CARRIABLE", hex(Stunned)
;print "KICKED", hex(Kicked)
;print "CARRIED", hex(Carried)

;print "MOUTH", hex(Yoshi)


;;;;; Status Codes


Init:
	inc !14C8,x
	rtl


Main:
	phb : phk : plb
CODE_0198FD:					;			|
	lda $9d : bne .nochanges
	lda !1FD6,x : beq .palchange
	dec !1FD6,x
.palchange
	LDA $13						;$0198FD	|\ 
	AND.b #$01					;$0198FF	||
	BNE .nochanges				;$019901	||
	LDA !15F6,X				;$019903	|| Cycle through the palettes every other frame.
	INC A						;$019906	||
	INC A						;$019907	||
	AND #$4F					;$019908	||
	STA !15F6,X				;$01990A	|/
.nochanges
	jsr MainSurfer
	plb
	rtl


MainSurfer:
	lda !1504,x
	beq .notsurfing
;	dec : cmp !sprite_slot : bne .notsurfing
	lda $77 : and #$0b : bne .blocked
.surfing
..controller
	ldy $0da0|!addr
	bpl + : ldy $0db3|!addr : +
;	lda $0daa|!addr,y : and #$c4
;	sta !_d6				; by---D--
;	lda $0dac|!addr,y : cmp #$80
;	and #$40 : adc #$00		; -x-----a
;	tsb !_d6				; bY---D-a
	lda $0daa|!addr,y : and #$04 : sta !_d6
	lda $0daa|!addr,y : ora #$07 : sta $0daa|!addr,y
	lda $0dac|!addr,y : ora #$30 : sta $0dac|!addr,y
..flags
	stz $13E8|!addr		; cape interact
	stz $73 : stz $140d|!addr : stz $74
	lda !14D4,x : xba : lda !D8,x
	rep #$20
	sec : sbc #$001F
	sta $d3
;	sta $96
	sep #$20
	lda !14E0,x : sta $d2 ;: sta $95
	lda !E4,x : sta $d1 ;: sta $94
;	lda #$02 : sta $1471|!addr
;	stz $1406|!addr
	lda !163E,x : sta $185c|!addr
	bra .notsurfing
.blocked
	stz !rider_flag : stz !1504,x
	stz $1470|!addr : stz $1471|!addr
.notsurfing
	lda !14C8,x ;: sta !1510,x
	eor #$08 : cmp #$04 : bcs .terminate
	asl : txy : tax
	jmp (.StatusSpoofPtr,x)
.StatusSpoofPtr
	dw StationaryShell, StationaryShell
	dw KickedShell, CarriedShell
.terminate
	rts


StationaryShell:				;-----------| Routine to handle sprites in the stationary/carryable/stunned state (sprite status 9).
	tyx
	lda #$09 : sta !14C8,x	; ensures proper status
CODE_01956A:					;```````````| Routine for all stunned sprites except springboards and P-balloons.
	LDA $9D						;$01956A	|\ 
	BEQ CODE_019571				;$01956C	|| If sprites are locked, then skip object/sprite/Mario interaction and movement.
	JMP CODE_0195F5				;$01956E	|/

CODE_019571:
	lda !1504,x
	beq .notsurfing
	lda $15 : bmi +
	inc !AA,x : inc !AA,x : +
.notsurfing
	jsl !UpdateSpritePos			;$019574	| Update X/Y position, apply gravity, and process interaction with blocks.
	lda !1588,x : and #$04				;$019577	|\ 
	BEQ CODE_019598				;$01957A	|| If the sprite is on the ground, process ground interaction.
	JSR BounceGround				;$01957C	||
CODE_01958C:					;			||
CODE_019598:					;			|
	lda !1588,x : and #$08		;$019598	|\ 
	BEQ CODE_0195DB				;$01959B	|| If the sprite hits a ceiling, send it back downwards.
	LDA #$10					;$01959D	||
	STA !AA,X					;$01959F	||
	lda !1588,x : and #$03		;$0195A1	||\ 
	BNE CODE_0195DB				;$0195A4	|||
	LDA !E4,X					;$0195A6	|||
	CLC							;$0195A8	|||
	ADC #$08					;$0195A9	|||
	STA $9A						;$0195AB	|||
	LDA !14E0,X				;$0195AD	|||
	ADC #$00					;$0195B0	|||
	STA $9B						;$0195B2	|||
	LDA !D8,X					;$0195B4	|||
	AND #$F0					;$0195B6	|||
	STA $98						;$0195B8	|||
	LDA !14D4,X				;$0195BA	||| If the sprite isn't also touching the side of a block, make it interact with the block.
	STA $99						;$0195BD	|||  i.e. this is the code that lets you actually hit a block with a carryable sprite.
	LDA !1588,X				;$0195BF	|||
	AND #$20					;$0195C2	||| Why it matters that the side isn't being touched, who knows.
	ASL							;$0195C4	|||
	ASL							;$0195C5	|||
	ASL							;$0195C6	|||
	ROL							;$0195C7	|||
	AND #$01					;$0195C8	|||
	STA $1933|!addr					;$0195CA	|||
	LDY #$00					;$0195CD	|||
	LDA $1868|!addr					;$0195CF	|||
	JSL !CODE_00F160				;$0195D2	|||
	LDA #$08					;$0195D6	|||
	STA !1FE2,X				;$0195D8	|//
CODE_0195DB:					;			|
	lda !1588,x : and #$03		;$0195DB	|\ 
	BEQ CODE_0195F2				;$0195DE	||
CODE_0195E9:					;			||
	LDA !B6,X					;$0195E9	||\ 
	ASL							;$0195EB	|||
	PHP							;$0195EC	||| Make the sprite bounce backwards from the wall at 1/4th of its speed.
	ROR !B6,X					;$0195ED	|||
	PLP							;$0195EF	|||
	ROR !B6,X					;$0195F0	|//
CODE_0195F2:					;			|
;	jsl !SprSprPMarioSprRts		;$0195F2	| Interact with Mario and other sprites.
	jsr ShellInteractSprite
	jsr MarioInteractShell
CODE_0195F5:					;			|
	LDA #$00					;$019806	|\\ Default animation frame.
	STA !1602,X				;$01980F	|/
	%SubOffScreen()		;$0195F8	| Process offscreen from -$40 to +$30.
	JSR HandleShellGfx				;$0195F5	| Draw graphics, and handle stunned sprite routines.
	lda !1504,x : beq .finish
	jmp HandleRiderPoses
.finish
	RTS							;$0195FB	|


DATA_0197AF:					;$0197AF	| Bounce speeds for carryable sprites when hitting the ground. Indexed by Y speed divided by 4.
	;db  $00, $00, $00, $F8, $F8, $F8, $F8, $F8
	;db  $F8, $F7, $F6, $F5, $F4, $F3, $F2, $E8
	;db  $E8, $E8, $E8
	db  $00, $00, $00,-$08,-$08,-$08,-$08,-$08
	db -$08,-$09,-$0a,-$0b,-$0c,-$0d,-$0e,-$18
	db -$18,-$18,-$18

BounceGround:					;-----------| Subroutine to make carryable sprites bounce when they hit the ground.
	LDA !B6,X					;$0197D5	|\ 
	PHP							;$0197D7	||
	BPL CODE_0197DD				;$0197D8	||
	eor #$ff : inc
CODE_0197DD:					;			||
	LSR							;$0197DD	|| Halve the sprite's X speed.
	PLP							;$0197DE	||
	BPL CODE_0197E4				;$0197DF	||
	eor #$ff : inc
CODE_0197E4:					;			||
	STA !B6,X					;$0197E4	|/
	LDA !AA,X					;$0197E6	|\ 
	PHA							;$0197E8	|| Set a normal ground Y speed.
;	JSR SetSomeYSpeed			;$0197E9	|/
;SetSomeYSpeed:					;-----------| Subroutine to set Y speed for a sprite when on the ground.
	LDA !1588,X				;$019A04	|\ 
	BMI CODE_019A10				;$019A07	||
	LDA #$00					;$019A09	|| 
	LDY !15B8,X				;$019A0B	|| If standing on a slope or Layer 2, give the sprite a Y speed of #$18.
	BEQ CODE_019A12				;$019A0E	|| Else, clear its Y speed.
CODE_019A10:					;			||
	LDA #$18					;$019A10	||
CODE_019A12:					;			||
	STA !AA,X					;$019A12	|/
;	RTS							;$019A14	|
	PLA							;$0197EC	|
	LSR							;$0197ED	|
	LSR							;$0197EE	|
	TAY							;$0197EF	|
CODE_0197FB:					;			|
	LDA.w DATA_0197AF,Y			;$0197FB	|\ 
	LDY !1588,X				;$0197FE	|| Get the Y speed to make the sprite bounce at when it hits the ground.
	BMI Return019805			;$019801	||
	STA !AA,X					;$019803	|/
Return019805:					;			|
	RTS							;$019805	|


KickedShell:
	tyx
CODE_019928:					;```````````| Kicked shell MAIN (see other main for misc ram; this routine also includes Buzzy Beetle shells and throwblocks)
	LDA !1528,X				;$019928	|\ 
	BNE CODE_019939				;$01992B	||
	LDA !B6,X					;$01992D	||
	CLC							;$01992F	|| If not being caught by a Koopa, return the shell to carryable state if it somehow slows down enough.
	ADC #$20					;$019930	||  (how to do this, though, is a mystery)
	CMP #$40					;$019932	||
	BCS CODE_019939				;$019934	||
	JSR CODE_01AA0B				;$019936	|/
CODE_019939:					;			|
	STZ !1528,X				;$019939	|
	LDA $9D						;$01993C	|\ 
;	ORA !163E,X				;$01993E	|| If sprites are frozen or (?) is happening, just draw graphics.
	BEQ CODE_019946				;$019941	||
	JMP CODE_01998F				;$019943	|/

CODE_019946:
;	JSR UpdateDirection			;$019946	|
;UpdateDirection:				;-----------| Subroutine to update a sprite's direction based on its current X speed.
	LDA #$00					;$019A15	|
	LDY !B6,X					;$019A17	|
	BEQ Return019A21			;$019A19	|
	BPL CODE_019A1E				;$019A1B	|
	INC						;$019A1D	|
CODE_019A1E:					;			|
	STA !157C,X				;$019A1E	|
Return019A21:					;			|
	lda !1504,x
	beq .notsurfing
	lda $15 : bmi +
	inc !AA,x : inc !AA,x : +
.notsurfing
	LDA !15B8,X				;$019949	|
	PHA							;$01994C	|
	jsl !UpdateSpritePos			;$01994D	| Update X/Y position, apply gravity, and process interaction with blocks.
	PLA							;$019950	|
	BEQ CODE_019969				;$019951	|\ 
	STA !_00						;$019953	||
	LDY !164A,X				;$019955	||
	BNE CODE_019969				;$019958	||
	CMP !15B8,X				;$01995A	|| If the sprite has just gone onto a slope, is not in water, and is moving faster than the slopes's angle,
	BEQ CODE_019969				;$01995D	||  then make it "bounce" slightly off the slope.
	EOR !B6,X					;$01995F	||
	BMI CODE_019969				;$019961	||
	LDA #$F8					;$019963	||
	STA !AA,X					;$019965	||
	BRA CODE_019975				;$019967	|/

CODE_019969:
	lda !1588,x : and #$04				;$019969	|\ 
	BEQ CODE_019984				;$01996C	|| If on the ground, set its Y speed to 10. (useless JSR)
	;JSR SetSomeYSpeed			;$01996E	||
;	LDA #$10					;$019971	|| [Change to #$0C to make it never fall in one-tile gaps, and #$28 to make it always (#$19 if not sprinting)]
;	wdm #$09
	lda #$0e
	STA !AA,X					;$019973	|/
	lda !1504,x : beq CODE_019975
	lda !1528,x : bne CODE_019975
	lda $16 : bpl CODE_019975
	lda #$b0 : sta !AA,x ;: sta $1406|!addr
	bra CODE_019984
CODE_019975:					;			|
	LDA $1860|!addr					;$019975	|\ 
	CMP #$B5					;$019978	||
	BEQ CODE_019980				;$01997A	||
	CMP #$B4					;$01997C	|| If the shell hits a purple triangle, send it flying in the air.
	BNE CODE_019984				;$01997E	||
CODE_019980:					;			||
	LDA #$B8					;$019980	||| Y speed to give the shell.
;	lda #$a8
	STA !AA,X					;$019982	|/
CODE_019984:					;			|
	lda !1588,x : and #$03		;$019984	|\ 
	BEQ CODE_01998C				;$019987	|| If it hits the side of a block, handle interaction with it.
;	JSR CODE_01999E				;$019989	|/
;CODE_01999E:					;-----------| Subroutine for thrown sprites interacting with the sides of blocks.
	LDA #$01					;$01999E	|\ SFX for hitting a block with any sprite.
	STA $1DF9|!addr					;$0199A0	|/
;	JSR CODE_0190A2				;$0199A3	| Invert the sprite's X speed.
;CODE_0190A2:					;			|
	LDA !B6,X					;$0190A2	|\ 
	EOR #$FF					;$0190A4	||
	INC						;$0190A6	||
	STA !B6,X					;$0190A7	|| Invert the sprite's speed.
	LDA !157C,X				;$0190A9	||
	EOR #$01					;$0190AC	||
	STA !157C,X				;$0190AE	|/
	lda !1504,x : beq +
	lda #01 : sta $185c|!addr : sta !163E,x
+	
;Return0190B1:					;			|
	LDA !15A0,X				;$0199A6	|\ 
	BNE CODE_0199D2				;$0199A9	||
	LDA !E4,X					;$0199AB	||
	SEC							;$0199AD	||
	SBC $1A						;$0199AE	||
	CLC							;$0199B0	||
	ADC #$14					;$0199B1	||
	CMP #$1C					;$0199B3	||
	BCC CODE_0199D2				;$0199B5	||
	LDA !1588,X				;$0199B7	|| If it's far enough on-screen, make it actually interact with the block.
	AND #$40					;$0199BA	||  i.e. this is the code that lets you actually hit a block with a thrown sprite.
	ASL							;$0199BC	||
	ASL							;$0199BD	||
	ROL							;$0199BE	||
	AND #$01					;$0199BF	||
	STA $1933|!addr					;$0199C1	||
	LDY #$00					;$0199C4	||
	LDA $18A7|!addr					;$0199C6	||
	JSL !CODE_00F160				;$0199C9	||
	LDA #$05					;$0199CD	||
	STA !1FE2,X				;$0199CF	|/
CODE_0199D2:					;			|
;	RTS							;$0199DB	|
CODE_01998C:					;			|
;	jsl !SprSprPMarioSprRts		;$01998C	| Process interaction with Mario and other sprites.
	jsr ShellInteractSprite
	jsr MarioInteractShell
CODE_01998F:					;			|
	lda #$00 : %SubOffScreen()		;$01998F	| Process offscreen from -$40 to +$30.
;	JMP SpinningShellFrame				;$019998	||  Else, draw shell graphics.
;SpinningShellFrame:					;-----------| Subroutine to draw a spinning shell's graphics.
	LDA !C2,X					;$019A2A	|
	STA !1558,X				;$019A2C	|
	LDA $14						;$019A2F	|\ 
	LSR							;$019A31	||
	LSR							;$019A32	||
	AND #$03					;$019A33	||
	sta !1602,x
	jsr HandleShellGfx
	STZ !1558,X
	lda !1504,x : beq .finish
	jmp HandleRiderPoses
.finish
	RTS							;$019A4D	|


CODE_01AA0B:					;			||  If $C2 is non-zero or the sprite is coming from status 08, then also set the stun timer.
	LDA !C2,X					;$01AA0B	||
	BNE SetStunnedTimer			;$01AA0D	||
	STZ !1540,X				;$01AA0F	||
	BRA SetAsStunned			;$01AA12	|/

SetStunnedTimer:
	LDa #$FF					;$01AA28	| How long to stun the four above sprites for when kicked/hit.
	STA !1540,X				;$01AA2A	|
SetAsStunned:					;			|
	LDA #$09					;$01AA2D	|\ Change to stationary/carryable status.
	STA !14C8,X				;$01AA2F	|/
	RTS							;$01AA32	|


CarriedShell:				;-----------| Routine to handle carried sprites (sprite status B).
	tyx
	JSR CODE_019F9B				;$019F71	| Run specific sprite routines.
	lda !1504,x : beq +
	stz $149A|!addr : stz $1498|!addr
+	LDA $13DD|!addr					;$019F74	|\ 
	BNE CODE_019F83				;$019F77	||
	LDA $1419|!addr					;$019F79	||
	BNE CODE_019F83				;$019F7C	|| If turning while sliding, going down a pipe, or otherwise facing the screen,
	LDA $1499|!addr					;$019F7E	||  center the item on Mario, and change OAM index to #00.
	BEQ CODE_019F86				;$019F81	||  (to make it go in front of Mario).
CODE_019F83:					;			||
	STZ !15EA,X				;$019F83	|/
CODE_019F86:					;			|
	LDA $64						;$019F86	|\ 
	PHA							;$019F88	||
	LDA $1419|!addr					;$019F89	|| If going down a pipe, send behind objects.
	BEQ CODE_019F92				;$019F8C	||
	LDA #$10					;$019F8E	||
	STA $64						;$019F90	|/
CODE_019F92:					;			|
	LDA #$00					;$019806	|\\ Default animation frame.
	LDY !15EA,X				;$019808	||
	BNE +				;$01980B	||
	LDA #$02					;$01980D	||| Animation frame when turning while Mario is holding it.
+	STA !1602,X				;$01980F	|/
	JSR HandleShellGfx				;$019F92	| Draw graphics and handle basic routines.
	PLA							;$019F95	|
	STA $64						;$019F96	|
	lda !1504,x : beq +
	phx
	jsl $00E2BD|!bank		;redraw player
	plx : +
	RTS							;$019F98	|

DATA_019F5B:					;$019F5B	| X low position offsets for sprites from Mario when carrying them.
	db  $0B,-$0B, $04,-$04, $04, $00				; Right, left, turning (< 1), turning (< 2, > 1), turning (> 2), centered.

DATA_019F61:					;$019F61	| X high position offsets for sprites from Mario when carrying them.
	db  $00,-$01, $00,-$01, $00, $00

DATA_019F67:					;$019F67	| X low byte offsets from Mario to drop sprites at.
	db -$0D, $0D
DATA_019F69:					;$019F69	| X high byte offsets from Mario to drop sprites at.
	db -$01, $00

KickSpeedX:						;$019F6B	| Base X speeds for carryable sprites when kicked/thrown.
	db -$2E, $2E,-$34, $34						; Third and fourth bytes are when spit out by Yoshi.

DATA_019F99:					;$019F99	| Base X speeds for carryable sprites when dropped.
	db -$04, $04

CODE_019F9B:					;```````````| Running carryable-sprite-specific routines; first up is P-balloon.
CODE_019FE0:					;```````````| Carrying sprite other than P-balloon (i.e. actually carrying something).
	jsl !CODE_019138				;$019FE0	| Handle interaction with blocks.
	LDA $71						;$019FE3	|\ 
	CMP #$01					;$019FE5	||
	BCC CODE_019FF4				;$019FE7	||
	LDA $1419|!addr					;$019FE9	|| If Mario let go of it (not thrown), return to stationary status.
	BNE CODE_019FF4				;$019FEC	||
	LDA #$09					;$019FEE	||
	STA !14C8,X				;$019FF0	||
	RTS							;$019FF3	|/

CODE_019FF4:
	LDA !14C8,X				;$019FF4	|\ 
	CMP #$08					;$019FF7	|| If the sprite returned to normal status (e.g. Goombas un-stunning), return.
	BEQ Return01A014			;$019FF9	|/
	LDA $9D						;$019FFB	|\ 
	BEQ CODE_01A002				;$019FFD	|| If the game is frozen, just handle offset from Mario.
	JMP CODE_01A0B1				;$019FFF	|/

CODE_01A002:
;	JSR CODE_019624				;$01A002	| Handle stun timer routines.
;	jsl !SprSprInteract		;$01A005	| Handle interaction with other sprites.
	LDA $1419|!addr					;$01A008	|\ 
	BNE CODE_01A011				;$01A00B	||
	BIT $15						;$01A00D	|| If X/Y are held or Mario is going down a pipe, offset the sprite from his position.
	BVC CODE_01A015				;$01A00F	||  Else, branch to let go of the sprite.
CODE_01A011:					;			||
	jmp CODE_01A0B1				;$01A011	|/
Return01A014:					;			|
	RTS							;$01A014	|



CODE_01A015:					;```````````| Subroutine to handle letting go of a sprite.
	STZ !1626,X				;$01A015	|
	LDY #$00					;$01A018	|\\ Base Y speed to give sprites when kicking them.
CODE_01A026:					;			||
	STY !AA,X					;$01A026	|/
	LDA #$09					;$01A028	|\ Return to carryable status. 
	STA !14C8,X				;$01A02A	|/
	LDA $15						;$01A02D	|\ 
	AND #$08					;$01A02F	|| Branch if holding up.
	BNE .redirect01A068				;$01A031	|/
	LDA $15						;$01A039	||
	AND #$04					;$01A03B	|| If not a Goomba or shell, don't kick by default.
	BEQ .redirect01A079				;$01A03D	|| If holding down, never kick.
	;BRA CODE_01A047				;$01A03F	|| If holding left/right and not down, always kick.
;	lda $7b : bpl + : eor #$ff : inc : +
;	cmp #$18 : bcc CODE_01A047
.checkride
	lda !1FD6,x : bne Return01A014
;	lda $7b : clc : adc #$20-1
;	cmp #$40-1 : bcc CODE_01A047
	lda $7b : bpl + : eor #$ff : inc
+	cmp #$1c : bcc CODE_01A047
	lda $76 : lsr : ror
	eor $7b : bpl CODE_01A047
.setrider
	lda $7d : sta !AA,x
	txa : inc : sta !1504,x : sta !rider_flag
	stz $1499|!addr : stz $13DD|!addr
	stz $73 : stz $140d|!addr
	stz $149a|!addr : stz $13e8|!addr
	lda #$01 : sta $1471|!addr
;	lda #$24 : sta $72
.riderposition
	lda !14D4,x : xba : lda !D8,x
	rep #$20
	sec : sbc #$001F
	sta $96
	sta $d3
	sep #$20
	lda !14E0,x : sta $95 : sta $d2
	lda !E4,x : sta $94 : sta $d1
.redirect01A079
	bra CODE_01A079
.redirect01A068
	bra CODE_01A068

CODE_01A047:					;```````````| Gently dropping a sprite (holding down, or release a non-shell/goomba sprite).
	LDY $76						;$01A047	|\ 
	LDA $D1						;$01A049	||
	CLC							;$01A04B	||
	ADC.w DATA_019F67,Y			;$01A04C	|| Fix offset from Mario (in case of turning).
	STA !E4,X					;$01A04F	||
	LDA $D2						;$01A051	||
	ADC.w DATA_019F69,Y			;$01A053	||
	STA !14E0,X				;$01A056	|/
	ldy #$00
	lda $d1
	sec : sbc !E4,x
	sta !_0f
	lda $d2 : sbc !14E0,x
	bpl + : iny
+	LDA.w DATA_019F99,Y			;$01A05C	||
	CLC							;$01A05F	|| Set X speed.
	ADC $7B						;$01A060	||
	STA !B6,X					;$01A062	|/
	STZ !AA,X					;$01A064	|
	BRA CODE_01A0A6				;$01A066	|


CODE_01A068:					;```````````| Kicking a sprite upwards (holding up).
	JSL !DispContactSpr			;$01A068	|
	LDA #$90					;$01A06C	|\\ Y speed to give sprites kicked upwards.
	STA !AA,X					;$01A06E	|/
	LDA $7B						;$01A070	|\ 
	STA !B6,X					;$01A072	|| Give the sprite half Mario's speed.
	ASL							;$01A074	||
	ROR !B6,X					;$01A075	|/
	BRA CODE_01A0A6				;$01A077	|


CODE_01A079:					;```````````| Kicking a sprite sideways (holding left/right, or releasing a shell/Goomba).
	JSL !DispContactSpr			;$01A079	|
	LDA !1540,X				;$01A07D	|
	STA !C2,X					;$01A080	|
	LDA #$0A					;$01A082	|\ Set thrown status. 
	STA !14C8,X				;$01A084	|/
	LDY $76						;$01A087	|\ 
	LDA $187A|!addr					;$01A089	||
	BEQ CODE_01A090				;$01A08C	||
	INY							;$01A08E	||
	INY							;$01A08F	||
CODE_01A090:					;			||
	LDA.w KickSpeedX,Y			;$01A090	||
	STA !B6,X					;$01A093	|| Set X speed to throw the sprite at; take base speed, and add half Mario's speed if moving in the same direction as him.
	EOR $7B						;$01A095	||  For whatever reason, if Mario is throwing the item while on Yoshi, the base speed will be faster.
	BMI CODE_01A0A6				;$01A097	||  (not that you can do that without a glitch...)
	LDA $7B						;$01A099	||
;	STA !_00						;$01A09B	||
;	ASL !_00						;$01A09D	||
	bpl + : inc : + cmp #$80
	ROR							;$01A09F	||
	and #$fc
	CLC							;$01A0A0	||
	ADC.w KickSpeedX,Y			;$01A0A1	||
	STA !B6,X					;$01A0A4	|/
CODE_01A0A6:					;			|
	LDA #$10					;$01A0A6	|\\ Number of frames to disable contact with Mario for when kicking any carryable sprite.
	STA !154C,X				;$01A0A8	|/
	LDA #$0C					;$01A0AB	|\ Show Mario's kicking pose.
	STA $149A|!addr					;$01A0AD	|/
	RTS							;$01A0B0	|


	; Scratch RAM usage and output:
	; $00 - Mario X position, low
	; $01 - Mario X position, high
	; $02 - Mario Y position, low
	; $03 - Mario Y position, high

CODE_01A0B1:					;-----------| Subroutine to offset a carryable sprite from Mario's position.
	LDY #$00					;$01A0B1	|\ 
	LDA $76						;$01A0B3	|| Get 0 = right, 1 = left.
	BNE CODE_01A0B8				;$01A0B5	||
	INY							;$01A0B7	|/
CODE_01A0B8:					;			|
	LDA $1499|!addr					;$01A0B8	|\ 
	BEQ CODE_01A0C4				;$01A0BB	||
	INY							;$01A0BD	||
	INY							;$01A0BE	|| Set Y = 2/3 or 3/4 when turning.
	CMP #$05					;$01A0BF	||
	BCC CODE_01A0C4				;$01A0C1	||
	INY							;$01A0C3	|/
CODE_01A0C4:					;			|
	LDA $1419|!addr					;$01A0C4	|\ 
	BEQ CODE_01A0CD				;$01A0C7	||
	CMP #$02					;$01A0C9	||
	BEQ CODE_01A0D4				;$01A0CB	||
CODE_01A0CD:					;			|| If turning while sliding, going down a vertical pipe, or climbing, set Y = 5.
	LDA $13DD|!addr					;$01A0CD	||
	ORA $74						;$01A0D0	||
	BEQ CODE_01A0D6				;$01A0D2	||
CODE_01A0D4:					;			||
	LDY #$05					;$01A0D4	|/
CODE_01A0D6:					;			|
	PHY							;$01A0D6	|
	LDY #$00					;$01A0D7	|\ 
	LDA $1471|!addr					;$01A0D9	||
	CMP #$03					;$01A0DC	||
	BEQ CODE_01A0E2				;$01A0DE	||
	LDY #$3D					;$01A0E0	||
CODE_01A0E2:					;			||
	LDA $94,Y					;$01A0E2	|| Decide whether to use Mario's position on the next frame, 
	STA !_00						;$01A0E5	||  or if on a revolving brown platform, current frame.
	LDA $95,Y					;$01A0E7	||
	STA !_01						;$01A0EA	||
	LDA $96,Y					;$01A0EC	||
	STA !_02						;$01A0EF	||
	LDA $97,Y					;$01A0F1	||
	STA !_03						;$01A0F4	|/
	PLY							;$01A0F6	|
	LDA !_00						;$01A0F7	|\ 
	CLC							;$01A0F9	||
	ADC.w DATA_019F5B,Y			;$01A0FA	||
	STA !E4,X					;$01A0FD	|| Offset horizontally from Mario.
	LDA !_01						;$01A0FF	||
	ADC.w DATA_019F61,Y			;$01A101	||
	STA !14E0,X				;$01A104	|/
	LDA #$0D					;$01A107	|\\ Y offset when big.
	LDY $73						;$01A109	||
	BNE CODE_01A111				;$01A10B	||
	LDY $19						;$01A10D	|| Offset vertically from Mario.
	BNE CODE_01A113				;$01A10F	||
CODE_01A111:					;			||
	LDA #$0F					;$01A111	||| Y offset when ducking or small.
CODE_01A113:					;			||
	LDY $1498|!addr					;$01A113	||
	BEQ CODE_01A11A				;$01A116	||
	LDA #$0F					;$01A118	||| Y offset when picking up an item.
CODE_01A11A:					;			||
	CLC							;$01A11A	||
	ADC !_02						;$01A11B	||
	STA !D8,X					;$01A11D	||
	LDA !_03						;$01A11F	||
	ADC #$00					;$01A121	||
	STA !14D4,X				;$01A123	|/
	LDA #$01					;$01A126	|\ 
	STA $148F|!addr					;$01A128	|| Set the flag for carrying an item.
	STA $1470|!addr					;$01A12B	|/
	RTS							;$01A12E	|





;; one big pile of spaghet
MarioInteractShell:
	lda !1504,x : beq .normalcheck
	lda !1FD6,x : bne .quickreturn
	lda !1588,x : and #$04 : eor #$04 : sta $1406|!addr
;	lda !_d6 : lsr : bcs .eject
	lda $18 : bmi .eject
	ora $16 : ora !_d6 : and #$44		; pressing down
	beq .quickreturn
	cmp #$44 : bne .quickreturn
;	bit $16 : bvc .quickreturn
	lda #$19 : sta !1FD6,x
	stz $185c|!addr
	rts
.eject
	lda #$b0 : sta $7d
	stz $7a
	lda !B6,x : bpl +
	inc			; ensure #$ff turns into #$00
+	cmp #$80 : ror : sta $7b
	stz !rider_flag : stz !1504,x
	stz $1470|!addr : stz $1471|!addr
	stz $148f|!addr : inc $140d|!addr
;	stz $185c|!addr
	lda #$10 : sta !154C,x
.quickreturn
	rts
.normalcheck
	jsl !MarioSprInteract
	bcc .nointeract
.interact
	lda !154C,x : ora !1FD6,x : bne .nointeract
;	lda !14C8,x : cmp #$0a : beq .kickedinteract
	LDA $15						;$01AA58	|\ 
	AND.b #$40					;$01AA5A	||
	BEQ .bouncecheck				;$01AA5C	||
	LDA.w $1470|!addr					;$01AA5E	|| If...
	ORA.w $187A|!addr					;$01AA61	||  - X and Y are held
	BNE .bouncecheck				;$01AA64	||  - Mario is not carrying something or riding Yoshi
	lda !14C8,x : cmp #$0a : bne +
	lda !157C,x : cmp $76 : bne .bouncecheck
+	LDA.b #$0B					;$01AA66	|| Then have Mario pick up the sprite and return.
	STA.w !14C8,X				;$01AA68	||
	INC.w $1470|!addr					;$01AA6B	||
	LDA.b #$08					;$01AA6E	||
	STA.w $1498|!addr					;$01AA70	||
.nointeract
	RTS							;$01AA73	|/
.bouncecheck
;	LDA.b #$14					;$01A897	|\\ Distance above the sprite that Mario's position must be to be considered on "top" of it.
;	wdm #$03
	lda #$18
;	lda #$1c
	STA !_01						;$01A899	||   (increasing this value = smaller safe space)
	LDA !_05						;$01A89B	||
	SEC							;$01A89D	||
	SBC !_01						;$01A89E	||
	ROL !_00						;$01A8A0	||
	CMP $D3						;$01A8A2	||
	PHP							;$01A8A4	||
	LSR !_00						;$01A8A5	||
	LDA !_0b						;$01A8A7	||
	SBC.b #$00					;$01A8A9	|| Branch to .kickcheck if:
	PLP							;$01A8AB	||  - Too low to bounce off the sprite (Y position greater than the sprite's).
	SBC $D4						;$01A8AC	||  - Moving upward, the sprite can't be hit while moving upwards,
	BMI .kickcheck				;$01A8AE	||     and Mario hasn't hit any other enemies.
	LDA.b #$02					;$01A8D8	|\ SFX for spinjumping off an enemy that can't be bounced on.
	STA.w $1DF9|!addr					;$01A8DA	|/  Also used for bouncing off of disco shells.
	LDA $74						;$01AA33	|\ If climbing, don't bounce.
	BNE .nobounceclimb			;$01AA35	|/
	LDA.b #$D0					;$01AA37	|\\ Speed Mario bounces off of an enemy without A being pressed.
	BIT $15						;$01AA39	||
	BPL .mariobounce				;$01AA3B	||
	LDA.b #$A8					;$01AA3D	||| Speed Mario bounces off of an enemy with A pressed.
.mariobounce					;			||
	STA $7D						;$01AA3F	|/
.nobounceclimb
	lda $1697|!addr : bne + : inc $1697|!addr
;	JSL DispContactMario		;$01A8E1	|
+	jsl $01AB99|!bank		;DispContactMario
	stz !1626,x
	lda !14C8,x : cmp #$0a : bne .bouncekick
	jmp CODE_01AA0B
.nobouncekick
	RTS							;$01A8E5	|
.kickcheck
;CODE_01AA97:					;```````````| Touching a Bob-Omb, Baby Yoshi, Goomba, or MechaKoopa.
	lda !14C8,x : cmp #$0a : beq .nobouncekick
.bouncekick
	lda #$03 : sta $1DF9|!addr				;$01AA97	|
	LDA.w !1540,X				;$01AA9A	|
	STA !C2,X					;$01AA9D	|
	LDA.b #$0A					;$01AA9F	|\ Set kicked status.
	STA.w !14C8,X				;$01AAA1	|/
	LDA.b #$10					;$01AAA4	|\ Disable contact with Mario for 16 frames.
	STA.w !154C,X				;$01AAA6	|/
	ldy #$00
	lda $d1
	sec : sbc !E4,x
	sta !_0f
	lda $d2 : sbc !14E0,x
	bpl + : iny
+	LDA.w KickSpeedX,Y			;$01AAAC	|\ Set the sprite's X speed.
	STA !B6,X					;$01AAAF	|/
	RTS							;$01AAB1	|


incsrc "DiscoInteract.asm"


GlitterSpawner:
	lda $13 : and.b #$03
;	ora $9d			; goalsphere does this
	phk
	pea.w .rtrn-1
	pea.w $8020		; bank 1 rtl
	jml $01b152|!bank	;glitter routine
.rtrn
	rts


HandleShellGfx:
;; Inlined GetDrawInfo
;;  If we can draw, we skip over an rts to continue.
;;  Otherwise, we insta-terminate ourselves.
	STZ !186C,x
	LDA !14E0,x
	XBA
	LDA !E4,x
	REP #$20
	SEC : SBC $1A
	STA !_00
	CLC
	ADC.w #$0040
	CMP.w #$0180
	SEP #$20
	LDA !_01
	BEQ +
	LDA #$01
+	STA !15A0,x
   ; in sa-1, this isn't #$000
   ; this actually doesn't matter
   ; because we change A and B to different stuff
	TDC
	ROL A
	STA !15C4,x
	beq .ValidDraw
	rts
.ValidDraw
	LDA !14D4,x
	XBA
	LDA !D8,x
	REP #$21
	ADC.w #$0010
	SEC : SBC $1C
	SEP #$21
	SBC #$10
	STA !_01
	XBA
	BEQ .OnScreenY
	INC !186C,x
.OnScreenY
DrawShell:
	ldy !157C,x
	lda.w ShellFacing,y
	sta !_02
	ldy !1602,x
	lda.w ShellTilemap,y
	xba : lda.w ShellProps,y
	eor !_02 : ora !15F6,x : ora $64
	ldy !15EA,x
	sta !oam1_props,y : xba
	sta !oam1_tile,y
	lda !_00 : sta !oam1_ofsX,y
	lda !_01 : sta !oam1_ofsY,y
	ldy #$02		; force 16x16
	lda #$00		; one tile
	%FinishOAMWrite()
	rts

ShellFacing:
	db $40,$00
ShellTilemap:
	db $8c,$8a,$8e,$8a
ShellProps:
	db $80,$80,$80,$c0

MarioFacing:
.small
	db 1,1
	db 1,0
	db 0,0
	db 0,1
;.big
;	db 1,1
;	db 1,0
;	db 0,0
;	db 0,1
MarioSpin:
.small
	db $00,$00
	db $25,$0f
	db $00,$00
	db $0f,$25
;.big
;	db $00,$00
;	db $44,$45
;	db $00,$00
;	db $45,$44

HandleRiderPoses:
	lda $71 : beq .marioposes
	jmp .position
.marioposes
	lda !1FD6,x : beq .nopickup
	dec : beq .noejectrider
	stz $7d
	lda !AA,x : bpl + : sta $7d : +
;	lda !B6,x : bpl +
;	inc			; ensure #$ff turns into #$00
;+	cmp #$80 : ror : sta $7b
	lda !B6,x : sta $7b
	stz $7a
	stz !rider_flag : stz !1504,x
	stz $1470|!addr : stz $148f|!addr
;	stz $185c|!addr
	lda #$0b : sta !14C8,x
.noejectrider
	lda !157C,x : sta $76
	lda #$3a : bra .storepose
.nopickup
	lda $14 : and #$06
	ora !157C,x
;	ldy $19 : beq +
;	ora #$08
;+
	tay
	lda.w MarioFacing,y
	sta $76
	lda.w MarioSpin,y
.storepose
	sta $13e0|!addr
	stz $13df|!addr
.position
	lda !14D4,x : xba : lda !D8,x
	rep #$20
	sec : sbc #$001F
	sta $96
	sep #$20
	lda !14E0,x : sta $95
	lda !E4,x : sta $94
	phx
	jsl $00E2BD|!bank
	plx
	stz $7d
.spawnglitter
	jmp GlitterSpawner
