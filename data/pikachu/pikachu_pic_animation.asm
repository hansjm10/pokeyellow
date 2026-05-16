PikaPicAnimThunderboltPals:
	db 4, %11000000
	db 4, %11100100
	db 4, %11000000
	db 4, %11100100
	db 4, %11000000
	db 4, %11100100
	db 4, %11000000
	db 4, %11100100
	db 4, %11000000
	db 4, %11100100
	db 4, %11000000
	db 4, %11100100
	db 4, %11000000
	db 4, %11100100
	db 4, %11000000
	db 4, %11100100
	db 4, %11000000
	db 4, %11100100
	db 4, %11000000
	db 4, %11100100
	db -1 ; end

UnusedPikaPicIntroAnimScript:
	pikapic_loadgfx PikaPicNeutral
	pikapic_loadgfx PikaPicCheerful
	pikapic_loadgfx PikachuSprite
	pikapic_animation PikaPicAnimBGFrames_1, $80, $0, $0
	pikapic_animation PikaPicAnimBGFrames_2, $b2, $5, $5
	pikapic_animation PikaPicAnimBGFrames_3, $b6, $5, $5
	pikapic_waitbgmap
	pikapic_cry
	pikapic_looptofinish

PikaPicAnimScript0:
PikaPicAnimScript1:
PikaPicAnimScript29:
	pikapic_setduration 40
	pikapic_loadgfx PikaPicNeutral
	pikapic_loadgfx PikaPicNeutralMouthGFX
	pikapic_animation PikaPicAnimBGFrames_4, $80, $0, $0
	pikapic_animation PikaPicAnimBGFrames_6, $99, $0, $0
	pikapic_waitbgmap
	pikapic_cry PikachuCry3
	pikapic_looptofinish

PikaPicAnimScript2:
	pikapic_setduration 44
	pikapic_loadgfx PikaPicHappy
	pikapic_loadgfx PikaPicHappyFaceGFX
	pikapic_animation PikaPicAnimBGFrames_4, $80, $0, $0
	pikapic_animation PikaPicAnimBGFrames_7, $99, $0, $0
	pikapic_waitbgmap
	pikapic_cry
	pikapic_looptofinish

PikaPicAnimScript3:
	pikapic_setduration 80
	pikapic_loadgfx PikaPicUnamused
	pikapic_loadgfx PikaPicUnamusedEarGFX
	pikapic_animation PikaPicAnimBGFrames_4, $80, $0, $0
	pikapic_animation PikaPicAnimBGFrames_8, $99, $0, $0
	pikapic_waitbgmap
	pikapic_cry
	pikapic_looptofinish

PikaPicAnimScript4:
	pikapic_setduration 70
	pikapic_loadgfx PikaPicJoyful
	pikapic_loadgfx PikaPicJoyfulJumpGFX
	pikapic_animation PikaPicAnimBGFrames_4, $80, $0, $0
	pikapic_animation PikaPicAnimBGFrames_9, $99, $0, $0
	pikapic_waitbgmap
	pikapic_cry
	pikapic_looptofinish

PikaPicAnimScript5:
	pikapic_setduration 32
	pikapic_loadgfx PikaPicConcerned
	pikapic_loadgfx PikaPicConcernedMarkGFX
	pikapic_animation PikaPicAnimBGFrames_4, $80, $0, $0
	pikapic_animation PikaPicAnimBGFrames_10, $99, $0, $0
	pikapic_waitbgmap
	pikapic_cry
	pikapic_looptofinish

PikaPicAnimScript6:
	pikapic_setduration 50
	pikapic_loadgfx PikaPicTurnedAway
	pikapic_loadgfx PikaPicTurnedAwayTailGFX
	pikapic_animation PikaPicAnimBGFrames_4, $80, $0, $0
	pikapic_animation PikaPicAnimBGFrames_11, $99, $0, $0
	pikapic_waitbgmap
	pikapic_cry PikachuCry38
	pikapic_looptofinish

