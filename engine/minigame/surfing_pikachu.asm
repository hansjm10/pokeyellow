SurfingPikachuMinigame::
	call SurfingPikachuMinigame_BlankPals
	call DelayFrame
	call DelayFrame
	call DelayFrame
	ldh a, [hTileAnimations]
	push af
	xor a
	ldh [hTileAnimations], a
	ld a, [wUpdateSpritesEnabled]
	push af
	ld a, $ff
	ld [wUpdateSpritesEnabled], a
	ldh a, [rIE]
	push af
	xor a
	ldh [rIF], a
	ld a, $f
	ldh [rIE], a
	ld a, $8
	ldh [rSTAT], a
	ldh a, [hAutoBGTransferDest + 1]
	push af
	ld a, $98
	ldh [hAutoBGTransferDest + 1], a
	call SurfingPikachuMinigameIntro
	call SurfingPikachuLoop
	xor a
	ldh [rBGP], a
	ldh [rOBP0], a
	ldh [rOBP1], a
	call UpdateCGBPal_BGP
	call UpdateCGBPal_OBP0
	call UpdateCGBPal_OBP1
	call ClearObjectAnimationBuffers
	call ClearSprites
	xor a
	ldh [hLCDCPointer], a
	ldh [hSCX], a
	ldh [hSCY], a
	ld a, $90
	ldh [hWY], a
	call DelayFrame
	pop af
	ldh [hAutoBGTransferDest + 1], a
	xor a
	ldh [rIF], a
	pop af
	ldh [rIE], a
	xor a
	ldh [rSTAT], a
	call RunDefaultPaletteCommand
	call ReloadMapAfterSurfingMinigame
	call PlayDefaultMusic
	call GBPalNormal
	pop af
	ld [wUpdateSpritesEnabled], a
	pop af
	ldh [hTileAnimations], a
	ret

SurfingPikachuLoop:
	call SurfingPikachuMinigame_LoadGFXAndLayout
	call DelayFrame
	ld b, SET_PAL_SURFING_PIKACHU_TITLE
	call RunPaletteCommand
.loop
	ld a, [wSurfingMinigameRoutineNumber]
	bit 7, a
	ret nz
	call SurfingPikachu_GetJoypad_3FrameBuffer
	call SurfingPikachu_CheckPressedSelect
	ret nz
	call RunSurfingMinigameRoutine
	ld a, $3c
	ld [wCurrentAnimatedObjectOAMBufferOffset], a
	call RunObjectAnimations
	call SurfingMinigame_MoveClouds
	call .DelayFrame
	call SurfingMinigame_UpdateMusicTempo
	jr .loop

.DelayFrame:
	call DelayFrame
	ret

SurfingPikachu_CheckPressedSelect:
	ld hl, wd492
	bit 1, [hl]
	ret z
	ldh a, [hJoyPressed]
	and PAD_SELECT
	ret

UnusedSurfingMinigameToggleStartFlag:
	ldh a, [hJoyPressed]
	and PAD_START
	ret z
	ld hl, wc5e2
	ld a, [hl]
	xor $1
	ld [hl], a
	ret

SurfingMinigame_UpdateMusicTempo:
	ld a, [wc634]
	and a
	ret z

	; check that all channels are on their last frame of note delay
	ld hl, wChannelNoteDelayCounters
	ld a, $1
	cp [hl]
	ret nz
	inc hl
	cp [hl]
	ret nz
	inc hl
	cp [hl]
	ret nz

	; de = ([wSurfingMinigamePikachuSpeed] & 0x3f) * 2
	ld a, [wSurfingMinigamePikachuSpeed]
	ld e, a
	ld a, [wSurfingMinigamePikachuSpeed + 1]
	and $3
	ld d, a
	sla e
	rl d
	ld e, d
	ld d, $0
	ld hl, .Tempos
	add hl, de
	add hl, de
	ld a, [hli]
	ld [wMusicTempo + 1], a
	ld a, [hl]
	ld [wMusicTempo], a
	ret

.Tempos:
	dw 117
	dw 109
	dw 101
	dw  93
	dw  85

SurfingMinigame_ResetMusicTempo:
	ld hl, wChannelNoteDelayCounters
	ld a, $1
	cp [hl]
	ret nz
	inc hl
	cp [hl]
	ret nz
	inc hl
	cp [hl]
	ret nz
	ld a, 117
	ld [wMusicTempo + 1], a
	xor a
	ld [wMusicTempo], a
	ret

SurfingPikachuMinigame_LoadGFXAndLayout:
	call SurfingPikachu_ClearTileMap
	call ClearSprites
	call DisableLCD
	ld hl, wSurfingMinigameData
	ld bc, wSurfingMinigameDataEnd - wSurfingMinigameData
	xor a
	call FillMemory
	ld hl, wLYOverrides
	ld bc, wLYOverridesBufferEnd - wLYOverrides
	xor a
	call FillMemory
	xor a
	ldh [hAutoBGTransferEnabled], a
	call ClearObjectAnimationBuffers

	ld hl, SurfingPikachu1Graphics1
	ld de, $9000
	ld bc, $500
	ld a, BANK(SurfingPikachu1Graphics1)
	call FarCopyData

	ld hl, SurfingPikachu1Graphics2
	ld de, $8000
	ld bc, $1000
	ld a, BANK(SurfingPikachu1Graphics2)
	call FarCopyData

	ld a, LOW(SurfingPikachuSpawnStateDataPointer)
	ld [wAnimatedObjectSpawnStateDataPointer], a
	ld a, HIGH(SurfingPikachuSpawnStateDataPointer)
	ld [wAnimatedObjectSpawnStateDataPointer + 1], a

	ld a, LOW(SurfingPikachuObjectJumptable)
	ld [wAnimatedObjectJumptablePointer], a
	ld a, HIGH(SurfingPikachuObjectJumptable)
	ld [wAnimatedObjectJumptablePointer + 1], a

	ld a, LOW(SurfingPikachuOAMData)
	ld [wAnimatedObjectOAMDataPointer], a
	ld a, HIGH(SurfingPikachuOAMData)
	ld [wAnimatedObjectOAMDataPointer + 1], a

	ld a, LOW(SurfingPikachuFrames)
	ld [wAnimatedObjectFramesDataPointer], a
	ld a, HIGH(SurfingPikachuFrames)
	ld [wAnimatedObjectFramesDataPointer + 1], a

	ld hl, vBGMap0
	ld bc, $80 tiles
	ld a, $0
	call FillMemory

	ld hl, $98c0
	ld bc, $18 tiles
	ld a, $b
	call FillMemory

	ld a, $1
	lb de, $74, $58
	call SpawnAnimatedObject

	ld a, $74
	ld [wSurfingMinigamePikachuObjectHeight], a

	call SurfingMinigame_InitScanlineOverrides

	xor a
	ldh [hSCX], a
	ldh [hSCY], a
	ld a, $7e
	ldh [hWY], a
	ld a, rSCY - $ff00
	ldh [hLCDCPointer], a
	ld a, $40
	ld [wSurfingMinigamePikachuSpeed], a
	xor a
	ld [wSurfingMinigamePikachuSpeed + 1], a
	xor a
	ld [wSurfingMinigamePikachuHP], a
	ld a, $60
	ld [wSurfingMinigamePikachuHP + 1], a
	ld hl, wSurfingMinigameWaveHeight
	ld bc, $14
	ld a, $74
	call FillMemory
	call SurfingMinigame_InitStatusOAM
	call SurfingMinigame_DrawHUDTilemap
	ld a, $e3
	ldh [rLCDC], a
	call SurfingPikachuMinigame_SetBGPals
	ld a, $e4
	ldh [rOBP0], a
	ld a, $e0
	ldh [rOBP1], a
	call UpdateCGBPal_OBP0
	call UpdateCGBPal_OBP1
	ret

SurfingPikachuMinigame_SetBGPals:
	ld a, [wOnSGB]
	and a
	jr nz, .sgb
	ld a, $d0
	ldh [rBGP], a
	call UpdateCGBPal_BGP
	ret

.sgb
	ld a, $e4
	ldh [rBGP], a
	call UpdateCGBPal_BGP
	ret

SurfingMinigame_InitStatusOAM:
	ld hl, wSpriteDataEnd
	ld de, SurfingMinigameHPDigitOAMTiles
	ld b, $97
	ld c, $80
	ld a, $4
	call SurfingMinigame_LoadStatusOAMGroup
	ld de, SurfingMinigameHPSeparatorOAMTiles
	ld b, $96
	ld c, $50
	ld a, $1
	call SurfingMinigame_LoadStatusOAMGroup
	ld de, SurfingMinigameHPLabelOAMTiles
	ld b, $14
	ld c, $20
	ld a, $5
	call SurfingMinigame_LoadStatusOAMGroup
	ld de, SurfingMinigameHPLabelShadowOAMTiles
	ld b, $20
	ld c, $80
	ld a, $4
	call SurfingMinigame_LoadStatusOAMGroup
	ret

SurfingMinigame_LoadStatusOAMGroup:
.loop
	push af
	ld [hl], b
	inc hl
	ld [hl], c
	inc hl
	ld a, [de]
	ld [hl], a
	inc hl
	ld [hl], $0
	inc hl
	ld a, c
	add $8
	ld c, a
	inc de
	pop af
	dec a
	jr nz, .loop
	ret

SurfingMinigameHPSeparatorOAMTiles:
	db $fe

SurfingMinigameHPDigitOAMTiles:
	db $d0
	db $d0
	db $d0
	db $d0

SurfingMinigameHPLabelOAMTiles:
	db $ec
	db $ed
	db $ed
	db $ee
	db $ef

SurfingMinigameHPLabelShadowOAMTiles:
	db $ec
	db $ed
	db $ee
	db $ef

SurfingMinigame_DrawHUDTilemap:
	ld de, $9c21
	ld hl, SurfingMinigameHUDTilemap
	ld c, $9
.loop
	ld a, [hli]
	ld [de], a
	inc de
	dec c
	jr nz, .loop
	ld hl, $9c01
	ld [hl], $15
	ld hl, $9c02
	ld [hl], $16
	ld hl, $9c2c
	ld [hl], $1b
	ld hl, $9c2d
	ld [hl], $1c
	ret

SurfingMinigameHUDTilemap:
	db $17
	db $18
	db $19
	db $19
	db $19
	db $19
	db $19
	db $19
	db $19

RunSurfingMinigameRoutine:
	ld a, [wSurfingMinigameRoutineNumber]
	ld e, a
	ld d, $0
	ld hl, .Jumptable
	add hl, de
	add hl, de
	ld a, [hli]
	ld h, [hl]
	ld l, a
	jp hl

