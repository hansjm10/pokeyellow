SummerBeachHousePrintHighScore:
	call SaveScreenTilesToBuffer2
	xor a
	ld [wUpdateSpritesEnabled], a
	ld hl, wStatusFlags5
	set BIT_NO_TEXT_DELAY, [hl]
	callfar PrintSurfingMinigameHighScore
	ld hl, wStatusFlags5
	res BIT_NO_TEXT_DELAY, [hl]
	call GBPalWhiteOutWithDelay3
	call ReloadTilesetTilePatterns
	call RestoreScreenTilesAndReloadTilePatterns
	call LoadScreenTilesFromBuffer2
	call Delay3
	call GBPalNormal
	ld hl, SummerBeachHousePrintErrorText
	ldh a, [hOaksAideResult]
	and a
	jr nz, .print_result
	ld hl, SummerBeachHousePrintCompletedText
.print_result
	call PrintText
	jp TextScriptEnd

SummerBeachHousePrintCompletedText:
	text_far _SummerBeachHousePrinterText5
	text_waitbutton
	text_end

SummerBeachHousePrintErrorText:
	text_far _SummerBeachHousePrinterText6
	text_waitbutton
	text_end
