DebugMenu:
IF DEF(_DEBUG)
	call ClearScreen

	; These debug names are used for TestBattle.
	; StartNewGameDebug uses the debug names from PrepareOakSpeech.
	ld hl, DebugBattlePlayerName
	ld de, wPlayerName
	ld bc, NAME_LENGTH
	call CopyData

	ld hl, DebugBattleRivalName
	ld de, wRivalName
	ld bc, NAME_LENGTH
	call CopyData

	call LoadFontTilePatterns
	call LoadHpBarAndStatusTilePatterns
	call ClearSprites
	call RunDefaultPaletteCommand

	hlcoord 5, 6
	lb bc, 3, 9
	call TextBoxBorder

	hlcoord 7, 7
	ld de, DebugMenuOptions
	call PlaceString

	ld a, TEXT_DELAY_MEDIUM
	ld [wOptions], a

	ld a, PAD_A | PAD_B | PAD_START
	ld [wMenuWatchedKeys], a
	xor a
	ld [wMenuJoypadPollCount], a
	inc a
	ld [wMaxMenuItem], a
	ld a, 7
	ld [wTopMenuItemY], a
	dec a
	ld [wTopMenuItemX], a
	xor a
	ld [wCurrentMenuItem], a
	ld [wLastMenuItem], a
	ld [wMenuWatchMovingOutOfBounds], a

	call HandleMenuInput
	bit B_PAD_B, a
	ld hl, DisplayTitleScreen
	ret nz

	ld a, [wCurrentMenuItem]
	and a ; FIGHT?
	jp z, TestBattle

	; DEBUG
	ld hl, wStatusFlags6
	set BIT_DEBUG_MODE, [hl]
	ld hl, StartNewGameDebug
	ret

DebugBattlePlayerName:
	db "Tom@"

DebugBattleRivalName:
	db "Juerry@"

DebugMenuOptions:
	db   "FIGHT"
	next "DEBUG@"

TestBattle: ; unreferenced except in _DEBUG
	ld a, 1
	ldh [hJoy7], a

	; Don't mess around with obedience.
	ld a, 1 << BIT_EARTHBADGE
	ld [wObtainedBadges], a

	ld hl, wStatusFlags7
	set BIT_TEST_BATTLE, [hl]

	ld hl, wNumBagItems
	ld de, TestBattleBagItems
.loop
	ld a, [de]
	cp -1
	jr z, .done
	inc de
	ld [wCurItem], a
	ld a, [de]
	inc de
	ld [wItemQuantity], a
	push de
	call AddItemToInventory
	pop de
	jr .loop
.done
	call LoadHpBarAndStatusTilePatterns
	call ClearScreen
	call ClearSprites
	hlcoord 0, 0
	lb bc, 1, 18
	call TextBoxBorder
	hlcoord 6, 1
	ld de, DebugFightTestTitleText
	call PlaceString
	hlcoord 4, 4
	ld de, DebugFightTestHeaderText
	call PlaceString
	hlcoord 1, 6
	ld de, DebugFightTestPartyRowsText
	call PlaceString
	xor a
	ld [wWhichPokemon], a
	ld [wEnemyMon], a
	ld [wEnemyMonLevel], a
	ld [wTrainerClass], a
	ld [wGrassMons + 1], a
	ld b, a
	ld c, a
	ld hl, wEnemyPartySpecies
	call DebugTestBattle_ClearSevenBytes
	ld hl, wPartyCount
	call DebugTestBattle_ClearSevenBytes
	ld de, wPartySpecies
	hlcoord 4, 6
	; fallthrough
DebugTestBattle_SelectPartySpeciesColumn:
	push hl
	push bc
	dec hl
	ld a, '▶'
	ld [hl], a
	ld bc, 11
	add hl, bc
	ld a, ' '
	ld [hl], a
	push de
	pop de
	pop bc
	pop hl
	; fallthrough
DebugTestBattle_PartySpeciesInputLoop:
	push bc
	push de
	call JoypadLowSensitivity
	pop de
	pop bc
	ldh a, [hJoy5]
	bit B_PAD_A, a
	jp nz, DebugTestBattle_IncrementPartySpecies
	bit B_PAD_B, a
	jp nz, DebugTestBattle_DecrementPartySpecies
	bit B_PAD_SELECT, a
	jp nz, DebugMenu
	bit B_PAD_START, a
	jp nz, DebugTestBattle_ValidateAndStartBattle
	bit B_PAD_RIGHT, a
	jp nz, DebugTestBattle_SelectPartyLevelColumn
	bit B_PAD_UP, a
	jp nz, DebugTestBattle_MovePartySpeciesCursorUp
	bit B_PAD_DOWN, a
	jp nz, DebugTestBattle_MovePartySpeciesCursorDown
	jr DebugTestBattle_PartySpeciesInputLoop

DebugTestBattle_ClearSevenBytes:
	xor a
	ld [hli], a
	ld [hli], a
	ld [hli], a
	ld [hli], a
	ld [hli], a
	ld [hli], a
	ld [hl], a
	ret

DebugTestBattle_IncrementPartySpecies:
	inc b
	ld a, b
	cp NUM_POKEMON_INDEXES + 1
	jr c, DebugTestBattle_PrintPartySpecies
	xor a
	ld b, a
	; fallthrough
DebugTestBattle_PrintPartySpecies:
	ld [de], a
	ld [wTempByteValue], a
	push bc
	push hl
	push de
	lb bc, LEADING_ZEROES | 1, 3
	call PrintNumber
	inc hl
	push hl
	ld de, DebugFightTestBlankNumberText
	call PlaceString
	ld bc, hSavedMapTextPtr
	add hl, bc
	ld de, DebugFightTestBlankNumberText
	call PlaceString
	pop hl
	ld a, [wNamedObjectIndex]
	and a
	jr nz, .got_mon_name
	ld de, DebugFightTestBlankNameText
	jr .place_name
.got_mon_name
	call GetMonName
.place_name
	call PlaceString
	pop de
	pop hl
	pop bc
	jr DebugTestBattle_PartySpeciesInputLoop

