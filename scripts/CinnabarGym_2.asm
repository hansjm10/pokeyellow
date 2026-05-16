CinnabarGymPrintQuizTextScript:
	callfar PrintCinnabarGymQuizText
	jp TextScriptEnd

ResetCinnabarGymWrongAnswerFlag:
	push hl
	ld hl, wCinnabarGymQuizFlags
	bit 7, [hl]
	res 7, [hl]
	pop hl
	ret

CheckCinnabarGymWrongAnswerPending:
	push hl
	ld hl, wCinnabarGymQuizFlags
	bit 7, [hl]
	pop hl
	ret