PikaPicAnimScript7:
	pikapic_setduration 58
	pikapic_loadgfx PikaPicExcited
	pikapic_loadgfx PikaPicExcitedJumpGFX
	pikapic_animation PikaPicAnimBGFrames_4, $80, $0, $0
	pikapic_animation PikaPicAnimBGFrames_12, $99, $0, $0
	pikapic_waitbgmap
	pikapic_cry
	pikapic_looptofinish

PikaPicAnimScript8:
	pikapic_setduration 44
	pikapic_loadgfx PikaPicCheerful
	pikapic_loadgfx PikaPicCheerfulFaceGFX
	pikapic_animation PikaPicAnimBGFrames_4, $80, $0, $0
	pikapic_animation PikaPicAnimBGFrames_13, $99, $0, $0
	pikapic_waitbgmap
	pikapic_cry
	pikapic_looptofinish

PikaPicAnimScript9:
	pikapic_setduration 56
	pikapic_loadgfx PikaPicBackView
	pikapic_loadgfx PikaPicBackViewTailGFX
	pikapic_animation PikaPicAnimBGFrames_4, $80, $0, $0
	pikapic_animation PikaPicAnimBGFrames_14, $99, $0, $0
	pikapic_waitbgmap
	pikapic_cry
	pikapic_looptofinish

PikaPicAnimScript10:
	pikapic_setduration 56
	pikapic_loadgfx PikaPicInLove
	pikapic_loadgfx PikaPicInLoveSmileGFX
	pikapic_loadgfx PikaPicInLoveGrinGFX
	pikapic_animation PikaPicAnimBGFrames_4, $80, $0, $0
	pikapic_animation PikaPicAnimBGFrames_16, $99, $0, $0
	pikapic_waitbgmap
	pikapic_cry
	pikapic_looptofinish

PikaPicAnimScript11:
	pikapic_setduration 100
	pikapic_loadgfx PikaPicSleeping
	pikapic_loadgfx PikaPicSleepingBubbleGFX
	pikapic_animation PikaPicAnimBGFrames_4, $80, $0, $0
	pikapic_animation PikaPicAnimBGFrames_17, $99, $0, $0
	pikapic_waitbgmap
	pikapic_cry
	pikapic_looptofinish

PikaPicAnimScript12:
	pikapic_setduration 50
	pikapic_loadgfx PikaPicSad
	pikapic_loadgfx PikaPicSadOpenMouthGFX
	pikapic_animation PikaPicAnimBGFrames_4, $80, $0, $0
	pikapic_animation PikaPicAnimBGFrames_18, $99, $0, $0
	pikapic_waitbgmap
	pikapic_cry PikachuCry25
	pikapic_looptofinish

PikaPicAnimScript13:
	pikapic_setduration 50
	pikapic_loadgfx PikaPicRefusing
	pikapic_loadgfx PikaPicRefusingBubbleGFX
	pikapic_animation PikaPicAnimBGFrames_4, $80, $0, $0
	pikapic_animation PikaPicAnimBGFrames_19, $99, $0, $0
	pikapic_waitbgmap
	pikapic_cry
	pikapic_looptofinish

PikaPicAnimScript14:
	pikapic_setduration 40
	pikapic_loadgfx PikaPicAngry
	pikapic_loadgfx PikaPicAngryBlinkGFX
	pikapic_animation PikaPicAnimBGFrames_4, $80, $0, $0
	pikapic_animation PikaPicAnimBGFrames_20, $99, $0, $0
	pikapic_waitbgmap
	pikapic_cry
	pikapic_looptofinish

PikaPicAnimScript15:
	pikapic_setduration 50
	pikapic_loadgfx PikaPicSurprised
	pikapic_loadgfx PikaPicSurprisedSideGFX
	pikapic_animation PikaPicAnimBGFrames_4, $80, $0, $0
	pikapic_animation PikaPicAnimBGFrames_21, $99, $0, $0
	pikapic_waitbgmap
	pikapic_cry
	pikapic_looptofinish

