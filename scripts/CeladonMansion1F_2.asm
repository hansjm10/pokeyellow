CeladonMansion1FPrintGrannyText::
	ld a, $1
	ld [wDoNotWaitForButtonPressAfterDisplayingText], a
	ld hl, CeladonMansionGrannyPokemonCompanyText
	call PrintText
	callfar IsStarterPikachuAliveInOurParty
	ret nc
	ld hl, CeladonMansionGrannyPikachuIntroText
	call PrintText
	ld a, $0
	ld [wDoNotWaitForButtonPressAfterDisplayingText], a
	call GetCeladonMansionPikachuHappinessText
	call PrintText
	ret

CeladonMansionGrannyPokemonCompanyText:
	text_far _CeladonMansion1Text2
	text_waitbutton
	text_end

CeladonMansionGrannyPikachuIntroText:
	text_far _CeladonMansion1Text6
	text_promptbutton
	text_end

GetCeladonMansionPikachuHappinessText:
	ld hl, CeladonMansionPikachuHappinessTextThresholds
.loop
	ld a, [hli]
	inc hl
	and a
	jr z, .done
	ld b, a
	ld a, [wPikachuHappiness]
	cp b
	jr c, .done
	inc hl
	inc hl
	jr .loop

.done
	ld a, [hli]
	ld h, [hl]
	ld l, a
	ret

CeladonMansionPikachuHappinessTextThresholds:
	dw   51, CeladonMansionPikachuUntamedText
	dw  101, CeladonMansionPikachuNeedsCareText
	dw  131, CeladonMansionPikachuCuteText
	dw  161, CeladonMansionPikachuTamedText
	dw  201, CeladonMansionPikachuHappyText
	dw  255, CeladonMansionPikachuFantasticDuoText
	dw -256, CeladonMansionPikachuFantasticDuoText

CeladonMansionPikachuUntamedText:
	text_far _CeladonMansion1Text7
	text_end

CeladonMansionPikachuNeedsCareText:
	text_far _CeladonMansion1Text8
	text_end

CeladonMansionPikachuCuteText:
	text_far _CeladonMansion1Text9
	text_end

CeladonMansionPikachuTamedText:
	text_far _CeladonMansion1Text10
	text_end

CeladonMansionPikachuHappyText:
	text_far _CeladonMansion1Text11
	text_end

CeladonMansionPikachuFantasticDuoText:
	text_far _CeladonMansion1Text12
	text_end
