CeruleanMelaniesHouse_Script:
	call EnableAutoTextBoxDrawing
	ret

CeruleanMelaniesHouse_TextPointers:
	def_text_pointers
	dw_const CeruleanMelanieHouseMelanieText, TEXT_CERULEANMELANIESHOUSE_MELANIE
	dw_const CeruleanMelanieHouseBulbasaurText, TEXT_CERULEANMELANIESHOUSE_BULBASAUR
	dw_const CeruleanMelanieHouseOddishText, TEXT_CERULEANMELANIESHOUSE_ODDISH
	dw_const CeruleanMelanieHouseSandshrewText, TEXT_CERULEANMELANIESHOUSE_SANDSHREW

CeruleanMelanieHouseMelanieText:
	text_asm
	ld a, $1
	ld [wDoNotWaitForButtonPressAfterDisplayingText], a
	CheckEvent EVENT_GOT_BULBASAUR_IN_CERULEAN
	jr nz, .already_got_bulbasaur
	ld hl, MelanieIntroText
	call PrintText
	ld a, [wPikachuHappiness]
	cp 147
	jr c, .done
	ld hl, MelanieOfferBulbasaurText
	call PrintText
	call YesNoChoice
	ld a, [wCurrentMenuItem]
	and a
	jr nz, .declined_bulbasaur
	ld a, $1
	ld [wDoNotWaitForButtonPressAfterDisplayingText], a
	ld a, BULBASAUR
	ld [wNamedObjectIndex], a
	ld [wCurPartySpecies], a
	call GetMonName
	ld a, $1
	ld [wDoNotWaitForButtonPressAfterDisplayingText], a
	lb bc, BULBASAUR, 10
	call GivePokemon
	jr nc, .done
	ld a, [wAddedToParty]
	and a
	call z, WaitForTextScrollButtonPress
	ld a, $1
	ld [wDoNotWaitForButtonPressAfterDisplayingText], a
	ld hl, MelanieGaveBulbasaurText
	call PrintText
	ld a, TOGGLE_CERULEAN_BULBASAUR
	ld [wToggleableObjectIndex], a
	predef HideObject
	SetEvent EVENT_GOT_BULBASAUR_IN_CERULEAN
.done
	jp TextScriptEnd

.declined_bulbasaur
	ld hl, MelanieDeclinedBulbasaurText
	call PrintText
	jp TextScriptEnd

.already_got_bulbasaur
	ld hl, MelanieBulbasaurDoingWellText
	call PrintText
	jp TextScriptEnd

MelanieIntroText:
	text_far MelanieText1
	text_waitbutton
	text_end

MelanieOfferBulbasaurText:
	text_far MelanieText2
	text_end

MelanieGaveBulbasaurText:
	text_far MelanieText3
	text_waitbutton
	text_end

MelanieBulbasaurDoingWellText:
	text_far MelanieText4
	text_waitbutton
	text_end

MelanieDeclinedBulbasaurText:
	text_far MelanieText5
	text_waitbutton
	text_end

CeruleanMelanieHouseBulbasaurText:
	text_far MelanieBulbasaurText
	text_asm
	ld a, BULBASAUR
	call PlayCry
	jp TextScriptEnd

CeruleanMelanieHouseOddishText:
	text_far MelanieOddishText
	text_asm
	ld a, ODDISH
	call PlayCry
	jp TextScriptEnd

CeruleanMelanieHouseSandshrewText:
	text_far MelanieSandshrewText
	text_asm
	ld a, SANDSHREW
	call PlayCry
	jp TextScriptEnd