PikaPicAnimScript16:
	pikapic_setduration 32
	pikapic_loadgfx PikaPicSideways
	pikapic_loadgfx PikaPicSidewaysShockGFX
	pikapic_animation PikaPicAnimBGFrames_4, $80, $0, $0
	pikapic_animation PikaPicAnimBGFrames_22, $99, $0, $0
	pikapic_waitbgmap
	pikapic_cry
	pikapic_looptofinish

PikaPicAnimScript17:
	pikapic_setduration 100
	pikapic_loadgfx PikaPicStartled
	pikapic_loadgfx PikaPicStartledSmileGFX
	pikapic_animation PikaPicAnimBGFrames_4, $80, $0, $0
	pikapic_animation PikaPicAnimBGFrames_23, $99, $0, $0
	pikapic_waitbgmap
	pikapic_cry
	pikapic_looptofinish

PikaPicAnimScript18:
	pikapic_setduration 32
	pikapic_loadgfx PikaPicCaughtMonGFX
	pikapic_loadgfx PikaPicCaughtMonHeartGFX
	pikapic_animation PikaPicAnimBGFrames_5, $80, $0, $0
	pikapic_animation PikaPicAnimBGFrames_24, $99, $0, $0
	pikapic_waitbgmap
	pikapic_cry PikachuCry18
	pikapic_looptofinish

PikaPicAnimScript19:
	pikapic_setduration 44
	pikapic_loadgfx PikaPicAffectionate
	pikapic_loadgfx PikaPicAffectionateBlinkGFX
	pikapic_animation PikaPicAnimBGFrames_4, $80, $0, $0
	pikapic_animation PikaPicAnimBGFrames_25, $99, $0, $0
	pikapic_waitbgmap
	pikapic_cry
	pikapic_looptofinish

PikaPicAnimScript20:
	pikapic_setduration 50
	pikapic_loadgfx PikaPicDelighted
	pikapic_loadgfx PikaPicDelightedSmileGFX
	pikapic_animation PikaPicAnimBGFrames_4, $80, $0, $0
	pikapic_animation PikaPicAnimBGFrames_26, $99, $0, $0
	pikapic_waitbgmap
	pikapic_cry
	pikapic_looptofinish

PikaPicAnimScript21:
	pikapic_setduration 40
	pikapic_loadgfx PikaPicFishing
	pikapic_loadgfx PikaPicFishingHeart1GFX
	pikapic_loadgfx PikaPicFishingHeart2GFX
	pikapic_loadgfx PikaPicFishingHeart3GFX
	pikapic_loadgfx PikaPicFishingHeart4GFX
	pikapic_animation PikaPicAnimBGFrames_4, $80, $0, $0
	pikapic_animation PikaPicAnimBGFrames_27, $99, $0, $0
	pikapic_waitbgmap
	pikapic_cry PikachuCry20
	pikapic_looptofinish

PikaPicAnimScript22:
	pikapic_setduration 40
	pikapic_loadgfx PikaPicScaredCoverGFX
	pikapic_loadgfx PikaPicScaredCoverOpenGFX
	pikapic_animation PikaPicAnimBGFrames_5, $80, $0, $0
	pikapic_animation PikaPicAnimBGFrames_28, $99, $0, $0
	pikapic_waitbgmap
	pikapic_cry
	pikapic_looptofinish

PikaPicAnimScript23:
	pikapic_setduration 70
	pikapic_loadgfx PikaPicCuriousPeekGFX
	pikapic_loadgfx PikaPicCuriousPeekBlinkGFX
	pikapic_animation PikaPicAnimBGFrames_5, $80, $0, $0
	pikapic_animation PikaPicAnimBGFrames_29, $99, $0, $0
	pikapic_waitbgmap
	pikapic_cry
	pikapic_looptofinish