.Jumptable:
	dw SurfingMinigameRoutine_SpawnPikachu ; 0
	dw SurfingMinigame_RunGame ; 1
	dw SurfingMinigame_WaitBeforeResults ; 2
	dw SurfingMinigame_ScrollToResultsScreen ; 3
	dw SurfingMinigame_DrawResultsScreenAndWait ; 4
	dw SurfingMinigame_WriteHPLeftAndWait ; 5
	dw SurfingMinigame_WriteRadnessAndWait ; 6
	dw SurfingMinigame_WriteTotalAndWait ; 7
	dw SurfingMinigame_AddRemainingHPToTotalAndWait ; 8
	dw SurfingMinigame_AddRadnessToTotalAndWait ; 9
	dw SurfingMinigame_WaitLast ; a
	dw SurfingMinigame_ExitOnPressA ; b
	dw SurfingMinigame_GameOver ; c

SurfingMinigameRoutine_SpawnPikachu:
	ld a, $2
	lb de, $48, $e0
	call SpawnAnimatedObject
	ld hl, wSurfingMinigameRoutineNumber
	inc [hl]
	ld a, $1
	ld [wc634], a
	ret

SurfingMinigame_RunGame:
	ld a, [wc5e5]
	cp $18
	jr nc, .finished_course
	ld hl, wSurfingMinigamePikachuHP
	ld a, [hli]
	or [hl]
	and a
	jr z, .dead
	call Random
	ld [wc5d5], a
	call SurfingMinigame_UpdateLYOverrides
	call SurfingMinigame_SetPikachuHeight
	call SurfingMinigame_ReadBGMapBuffer
	call SurfingMinigame_ScrollAndGenerateBGMap
	call SurfingMinigame_UpdatePikachuDistance
	call SurfingMinigame_Deduct1HP
	call SurfingMinigame_DrawHP
	ret

.finished_course
	ld hl, wSurfingMinigameRoutineNumber
	inc [hl]
	xor a
	ld [wc634], a
	ld a, 192
	ld [wSurfingMinigameRoutineDelay], a
	ret

.dead
	ld a, $1
	ld [wc630], a
	ld a, $c
	ld [wSurfingMinigameRoutineNumber], a
	ld a, $80
	ld [wc631], a
	ld a, $b
	lb de, $88, $58
	call SpawnAnimatedObject
	ld hl, ANIM_OBJ_Y_OFFSET
	add hl, bc
	ld [hl], $80
	ld hl, ANIM_OBJ_FIELD_B
	add hl, bc
	ld [hl], $80
	ld hl, ANIM_OBJ_FIELD_C
	add hl, bc
	ld [hl], $30
	xor a
	ld [wc634], a
	ret

SurfingMinigame_WaitBeforeResults:
	call SurfingMinigame_RunDelayTimer
	jr c, .done_delay
	xor a
	ld [wc5d5], a
	call SurfingMinigame_UpdateLYOverrides
	call SurfingMinigame_SetPikachuHeight
	call SurfingMinigame_ReadBGMapBuffer
	call SurfingMinigame_FastScrollAndGenerateBGMap
	call SurfingMinigame_ResetMusicTempo
	ret

.done_delay
	ld hl, wSurfingMinigameRoutineNumber
	inc [hl]
	ld a, $90
	ldh [hSCX], a
	ld a, $72
	ld [wSurfingMinigameWaveFunctionNumber], a
	ld a, $4
	ld [wc5d2], a
	xor a
	ldh [hLCDCPointer], a
	ld [wSurfingMinigameSCX], a
	ld [wSurfingMinigameSCX2], a
	ld [wSurfingMinigameSCXHi], a
	ret

SurfingMinigame_ScrollToResultsScreen:
	ldh a, [hSCX]
	and a
	jr z, .done
	call SurfingMinigame_UpdateLYOverrides
	call SurfingMinigame_SetPikachuHeight
	call SurfingMinigame_ReadBGMapBuffer
	ldh a, [hSCX]
	dec a
	dec a
	dec a
	dec a
	ldh [hSCX], a
	ld a, $e0
	ld [wSurfingMinigameXOffset], a
	call SurfingMinigame_GenerateBGMap
	ret

.done
	xor a
	ld [wSurfingMinigamePikachuSpeed], a
	ld [wSurfingMinigamePikachuSpeed + 1], a
	ld hl, wSurfingMinigameRoutineNumber
	inc [hl]
	ld a, $5
	ld [wc5d2], a
	ret

SurfingMinigame_DrawResultsScreenAndWait:
	call SurfingMinigame_DrawResultsScreen
	ld a, 32
	ld [wSurfingMinigameRoutineDelay], a
	ld hl, wSurfingMinigameRoutineNumber
	inc [hl]
	ret

SurfingMinigame_WriteHPLeftAndWait:
	call SurfingMinigame_RunDelayTimer
	ret nc
	call SurfingMinigame_WriteHPLeft
	ld a, 64
	ld [wSurfingMinigameRoutineDelay], a
	ld hl, wSurfingMinigameRoutineNumber
	inc [hl]
	ret

SurfingMinigame_WriteRadnessAndWait:
	call SurfingMinigame_RunDelayTimer
	ret nc
	call SurfingMinigame_WriteRadness
	ld a, 64
	ld [wSurfingMinigameRoutineDelay], a
	ld hl, wSurfingMinigameRoutineNumber
	inc [hl]
	ret

SurfingMinigame_WriteTotalAndWait:
	call SurfingMinigame_RunDelayTimer
	ret nc
	call SurfingMinigame_WriteTotal
	ld a, 64
	ld [wSurfingMinigameRoutineDelay], a
	ld hl, wSurfingMinigameRoutineNumber
	inc [hl]
	ret

SurfingMinigame_AddRemainingHPToTotalAndWait:
	call SurfingMinigame_RunDelayTimer
	ret nc
	call SurfingMinigame_AddRemainingHPToTotal
	push af
	call SurfingMinigame_BCDPrintTotalScore
	pop af
	ret nc
	ld a, 64
	ld [wSurfingMinigameRoutineDelay], a
	ld hl, wSurfingMinigameRoutineNumber
	inc [hl]
	ret

SurfingMinigame_AddRadnessToTotalAndWait:
	call SurfingMinigame_RunDelayTimer
	ret nc
	call SurfingMinigame_AddRadnessToTotal
	push af
	call SurfingMinigame_BCDPrintTotalScore
	pop af
	ret nc
	ld a, 128
	ld [wSurfingMinigameRoutineDelay], a
	ld hl, wSurfingMinigameRoutineNumber
	inc [hl]
	call DidPlayerGetAHighScore
	ret nc
	call SurfingMinigame_PrintTextHiScore
	ld a, $6
	ld [wc5d2], a
	ret

SurfingMinigame_WaitLast:
	call SurfingMinigame_RunDelayTimer
	ret nc
	ld hl, wSurfingMinigameRoutineNumber
	inc [hl]
	ret

SurfingMinigame_ExitOnPressA:
	call SurfingMinigame_UpdateLYOverrides
	ldh a, [hJoyPressed]
	and PAD_A
	ret z
	ld hl, wSurfingMinigameRoutineNumber
	set 7, [hl]
	ret

SurfingMinigame_GameOver:
	call SurfingMinigame_UpdateLYOverrides
	call SurfingMinigame_SetPikachuHeight
	call SurfingMinigame_ReadBGMapBuffer
	call SurfingMinigame_ScrollAndGenerateBGMap
	call SurfingMinigame_ResetMusicTempo
	ld hl, wc631
	ld a, [hl]
	and a
	jr z, .wait_press_a
	dec [hl]
	ret

.wait_press_a
	ldh a, [hJoyPressed]
	and PAD_A
	ret z
	ld hl, wSurfingMinigameRoutineNumber
	set 7, [hl]
	ret

SurfingMinigame_RunDelayTimer:
	ld hl, wSurfingMinigameRoutineDelay
	ld a, [hl]
	and a
	jr z, .set_carry
	dec [hl]
	and a
	ret

.set_carry
	scf
	ret

SurfingMinigame_UpdatePikachuDistance:
	ld a, [wc5e5 + 1]
	ld h, a
	ld a, [wc5e5 + 2]
	ld l, a
	ld a, [wSurfingMinigamePikachuSpeed]
	ld e, a
	ld a, [wSurfingMinigamePikachuSpeed + 1]
	ld d, a
	add hl, de
	ld a, h
	ld [wc5e5 + 1], a
	ld a, l
	ld [wc5e5 + 2], a
	ret nc
	ld hl, wc5e5
	inc [hl]
	ld hl, wShadowOAMSprite04XCoord
	dec [hl]
	dec [hl]
	ret

SurfingMinigameAnimatedObjectFn_Pikachu:
	ld a, [wc5d2]
	ld e, a
	ld d, $0
	ld hl, SurfingMinigamePikachuStatePointers
	add hl, de
	add hl, de
	ld a, [hli]
	ld h, [hl]
	ld l, a
	jp hl

SurfingMinigamePikachuStatePointers:
	dw SurfingMinigamePikachuState_Riding
	dw SurfingMinigame_ScoreCurrentWave
	dw SurfingMinigamePikachuState_LandingBounce
	dw SurfingMinigamePikachuState_Crash
	dw SurfingMinigamePikachuState_GameOver
	dw SurfingMinigamePikachuState_StartResultsPose
	dw SurfingMinigamePikachuState_ResultsBounce

SurfingMinigamePikachuState_Riding:
	ld a, [wc630]
	and a
	jr nz, .game_over
	call SurfingMinigame_SpawnWaveSplash
	ld a, [wSurfingMinigamePikachuObjectHeight]
	ld hl, ANIM_OBJ_Y_COORD
	add hl, bc
	ld [hl], a
	call SurfingMinigame_CheckWaveLaunch
	jr c, .splash
	call SurfingMinigame_UpdatePikachuFrameForWave
	call SurfingMinigame_SpeedUpPikachu
	ret

.splash
	call SurfingMinigame_UpdatePikachuFrameForWave
	ld a, $1 ; on a wave
	ld [wc5d2], a
	xor a
	ld hl, ANIM_OBJ_FIELD_C
	add hl, bc
	ld [hl], a
	ld hl, ANIM_OBJ_FIELD_D
	add hl, bc
	ld [hl], a
	ld hl, ANIM_OBJ_FIELD_E
	add hl, bc
	ld [hl], a
	ld [wSurfingMinigameRadnessMeter], a
	ld [wSurfingMinigameTrickFlags], a
	xor a
	ld [wChannelSoundIDs + CHAN8], a
	ld a, SFX_SURFING_JUMP
	call PlaySound
	ret

.game_over
	xor a
	ld [wSurfingMinigamePikachuSpeed], a
	ld [wSurfingMinigamePikachuSpeed + 1], a
	ld a, $4
	ld [wc5d2], a
	call SurfingMinigame_UpdatePikachuFrameForWave
	ret

SurfingMinigame_ScoreCurrentWave:
	call SurfingMinigame_DPadAction
	call SurfingMinigame_UpdatePikachuHeight
	ret nc
	call SurfingMinigame_TileInteraction
	jr c, .splash
	call SurfingMinigame_CalculateAndAddRadnessFromStunt
	ld hl, ANIM_OBJ_FIELD_C
	add hl, bc
	ld [hl], $0
	ld a, $2
	ld [wc5d2], a
	ret