DebugTestBattle_DecrementPartySpecies:
	dec b
	ld a, b
	cp OPP_ID_OFFSET + 1
	jp c, DebugTestBattle_PrintPartySpecies
	ld a, NUM_POKEMON_INDEXES
	ld b, a
	jp DebugTestBattle_PrintPartySpecies

DebugTestBattle_MovePartySpeciesCursorUp:
	ld a, [wWhichPokemon]
	dec a
	cp -1
	jp z, DebugTestBattle_PartySpeciesInputLoop
	ld [wWhichPokemon], a
	dec de
	dec hl
	ld a, ' '
	ld [hl], a
	push bc
	ld bc, hMovingBGTilesCounter1
	add hl, bc
	pop bc
	ld a, '▶'
	ld [hl], a
	inc hl
	push hl
	call DebugTestBattle_LoadSelectedPartySpeciesAndLevel
	pop hl
	jp DebugTestBattle_PartySpeciesInputLoop

DebugTestBattle_MovePartySpeciesCursorDown:
	ld a, [wWhichPokemon]
	inc a
	cp 6
	jp nc, DebugTestBattle_PartySpeciesInputLoop
	ld [wWhichPokemon], a
	inc de
	dec hl
	ld a, ' '
	ld [hl], a
	ld bc, SCREEN_WIDTH * 2
	add hl, bc
	ld a, '▶'
	ld [hl], a
	inc hl
	push hl
	call DebugTestBattle_LoadSelectedPartySpeciesAndLevel
	pop hl
	jp DebugTestBattle_PartySpeciesInputLoop

DebugTestBattle_SelectPartyLevelColumn:
	push hl
	push bc
	dec hl
	ld a, ' '
	ld [hl], a
	ld bc, 11
	add hl, bc
	ld a, '▶'
	ld [hl], a
	pop bc
	pop hl
	; fallthrough
DebugTestBattle_PartyLevelInputLoop:
	push bc
	push de
	call JoypadLowSensitivity
	pop de
	pop bc
	ldh a, [hJoy5]
	bit B_PAD_A, a
	jp nz, DebugTestBattle_IncrementPartyLevel
	bit B_PAD_B, a
	jp nz, DebugTestBattle_DecrementPartyLevel
	bit B_PAD_START, a
	jp nz, DebugTestBattle_ValidateAndStartBattle
	bit B_PAD_LEFT, a
	jp nz, DebugTestBattle_SelectPartySpeciesColumn
	bit B_PAD_UP, a
	jp nz, DebugTestBattle_MovePartyLevelCursorUp
	bit B_PAD_DOWN, a
	jp nz, DebugTestBattle_MovePartyLevelCursorDown
	jr DebugTestBattle_PartyLevelInputLoop

DebugTestBattle_IncrementPartyLevel:
	inc c
	ld a, c
	cp MAX_LEVEL + 1
	jr c, DebugTestBattle_PrintPartyLevel
	ld a, 1
	ld c, a
	; fallthrough
DebugTestBattle_PrintPartyLevel:
	ld a, [wWhichPokemon]
	push de
	ld de, wEnemyPartySpecies
	add e
	ld e, a
	jr nc, .got_level_pointer
	inc d
.got_level_pointer
	ld a, c
	ld [de], a
	push bc
	push hl
	ld bc, 11
	add hl, bc
	lb bc, LEADING_ZEROES | 1, 3
	call PrintNumber
	pop hl
	pop bc
	pop de
	jp DebugTestBattle_PartyLevelInputLoop

DebugTestBattle_DecrementPartyLevel:
	dec c
	ld a, c
	cp MAX_LEVEL + 1
	jr nc, .wrap_to_max_level
	and a
	jp nz, DebugTestBattle_PrintPartyLevel
.wrap_to_max_level
	ld a, MAX_LEVEL
	ld c, a
	jp DebugTestBattle_PrintPartyLevel

DebugTestBattle_MovePartyLevelCursorUp:
	ld a, [wWhichPokemon]
	dec a
	cp -1
	jp z, DebugTestBattle_PartyLevelInputLoop
	ld [wWhichPokemon], a
	dec de
	push hl
	ld bc, 10
	add hl, bc
	ld a, ' '
	ld [hl], a
	pop hl
	ld bc, hMovingBGTilesCounter1
	add hl, bc
	push hl
	ld bc, 10
	add hl, bc
	ld a, '▶'
	ld [hl], a
	call DebugTestBattle_LoadSelectedPartySpeciesAndLevel
	pop hl
	jp DebugTestBattle_PartyLevelInputLoop

DebugTestBattle_MovePartyLevelCursorDown:
	ld a, [wWhichPokemon]
	inc a
	cp 6
	jp nc, DebugTestBattle_PartyLevelInputLoop
	ld [wWhichPokemon], a
	inc de
	push hl
	ld bc, 10
	add hl, bc
	ld a, ' '
	ld [hl], a
	pop hl
	ld bc, SCREEN_WIDTH * 2
	add hl, bc
	push hl
	ld bc, 10
	add hl, bc
	ld a, '▶'
	ld [hl], a
	call DebugTestBattle_LoadSelectedPartySpeciesAndLevel
	pop hl
	jp DebugTestBattle_PartyLevelInputLoop

DebugTestBattle_LoadSelectedPartySpeciesAndLevel:
	ld hl, wPartySpecies
	ld a, [wWhichPokemon]
	add l
	ld l, a
	jr nc, .got_species_pointer
	inc h
.got_species_pointer
	ld a, [hl]
	ld b, a
	ld hl, wEnemyPartySpecies
	ld a, [wWhichPokemon]
	add l
	ld l, a
	jr nc, .got_level_pointer
	inc h
.got_level_pointer
	ld a, [hl]
	ld c, a
	ret

DebugTestBattle_ValidateAndStartBattle:
	ld hl, wPartyCount
	ld de, wEnemyPartyCount
	xor a
	ld [hl], a
	inc hl
	ld a, [hli]
	ld b, a
	ld c, 6
	xor a
	ld [wIsInBattle], a
