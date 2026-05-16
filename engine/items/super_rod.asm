ReadSuperRodData:
	ld a, [wCurMap]
	ld c, a
	ld hl, SuperRodFishingSlots
.loop
	ld a, [hli]
	cp $ff
	jr z, .notfound
	cp c
	jr z, .found
	ld de, $8
	add hl, de
	jr .loop
.found
	call GenerateRandomFishingEncounter
	ret
.notfound
	ld de, $0
	ret

GenerateRandomFishingEncounter:
	call Random
	cp $66
	jr c, .select_slot
	inc hl
	inc hl
	cp $b2
	jr c, .select_slot
	inc hl
	inc hl
	cp $e5
	jr c, .select_slot
	inc hl
	inc hl
.select_slot
	ld e, [hl]
	inc hl
	ld d, [hl]
	ret

INCLUDE "data/wild/super_rod.asm"