.splash
	ld a, $3
	ld [wc5d2], a
	ld a, $60
	ld [wc5e1], a
	ld a, $10
	call SetCurrentAnimatedObjectCallbackAndResetFrameStateRegisters
	xor a
	ld [wChannelSoundIDs + CHAN8], a
	ld a, SFX_SURFING_CRASH
	call PlaySound
	ret

SurfingMinigamePikachuState_LandingBounce:
	ld hl, ANIM_OBJ_FIELD_C
	add hl, bc
	ld a, [hl]
	cp $20
	jr nc, .done
	inc [hl]
	inc [hl]
	inc [hl]
	inc [hl]
	ld d, $4
	call SurfingPikachu_Sine
	ld hl, ANIM_OBJ_Y_OFFSET
	add hl, bc
	ld [hl], a
	call SurfingMinigame_SpawnWaveSplash
	ld a, [wSurfingMinigamePikachuObjectHeight]
	ld hl, ANIM_OBJ_Y_COORD
	add hl, bc
	ld [hl], a
	ret

.done
	ld hl, ANIM_OBJ_Y_OFFSET
	add hl, bc
	ld [hl], $0
	ld a, $0
	ld [wc5d2], a
	ret

SurfingMinigamePikachuState_Crash:
	ld hl, wc5e1
	ld a, [hl]
	and a
	jr z, .done
	dec [hl]
	ld a, [wSurfingMinigamePikachuObjectHeight]
	ld hl, ANIM_OBJ_Y_COORD
	add hl, bc
	ld [hl], a
	ret

.done
	ld a, $0
	ld [wc5d2], a
	ld a, $4
	call SetCurrentAnimatedObjectCallbackAndResetFrameStateRegisters
	ret

SurfingMinigamePikachuState_GameOver:
	ld a, [wSurfingMinigamePikachuObjectHeight]
	ld hl, ANIM_OBJ_Y_COORD
	add hl, bc
	ld [hl], a
	call SurfingMinigame_UpdatePikachuFrameForWave
	ret

SurfingMinigamePikachuState_StartResultsPose:
	ld a, $f
	call SetCurrentAnimatedObjectCallbackAndResetFrameStateRegisters
	ld hl, ANIM_OBJ_FIELD_C
	add hl, bc
	ld [hl], $0
	ret

SurfingMinigamePikachuState_ResultsBounce:
	ld hl, ANIM_OBJ_FIELD_C
	add hl, bc
	ld a, [hl]
	inc [hl]
	inc [hl]
	and $3f
	cp $20
	jr c, .clear_y_offset
	ld d, $10
	call SurfingPikachu_Sine
	ld hl, ANIM_OBJ_Y_OFFSET
	add hl, bc
	ld [hl], a
	ret

.clear_y_offset
	ld hl, ANIM_OBJ_Y_OFFSET
	add hl, bc
	ld [hl], $0
	ret

SurfingMinigame_DPadAction:
	ld de, hJoy5
	ld a, [de]
	and PAD_LEFT
	jr nz, .d_left
	ld a, [de]
	and PAD_RIGHT
	jr nz, .d_right
	ret

.d_left
	ld hl, ANIM_OBJ_FIELD_E
	add hl, bc
	ld [hl], $0
	ld hl, ANIM_OBJ_FIELD_D
	add hl, bc
	ld a, [hl]
	inc [hl]
	cp $b
	jr c, .d_left_skip
	call .StartTrick
	ld hl, wSurfingMinigameTrickFlags
	set 0, [hl]
.d_left_skip
	ld hl, ANIM_OBJ_FRAME_SET
	add hl, bc
	ld a, [hl]
	cp $e
	jr nc, .d_left_reset
	inc [hl]
	ret

.d_left_reset
	ld [hl], $1
	ret

.d_right
	ld hl, ANIM_OBJ_FIELD_D
	add hl, bc
	ld [hl], $0
	ld hl, ANIM_OBJ_FIELD_E
	add hl, bc
	ld a, [hl]
	inc [hl]
	cp $d
	jr c, .d_right_skip
	call .StartTrick
	ld hl, wSurfingMinigameTrickFlags
	set 1, [hl]
.d_right_skip
	ld hl, ANIM_OBJ_FRAME_SET
	add hl, bc
	ld a, [hl]
	cp $1
	jr z, .d_right_reset
	dec [hl]
	ret

.d_right_reset
	ld [hl], $e
	ret

.StartTrick:
	call SurfingMinigame_IncreaseRadnessMeter
	xor a
	ld hl, ANIM_OBJ_FIELD_D
	add hl, bc
	ld [hl], a
	ld hl, ANIM_OBJ_FIELD_E
	add hl, bc
	ld [hl], a
	ld a, SFX_SURFING_FLIP
	call PlaySound
	ret

SurfingMinigame_TileInteraction:
	ld hl, ANIM_OBJ_FRAME_SET
	add hl, bc
	ld a, [wSurfingMinigameBGMapReadBuffer]
	cp $6
	jr z, .tile_06
	cp $14
	jr z, .tile_14
	cp $12
	jr z, .tile_12
	cp $7
	jr z, .tile_07
	ld a, [hl]
	cp $1
	jp z, .action_0
	cp $2
	jr z, .action_1
	cp $3
	jr z, .action_2
	cp $4
	jr z, .action_3
	cp $5
	jr z, .action_2
	cp $6
	jr z, .action_1
	cp $7
	jr z, .action_0
	jr .action_0

.tile_06
	ld a, [hl]
	cp $1
	jr z, .action_0
	cp $2
	jr z, .action_0
	cp $3
	jr z, .action_0
	cp $4
	jr z, .action_1
	cp $5
	jr z, .action_2
	cp $6
	jr z, .action_3
	cp $7
	jr z, .action_2
	jr .action_0

.tile_07
	ld a, [hl]
	cp $1
	jr z, .action_2
	cp $2
	jr z, .action_3
	cp $3
	jr z, .action_2
	cp $4
	jr z, .action_1
	cp $5
	jr z, .action_0
	cp $6
	jr z, .action_0
	cp $7
	jr z, .action_0
	jr .action_0

.tile_12
.tile_14
	ld a, [hl]
	cp $1
	jr z, .action_0
	cp $2
	jr z, .action_1
	cp $3
	jr z, .action_2
	cp $4
	jr z, .action_3
	cp $5
	jr z, .action_3
	cp $6
	jr z, .action_2
	cp $7
	jr z, .action_1
	jr .action_0

.action_1
	call SufingMinigame_ReduceSpeedBy128
	jr .action_3

.action_2
	call SufingMinigame_ReduceSpeedBy64
.action_3
	xor a
	ld [wChannelSoundIDs + CHAN8], a
	ld a, SFX_SURFING_LAND
	call PlaySound
	and a
	ret

.action_0
	ld a, $40
	ld [wSurfingMinigamePikachuSpeed], a
	xor a
	ld [wSurfingMinigamePikachuSpeed + 1], a
	scf
	ret

SurfingMinigame_SpeedUpPikachu:
	ld a, [wSurfingMinigamePikachuSpeed + 1]
	cp $2
	ret nc
	ld h, a
	ld a, [wSurfingMinigamePikachuSpeed]
	ld l, a
	ld de, $2
	add hl, de
	ld a, h
	ld [wSurfingMinigamePikachuSpeed + 1], a
	ld a, l
	ld [wSurfingMinigamePikachuSpeed], a
	ret

SufingMinigame_ReduceSpeedBy64:
	ld a, [wSurfingMinigamePikachuSpeed + 1]
	and a
	jr nz, .go
	ld a, [wSurfingMinigamePikachuSpeed]
	cp $40
	jr nc, .go
	xor a
	ld [wSurfingMinigamePikachuSpeed], a
	ret

.go
	ld a, [wSurfingMinigamePikachuSpeed + 1]
	ld h, a
	ld a, [wSurfingMinigamePikachuSpeed]
	ld l, a
	ld de, -$40
	add hl, de
	ld a, h
	ld [wSurfingMinigamePikachuSpeed + 1], a
	ld a, l
	ld [wSurfingMinigamePikachuSpeed], a
	ret

SufingMinigame_ReduceSpeedBy128:
	ld a, [wSurfingMinigamePikachuSpeed + 1]
	and a
	jr nz, .go
	ld a, [wSurfingMinigamePikachuSpeed]
	cp $80
	jr nc, .go
	xor a
	ld [wSurfingMinigamePikachuSpeed], a
	ret

.go
	ld a, [wSurfingMinigamePikachuSpeed + 1]
	ld h, a
	ld a, [wSurfingMinigamePikachuSpeed]
	ld l, a
	ld de, -$80
	add hl, de
	ld a, h
	ld [wSurfingMinigamePikachuSpeed + 1], a
	ld a, l
	ld [wSurfingMinigamePikachuSpeed], a
	ret

SurfingMinigame_CheckWaveLaunch:
	ldh a, [hSCX]
	and $7
	cp $3
	jr c, .no_launch
	cp $5
	jr nc, .no_launch
	ld a, [wSurfingMinigameBGMapReadBuffer]
	cp $14
	jr nz, .no_launch
	call SufingMinigame_GetSpeedDividedBy32
	cp $a
	jr c, .no_launch
	ld [wc5ec], a
	call SurfingMinigame_ResetPikachuJumpArc
	scf
	ret

.no_launch
	and a
	ret

SurfingMinigame_UpdatePikachuFrameForWave:
	ldh a, [hSCX]
	and $7
	cp $3
	ret c
	cp $5
	ret nc
	ld a, [wSurfingMinigameBGMapReadBuffer]
	cp $6
	jr z, .uphill_tile
	cp $14
	jr z, .uphill_tile
	cp $7
	jr z, .downhill_tile
	call SurfingMinigame_UpdateNeutralSurfFrame
	ld a, $4
	ld hl, ANIM_OBJ_FRAME_SET
	add hl, bc
	ld [hl], a
	ret

.uphill_tile
	ld a, $6
	jr .apply_wave_frame

.downhill_tile
	ld a, $2
.apply_wave_frame
	ld e, a
	ld a, [wc5de]
	dec a
	add e
	ld hl, ANIM_OBJ_FRAME_SET
	add hl, bc
	ld [hl], a
	ret

SurfingMinigame_UpdateNeutralSurfFrame:
	ld hl, wc5e0
	ld a, [hl]
	inc [hl]
	and $7
	ret nz
	ld a, [wc5df]
	and a
	jr z, .increasing
	ld a, [wc5de]
	and a
	jr z, .switch_to_increasing
	dec a
	ld [wc5de], a
	ret

.switch_to_increasing
	xor a
	ld [wc5df], a
	ret

.increasing
	ld a, [wc5de]
	cp $2
	jr z, .switch_to_decreasing
	inc a
	ld [wc5de], a
	ret

.switch_to_decreasing
	ld a, $1
	ld [wc5df], a
	ret