.add_party_loop
	ld a, b
	ld [wCurPartySpecies], a
	ld a, [hl]
	ld b, a
	inc de
	ld a, [de]
	and a
	jr z, .next_party_mon
	ld [wCurEnemyLevel], a
	xor a
	ld [wMonDataLocation], a
	ld a, [wCurPartySpecies]
	and a
	jr z, .next_party_mon
	call AddPartyMon
.next_party_mon
	inc hl
	dec c
	jr nz, .add_party_loop
	ld b, 7
	ld hl, wPartySpecies
	ld de, wEnemyPartyCount
.validate_party_loop
	inc de
	dec b
	jp z, TestBattle
	ld a, [hli]
	and a
	jr z, .validate_party_loop
	ld a, [de]
	and a
	jr z, .validate_party_loop
	hlcoord 0, 3
	lb bc, 15, 20
	call ClearScreenArea
	hlcoord 0, 3
	lb bc, 15, 20
	call ClearScreenArea
	hlcoord 0, 3
	lb bc, 15, 20
	call ClearScreenArea
	ld c, 20
	call DelayFrames
	ld a, 1
	ld [wIsInBattle], a
	ld de, DebugFightTestWildMonText
	ld a, [wGrassMons + 1]
	cp MAX_LEVEL + 1
	jr c, .got_battle_type_text
	ld a, 2
	ld [wIsInBattle], a
	ld de, DebugFightTestTrainerText
.got_battle_type_text
	hlcoord 1, 4
	call PlaceString
	hlcoord 1, 6
	ld de, DebugFightTestOpponentHeaderText
	call PlaceString
	ld a, [wEnemyMon]
	ld b, a
	ld a, [wIsInBattle]
	dec a
	jr z, .wild_battle
	ld a, [wTrainerClass]
	ld [wTempByteValue], a
	ld b, a
	ld de, wTempByteValue
	hlcoord 1, 8
	push bc
	lb bc, LEADING_ZEROES | 1, 3
	call PrintNumber
	hlcoord 5, 8
	ld de, DebugFightTestBlankNameFieldText
	call PlaceString
	call GetTrainerName
	hlcoord 5, 8
	ld de, wTrainerName
	call PlaceString
	pop bc
	jr .print_level
.wild_battle
	ld a, b
	and a
	jr z, .print_level
	ld de, wTempByteValue
	ld [de], a
	hlcoord 1, 8
	push bc
	lb bc, LEADING_ZEROES | 1, 3
	call PrintNumber
	hlcoord 5, 8
	ld de, DebugFightTestBlankNameFieldText
	call PlaceString
	call GetMonName
	hlcoord 5, 8
	call PlaceString
	pop bc
.print_level
	ld a, [wEnemyMonLevel]
	ld c, a
	ld de, wTempByteValue
	ld [de], a
	hlcoord 16, 8
	push bc
	lb bc, LEADING_ZEROES | 1, 3
	call PrintNumber
	pop bc
	; fallthrough
DebugTestBattle_SelectBattleType:
	ld a, ' '
	ldcoord_a 0, 8
	ldcoord_a 15, 8
	ld a, '▶'
	ldcoord_a 0, 4
	; fallthrough
DebugTestBattle_BattleTypeInputLoop:
	push bc
	call JoypadLowSensitivity
	pop bc
	ldh a, [hJoy5]
	bit B_PAD_A, a
	jp nz, DebugTestBattle_ToggleBattleType
	bit B_PAD_START, a
	jp nz, DebugTestBattle_StartSelectedBattle
	bit B_PAD_DOWN, a
	jp nz, DebugTestBattle_SelectOpponentID
	jr DebugTestBattle_BattleTypeInputLoop

DebugTestBattle_ToggleBattleType:
	hlcoord 1, 8
	ld de, DebugFightTestOpponentBlankRowText
	call PlaceString
	hlcoord 5, 7
	ld de, DebugFightTestBlankNameFieldText
	call PlaceString
	xor a
	ld b, a
	ld c, a
	ld a, [wIsInBattle]
	dec a
	jr nz, .set_wild_battle
	ld a, 2
	ld [wIsInBattle], a
	ld a, ' '
	ldcoord_a 4, 3
	hlcoord 1, 4
	ld de, DebugFightTestTrainerText
	call PlaceString
	jp DebugTestBattle_BattleTypeInputLoop
.set_wild_battle
	ld a, 1
	ld [wIsInBattle], a
	ld a, ' '
	ldcoord_a 1, 3
	hlcoord 1, 4
	ld de, DebugFightTestWildMonText
	call PlaceString
	jp DebugTestBattle_BattleTypeInputLoop

DebugTestBattle_SelectOpponentID:
	ld a, '▶'
	ldcoord_a 0, 8
	ld a, ' '
	ldcoord_a 15, 8
	ldcoord_a 0, 4
	; fallthrough
DebugTestBattle_OpponentIDInputLoop:
	push bc
	call JoypadLowSensitivity
	pop bc
	ldh a, [hJoy5]
	bit B_PAD_A, a
	jp nz, DebugTestBattle_IncrementOpponentID
	bit B_PAD_B, a
	jp nz, DebugTestBattle_DecrementOpponentID
	bit B_PAD_START, a
	jp nz, DebugTestBattle_StartSelectedBattle
	bit B_PAD_RIGHT, a
	jp nz, DebugTestBattle_SelectOpponentLevel
	bit B_PAD_UP, a
	jp nz, DebugTestBattle_SelectBattleType
	jr DebugTestBattle_OpponentIDInputLoop

DebugTestBattle_IncrementOpponentID:
	push bc
	hlcoord 5, 7
	ld de, DebugFightTestBlankNameFieldText
	call PlaceString
	hlcoord 5, 8
	ld de, DebugFightTestBlankNameFieldText
	call PlaceString
	pop bc
	ld a, [wIsInBattle]
	dec a
	jr z, DebugTestBattle_PrintOpponentTrainerID.print_species
	inc b
	ld a, b
	cp 48
	jr c, DebugTestBattle_PrintOpponentTrainerID
	ld b, 1
	; fallthrough
