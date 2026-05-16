Museum2F_Script:
	call EnableAutoTextBoxDrawing
	ret

Museum2F_TextPointers:
	def_text_pointers
	dw_const Museum2FYoungsterText,        TEXT_MUSEUM2F_YOUNGSTER
	dw_const Museum2FGrampsText,           TEXT_MUSEUM2F_GRAMPS
	dw_const Museum2FScientistText,        TEXT_MUSEUM2F_SCIENTIST
	dw_const Museum2FBrunetteGirlText,     TEXT_MUSEUM2F_BRUNETTE_GIRL
	dw_const Museum2FHikerText,            TEXT_MUSEUM2F_HIKER
	dw_const Museum2FSpaceShuttleSignText, TEXT_MUSEUM2F_SPACE_SHUTTLE_SIGN
	dw_const Museum2FMoonStoneSignText,    TEXT_MUSEUM2F_MOON_STONE_SIGN

Museum2FYoungsterText:
	text_far _Museum2FYoungsterText
	text_end

Museum2FGrampsText:
	text_far _Museum2FGrampsText
	text_end

Museum2FScientistText:
	text_far _Museum2FScientistText
	text_end

Museum2FBrunetteGirlText:
	text_far _Museum2FBrunetteGirlText
	text_end

Museum2FHikerText:
	text_asm
	ld a, [wPikachuStatusFlags]
	bit 7, a
	jr nz, .check_pikachu_happiness
	ld hl, Museum2FHikerNoPikachuText
	call PrintText
	jr .done

.check_pikachu_happiness
	ld a, [wPikachuHappiness]
	cp 101
	jr c, .low_happiness
	ld hl, Museum2FHikerHighHappinessPikachuText
	call PrintText
	jr .done

.low_happiness
	ld hl, Museum2FHikerLowHappinessPikachuText
	call PrintText
.done
	jp TextScriptEnd

Museum2FHikerNoPikachuText:
	text_far _Museum2FHikerText
	text_end

Museum2FHikerLowHappinessPikachuText:
	text_far _Museum2FPikachuText1
	text_end

Museum2FHikerHighHappinessPikachuText:
	text_far _Museum2FPikachuText2
	text_end

Museum2FSpaceShuttleSignText:
	text_far _Museum2FSpaceShuttleSignText
	text_end

Museum2FMoonStoneSignText:
	text_far _Museum2FMoonStoneSignText
	text_end