SufingMinigame_GetSpeedDividedBy32:
	ld a, [wSurfingMinigamePikachuSpeed]
	ld l, a
	ld a, [wSurfingMinigamePikachuSpeed + 1]
	ld h, a
	add hl, hl
	add hl, hl
	add hl, hl
	ld a, h
	ret

SurfingMinigame_SpawnWaveSplash:
	ld hl, wc5eb
	ld a, [hl]
	inc [hl]
	and $3
	ret nz
	call .GetYCoord
	ld d, a
	ld hl, ANIM_OBJ_X_COORD
	add hl, bc
	ld e, [hl]
	ld a, $a
	push bc
	call SpawnAnimatedObject
	pop bc
	ret

.GetYCoord:
	ldh a, [hSCX]
	and $8
	jr nz, .get_height_plus_9
	ld hl, wSurfingMinigameWaveHeight + 8
	jr .got_hl

.get_height_plus_9
	ld hl, wSurfingMinigameWaveHeight + 9
.got_hl
	ld a, [wSurfingMinigameBGMapReadBuffer + 1]
	cp $6
	jr z, .six_or_twenty
	cp $14
	jr z, .six_or_twenty
	cp $7
	jr z, .seven
	ld a, [hl]
	ret

.six_or_twenty
	ldh a, [hSCX]
	and $7
	ld e, a
	ld a, [hl]
	sub e
	ret

.seven
	ldh a, [hSCX]
	and $7
	add [hl]
	ret

SurfingMinigameAnimatedObjectFn_MoveRightToX58:
	ld hl, ANIM_OBJ_X_COORD
	add hl, bc
	ld a, [hl]
	cp $58
	ret z
	add $4
	ld [hl], a
	ret

UnusedSurfingMinigameAnimatedObjectFn_Mask: ; unreferenced
	call MaskCurrentAnimatedObjectStruct
	ret

SurfingMinigameAnimatedObjectFn_FlippingPika:
	ld hl, ANIM_OBJ_FIELD_B
	add hl, bc
	ld a, [hl]
	and a
	ret z
	dec [hl]
	dec [hl]
	ld d, a
	ld hl, ANIM_OBJ_FIELD_C
	add hl, bc
	ld a, [hl]
	inc [hl]
	call SurfingPikachu_Sine
	cp $80
	jr nc, .positive
	xor $ff
	inc a
.positive
	ld hl, ANIM_OBJ_Y_OFFSET
	add hl, bc
	ld [hl], a
	ret

SurfingMinigameAnimatedObjectFn_IntroAnimationPikachu:
	ld hl, ANIM_OBJ_FIELD_B
	add hl, bc
	ld a, [hl]
	inc [hl]
	and $1
	ret z
	ld hl, ANIM_OBJ_X_COORD
	add hl, bc
	ld a, [hl]
	cp $c0
	jr z, .done
	inc [hl]
	ret

.done
	ld a, $1
	ld [wSurfingMinigameIntroAnimationFinished], a
	call MaskCurrentAnimatedObjectStruct
	ret

SurfingMinigame_MoveClouds:
	ld a, [wc635]
	ld e, a
	ld d, $0
	ld a, [wSurfingMinigamePikachuSpeed]
	ld l, a
	ld a, [wSurfingMinigamePikachuSpeed + 1]
	ld h, a
	add hl, de
	ld a, l
	ld [wc635], a
	ld d, h
	ld hl, wShadowOAMSprite05XCoord
	ld e, $9
.loop
	ld a, [hl]
	add d
	ld [hli], a
	inc hl
	inc hl
	inc hl
	dec e
	jr nz, .loop
	ret

SurfingMinigame_ReadBGMapBuffer:
	ld a, [wSurfingMinigameBGMapReadBuffer] ; ???
	ldh a, [hSCX]
	add $48
	ld e, a
	srl e
	srl e
	srl e
	ld d, $0
	ld hl, vBGMap0
	add hl, de
	ld a, [wSurfingMinigamePikachuObjectHeight]
	srl a
	srl a
	srl a
	ld c, a
.loop
	ld a, c
	and a
	jr z, .copy
	dec c
	ld de, $20
	add hl, de
	ld a, h
	and $3
	or $98
	ld h, a
	jr .loop

.copy
	ld de, wSurfingMinigameBGMapReadBuffer
	ld a, e
	ldh [hVBlankCopyDest], a
	ld a, d
	ldh [hVBlankCopyDest + 1], a
	ld a, l
	ldh [hVBlankCopySource], a
	ld a, h
	ldh [hVBlankCopySource + 1], a
	ld a, 16 / $10
	ldh [hVBlankCopySize], a
	ret

SurfingMinigame_SetPikachuHeight:
	ldh a, [hSCX]
	and $8
	jr nz, .use_next_wave_height
	ld hl, wSurfingMinigameWaveHeight + 7
	jr .got_wave_height

.use_next_wave_height
	ld hl, wSurfingMinigameWaveHeight + 8
.got_wave_height
	ld a, [wSurfingMinigameBGMapReadBuffer]
	cp $6
	jr z, .uphill_tile
	cp $14
	jr z, .uphill_tile
	cp $7
	jr z, .downhill_tile
	ld a, [hl]
	ld [wSurfingMinigamePikachuObjectHeight], a
	ret

.uphill_tile
	ldh a, [hSCX]
	and $7
	ld e, a
	ld a, [hl]
	sub e
	ld [wSurfingMinigamePikachuObjectHeight], a
	ret

.downhill_tile
	ldh a, [hSCX]
	and $7
	add [hl]
	ld [wSurfingMinigamePikachuObjectHeight], a
	ret

SurfingMinigame_Deduct1HP:
	ld hl, wSurfingMinigamePikachuHP
	ld e, $99
	call .BCD_Deduct
	ret nc
	inc hl
	ld e, $99
.BCD_Deduct:
	ld a, [hl]
	and a
	jr z, .roll_over
	sub $1
	daa
	ld [hl], a
	and a
	ret

.roll_over
	ld [hl], e
	scf
	ret

SurfingMinigame_DrawHP:
	ld de, wSurfingMinigamePikachuHP + 1
	ld hl, wShadowOAMSprite00TileID
	ld a, [de]
	call .PlaceBCDNumber
	ld hl, wShadowOAMSprite02TileID
	ld a, [de]
.PlaceBCDNumber:
	ld c, a
	swap a
	and $f
	add $d0
	ld [hli], a
	inc hl
	inc hl
	inc hl
	ld a, c
	and $f
	add $d0
	ld [hl], a
	dec de
	ret

SurfingMinigame_DrawResultsScreen:
	ld hl, wTileMap
	ld bc, SCREEN_AREA
	xor a
	call FillMemory
	ld hl, .BeachTilemap
	decoord 0, 6
	ld bc, .BeachTilemapEnd - .BeachTilemap
	call CopyData
	call .PlaceTextbox
	ld hl, wShadowOAMSprite05XCoord
	ld bc, 9 * 4
	xor a
	call FillMemory
	ld a, $1
	ldh [hAutoBGTransferEnabled], a
	ret

.BeachTilemap:
INCBIN "gfx/surfing_pikachu/results_beach.tilemap"
.BeachTilemapEnd:

.PlaceTextbox:
	hlcoord 1, 1
	lb de, $3b, $3c
	ld a, $40
	call .place_row
	hlcoord 1, 2
	lb de, $3f, $3f
	ld a, $ff
	call .place_row
	hlcoord 1, 3
	lb de, $3f, $3f
	ld a, $ff
	call .place_row
	hlcoord 1, 4
	lb de, $3f, $3f
	ld a, $ff
	call .place_row
	hlcoord 1, 5
	lb de, $3f, $3f
	ld a, $ff
	call .place_row
	hlcoord 1, 6
	lb de, $3f, $3f
	ld a, $ff
	call .place_row
	hlcoord 1, 7
	lb de, $3f, $3f
	ld a, $ff
	call .place_row
	hlcoord 1, 8
	lb de, $3f, $3f
	ld a, $ff
	call .place_row
	hlcoord 1, 9
	lb de, $3d, $3e
	ld a, $40
	call .place_row
	ret

.place_row:
	ld [hl], d
	inc hl
	ld c, $10
.loop
	ld [hli], a
	dec c
	jr nz, .loop
	ld [hl], e
	ret

SurfingMinigame_PrintTextHiScore:
	ld hl, .Hi_Score
	decoord 6, 8
	ld bc, $9
	call CopyData
	ret

.Hi_Score:
	db $20,$2e,$2f,$30,$31,$2c,$32,$23,$33 ; Hi-Score!!

SurfingMinigame_WriteHPLeft:
	ld hl, .HP_Left
	decoord 2, 2
	ld bc, $7
	call CopyData
	call SurfingMinigame_BCDPrintHPLeft
	ret

.HP_Left:
	db $20,$21,$ff,$22,$23,$24,$25 ; HP Left

SurfingMinigame_AddRemainingHPToTotal:
	ld c, 99
.loop
	push bc
	ld hl, wSurfingMinigamePikachuHP
	ld a, [hli]
	or [hl]
	and a
	jr z, .dead
	call SurfingMinigame_Deduct1HP
	ld e, $1
	call SurfingMinigame_AddPointsToTotal
	pop bc
	dec c
	jr nz, .loop
	ld a, SFX_PRESS_AB
	call PlaySound
	and a
	ret

.dead
	pop bc
	scf
	ret

SurfingMinigame_BCDPrintHPLeft:
	hlcoord 10, 2
	ld de, wSurfingMinigamePikachuHP + 1
	ld a, [de]
	call SurfingPikachu_PlaceBCDNumber
	inc hl
	ld a, [de]
	call SurfingPikachu_PlaceBCDNumber
	inc hl
	inc hl
	ld [hl], $21 ; P
	inc hl
	ld [hl], $25 ; t
	inc hl
	ld [hl], $26 ; s
	ret

SurfingMinigame_WriteRadness:
	ld hl, .Radness
	decoord 2, 4
	ld bc, $7
	call CopyData
	call SurfingMinigame_BCDPrintRadness
	ret

.Radness:
	db $27,$28,$29,$2a,$23,$26,$26 ; Radness

SurfingMinigame_AddRadnessToTotal:
	ld c, 99
.loop
	push bc
	ld hl, wSurfingMinigameRadnessScore
	ld a, [hli]
	ld e, a
	or [hl]
	jr z, .done
	ld d, [hl]
	ld a, e
	sub $1
	daa
	ld e, a
	ld a, d
	sbc $0
	daa
	ld [hld], a
	ld [hl], e
	ld e, $1
	call SurfingMinigame_AddPointsToTotal
	pop bc
	dec c
	jr nz, .loop
	ld a, SFX_PRESS_AB
	call PlaySound
	and a
	ret

.done
	pop bc
	scf
	ret

