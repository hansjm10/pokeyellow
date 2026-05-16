CinnabarGymPrintGymGuideText::
	CheckEvent EVENT_BEAT_BLAINE
	jr nz, .afterBeat
	ld hl, .ChampInMakingText
	jr .done
.afterBeat
	ld hl, .BeatBlaineText
.done
	call PrintText
	ret

.ChampInMakingText:
	text_far _CinnabarGymGymGuideChampInMakingText
	text_end

.BeatBlaineText:
	text_far _CinnabarGymGymGuideBeatBlaineText
	text_end

PrintCinnabarGymQuizText::
	ld hl, CinnabarGymQuizTextPointers
	ld d, 0
	add hl, de
	add hl, de
	ld a, [hli]
	ld h, [hl]
	ld l, a
	jp PrintText

CinnabarGymQuizTextPointers:
	dw CinnabarGymQuizText1
	dw CinnabarGymQuizText2
	dw CinnabarGymQuizText3
	dw CinnabarGymQuizText4
	dw CinnabarGymQuizText5
	dw CinnabarGymQuizText6

CinnabarGymQuizText1:
	text_far _CinnabarGymText_1
	text_end

CinnabarGymQuizText2:
	text_far _CinnabarGymText_2
	text_end

CinnabarGymQuizText3:
	text_far _CinnabarGymText_3
	text_end

CinnabarGymQuizText4:
	text_far _CinnabarGymText_4
	text_end

CinnabarGymQuizText5:
	text_far _CinnabarGymText_5
	text_end

CinnabarGymQuizText6:
	text_far _CinnabarGymText_6
	text_end

CinnabarGymUnusedAnswerTheQuestionText:
	text_far _CinnabarGymText_7 ; unused
	text_end
