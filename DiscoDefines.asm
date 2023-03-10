includefrom "DiscoSurfer.asm"

;;; True + False defines
;;;  do not change, ever

!True ?= 1
!False ?= 0

;; Global Rider Flag RAM
;;  change from $1879 to $188A
;;  if you want to force eject
;;  if the rider takes damage.
;; Recommended to be in wordram


	!rider_flag		= $1879|!addr


;;; Misc Defines


;; JSL Names


!GetRand = $01ACF9|!bank
!ZeroSpriteTables = $07F722|!bank
!SetSpriteTables = $0187A7|!bank		;PIXI
;!SubSprYPosNoGrvty = $01801A|!bank
!UpdateYPosNoGrvty = $01801A|!bank
;!SubSprXPosNoGrvty = $018022|!bank
!UpdateXPosNoGrvty = $018022|!bank
;!SubUpdateSprPos = $01802A|!bank
!UpdateSpritePos = $01802A|!bank
;MarioSprInteractRt = $01A7DC|!bank
!MarioSprInteract = $01A7DC|!bank
;SubSprSprInteract = $018032|!bank
!SprSprInteract = $018032|!bank
;SubSprSprPMarioSpr = $01803A|!bank
!SprSprPMarioSprRts = $01803A|!bank
!GetMarioClipping = $03B664|!bank
!GetSpriteClippingA = $03B69F|!bank
!GetSpriteClippingB = $03B6E5|!bank
!CheckForContact = $03B72B|!bank
!GivePoints = $02ACE5|!bank
!FindFreeSprSlot = $02A9E4|!bank
!InitSpriteTables = $07F7D2|!bank
!DispContactSpr = $01AB6F|!bank
!CODE_00F160 = $00F160|!bank
!CODE_019138 = $019138|!bank


;; Current Sprite Slot
;;  Why PIXI didn't have this be
;;  a define is anybody's guess.


	!sprite_slot	?=	$15e9|!addr


;; OAM Shenanigans
;;  Slightly based on
;;  Daiyousei's naming


	!oam1_ofsX		?=	$0300|!addr
	!oam1_ofsY		?=	$0301|!addr
	!oam1_tile		?=	$0302|!addr
	!oam1_props		?=	$0303|!addr

	!oam0_ofsX		?=	$0200|!addr
	!oam0_ofsY		?=	$0201|!addr
	!oam0_tile		?=	$0202|!addr
	!oam0_props		?=	$0203|!addr

	!oam1_bitSizes	?=	$0410|!addr
	!oam0_bitSizes	?=	$0400|!addr
	!oam1_sizes		?=	$0460|!addr
	!oam0_sizes		?=	$0420|!addr


;; Scratch RAMs


	!_00		?=	$00
	!_01		?=	$01
	!_02		?=	$02
	!_03		?=	$03
	!_04		?=	$04
	!_05		?=	$05
	!_06		?=	$06
	!_07		?=	$07
	!_08		?=	$08
	!_09		?=	$09
	!_0a		?=	$0a
	!_0b		?=	$0b
	!_0c		?=	$0c
	!_0d		?=	$0d
	!_0e		?=	$0e
	!_0f		?=	$0f

	!_8a		?=	$8a
	!_8b		?=	$8b
	!_8c		?=	$8c
	!_8d		?=	$8d
	!_8e		?=	$8e
	!_8f		?=	$8f