SurfingMinigame_BCDPrintRadness:
	ld a, [wSurfingMinigameRadnessScore + 1]
	hlcoord 10, 4
	call SurfingPikachu_PlaceBCDNumber
	ld a, [wSurfingMinigameRadnessScore]
	hlcoord 12, 4
	call SurfingPikachu_PlaceBCDNumber
	inc hl
	inc hl
	ld [hl], $21 ; P
	inc hl
	ld [hl], $25 ; t
	inc hl
	ld [hl], $26 ; s
	ret

SurfingMinigame_AddPointsToTotal:
	ld a, [wSurfingMinigameTotalScore]
	add e
	daa
	ld [wSurfingMinigameTotalScore], a
	ld a, [wSurfingMinigameTotalScore + 1]
	adc $0
	daa
	ld [wSurfingMinigameTotalScore + 1], a
	ret nc
	ld a, $99
	ld [wSurfingMinigameTotalScore], a
	ld [wSurfingMinigameTotalScore + 1], a
	ret

SurfingMinigame_BCDPrintTotalScore:
	ld a, [wSurfingMinigameTotalScore + 1]
	hlcoord 10, 6
	call SurfingPikachu_PlaceBCDNumber
	ld a, [wSurfingMinigameTotalScore]
	hlcoord 12, 6
	call SurfingPikachu_PlaceBCDNumber
	inc hl
	inc hl
	ld [hl], $21 ; P
	inc hl
	ld [hl], $25 ; t
	inc hl
	ld [hl], $26 ; s
	ret

SurfingMinigame_WriteTotal:
	ld hl, .Total
	decoord 2, 6
	ld bc, $5
	call CopyData
	call SurfingMinigame_BCDPrintRadness
	call SurfingMinigame_BCDPrintTotalScore
	ret

.Total:
	db $2b,$2c,$25,$28,$2d ; Total

DidPlayerGetAHighScore:
	ld hl, wSurfingMinigameHiScore + 1
	ld a, [wSurfingMinigameTotalScore + 1]
	cp [hl]
	jr c, .not_high_score
	jr nz, .high_score
	dec hl
	ld a, [wSurfingMinigameTotalScore]
	cp [hl]
	jr c, .not_high_score
	jr nz, .high_score
.not_high_score
	call WaitForSoundToFinish
	ldpikacry e, PikachuCry28
	call SurfingMinigame_PlayPikaCryIfSurfingPikaInParty
	and a
	ret

.high_score
	ld a, [wSurfingMinigameTotalScore]
	ld [wSurfingMinigameHiScore], a
	ld a, [wSurfingMinigameTotalScore + 1]
	ld [wSurfingMinigameHiScore + 1], a
	call WaitForSoundToFinish
	ldpikacry e, PikachuCry34
	call SurfingMinigame_PlayPikaCryIfSurfingPikaInParty
	ld a, SFX_GET_ITEM2_4_2
	call PlaySound
	scf
	ret

SurfingMinigame_PlayPikaCryIfSurfingPikaInParty:
	push de
	callfar IsSurfingStarterPikachuInParty
	pop de
	ret nc
	callfar PlayPikachuSoundClip
	ret

SurfingMinigame_IncreaseRadnessMeter:
	ld a, [wSurfingMinigameRadnessMeter]
	inc a
	cp $4
	jr c, .cap
	ld a, $3
.cap
	ld [wSurfingMinigameRadnessMeter], a
	ret

SurfingMinigame_CalculateAndAddRadnessFromStunt:
	; Compute the amount of radness points from the
	; current trick based on the number of
	; consecutive flips
	; Single flip:                +0050
	; 2 of the same flip:         +0150
	; 3 or more of the same flip: +0350
	; 2 different flips:          +0180
	; 3 or more different flips:  +0500
	ld a, [wSurfingMinigameRadnessMeter]
	and a
	ret z
	ld a, [wSurfingMinigameTrickFlags]
	and $3
	cp $3 ; did a combination of front and back flips
	jr z, .mixed_chain
	ld a, [wSurfingMinigameRadnessMeter]
	ld d, a
	ld e, $1
	ld a, $0
.get_amount_of_radness
	add e
	sla e
	dec d
	jr nz, .get_amount_of_radness
.add_radness_50_at_a_time
	push af
	ld e, $50
	call SurfingMinigame_AddRadness
	pop af
	dec a
	jr nz, .add_radness_50_at_a_time
	ld hl, ANIM_OBJ_Y_COORD
	add hl, bc
	ld a, [hl]
	sub $10
	ld d, a
	ld hl, ANIM_OBJ_X_COORD
	add hl, bc
	ld e, [hl]
	ld a, [wSurfingMinigameRadnessMeter]
	add $3
	push bc
	call SpawnAnimatedObject
	pop bc
	ret

.mixed_chain
	ld a, [wSurfingMinigameRadnessMeter]
	cp $3
	jr c, .add_180_radness_points
	ld a, 10
.add_500_radness_50_at_a_time
	push af
	ld e, $50
	call SurfingMinigame_AddRadness
	pop af
	dec a
	jr nz, .add_500_radness_50_at_a_time
	ld hl, ANIM_OBJ_Y_COORD
	add hl, bc
	ld a, [hl]
	sub $10
	ld d, a
	ld hl, ANIM_OBJ_X_COORD
	add hl, bc
	ld e, [hl]
	ld a, $9
	push bc
	call SpawnAnimatedObject
	pop bc
	ret

.add_180_radness_points
	ld e, $50
	call SurfingMinigame_AddRadness
	ld e, $50
	call SurfingMinigame_AddRadness
	ld e, $50
	call SurfingMinigame_AddRadness
	ld e, $30
	call SurfingMinigame_AddRadness
	ld hl, ANIM_OBJ_Y_COORD
	add hl, bc
	ld a, [hl]
	sub $10
	ld d, a
	ld hl, ANIM_OBJ_X_COORD
	add hl, bc
	ld e, [hl]
	ld a, $8
	push bc
	call SpawnAnimatedObject
	pop bc
	ret

SurfingMinigame_AddRadness:
	ld a, [wSurfingMinigameRadnessScore]
	add e
	daa
	ld [wSurfingMinigameRadnessScore], a
	ld a, [wSurfingMinigameRadnessScore + 1]
	adc $0
	daa
	ld [wSurfingMinigameRadnessScore + 1], a
	ret nc
	ld a, $99
	ld [wSurfingMinigameRadnessScore], a
	ld [wSurfingMinigameRadnessScore + 1], a
	ret

SurfingMinigame_FastScrollAndGenerateBGMap:
	ld a, $a0
	ld [wSurfingMinigameXOffset], a
	ldh a, [hSCX]
	ld h, a
	ld a, [wSurfingMinigameSCX]
	ld l, a
	ld de, $900
	add hl, de
	ld a, l
	ld [wSurfingMinigameSCX], a
	ld a, h
	ldh [hSCX], a
	jr SurfingMinigame_GenerateBGMap

SurfingMinigame_ScrollAndGenerateBGMap:
	ld a, $a0
	ld [wSurfingMinigameXOffset], a
	ldh a, [hSCX]
	ld h, a
	ld a, [wSurfingMinigameSCX]
	ld l, a
	ld de, $180
	add hl, de
	ld a, l
	ld [wSurfingMinigameSCX], a
	ld a, h
	ldh [hSCX], a
SurfingMinigame_GenerateBGMap:
	ld hl, wSurfingMinigameSCX2
	ldh a, [hSCX]
	cp [hl]
	ret z
	ld [hl], a
	and $f0
	ld hl, wSurfingMinigameSCXHi
	cp [hl]
	ret z
	ld [hl], a
	call SurfingMinigame_GetWaveDataPointers
	; b and c contain the height of the next wave to appear
	; on screen, in number of pixels from the top of the screen
	ld a, b
	ld [wSurfingMinigameWaveHeightBuffer], a
	ld a, c
	ld [wSurfingMinigameWaveHeightBuffer + 1], a
	push de
	ld hl, wSurfingMinigameWaveHeight
	ld de, wSurfingMinigameWaveHeight + 2
	ld c, SCREEN_WIDTH - 2
.copy_loop
	ld a, [de]
	inc de
	ld [hli], a
	dec c
	jr nz, .copy_loop
	ld a, [wSurfingMinigameWaveHeightBuffer]
	ld [hli], a
	ld a, [wSurfingMinigameWaveHeightBuffer + 1]
	ld [hl], a
	pop de
	ld hl, wRedrawRowOrColumnSrcTiles
	ld c, $8
.loop
	ld a, [de]
	call .CopyRedrawSrcTiles
	inc de
	dec c
	jr nz, .loop
	ld a, [wSurfingMinigameXOffset]
	ld e, a
	ldh a, [hSCX]
	add e
	and $f0
	srl a
	srl a
	srl a
	ld e, a
	ld d, $0
	ld hl, vBGMap0
	add hl, de
	ld a, l
	ldh [hRedrawRowOrColumnDest], a
	ld a, h
	ldh [hRedrawRowOrColumnDest + 1], a
	ld a, $1
	ldh [hRedrawRowOrColumnMode], a
	ret

.CopyRedrawSrcTiles:
	push de
	push hl
	ld l, a
	ld h, $0
	ld de, SurfingMinigameWaveMetatileTilemap
	add hl, hl
	add hl, hl
	add hl, de
	ld e, l
	ld d, h
	pop hl
	ld a, [de]
	inc de
	ld [hli], a
	ld a, [de]
	inc de
	ld [hli], a
	ld a, [de]
	inc de
	ld [hli], a
	ld a, [de]
	inc de
	ld [hli], a
	pop de
	ret

SurfingMinigame_GetWaveDataPointers:
	ld a, [wSurfingMinigameWaveFunctionNumber]
	ld e, a
	ld d, $0
	ld hl, SurfingMinigameWaveFunctionPointers
	add hl, de
	add hl, de
	ld a, [hli]
	ld h, [hl]
	ld l, a
	jp hl