PikaPicAnimScript24:
	pikapic_setduration 60
	pikapic_loadgfx PikaPicExclamationGFX
	pikapic_loadgfx PikaPicExclamationFlatGFX
	pikapic_animation PikaPicAnimBGFrames_5, $80, $0, $0
	pikapic_animation PikaPicAnimBGFrames_30, $99, $0, $0
	pikapic_waitbgmap
	pikapic_cry
	pikapic_looptofinish

PikaPicAnimScript25:
	pikapic_setduration 50
	pikapic_loadgfx PikaPicThunderbolt
	pikapic_loadgfx PikaPicThunderboltQuestion1GFX
	pikapic_loadgfx PikaPicThunderboltQuestion2GFX
	pikapic_animation PikaPicAnimBGFrames_4, $80, $0, $0
	pikapic_animation PikaPicAnimBGFrames_31, $99, $0, $0
	pikapic_waitbgmap
	pikapic_cry
	pikapic_writebyte 13
	pikapic_waitbgmap
	pikapic_thunderbolt
	pikapic_ret

UnusedPikaPicWaitBGMapAnimScript:
	pikapic_waitbgmap
PikaPicAnimScript26:
	pikapic_setduration 100
	pikapic_loadgfx PikaPicSleeping
	pikapic_loadgfx PikaPicSleepingBubbleGFX
	pikapic_loadgfx PikaPicSleepingSideGFX
	pikapic_loadgfx PikaPicSleepingWakeGFX
	pikapic_animation PikaPicAnimBGFrames_4, $80, $0, $0
	pikapic_animation PikaPicAnimBGFrames_32, $99, $0, $0
	pikapic_waitbgmap
	pikapic_cry
	pikapic_looptofinish

PikaPicAnimScript27:
	pikapic_setduration 30
	pikapic_loadgfx PikaPicBillReaction
	pikapic_loadgfx PikaPicBillReactionShockGFX
	pikapic_animation PikaPicAnimBGFrames_4, $80, $0, $0
	pikapic_animation PikaPicAnimBGFrames_33, $99, $0, $0
	pikapic_waitbgmap
	pikapic_cry
	pikapic_looptofinish

PikaPicAnimScript28:
	pikapic_setduration 64
	pikapic_loadgfx PikaPicStatusCondition
	pikapic_loadgfx PikaPicStatusConditionSadGFX
	pikapic_animation PikaPicAnimBGFrames_4, $80, $0, $0
	pikapic_animation PikaPicAnimBGFrames_34, $99, $0, $0
	pikapic_waitbgmap
	pikapic_cry
	pikapic_looptofinish

MACRO pikapicanimgfx
	IF _NARG == 2
	\2_id::
		db \1  ; size (-1 if compressed)
		dba \2 ; pointer
	ELSE
		db \1 ; size
		dbw \2, \3 ; bank, address
	ENDC
ENDM