DebugTestBattle_PrintOpponentTrainerID:
	ld a, b
	ld [wTempByteValue], a
	ld de, wTempByteValue
	hlcoord 1, 8
	push bc
	lb bc, LEADING_ZEROES | 1, 3
	call PrintNumber
	ld a, [wTempByteValue]
	ld [wTrainerClass], a
	call GetTrainerName
	hlcoord 5, 8
	ld de, wTrainerName
	call PlaceString
	pop bc
	jp DebugTestBattle_OpponentIDInputLoop
.print_species
	inc b
	ld a, b
	cp NUM_POKEMON_INDEXES + 1
	jr c, DebugTestBattle_PrintOpponentSpeciesID
	ld b, 1
	; fallthrough
DebugTestBattle_PrintOpponentSpeciesID:
	ld a, b
	ld [wTempByteValue], a
	ld de, wTempByteValue
	hlcoord 1, 8
	push bc
	lb bc, LEADING_ZEROES | 1, 3
	call PrintNumber
	call GetMonName
	hlcoord 5, 8
	call PlaceString
	pop bc
	jp DebugTestBattle_OpponentIDInputLoop

DebugTestBattle_DecrementOpponentID:
	push bc
	hlcoord 5, 7
	ld de, DebugFightTestBlankNameFieldText
	call PlaceString
	hlcoord 5, 8
	ld de, DebugFightTestBlankNameFieldText
	call PlaceString
	pop bc
	ld a, [wIsInBattle]
	dec a
	jr z, .decrement_species
	dec b
	ld a, b
	cp 48
	jr nc, .wrap_to_max_trainer
	and a
	jp nz, DebugTestBattle_PrintOpponentTrainerID
.wrap_to_max_trainer
	ld b, 47
	jp DebugTestBattle_PrintOpponentTrainerID
.decrement_species
	dec b
	ld a, b
	cp NUM_POKEMON_INDEXES + 1
	jr nc, .wrap_to_max_species
	and a
	jp nz, DebugTestBattle_PrintOpponentSpeciesID
.wrap_to_max_species
	ld b, NUM_POKEMON_INDEXES
	jp DebugTestBattle_PrintOpponentSpeciesID

DebugTestBattle_SelectOpponentLevel:
	ld a, ' '
	ldcoord_a 0, 8
	ld a, '▶'
	ldcoord_a 15, 8
	; fallthrough
DebugTestBattle_OpponentLevelInputLoop:
	push bc
	call JoypadLowSensitivity
	pop bc
	ldh a, [hJoy5]
	bit B_PAD_A, a
	jp nz, DebugTestBattle_IncrementOpponentLevel
	bit B_PAD_B, a
	jp nz, DebugTestBattle_DecrementOpponentLevel
	bit B_PAD_START, a
	jp nz, DebugTestBattle_StartSelectedBattle
	bit B_PAD_LEFT, a
	jp nz, DebugTestBattle_SelectOpponentID
	bit B_PAD_UP, a
	jp nz, DebugTestBattle_SelectBattleType
	jr DebugTestBattle_OpponentLevelInputLoop

DebugTestBattle_IncrementOpponentLevel:
	inc c
	ld a, c
	cp MAX_LEVEL + 1
	jr c, DebugTestBattle_PrintOpponentLevel
	ld c, 1
DebugTestBattle_PrintOpponentLevel:
	hlcoord 16, 8
	ld a, c
	ld de, wCurEnemyLevel
	ld [de], a
	push bc
	lb bc, LEADING_ZEROES | 1, 3
	call PrintNumber
	pop bc
	jp DebugTestBattle_OpponentLevelInputLoop

DebugTestBattle_DecrementOpponentLevel:
	dec c
	ld a, c
	cp MAX_LEVEL + 1
	jr nc, .wrap_to_max_level
	and a
	jp nz, DebugTestBattle_PrintOpponentLevel
.wrap_to_max_level
	ld c, MAX_LEVEL
	jp DebugTestBattle_PrintOpponentLevel

DebugTestBattle_StartSelectedBattle:
	ld a, b
	and a
	jp z, DebugTestBattle_SelectBattleType
	ld a, c
	and a
	jp z, DebugTestBattle_SelectBattleType
	ld a, [wIsInBattle]
	dec a
	jr z, .got_opponent
	ld a, b
	add OPP_ID_OFFSET
	ld b, a
	ld a, c
	ld [wTrainerNo], a
.got_opponent
	ld a, c
	ld [wCurEnemyLevel], a
	ld a, b
	ld [wCurOpponent], a
	xor a
	ld [wStatusFlags3], a
	predef InitOpponent
	xor a
	ld [wNumRunAttempts], a
	ld hl, wPlayerStatsToDouble
	ld bc, wEnemyStatsToDouble - wPlayerStatsToDouble
	call FillMemory
	ld hl, wEnemyStatsToDouble
	ld bc, wPlayerNumAttacksLeft - wEnemyStatsToDouble
	call FillMemory
	call LoadFontTilePatterns
	call ClearScreen
	call ClearSprites
	ld a, %11100100
	ldh [rBGP], a
	ldh [rOBP0], a
	ldh [rOBP1], a
	call UpdateCGBPal_BGP
	call UpdateCGBPal_OBP0
	call UpdateCGBPal_OBP1
	hlcoord 0, 0
	lb bc, 1, 18
	call TextBoxBorder
	hlcoord 6, 1
	ld de, DebugFightTestTitleText
	call PlaceString
	hlcoord 4, 4
	ld de, DebugFightTestHeaderText
	call PlaceString
	hlcoord 1, 6
	ld de, DebugFightTestPartyRowsText
	call PlaceString
	ld de, wPartyCount
	xor a
	ld [de], a
	ld [wWhichPokemon], a
	inc de
	hlcoord 4, 6
	push de
	push hl
	; fallthrough
DebugTestBattle_PrintInitializedPartyRow:
	ld a, [wWhichPokemon]
	ld de, wPartySpecies
	add e
	ld e, a
	jr nc, .got_species_pointer
	inc d