SurfingMinigameWaveFunctionPointers:
	dw SurfingMinigameWaveFunction_NoWave ; 00

	dw SurfingMinigameWaveFunction_Type01 ; 01
	dw SurfingMinigameWaveFunction_Type02 ; 02
	dw SurfingMinigameWaveFunction_Type03 ; 03
	dw SurfingMinigameWaveFunction_Type04 ; 04
	dw SurfingMinigameWaveFunction_Flat ; 05
	dw SurfingMinigameWaveFunction_Type06 ; 06
	dw SurfingMinigameWaveFunction_Type07 ; 07
	dw SurfingMinigameWaveFunction_Type08 ; 08
	dw SurfingMinigameWaveFunction_Flat ; 09
	dw SurfingMinigameWaveFunction_Flat ; 0a
	dw SurfingMinigameWaveFunction_Flat ; 0b
	dw SurfingMinigameWaveFunction_Flat ; 0c
	dw SurfingMinigameWaveFunction_ResetFlat ; 0d

	dw SurfingMinigameWaveFunction_Type0E ; 0e
	dw SurfingMinigameWaveFunction_Type0F ; 0f
	dw SurfingMinigameWaveFunction_Type10 ; 10
	dw SurfingMinigameWaveFunction_Type11 ; 11
	dw SurfingMinigameWaveFunction_Type12 ; 12
	dw SurfingMinigameWaveFunction_Type13 ; 13
	dw SurfingMinigameWaveFunction_Flat ; 14
	dw SurfingMinigameWaveFunction_Flat ; 15
	dw SurfingMinigameWaveFunction_Flat ; 16
	dw SurfingMinigameWaveFunction_Flat ; 17
	dw SurfingMinigameWaveFunction_Flat ; 18
	dw SurfingMinigameWaveFunction_ResetFlat ; 19

	dw SurfingMinigameWaveFunction_Type1A ; 1a
	dw SurfingMinigameWaveFunction_Type1B ; 1b
	dw SurfingMinigameWaveFunction_Type1C ; 1c
	dw SurfingMinigameWaveFunction_Type1D ; 1d
	dw SurfingMinigameWaveFunction_Type1E ; 1e
	dw SurfingMinigameWaveFunction_Type1A ; 1f
	dw SurfingMinigameWaveFunction_Type1B ; 20
	dw SurfingMinigameWaveFunction_Type1C ; 21
	dw SurfingMinigameWaveFunction_Type1D ; 22
	dw SurfingMinigameWaveFunction_Type1E ; 23
	dw SurfingMinigameWaveFunction_Flat ; 24
	dw SurfingMinigameWaveFunction_Flat ; 25
	dw SurfingMinigameWaveFunction_Flat ; 26
	dw SurfingMinigameWaveFunction_Flat ; 27
	dw SurfingMinigameWaveFunction_ResetFlat ; 28

	dw SurfingMinigameWaveFunction_Type01 ; 29
	dw SurfingMinigameWaveFunction_Type02 ; 2a
	dw SurfingMinigameWaveFunction_Type03 ; 2b
	dw SurfingMinigameWaveFunction_Type04 ; 2c
	dw SurfingMinigameWaveFunction_Flat ; 2d
	dw SurfingMinigameWaveFunction_Flat ; 2e
	dw SurfingMinigameWaveFunction_Flat ; 2f
	dw SurfingMinigameWaveFunction_Flat ; 30
	dw SurfingMinigameWaveFunction_ResetFlat ; 31

	dw SurfingMinigameWaveFunction_Type06 ; 32
	dw SurfingMinigameWaveFunction_Type07 ; 33
	dw SurfingMinigameWaveFunction_Type08 ; 34
	dw SurfingMinigameWaveFunction_Type06 ; 35
	dw SurfingMinigameWaveFunction_Type07 ; 36
	dw SurfingMinigameWaveFunction_Type08 ; 37
	dw SurfingMinigameWaveFunction_Type06 ; 38
	dw SurfingMinigameWaveFunction_Type07 ; 39
	dw SurfingMinigameWaveFunction_Type08 ; 3a
	dw SurfingMinigameWaveFunction_Flat ; 3b
	dw SurfingMinigameWaveFunction_Flat ; 3c
	dw SurfingMinigameWaveFunction_Flat ; 3d
	dw SurfingMinigameWaveFunction_Flat ; 3e
	dw SurfingMinigameWaveFunction_ResetFlat ; 3f

	dw SurfingMinigameWaveFunction_Type40 ; 40
	dw SurfingMinigameWaveFunction_Type41 ; 41
	dw SurfingMinigameWaveFunction_Type1A ; 42
	dw SurfingMinigameWaveFunction_Type1B ; 43
	dw SurfingMinigameWaveFunction_Type1C ; 44
	dw SurfingMinigameWaveFunction_Type1D ; 45
	dw SurfingMinigameWaveFunction_Type1E ; 46
	dw SurfingMinigameWaveFunction_Type40 ; 47
	dw SurfingMinigameWaveFunction_Type41 ; 48
	dw SurfingMinigameWaveFunction_Flat ; 49
	dw SurfingMinigameWaveFunction_Flat ; 4a
	dw SurfingMinigameWaveFunction_Flat ; 4b
	dw SurfingMinigameWaveFunction_ResetFlat ; 4c

	dw SurfingMinigameWaveFunction_Type0E ; 4d
	dw SurfingMinigameWaveFunction_Type0F ; 4e
	dw SurfingMinigameWaveFunction_Type10 ; 4f
	dw SurfingMinigameWaveFunction_Type11 ; 50
	dw SurfingMinigameWaveFunction_Type12 ; 51
	dw SurfingMinigameWaveFunction_Type13 ; 52
	dw SurfingMinigameWaveFunction_Flat ; 53
	dw SurfingMinigameWaveFunction_Type40 ; 54
	dw SurfingMinigameWaveFunction_Type41 ; 55
	dw SurfingMinigameWaveFunction_Type40 ; 56
	dw SurfingMinigameWaveFunction_Type41 ; 57
	dw SurfingMinigameWaveFunction_Flat ; 58
	dw SurfingMinigameWaveFunction_Flat ; 59
	dw SurfingMinigameWaveFunction_Flat ; 5a
	dw SurfingMinigameWaveFunction_ResetFlat ; 5b

	dw SurfingMinigameWaveFunction_Type1A ; 5c
	dw SurfingMinigameWaveFunction_Type1B ; 5d
	dw SurfingMinigameWaveFunction_Type1C ; 5e
	dw SurfingMinigameWaveFunction_Type1D ; 5f
	dw SurfingMinigameWaveFunction_Type1E ; 60
	dw SurfingMinigameWaveFunction_Type01 ; 61
	dw SurfingMinigameWaveFunction_Type02 ; 62
	dw SurfingMinigameWaveFunction_Type03 ; 63
	dw SurfingMinigameWaveFunction_Type04 ; 64
	dw SurfingMinigameWaveFunction_Flat ; 65
	dw SurfingMinigameWaveFunction_Flat ; 66
	dw SurfingMinigameWaveFunction_Flat ; 67
	dw SurfingMinigameWaveFunction_Flat ; 68
	dw SurfingMinigameWaveFunction_ResetFlat ; 69

	dw SurfingMinigameWaveFunction_BigKahuna1 ; 6a
	dw SurfingMinigameWaveFunction_BigKahuna2 ; 6b
	dw SurfingMinigameWaveFunction_BigKahuna3 ; 6c
	dw SurfingMinigameWaveFunction_BigKahuna4 ; 6d
	dw SurfingMinigameWaveFunction_BigKahuna5 ; 6e
	dw SurfingMinigameWaveFunction_BigKahuna6 ; 6f
	dw SurfingMinigameWaveFunction_BigKahuna7 ; 70
	dw SurfingMinigameWaveFunction_EndFlat ; 71

	dw SurfingMinigameWaveFunction_Flat ; 72
	dw SurfingMinigameWaveFunction_Type73 ; 73
	dw SurfingMinigameWaveFunction_Type74 ; 74
	dw SurfingMinigameWaveFunction_Type74 ; 75
	dw SurfingMinigameWaveFunction_Type74 ; 76
	dw SurfingMinigameWaveFunction_Type74 ; 77
	dw SurfingMinigameWaveFunction_Type74 ; 78
	dw SurfingMinigameWaveFunction_Type74 ; 79
	dw SurfingMinigameWaveFunction_Type74 ; 7a
	dw SurfingMinigameWaveFunction_ResetType74 ; 7b

SurfingMinigameWaveFunction_NoWave:
	ld a, [wc5e5]
	cp $16
	jr c, .check_param
	jr z, .big_kahuna
	jr nc, .got_wave
.big_kahuna
	ld a, $6a
	jr .got_next_fn

.check_param
	ld a, [wc5d5]
	and a
	jr z, .got_wave
	dec a
	and $7
	ld e, a
	ld d, $0
	ld hl, SurfingMinigameInitialWaveFunctions
	add hl, de
	ld a, [hl]
.got_next_fn
	ld [wSurfingMinigameWaveFunctionNumber], a
.got_wave
	lb bc, $74, $74
	ld de, SurfingMinigameWaveTiles_Flat
	ret

SurfingMinigameInitialWaveFunctions:
	db $01,$0e,$1a,$29,$32,$40,$4d,$5c

SurfingMinigameWaveFunction_Flat:
	lb bc, $74, $74
	ld de, SurfingMinigameWaveTiles_Flat
	jp SurfingMinigameWaveFunction_GoToNextWaveFunction

SurfingMinigameWaveFunction_BigKahuna1:
	lb bc, $74, $6c
	ld de, SurfingMinigameWaveTiles_BigKahuna1
	jp SurfingMinigameWaveFunction_GoToNextWaveFunction

SurfingMinigameWaveFunction_BigKahuna2:
	lb bc, $64, $5c
	ld de, SurfingMinigameWaveTiles_BigKahuna2
	jp SurfingMinigameWaveFunction_GoToNextWaveFunction

SurfingMinigameWaveFunction_BigKahuna3:
	lb bc, $54, $4c
	ld de, SurfingMinigameWaveTiles_BigKahuna3
	jp SurfingMinigameWaveFunction_GoToNextWaveFunction

SurfingMinigameWaveFunction_BigKahuna4:
	lb bc, $44, $44
	ld de, SurfingMinigameWaveTiles_BigKahuna4
	jp SurfingMinigameWaveFunction_GoToNextWaveFunction

SurfingMinigameWaveFunction_BigKahuna5:
	lb bc, $44, $4c
	ld de, SurfingMinigameWaveTiles_BigKahuna5
	jp SurfingMinigameWaveFunction_GoToNextWaveFunction

SurfingMinigameWaveFunction_BigKahuna6:
	lb bc, $54, $5c
	ld de, SurfingMinigameWaveTiles_BigKahuna6
	jp SurfingMinigameWaveFunction_GoToNextWaveFunction

SurfingMinigameWaveFunction_BigKahuna7:
	lb bc, $64, $6c
	ld de, SurfingMinigameWaveTiles_BigKahuna7
	jp SurfingMinigameWaveFunction_GoToNextWaveFunction

SurfingMinigameWaveFunction_Type0E:
	lb bc, $74, $6c
	ld de, SurfingMinigameWaveTiles_Type0E
	jp SurfingMinigameWaveFunction_GoToNextWaveFunction

SurfingMinigameWaveFunction_Type0F:
	lb bc, $64, $5c
	ld de, SurfingMinigameWaveTiles_Type0F
	jp SurfingMinigameWaveFunction_GoToNextWaveFunction

SurfingMinigameWaveFunction_Type10:
	lb bc, $54, $4c
	ld de, SurfingMinigameWaveTiles_Type10
	jp SurfingMinigameWaveFunction_GoToNextWaveFunction

SurfingMinigameWaveFunction_Type11:
	lb bc, $4c, $4c
	ld de, SurfingMinigameWaveTiles_Type11
	jp SurfingMinigameWaveFunction_GoToNextWaveFunction

SurfingMinigameWaveFunction_Type12:
	lb bc, $54, $5c
	ld de, SurfingMinigameWaveTiles_Type12
	jp SurfingMinigameWaveFunction_GoToNextWaveFunction