PikaPicAnimGFXHeaders:
	pikapicanimgfx  1, $39, NULL     ; 00
	pikapicanimgfx -1, PikaPicNeutral     ; 01
	pikapicanimgfx  5, PikaPicNeutralMouthGFX     ; 02
	pikapicanimgfx -1, PikaPicHappy     ; 03
	pikapicanimgfx 10, PikaPicHappyFaceGFX     ; 04
	pikapicanimgfx -1, PikaPicUnamused     ; 05
	pikapicanimgfx  6, PikaPicUnamusedEarGFX     ; 06
	pikapicanimgfx -1, PikaPicJoyful     ; 07
	pikapicanimgfx 20, PikaPicJoyfulJumpGFX     ; 08
	pikapicanimgfx -1, PikaPicConcerned     ; 09
	pikapicanimgfx  4, PikaPicConcernedMarkGFX     ; 0a
	pikapicanimgfx -1, PikaPicTurnedAway     ; 0b
	pikapicanimgfx  4, PikaPicTurnedAwayTailGFX     ; 0c
	pikapicanimgfx -1, PikaPicExcited     ; 0d
	pikapicanimgfx 25, PikaPicExcitedJumpGFX     ; 0e
	pikapicanimgfx -1, PikaPicCheerful     ; 0f
	pikapicanimgfx 10, PikaPicCheerfulFaceGFX     ; 00
	pikapicanimgfx -1, PikaPicBackView     ; 11
	pikapicanimgfx  6, PikaPicBackViewTailGFX     ; 12
	pikapicanimgfx -1, PikaPicInLove     ; 13
	pikapicanimgfx 25, PikaPicInLoveSmileGFX     ; 14
	pikapicanimgfx 25, PikaPicInLoveGrinGFX     ; 15
	pikapicanimgfx -1, PikaPicSleeping     ; 16
	pikapicanimgfx 25, PikaPicSleepingBubbleGFX     ; 17
	pikapicanimgfx -1, PikaPicSad     ; 18
	pikapicanimgfx 25, PikaPicSadOpenMouthGFX     ; 19
	pikapicanimgfx -1, PikaPicRefusing     ; 1a
	pikapicanimgfx 25, PikaPicRefusingBubbleGFX     ; 1b
	pikapicanimgfx -1, PikaPicAngry     ; 1c
	pikapicanimgfx 25, PikaPicAngryBlinkGFX     ; 1d
	pikapicanimgfx -1, PikaPicSurprised     ; 1e
	pikapicanimgfx 25, PikaPicSurprisedSideGFX     ; 1f
	pikapicanimgfx -1, PikaPicSideways     ; 20
	pikapicanimgfx 25, PikaPicSidewaysShockGFX     ; 21
	pikapicanimgfx -1, PikaPicStartled     ; 22
	pikapicanimgfx 25, PikaPicStartledSmileGFX     ; 23
	pikapicanimgfx 25, PikaPicCaughtMonGFX     ; 24
	pikapicanimgfx 25, PikaPicCaughtMonHeartGFX     ; 25
	pikapicanimgfx -1, PikaPicAffectionate     ; 26
	pikapicanimgfx 25, PikaPicAffectionateBlinkGFX     ; 27
	pikapicanimgfx -1, PikaPicDelighted     ; 28
	pikapicanimgfx 25, PikaPicDelightedSmileGFX     ; 29
	pikapicanimgfx -1, PikaPicFishing     ; 2a
	pikapicanimgfx 25, PikaPicFishingHeart1GFX     ; 2b
	pikapicanimgfx 25, PikaPicFishingHeart2GFX     ; 2c
	pikapicanimgfx 25, PikaPicFishingHeart3GFX     ; 2d
	pikapicanimgfx 25, PikaPicFishingHeart4GFX     ; 2e
	pikapicanimgfx 25, PikaPicScaredCoverGFX     ; 2f
	pikapicanimgfx 25, PikaPicScaredCoverOpenGFX     ; 30
	pikapicanimgfx 25, PikaPicCuriousPeekGFX     ; 31
	pikapicanimgfx 25, PikaPicCuriousPeekBlinkGFX     ; 32
	pikapicanimgfx 25, PikaPicExclamationGFX     ; 33
	pikapicanimgfx 25, PikaPicExclamationFlatGFX     ; 34
	pikapicanimgfx -1, PikaPicThunderbolt     ; 35
	pikapicanimgfx 25, PikaPicThunderboltQuestion1GFX     ; 36
	pikapicanimgfx 25, PikaPicThunderboltQuestion2GFX     ; 37
	pikapicanimgfx 25, PikaPicSleepingSideGFX     ; 38
	pikapicanimgfx 25, PikaPicSleepingWakeGFX     ; 39
	pikapicanimgfx -1, PikaPicBillReaction     ; 3a
	pikapicanimgfx 25, PikaPicBillReactionShockGFX     ; 3b
	pikapicanimgfx -1, PikaPicStatusCondition     ; 3c
	pikapicanimgfx 25, PikaPicStatusConditionSadGFX     ; 3d
	pikapicanimgfx 24, PikachuSprite ; 3e