.got_species_pointer
	ld a, [de]
	cp -1
	jp z, DebugTestBattle_ReturnToPartySelection
	ld [wTempByteValue], a
	push hl
	lb bc, LEADING_ZEROES | 1, 3
	call PrintNumber
	inc hl
	ld de, DebugFightTestBlankNumberText
	call PlaceString
	call GetMonName
	call PlaceString
	pop hl
	push hl
	ld bc, 11
	add hl, bc
	push hl
	ld a, [wWhichPokemon]
	ld hl, wPartyMon1Level
	ld bc, wPartyMon2 - wPartyMon1
	call AddNTimes
	ld d, h
	ld e, l
	ld a, [de]
	ld [wCurEnemyLevel], a
	pop hl
	lb bc, LEADING_ZEROES | 1, 3
	call PrintNumber
	ld a, [wWhichPokemon]
	ld de, wEnemyPartySpecies
	add e
	ld e, a
	jr nc, .got_level_pointer
	inc d
.got_level_pointer
	ld a, [wCurEnemyLevel]
	ld [de], a
	pop hl
	ld a, [wWhichPokemon]
	inc a
	ld [wWhichPokemon], a
	ld bc, SCREEN_WIDTH * 2
	add hl, bc
	jp DebugTestBattle_PrintInitializedPartyRow

DebugTestBattle_ReturnToPartySelection:
	pop hl
	pop de
	ld a, [wPartyMon1]
	ld b, a
	ld a, [wPartyMon1Level]
	ld c, a
	xor a
	ld [wWhichPokemon], a
	jp DebugTestBattle_SelectPartySpeciesColumn

DebugUnusedKenshirouName:
	db   "けんしろう@" ; "KENSHIROU@"

DebugFightTestTitleText:
	db   "テスト ファイト@" ; "FIGHT TEST@"

DebugFightTestHeaderText:
	db   "№．  なまえ    レべル@" ; "№．  NAME  LEVEL@"

DebugFightTestPartyRowsText:
	db   "１．▶０００ ーーーーー  ０００"
	next "２． ０００ ーーーーー  ０００"
	next "３． ０００ ーーーーー  ０００"
	next "４． ０００ ーーーーー  ０００"
	next "５． ０００ ーーーーー  ０００"
	next "６． ０００ ーーーーー  ０００@"

DebugFightTestBlankNumberText:
	db   "     @"

DebugFightTestBlankNameText:
	db   "ーーーーー@"

DebugFightTestWildMonText:
	db   "ワイルドモンスター@" ; "WILD #MON@"

DebugFightTestTrainerText:
	db   "ディーラー    @" ; "TRAINER      @"

DebugFightTestOpponentHeaderText:
	db   "№．  なまえ        レべル" ; "№．  NAME     LABEL"
	next ""
DebugFightTestOpponentBlankRowText:
	db   "０００ ーーーーーーーーーー ０００@"

DebugFightTestBlankNameFieldText:
	db   "          @"

TestBattleBagItems:
	db GREAT_BALL, 99
	db POKE_BALL, 99
	db ANTIDOTE, 99
	db FULL_RESTORE, 99
	db MAX_POTION, 99
	db HYPER_POTION, 99
	db SUPER_POTION, 99
	db POTION, 99
	db -1 ; end

DebugCreateBoxMon:
	ld a, [wBoxCount]
	cp 30
	jp nc, DebugCreateBoxMon_BoxFull
	call ClearScreen
	call UpdateSprites
	ld a, [wLetterPrintingDelayFlags]
	push af
	xor a
	ld [wLetterPrintingDelayFlags], a
	ld hl, wEnemyMonOT
	ld [hli], a
	ld [hli], a
	ld [hl], a
	inc a
	ldh [hJoy7], a
	ld [wCurPartySpecies], a
	ld [wCurEnemyLevel], a
	; fallthrough
DebugCreateBoxMon_SelectSpecies:
	hlcoord 0, 3
	ld [hl], ' '
	hlcoord 0, 1
	ld [hl], '▶'
	call DebugCreateBoxMon_PrintSpecies
.input_loop
	call DelayFrame
	call JoypadLowSensitivity
	ldh a, [hJoy5]
	bit B_PAD_A, a
	jp nz, DebugCreateBoxMon_IncrementSpecies
	bit B_PAD_B, a
	jp nz, DebugCreateBoxMon_DecrementSpecies
	bit B_PAD_DOWN, a
	jp nz, DebugCreateBoxMon_SelectLevel
	jr .input_loop

DebugCreateBoxMon_IncrementSpecies:
	ld hl, wCurPartySpecies
	inc [hl]
	ld a, [hl]
	cp NUM_POKEMON + 1
	jr c, DebugCreateBoxMon_SelectSpecies
	ld [hl], DEX_BULBASAUR
	jr DebugCreateBoxMon_SelectSpecies

DebugCreateBoxMon_DecrementSpecies:
	ld hl, wCurPartySpecies
	dec [hl]
	jr nz, DebugCreateBoxMon_SelectSpecies
	ld [hl], DEX_MEW
	jr DebugCreateBoxMon_SelectSpecies

DebugCreateBoxMon_PrintSpecies:
	hlcoord 1, 0
	lb bc, 2, 9
	call ClearScreenArea
	hlcoord 1, 1
	ld de, wCurPartySpecies
	lb bc, LEADING_ZEROES | 1, 3
	call PrintNumber
	inc hl
	push hl
	ld a, [wCurPartySpecies]
	ld [wPokedexNum], a
	callfar PokedexToIndex
	call GetMonName
	pop hl
	call PlaceString
	ld a, [wPokedexNum]
	ld [wCurSpecies], a
	call GetMonHeader
	ret

DebugCreateBoxMon_SelectLevel:
	hlcoord 0, 1
	ld [hl], ' '
	hlcoord 0, 3
	ld [hl], '▶'
	hlcoord 0, 5
	ld [hl], ' '
	call DebugCreateBoxMon_PrintLevel
	call DebugCreateBoxMon_PrintDefaultMoves
.input_loop
	call DelayFrame
	call JoypadLowSensitivity
	ld hl, wCurEnemyLevel
	ldh a, [hJoy5]
	bit B_PAD_A, a
	jp nz, DebugCreateBoxMon_IncrementLevel
	bit B_PAD_B, a
	jp nz, DebugCreateBoxMon_DecrementLevel
	bit B_PAD_START, a
	jp nz, DebugCreateBoxMon_SendToBox
	bit B_PAD_UP, a
	jp nz, DebugCreateBoxMon_SelectSpecies
	bit B_PAD_DOWN, a
	jp nz, DebugCreateBoxMon_SelectMoves
	jr .input_loop