SurfingMinigameWaveFunction_Type13:
	lb bc, $64, $6c
	ld de, SurfingMinigameWaveTiles_Type13
	jp SurfingMinigameWaveFunction_GoToNextWaveFunction

SurfingMinigameWaveFunction_Type1A:
	lb bc, $74, $6c
	ld de, SurfingMinigameWaveTiles_Type1A
	jp SurfingMinigameWaveFunction_GoToNextWaveFunction

SurfingMinigameWaveFunction_Type1B:
	lb bc, $64, $5c
	ld de, SurfingMinigameWaveTiles_Type1B
	jp SurfingMinigameWaveFunction_GoToNextWaveFunction

SurfingMinigameWaveFunction_Type1C:
	lb bc, $54, $54
	ld de, SurfingMinigameWaveTiles_Type1C
	jp SurfingMinigameWaveFunction_GoToNextWaveFunction

SurfingMinigameWaveFunction_Type1D:
	lb bc, $54, $5c
	ld de, SurfingMinigameWaveTiles_Type1D
	jp SurfingMinigameWaveFunction_GoToNextWaveFunction

SurfingMinigameWaveFunction_Type1E:
	lb bc, $64, $6c
	ld de, SurfingMinigameWaveTiles_Type1E
	jp SurfingMinigameWaveFunction_GoToNextWaveFunction

SurfingMinigameWaveFunction_Type01:
	lb bc, $74, $6c
	ld de, SurfingMinigameWaveTiles_Type01
	jp SurfingMinigameWaveFunction_GoToNextWaveFunction

SurfingMinigameWaveFunction_Type02:
	lb bc, $64, $5c
	ld de, SurfingMinigameWaveTiles_Type02
	jp SurfingMinigameWaveFunction_GoToNextWaveFunction

SurfingMinigameWaveFunction_Type03:
	lb bc, $5c, $5c
	ld de, SurfingMinigameWaveTiles_Type03
	jp SurfingMinigameWaveFunction_GoToNextWaveFunction

SurfingMinigameWaveFunction_Type04:
	lb bc, $64, $6c
	ld de, SurfingMinigameWaveTiles_Type04
	jp SurfingMinigameWaveFunction_GoToNextWaveFunction

SurfingMinigameWaveFunction_Type06:
	lb bc, $74, $6c
	ld de, SurfingMinigameWaveTiles_Type06
	jp SurfingMinigameWaveFunction_GoToNextWaveFunction

SurfingMinigameWaveFunction_Type07:
	lb bc, $64, $64
	ld de, SurfingMinigameWaveTiles_Type07
	jp SurfingMinigameWaveFunction_GoToNextWaveFunction

SurfingMinigameWaveFunction_Type08:
	lb bc, $64, $6c
	ld de, SurfingMinigameWaveTiles_Type08
	jp SurfingMinigameWaveFunction_GoToNextWaveFunction

SurfingMinigameWaveFunction_Type40:
	lb bc, $74, $6c
	ld de, SurfingMinigameWaveTiles_Type40
	jp SurfingMinigameWaveFunction_GoToNextWaveFunction

SurfingMinigameWaveFunction_Type41:
	lb bc, $6c, $6c
	ld de, SurfingMinigameWaveTiles_Type41
	jp SurfingMinigameWaveFunction_GoToNextWaveFunction

SurfingMinigameWaveFunction_Type73:
	lb bc, $74, $74
	ld de, SurfingMinigameWaveTiles_Type73
	jp SurfingMinigameWaveFunction_GoToNextWaveFunction

SurfingMinigameWaveFunction_Type74:
	lb bc, $74, $74
	ld de, SurfingMinigameWaveTiles_Type74
	jp SurfingMinigameWaveFunction_GoToNextWaveFunction

SurfingMinigameWaveFunction_ResetType74:
	lb bc, $74, $74
	ld de, SurfingMinigameWaveTiles_Type74
	jp SurfingMinigameWaveFunction_ResetWaveFunction

SurfingMinigameWaveFunction_ResetFlat:
	lb bc, $74, $74
	ld de, SurfingMinigameWaveTiles_Flat
	jp SurfingMinigameWaveFunction_ResetWaveFunction

SurfingMinigameWaveFunction_EndFlat:
	lb bc, $74, $74
	ld de, SurfingMinigameWaveTiles_Flat
	ret

UnusedSurfingMinigameWaveFunction_Increment: ; unused
	inc a
	ld [wSurfingMinigameWaveFunctionNumber], a
	ret

SurfingMinigameWaveFunction_GoToNextWaveFunction:
	ld hl, wSurfingMinigameWaveFunctionNumber
	inc [hl]
	ret

SurfingMinigameWaveFunction_ResetWaveFunction:
	xor a
	ld [wSurfingMinigameWaveFunctionNumber], a
	ret

SurfingPikachuMinigameIntro:
	call SurfingPikachu_ClearTileMap
	call ClearSprites
	call DisableLCD
	xor a
	ldh [hAutoBGTransferEnabled], a
	call ClearObjectAnimationBuffers
	ld hl, SurfingPikachu1Graphics3
	ld de, $8800
	ld bc, $900
	ld a, BANK(SurfingPikachu1Graphics3)
	call FarCopyData
	ld a, LOW(SurfingPikachuSpawnStateDataPointer)
	ld [wAnimatedObjectSpawnStateDataPointer], a
	ld a, HIGH(SurfingPikachuSpawnStateDataPointer)
	ld [wAnimatedObjectSpawnStateDataPointer + 1], a
	ld a, LOW(SurfingPikachuObjectJumptable)
	ld [wAnimatedObjectJumptablePointer], a
	ld a, HIGH(SurfingPikachuObjectJumptable)
	ld [wAnimatedObjectJumptablePointer + 1], a
	ld a, LOW(SurfingPikachuOAMData)
	ld [wAnimatedObjectOAMDataPointer], a
	ld a, HIGH(SurfingPikachuOAMData)
	ld [wAnimatedObjectOAMDataPointer + 1], a
	ld a, LOW(SurfingPikachuFrames)
	ld [wAnimatedObjectFramesDataPointer], a
	ld a, HIGH(SurfingPikachuFrames)
	ld [wAnimatedObjectFramesDataPointer + 1], a
	ld a, $c
	lb de, $74, $58
	call SpawnAnimatedObject
	call DrawSurfingPikachuMinigameIntroBackground
	xor a
	ldh [hSCX], a
	ldh [hSCY], a
	ld a, $90
	ldh [hWY], a
	ld b, SET_PAL_SURFING_PIKACHU_MINIGAME
	call RunPaletteCommand
	ld a, $e3
	ldh [rLCDC], a
	ld a, $1
	ldh [hAutoBGTransferEnabled], a
	call DelayFrame
	call DelayFrame
	call DelayFrame
	call SurfingPikachuMinigame_SetBGPals
	ld a, $e4
	ldh [rOBP0], a
	ld a, $e0
	ldh [rOBP1], a
	call UpdateCGBPal_OBP0
	call UpdateCGBPal_OBP1
	call DelayFrame
	ld a, MUSIC_SURFING_PIKACHU
	ld c, BANK(Music_SurfingPikachu)
	call PlayMusic
	xor a
	ld [wSurfingMinigameIntroAnimationFinished], a
.loop
	ld a, [wSurfingMinigameIntroAnimationFinished]
	and a
	ret nz
	ld a, $0
	ld [wCurrentAnimatedObjectOAMBufferOffset], a
	call RunObjectAnimations
	call DelayFrame
	jr .loop

DrawSurfingPikachuMinigameIntroBackground:
	ld hl, wTileMap
	ld bc, SCREEN_AREA
	ld a, $ff
	call FillMemory
	ld hl, SurfingPikachuIntroBeachTilemap
	decoord 0, 6
	ld bc, 12 * SCREEN_WIDTH
	call CopyData
	ld de, SurfingPikachuIntroTitleTilemap
	hlcoord 4, 0
	lb bc, 6, 12
	call .CopyBox
	hlcoord 3, 7
	lb bc, 3, 15
	call .FillBoxWithFF
	ld hl, SurfingPikachuIntroSignTopTilemap
	decoord 3, 7
	ld bc, 15
	call CopyData
	ld hl, SurfingPikachuIntroSignBottomTilemap
	decoord 4, 9
	ld bc, 13
	call CopyData
	ret

.CopyBox:
.copy_row
	push bc
	push hl
.copy_col
	ld a, [de]
	inc de
	ld [hli], a
	dec c
	jr nz, .copy_col
	ld bc, SCREEN_WIDTH
	pop hl
	add hl, bc
	pop bc
	dec b
	jr nz, .copy_row
	ret

.FillBoxWithFF:
.fill_row
	push bc
	push hl
.fill_col
	ld [hl], $ff
	inc hl
	dec c
	jr nz, .fill_col
	pop hl
	ld bc, SCREEN_WIDTH
	add hl, bc
	pop bc
	dec b
	jr nz, .fill_row
	ret

SurfingPikachuIntroBeachTilemap: INCBIN "gfx/surfing_pikachu/intro_beach.tilemap"
SurfingPikachuIntroSignTopTilemap: INCBIN "gfx/surfing_pikachu/intro_sign_top.tilemap"
SurfingPikachuIntroSignBottomTilemap: INCBIN "gfx/surfing_pikachu/intro_sign_bottom.tilemap"
SurfingPikachuIntroTitleTilemap: INCBIN "gfx/surfing_pikachu/intro_title.tilemap"

SurfingMinigame_UpdateLYOverrides:
	ld hl, wLYOverrides + $10
	ld de, wLYOverrides + $11
	ld c, $80
	ld a, [hl]
	push af
.loop
	ld a, [de]
	inc de
	ld [hli], a
	dec c
	jr nz, .loop
	pop af
	ld [hl], a
	ret

SurfingMinigame_InitScanlineOverrides:
	ld hl, wLYOverrides
	ld bc, wLYOverridesEnd - wLYOverrides
	ld de, $0
.loop
	ld a, e
	and $1f
	ld e, a
	push hl
	ld hl, SurfingMinigame_LYOverridesInitialSineWave
	add hl, de
	ld a, [hl]
	pop hl
	ld [hli], a
	inc e
	dec bc
	ld a, c
	or b
	jr nz, .loop
	ret

SurfingPikachu_GetJoypad_3FrameBuffer:
	call Joypad
	ldh a, [hFrameCounter]
	and a
	jr nz, .delayed
	ldh a, [hJoyHeld]
	ldh [hJoy5], a
	ld a, $2
	ldh [hFrameCounter], a
	ret

.delayed
	xor a
	ldh [hJoy5], a
	ret

SurfingPikachuMinigame_BlankPals:
	xor a
	ldh [rBGP], a
	ldh [rOBP0], a
	ldh [rOBP1], a
	call UpdateCGBPal_BGP
	call UpdateCGBPal_OBP0
	call UpdateCGBPal_OBP1
	ret

