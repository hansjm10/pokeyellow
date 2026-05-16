SurfingPikachuFrames:
	dw SurfingPikachuFrame00 ; 00
	dw SurfingPikachuFrame01 ; 01
	dw SurfingPikachuFrame02 ; 02
	dw SurfingPikachuFrame03 ; 03
	dw SurfingPikachuFrame04 ; 04
	dw SurfingPikachuFrame05 ; 05
	dw SurfingPikachuFrame06 ; 06
	dw SurfingPikachuFrame07 ; 07
	dw SurfingPikachuFrame08 ; 08
	dw SurfingPikachuFrame09 ; 09
	dw SurfingPikachuFrame0A ; 0a
	dw SurfingPikachuFrame0B ; 0b
	dw SurfingPikachuFrame0C ; 0c
	dw SurfingPikachuFrame0D ; 0d
	dw SurfingPikachuFrame0E ; 0e
	dw SurfingPikachuFrame0F ; 0f
	dw SurfingPikachuFrame10 ; 10
	dw SurfingPikachuFrame11 ; 11
	dw SurfingPikachuFrame12 ; 12
	dw SurfingPikachuFrame13 ; 13
	dw SurfingPikachuFrame14 ; 14
	dw SurfingPikachuFrame15 ; 15
	dw SurfingPikachuFrame16 ; 16
	dw SurfingPikachuFrame17 ; 17
	dw SurfingPikachuFrame18 ; 18
	dw SurfingPikachuFrame19 ; 19
	dw SurfingPikachuFrame1A ; 1a
	dw SurfingPikachuFrame1B ; 1b

SurfingPikachuFrame00:
	frame $00, 32
	endanim

SurfingPikachuFrame01:
	frame $01, 8
	frame $02, 8
	dorestart

SurfingPikachuFrame02:
	frame $03, 8
	frame $04, 8
	dorestart

SurfingPikachuFrame03:
	frame $05, 8
	frame $06, 8
	dorestart

SurfingPikachuFrame04:
	frame $07, 8
	frame $08, 8
	dorestart

SurfingPikachuFrame05:
	frame $09, 8
	frame $0a, 8
	dorestart

SurfingPikachuFrame06:
	frame $0b, 8
	frame $0c, 8
	dorestart

SurfingPikachuFrame07:
	frame $0d, 8
	frame $0e, 8
	dorestart

SurfingPikachuFrame08:
	frame $01, 8, OAM_XFLIP, OAM_YFLIP
	frame $02, 8, OAM_XFLIP, OAM_YFLIP
	dorestart

SurfingPikachuFrame09:
	frame $03, 8, OAM_XFLIP, OAM_YFLIP
	frame $04, 8, OAM_XFLIP, OAM_YFLIP
	dorestart

SurfingPikachuFrame0A:
	frame $05, 8, OAM_XFLIP, OAM_YFLIP
	frame $06, 8, OAM_XFLIP, OAM_YFLIP
	dorestart

SurfingPikachuFrame0B:
	frame $07, 8, OAM_XFLIP, OAM_YFLIP
	frame $08, 8, OAM_XFLIP, OAM_YFLIP
	dorestart

SurfingPikachuFrame0C:
	frame $09, 8, OAM_XFLIP, OAM_YFLIP
	frame $0a, 8, OAM_XFLIP, OAM_YFLIP
	dorestart

SurfingPikachuFrame0D:
	frame $0b, 8, OAM_XFLIP, OAM_YFLIP
	frame $0c, 8, OAM_XFLIP, OAM_YFLIP
	dorestart

SurfingPikachuFrame0E:
	frame $0d, 8, OAM_XFLIP, OAM_YFLIP
	frame $0e, 8, OAM_XFLIP, OAM_YFLIP
	dorestart

SurfingPikachuFrame0F:
	frame $11, 7
	frame $12, 7
	dorestart

SurfingPikachuFrame10:
	frame $13, 2
	frame $14, 2
	dorepeat 8
	frame $15, 2
	endanim

SurfingPikachuFrame11:
	frame $16, 32
	frame $16, 32
	delanim

SurfingPikachuFrame12:
	frame $17, 32
	frame $17, 32
	delanim

SurfingPikachuFrame13:
	frame $18, 32
	endanim

SurfingPikachuFrame15:
	frame $1a, 4
	dorepeat 1
	frame $1a, 3
	dorepeat 1
	frame $1a, 2
	dorepeat 1
	frame $1a, 1
	delanim

SurfingPikachuFrame16:
	frame $1b, 4
	dorepeat 1
	frame $1b, 3
	dorepeat 1
	frame $1b, 2
	dorepeat 1
	frame $1b, 1
	delanim

SurfingPikachuFrame17:
	frame $1c, 4
	dorepeat 1
	frame $1c, 3
	dorepeat 1
	frame $1c, 2
	dorepeat 1
	frame $1c, 1
	delanim

SurfingPikachuFrame18:
	frame $1d, 4
	dorepeat 1
	frame $1d, 3
	dorepeat 1
	frame $1d, 2
	dorepeat 1
	frame $1d, 1
	delanim

SurfingPikachuFrame19:
	frame $1e, 4
	dorepeat 1
	frame $1e, 3
	dorepeat 1
	frame $1e, 2
	dorepeat 1
	frame $1e, 1
	delanim

SurfingPikachuFrame1A:
	frame $1f, 4
	dorepeat 1
	frame $1f, 3
	dorepeat 1
	frame $1f, 2
	dorepeat 1
	frame $1f, 1
	delanim

SurfingPikachuFrame14:
	frame $19, 1
	delanim

SurfingPikachuFrame1B:
	frame $20, 7
	frame $21, 7
	frame $22, 7
	frame $23, 7
	dorestart