DebugCreateBoxMon_IncrementLevel:
	inc [hl]
	ld a, [hl]
	cp MAX_LEVEL + 1
	jr c, DebugCreateBoxMon_SelectLevel
	ld [hl], 1
	jr DebugCreateBoxMon_SelectLevel

DebugCreateBoxMon_DecrementLevel:
	dec [hl]
	jr nz, DebugCreateBoxMon_SelectLevel
	ld [hl], MAX_LEVEL
	jr DebugCreateBoxMon_SelectLevel

DebugCreateBoxMon_PrintLevel:
	hlcoord 1, 3
	ld de, wCurEnemyLevel
	lb bc, LEADING_ZEROES | 1, 3
	call PrintNumber
	ret

DebugCreateBoxMon_PrintDefaultMoves:
	hlcoord 1, 4
	lb bc, 8, 11
	call ClearScreenArea
	ld a, [wCurPartySpecies]
	push af
	ld [wPokedexNum], a
	ld hl, BaseStats + 15
	dec a
	ld bc, BASE_DATA_SIZE
	call AddNTimes
	ld de, wMoves
	ld bc, NUM_MOVES
	ld a, BANK(BaseStats)
	call FarCopyData
	callfar PokedexToIndex
	ld a, [wPokedexNum]
	ld [wCurPartySpecies], a
	xor a
	ld [wChangeMonPicEnemyTurnSpecies], a
	ld de, wMoves
	predef WriteMonMoves
	hlcoord 1, 5
	ld de, wMoves
	ld b, NUM_MOVES
.print_moves_loop
	ld a, [de]
	inc de
	and a
	jr z, .done
	push de
	push bc
	push hl
	ld [wTempByteValue], a
	ld de, wTempByteValue
	lb bc, LEADING_ZEROES | 1, 3
	call PrintNumber
	inc hl
	call GetMoveName
	call PlaceString
	pop hl
	ld bc, SCREEN_WIDTH * 2
	add hl, bc
	pop bc
	pop de
	dec b
	jr nz, .print_moves_loop
.done
	pop af
	ld [wCurPartySpecies], a
	ret

DebugCreateBoxMon_SelectMoves:
	ld de, wMoves
	hlcoord 0, 5
	ld b, 1
	; fallthrough
DebugCreateBoxMon_MoveInputLoop:
	call DebugCreateBoxMon_PrintSelectedMove
.input_loop
	call DelayFrame
	push de
	push bc
	call JoypadLowSensitivity
	pop bc
	pop de
	ldh a, [hJoy5]
	bit B_PAD_A, a
	jp nz, DebugCreateBoxMon_IncrementMove
	bit B_PAD_B, a
	jp nz, DebugCreateBoxMon_DecrementMove
	bit B_PAD_START, a
	jp nz, DebugCreateBoxMon_SendToBox
	bit B_PAD_UP, a
	jp nz, DebugCreateBoxMon_MoveCursorUp
	bit B_PAD_DOWN, a
	jp nz, DebugCreateBoxMon_MoveCursorDown
	jr .input_loop

DebugCreateBoxMon_IncrementMove:
	ld a, [de]
	inc a
	ld [de], a
	cp NUM_ATTACKS
	jr c, DebugCreateBoxMon_MoveInputLoop
	ld a, 1
	ld [de], a
	jr DebugCreateBoxMon_MoveInputLoop

DebugCreateBoxMon_DecrementMove:
	ld a, [de]
	dec a
	ld [de], a
	jr nz, DebugCreateBoxMon_MoveInputLoop
	ld a, NUM_ATTACKS - 1
	ld [de], a
	jr DebugCreateBoxMon_MoveInputLoop

DebugCreateBoxMon_MoveCursorUp:
	dec de
	dec b
	jp z, DebugCreateBoxMon_SelectLevel
	push bc
	ld bc, hMovingBGTilesCounter1
	add hl, bc
	pop bc
	jr DebugCreateBoxMon_MoveInputLoop

DebugCreateBoxMon_MoveCursorDown:
	inc de
	inc b
	ld a, b
	cp 5
	jp z, DebugCreateBoxMon_SelectDVs
	push bc
	ld bc, SCREEN_WIDTH * 2
	add hl, bc
	pop bc
	jr DebugCreateBoxMon_MoveInputLoop

DebugCreateBoxMon_PrintSelectedMove:
	push hl
	push de
	push bc
	push hl
	push de
	ld bc, hSpriteMapYCoord
	add hl, bc
	lb bc, 2, 11
	call ClearScreenArea
	pop de
	pop hl
	push hl
	ld [hl], '▶'
	ld bc, hMovingBGTilesCounter1
	add hl, bc
	ld [hl], ' '
	ld bc, SCREEN_WIDTH * 4
	add hl, bc
	ld [hl], ' '
	pop hl
	inc hl
	ld a, [de]
	ld de, wTempByteValue
	ld [de], a
	lb bc, LEADING_ZEROES | 1, 3
	call PrintNumber
	ld a, [wTempByteValue]
	and a
	jr z, .no_move
	call DebugCreateBoxMon_MarkIllegalMove
	inc hl
	call GetMoveName
	call PlaceString
.no_move
	pop bc
	pop de
	pop hl
	ret

DebugCreateBoxMon_MarkIllegalMove:
	ld a, [wCurPartySpecies]
	push af
	ld a, [wPokedexNum]
	push af
	push hl
	ld a, [wCurPartySpecies]
	ld [wPokedexNum], a
	callfar PokedexToIndex
	ld a, [wPokedexNum]
	ld [wCurPartySpecies], a
	pop hl
	pop af
	ld [wPokedexNum], a
	push hl
	callfar CanCurrentSpeciesOrPreEvolutionLearnMove
	pop hl
	jr c, .done
	ld [hl], '×'
.done
	pop af
	ld [wCurPartySpecies], a
	ret

DebugCreateBoxMon_SelectDVs:
	ld de, wEnemyMonOT
	hlcoord 0, 13
	ld b, 1
	; fallthrough