SurfingPikachuMinigame_NormalPals:
	ld a, $e4
	ldh [rBGP], a
	ldh [rOBP0], a
	ld a, $e0
	ldh [rOBP1], a
	call UpdateCGBPal_BGP
	call UpdateCGBPal_OBP0
	call UpdateCGBPal_OBP1
	ret

SurfingPikachu_ClearTileMap:
	ld hl, wTileMap
	ld bc, SCREEN_AREA
	xor a
	call FillMemory
	ret

SurfingMinigame_ResetPikachuJumpArc:
	xor a
	ld [wc5ed], a
	ld [wc5ee], a
	ret

SurfingMinigame_UpdatePikachuHeight:
	ld a, [wc5ed]
	and a
	jr nz, .positive
	ld a, [wc5ec]
	ld d, a
	ld a, [wc5ee]
	or d
	jr z, .done
	ld a, [wc5ee]
	ld e, a
	ld hl, -$80
	add hl, de
	ld a, l
	ld [wc5ee], a
	ld a, h
	ld [wc5ec], a

	; -(4 * a ** 2)
	ld e, a
	ld d, $0
	call SurfingMinigame_NTimesDE
	ld e, l
	ld d, h
	ld a, $4
	call SurfingMinigame_NTimesDE
	ld a, l
	xor $ff
	inc a
	ld l, a
	ld a, h
	xor $ff
	ld h, a

	push hl
	ld hl, ANIM_OBJ_Y_COORD
	add hl, bc
	ld d, [hl]
	ld hl, ANIM_OBJ_FIELD_C
	add hl, bc
	ld e, [hl]
	pop hl

	add hl, de
	ld e, l
	ld d, h

	ld hl, ANIM_OBJ_Y_COORD
	add hl, bc
	ld [hl], d
	ld hl, ANIM_OBJ_FIELD_C
	add hl, bc
	ld [hl], e
	and a
	ret

.done
	ld a, $1
	ld [wc5ed], a
	and a
	ret

.positive
	ld a, [wSurfingMinigamePikachuObjectHeight]
	ld e, a
	ld hl, ANIM_OBJ_Y_COORD
	add hl, bc
	ld a, [hl]
	cp $90
	jr nc, .okay
	cp e
	jr nc, .reset
.okay
	ld a, [wc5ec]
	ld d, a
	ld a, [wc5ee]
	ld e, a
	ld hl, $80
	add hl, de
	ld a, l
	ld [wc5ee], a
	ld a, h
	ld [wc5ec], a

	; 4 * a ** 2
	ld e, a
	ld d, $0
	call SurfingMinigame_NTimesDE
	ld e, l
	ld d, h
	ld a, $4
	call SurfingMinigame_NTimesDE

	push hl
	ld hl, ANIM_OBJ_Y_COORD
	add hl, bc
	ld d, [hl]
	ld hl, ANIM_OBJ_FIELD_C
	add hl, bc
	ld e, [hl]
	pop hl

	add hl, de
	ld e, l
	ld d, h

	ld hl, ANIM_OBJ_Y_COORD
	add hl, bc
	ld [hl], d
	ld hl, ANIM_OBJ_FIELD_C
	add hl, bc
	ld [hl], e
	and a
	ret

.reset
	ld hl, ANIM_OBJ_Y_COORD
	add hl, bc
	ld a, [wSurfingMinigamePikachuObjectHeight]
	ld [hl], a
	ld hl, ANIM_OBJ_FIELD_C
	add hl, bc
	ld [hl], $0
	scf
	ret

SurfingMinigame_NTimesDE:
	ld hl, $0
.loop
	srl a
	jr nc, .no_add
	add hl, de
.no_add
	sla e
	rl d
	and a
	jr nz, .loop
	ret

SurfingPikachu_PlaceBCDNumber:
	ld c, a
	swap a
	and $f
	add $d0
	ld [hli], a
	ld a, c
	and $f
	add $d0
	ld [hl], a
	dec de
	ret

SurfingPikachu_Cosine: ; cosine
	add $10
SurfingPikachu_Sine: ; sine
	and $3f
	cp $20
	jr nc, .positive
	call .GetSine
	ld a, h
	ret

.positive
	and $1f
	call .GetSine
	ld a, h
	xor $ff
	inc a
	ret

.GetSine:
	ld e, a
	ld a, d
	ld d, $0
	ld hl, .SineWave
	add hl, de
	add hl, de
	ld e, [hl]
	inc hl
	ld d, [hl]
	ld hl, $0
.loop
	srl a
	jr nc, .no_add
	add hl, de
.no_add
	sla e
	rl d
	and a
	jr nz, .loop
	ret

.SineWave:
	sine_table 32

SurfingPikachuSpawnStateDataPointer:
	db $00, $00, $00 ; 0
	db $04, $01, $00 ; 1
	db $11, $02, $00 ; 2
	db $12, $02, $00 ; 3
	db $15, $00, $00 ; 4
	db $16, $00, $00 ; 5
	db $17, $00, $00 ; 6
	db $18, $00, $00 ; 7
	db $19, $00, $00 ; 8
	db $1a, $00, $00 ; 9
	db $14, $00, $00 ; a
	db $13, $03, $00 ; b
	db $1b, $04, $00 ; c

SurfingPikachuObjectJumptable:
	dw SurfingMinigameAnimatedObjectFn_nop ; 0
	dw SurfingMinigameAnimatedObjectFn_Pikachu ; 1
	dw SurfingMinigameAnimatedObjectFn_MoveRightToX58 ; 2
	dw SurfingMinigameAnimatedObjectFn_FlippingPika ; 3
	dw SurfingMinigameAnimatedObjectFn_IntroAnimationPikachu ; 4

SurfingMinigameAnimatedObjectFn_nop:
	ret

INCLUDE "data/sprite_anims/surfing_pikachu_frames.asm"
INCLUDE "data/sprite_anims/surfing_pikachu_oam.asm"

SurfingMinigame_LYOverridesInitialSineWave:
; a sine wave with amplitude 2
	db  0,  0,  0,  1,  1,  1,  1,  2
	db  2,  2,  1,  1,  1,  1,  0,  0
	db  0,  0,  0, -1, -1, -1, -1, -2
	db -2, -2, -1, -1, -1, -1,  0,  0

SurfingMinigameWaveMetatileTilemap:
	db $00, $00, $00, $00 ; 00
	db $0b, $0b, $0b, $0b ; 01
	db $0b, $02, $02, $06 ; 02
	db $03, $0b, $07, $03 ; 03
	db $06, $06, $06, $06 ; 04
	db $07, $07, $07, $07 ; 05
	db $06, $04, $04, $08 ; 06
	db $05, $07, $08, $05 ; 07
	db $0b, $0b, $11, $12 ; 08
	db $0b, $0b, $13, $03 ; 09
	db $14, $12, $04, $08 ; 0a
	db $13, $07, $08, $05 ; 0b
	db $06, $14, $06, $14 ; 0c
	db $13, $07, $13, $07 ; 0d
	db $08, $08, $08, $08 ; 0e
	db $14, $12, $14, $12 ; 0f
	db $0b, $11, $02, $14 ; 10
	db $06, $14, $06, $14 ; 11
	db $0c, $0c, $0d, $0d ; 12
	db $0d, $0d, $0d, $0d ; 13
	db $0e, $0f, $10, $0b ; 14
	db $12, $13, $12, $13 ; 15

SurfingMinigameWaveTiles_Flat:
	db $00, $00, $00, $01, $01, $01, $01, $01
SurfingMinigameWaveTiles_BigKahuna1:
	db $00, $00, $00, $01, $01, $02, $04, $06
SurfingMinigameWaveTiles_BigKahuna2:
	db $00, $00, $00, $01, $02, $04, $06, $0e
SurfingMinigameWaveTiles_BigKahuna3:
	db $00, $00, $00, $10, $11, $06, $0e, $0e
SurfingMinigameWaveTiles_BigKahuna4:
	db $00, $00, $00, $15, $15, $0e, $0e, $0e
SurfingMinigameWaveTiles_BigKahuna5:
	db $00, $00, $00, $03, $05, $07, $0e, $0e
SurfingMinigameWaveTiles_BigKahuna6:
	db $00, $00, $00, $01, $03, $05, $07, $0e
SurfingMinigameWaveTiles_BigKahuna7:
	db $00, $00, $00, $01, $01, $03, $05, $07
SurfingMinigameWaveTiles_Type0E:
	db $00, $00, $00, $01, $01, $02, $04, $06
SurfingMinigameWaveTiles_Type0F:
	db $00, $00, $00, $01, $02, $04, $06, $0e
SurfingMinigameWaveTiles_Type10:
	db $00, $00, $00, $08, $0f, $0a, $0e, $0e
SurfingMinigameWaveTiles_Type11:
	db $00, $00, $00, $09, $0d, $0b, $0e, $0e
SurfingMinigameWaveTiles_Type12:
	db $00, $00, $00, $01, $03, $05, $07, $0e
SurfingMinigameWaveTiles_Type13:
	db $00, $00, $00, $01, $01, $03, $05, $07
SurfingMinigameWaveTiles_Type1A:
	db $00, $00, $00, $01, $01, $02, $04, $06
SurfingMinigameWaveTiles_Type1B:
	db $00, $00, $00, $01, $10, $11, $06, $0e
SurfingMinigameWaveTiles_Type1C:
	db $00, $00, $00, $01, $15, $15, $0e, $0e
SurfingMinigameWaveTiles_Type1D:
	db $00, $00, $00, $01, $03, $05, $07, $0e
SurfingMinigameWaveTiles_Type1E:
	db $00, $00, $00, $01, $01, $03, $05, $07
SurfingMinigameWaveTiles_Type01:
	db $00, $00, $00, $01, $01, $02, $04, $06
SurfingMinigameWaveTiles_Type02:
	db $00, $00, $00, $01, $08, $0f, $0a, $0e
SurfingMinigameWaveTiles_Type03:
	db $00, $00, $00, $01, $09, $0d, $0b, $0e
SurfingMinigameWaveTiles_Type04:
	db $00, $00, $00, $01, $01, $03, $05, $07
SurfingMinigameWaveTiles_Type06:
	db $00, $00, $00, $01, $01, $10, $11, $06
SurfingMinigameWaveTiles_Type07:
	db $00, $00, $00, $01, $01, $15, $15, $0e
SurfingMinigameWaveTiles_Type08:
	db $00, $00, $00, $01, $01, $03, $05, $07
SurfingMinigameWaveTiles_Type40:
	db $00, $00, $00, $01, $01, $08, $0f, $0a
SurfingMinigameWaveTiles_Type41:
	db $00, $00, $00, $01, $01, $09, $0d, $0b
SurfingMinigameWaveTiles_Type73:
	db $00, $00, $00, $14, $14, $14, $14, $14
SurfingMinigameWaveTiles_Type74:
	db $00, $00, $00, $12, $13, $13, $13, $13