DebugCreateBoxMon_DVInputLoop:
	call DebugCreateBoxMon_PrintSelectedDVByte
.input_loop
	call DelayFrame
	push de
	push bc
	call JoypadLowSensitivity
	pop bc
	pop de
	ldh a, [hJoy5]
	bit B_PAD_A, a
	jp nz, DebugCreateBoxMon_IncrementDVByte
	bit B_PAD_B, a
	jp nz, DebugCreateBoxMon_DecrementDVByte
	bit B_PAD_START, a
	jp nz, DebugCreateBoxMon_SendToBox
	bit B_PAD_UP, a
	jp nz, DebugCreateBoxMon_DVCursorUp
	bit B_PAD_DOWN, a
	jp nz, DebugCreateBoxMon_DVCursorDown
	jr .input_loop

DebugCreateBoxMon_IncrementDVByte:
	ld a, [de]
	inc a
	ld [de], a
	jr DebugCreateBoxMon_DVInputLoop

DebugCreateBoxMon_DecrementDVByte:
	ld a, [de]
	dec a
	ld [de], a
	jr DebugCreateBoxMon_DVInputLoop

DebugCreateBoxMon_DVCursorUp:
	dec de
	dec b
	jp z, DebugCreateBoxMon_ReturnToMoveSelection
	push bc
	ld bc, hMovingBGTilesCounter1
	add hl, bc
	pop bc
	jr DebugCreateBoxMon_DVInputLoop

DebugCreateBoxMon_ReturnToMoveSelection:
	ld de, wMoves + 3
	hlcoord 0, 11
	ld b, NUM_MOVES
	jp DebugCreateBoxMon_MoveInputLoop

DebugCreateBoxMon_DVCursorDown:
	ld a, b
	cp 3
	jr z, DebugCreateBoxMon_DVInputLoop
	inc b
	inc de
	push bc
	ld bc, SCREEN_WIDTH * 2
	add hl, bc
	pop bc
	jr DebugCreateBoxMon_DVInputLoop

DebugCreateBoxMon_PrintSelectedDVByte:
	push hl
	push de
	push bc
	push hl
	ld [hl], '▶'
	ld bc, hMovingBGTilesCounter1
	add hl, bc
	ld [hl], ' '
	ld bc, SCREEN_WIDTH * 4
	add hl, bc
	ld [hl], ' '
	pop hl
	inc hl
	ld a, [de]
	ld de, wTempByteValue
	ld [de], a
	lb bc, LEADING_ZEROES | 1, 3
	call PrintNumber
	call DebugCreateBoxMon_PrintStats
	pop bc
	pop de
	pop hl
	ret

DebugCreateBoxMon_PrintStats:
	hlcoord 12, 0
	lb bc, 18, 8
	call ClearScreenArea
	hlcoord 13, 1
	ld de, DebugCreateBoxMonStatsText
	call PlaceString
	ld b, 10
	ld hl, wLoadedMonHPExp
	ld a, [wEnemyMonOT + 2]
.fill_stat_exp_loop
	ld [hli], a
	dec b
	jr nz, .fill_stat_exp_loop
	ld a, [wEnemyMonOT]
	ld [hli], a
	ld a, [wEnemyMonOT + 1]
	ld [hl], a
	ld hl, wLoadedMonExp + 2
	ld de, wLoadedMonStats
	ld b, 1
	call CalcStats
	hlcoord 17, 1
	ld de, wLoadedMonStats
	ld b, 5
.print_stats_loop
	push bc
	push de
	push hl
	lb bc, LEADING_ZEROES | 2, 3
	call PrintNumber
	pop hl
	ld bc, SCREEN_WIDTH * 2
	add hl, bc
	pop de
	inc de
	inc de
	pop bc
	dec b
	jr nz, .print_stats_loop
	ret

DebugCreateBoxMonStatsText:
	db   "たいりき"  ; hp
	next "こうげき"  ; attack
	next "ぼうぎょ"  ; defense
	next "すばやさ"  ; speed
	next "とくしゅ@" ; special

DebugCreateBoxMon_SendToBox:
	ld a, [wCurEnemyLevel]
	ld [wEnemyMonLevel], a
	ld a, [wCurPartySpecies]
	ld [wPokedexNum], a
	callfar PokedexToIndex
	ld a, [wPokedexNum]
	ld [wCurPartySpecies], a
	ld [wCurSpecies], a
	call GetMonHeader
	ld hl, wEnemyMon
	ld a, [wCurPartySpecies]
	ld [hli], a
	ld a, [wLoadedMonStats]
	ld [hli], a
	ld a, [wLoadedMonStats + 1]
	ld [hli], a
	xor a
	ld [hli], a
	ld [hli], a
	ld a, [wMonHTypes]
	ld [hli], a
	ld a, [wMonHType2]
	ld [hli], a
	ld a, [wMonHCatchRate]
	ld [hli], a
	ld a, [wMoves]
	ld [hli], a
	ld a, [wMoves + 1]
	ld [hli], a
	ld a, [wMoves + 2]
	ld [hli], a
	ld a, [wMoves + 3]
	ld [hl], a
	ld hl, wEnemyMonPP
	xor a
	ld [hli], a
	ld [hli], a
	ld [hli], a
	ld [hl], a
	ld a, [wEnemyMonOT]
	ld [wEnemyMonDVs], a
	ld a, [wEnemyMonOT + 1]
	ld [wEnemyMonDVs + 1], a
	callfar SendNewMonToBox
	ld b, 10
	ld hl, wBoxMon1HPExp
	ld a, [wEnemyMonOT + 2]
.fill_stat_exp_loop
	ld [hli], a
	dec b
	jr nz, .fill_stat_exp_loop
	ld a, 1
	ld [wDoNotWaitForButtonPressAfterDisplayingText], a
	pop af
	ld [wLetterPrintingDelayFlags], a
	jr DebugCreateBoxMon_Return
DebugCreateBoxMon_BoxFull:
	ld hl, DebugCreateBoxMonBoxFullText
	call PrintText
DebugCreateBoxMon_Return:
	ret

DebugCreateBoxMonBoxFullText:
	text_far _BoxFullDebugText
	text_end

DebugFillBoxes:
	ld a, 1
	ldh [hJoy7], a
	ld a, 2
	ld [wCurEnemyLevel], a
	ld hl, DebugFillBoxesConfirmText
	call PrintText
	call YesNoChoice
	ld a, [wCurrentMenuItem]
	and a
	jp nz, DebugFillBoxes_Return
	ld hl, DebugFillBoxesEmptyText
	call PrintText
	callfar EmptyAllSRAMBoxes
	ld hl, wBoxCount
	xor a
	ld [hli], a
	dec a
	ld [hl], a
	; fallthrough
DebugFillBoxes_SelectLevel:
	hlcoord 2, 13
	ld [hl], 'ﾞ'
	hlcoord 1, 14
	ld [hl], 'レ'
	inc hl
	ld [hl], 'へ'
	inc hl
	ld [hl], 'ル'
	inc hl
	inc hl
	ld de, wCurEnemyLevel
	lb bc, LEADING_ZEROES | 1, 3
	call PrintNumber
	call DelayFrame
	call JoypadLowSensitivity
	ldh a, [hJoy5]
	bit B_PAD_A, a
	jp nz, DebugFillBoxes_IncrementLevel
	bit B_PAD_B, a
	jp nz, DebugFillBoxes_DecrementLevel
	bit B_PAD_START, a
	jp nz, DebugFillBoxes_Start
	jr DebugFillBoxes_SelectLevel

DebugFillBoxes_IncrementLevel:
	ld a, [wCurEnemyLevel]
	inc a
	cp MAX_LEVEL + 1
	jr c, DebugFillBoxes_SetLevel
	ld a, 2
	jr DebugFillBoxes_SetLevel
DebugFillBoxes_DecrementLevel:
	ld a, [wCurEnemyLevel]
	dec a
	cp 2
	jr nc, DebugFillBoxes_SetLevel
	ld a, MAX_LEVEL
DebugFillBoxes_SetLevel:
	ld [wCurEnemyLevel], a
	jr DebugFillBoxes_SelectLevel

DebugFillBoxes_Start:
	ld c, 0
	ld d, 0
.next_box
	push bc
	push de
	call DebugFillBoxes_SwitchAndSaveBox
	ld hl, wChangeMonPicEnemyTurnSpecies
	inc [hl]
	pop de
	pop bc
	ld b, 30
.fill_box_loop
	inc c
	push bc
	push de
	ld a, c
	ld [wPokedexNum], a
	callfar PokedexToIndex
	ld a, [wPokedexNum]
	ld [wEnemyMonSpecies2], a
	ld [wCurPartySpecies], a
	xor a
	ld [wEnemyBattleStatus3], a
	callfar LoadEnemyMonData
	ld a, [wEnemyMonSpecies2]
	ld [wCurPartySpecies], a
	callfar SendNewMonToBox
	pop de
	pop bc
	ld a, c
	cp NUM_POKEMON
	jr z, DebugFillBoxes_Return
	dec b
	jr nz, .fill_box_loop
	inc d
	jr .next_box
	; fallthrough
DebugFillBoxes_Return:
	ld a, 1
	ld [wDoNotWaitForButtonPressAfterDisplayingText], a
	xor a
	ldh [hJoy7], a
	ret

DebugFillBoxesEmptyText:
	text_end

DebugFillBoxesConfirmText:
	text_far _BoxWillBeClearedText
	text_end

DebugFillBoxes_SwitchAndSaveBox:
	push de
	ld a, SFX_SAVE
	call PlaySoundWaitForCurrent
	call WaitForSoundToFinish
	call DebugFillBoxes_GetCurrentBoxPointer
	ld e, l
	ld d, h
	ld hl, wBoxCount
	call DebugFillBoxes_CopyAndClearBoxData
	pop de
	ld a, d
	set BIT_HAS_CHANGED_BOXES, a
	ld [wCurrentBoxNum], a
	push de
	call DebugFillBoxes_GetCurrentBoxPointer
	ld de, wBoxCount
	call DebugFillBoxes_CopyAndClearBoxData
	ld a, [wLetterPrintingDelayFlags]
	push af
	ld a, 1 << BIT_FAST_TEXT_DELAY
	ld [wLetterPrintingDelayFlags], a
	callfar SaveGameData
	pop af
	ld [wLetterPrintingDelayFlags], a
	pop de
	ret

DebugFillBoxes_GetCurrentBoxPointer:
	ld hl, DebugFillBoxesSRAMBoxPointers
	ld a, [wCurrentBoxNum]
	and %01111111
	cp 4
	ld b, 2
	jr c, .got_bank
	inc b
	and 3
.got_bank
	ld e, a
	ld d, 0
	add hl, de
	add hl, de
	ld a, [hli]
	ld h, [hl]
	ld l, a
	ret

DebugFillBoxesSRAMBoxPointers:
	dw sBox1
	dw sBox2
	dw sBox3
	dw sBox4

DebugFillBoxes_CopyAndClearBoxData:
	push hl
	call DebugEnableSRAM
	ld a, b
	ld [rRAMB], a
	ld bc, sBox2 - sBox1
	call CopyData
	pop hl
	xor a
	ld [hli], a
	dec a
	ld [hl], a
	ld hl, sBox1
	ld bc, sBox5 - sBox1 + 1
	call DebugFillBoxes_CalculateSRAMChecksum
	ld [sBox5], a
	call DebugDisableSRAM
	ret

DebugEnableSRAM: ; duplicate of EnableSRAM
	ld a, BMODE_ADVANCED
	ld [rBMODE], a
	ld a, RAMG_SRAM_ENABLE
	ld [rRAMG], a
	ret

DebugDisableSRAM: ; duplicate of DisableSRAM
	ld a, 0
	ld [rBMODE], a
	ld [rRAMG], a
	ret

DebugFillBoxes_CalculateSRAMChecksum:
	ld d, 0
.sum_loop
	ld a, [hli]
	add d
	ld d, a
	dec bc
	ld a, b
	or c
	jr nz, .sum_loop
	ld a, d
	cpl
	ret
ELSE
	ret
ENDC
