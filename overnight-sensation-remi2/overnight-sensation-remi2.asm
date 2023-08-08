;******************************************************************************
;      Ｏｖｅｒｎｉｇｈｔ　Ｓｅｎｓａｔｉｏｎ ＲＥＭＩ２（リミックツー）
;			～時代はあなたに委ねてる～
;
;			1997 ABCP ALL RIGHT RESERVED.
;
;							Ver.1997-03-03 21:43:17
;******************************************************************************

	.186

CODE	SEGMENT
	ASSUME	CS:CODE,DS:CODE,SS:CODE,ES:CODE
	ORG	0100H
START:
	ORG	2000H
	MOV	AX,000FH
	OUT	18H,AX
	STI
	MOV	AH,10H
	INT	41H
	MOV	BYTE PTR MODE,1
	MOV	BX,0205H
	MOV	DI,OFFSET COPYRIGHT
	CALL	PRINT
	MOV	CX,04000H
COPYRIGHT_LOOP:
	CALL	BREAK_KEY_CHECK
	LOOP	COPYRIGHT_LOOP
BEGIN:
	MOV	AH,10H			;CLS(BIOS)
	INT	41H
BDISP1:
	MOV	SI,OFFSET TITLE_GRAPH
BDISP:
	MOV	AX,0A000H
	MOV	ES,AX
	XOR	DI,DI
	MOV	AL,23H
	STOSB
	MOV	AL,35H
	STOSB
	MOV	DL,4
	MOV	AL,21H
	STOSB
	MOV	AL,DL
	STOSB
	MOV	AL,22H
	STOSB
	MOV	AL,3
	STOSB
	MOV	AL,20H
	STOSB
	MOV	CX,16
BDILP0:
	LODSB
	DB	0C0H,0E8H,004H		;SHR AL,4
	STOSB
	INC	DI
	LOOP	BDILP0
BDILP1:
	INC	DL
	INC	DI
	MOV	AL,21H
	STOSB
	MOV	AL,DL
	STOSB
	MOV	AL,22H
	STOSB
	MOV	AL,3
	STOSB
	MOV	AL,20H
	STOSB
	MOV	CX,16
BDILP2:
	DB	08AH,064H,0F0H		;MOV AH,[SI-Y_LEN]
	LODSB
	DB	0C1H,0E8H,004H		;SHR AX,4
	STOSB
	INC	DI
	LOOP	BDILP2
	CMP	DL,16
	JNZ	BDILP1
	SUB	SI,16
	MOV	DL,3
BDILP3:
	INC	DL
	INC	DI
	MOV	AL,21H
	STOSB
	MOV	AL,DL
	STOSB
	MOV	AL,22H
	STOSB
	MOV	AL,35
	STOSB
	MOV	AL,20H
	STOSB
	MOV	CX,16
BDILP4:
	DB	08AH,064H,0F0H		;MOV AH,[SI-Y_LEN]
	LODSB
	DB	0C1H,0E8H,004H
	STOSB
	INC	DI
	LOOP	BDILP4
	CMP	DL,16
	JNZ	BDILP3
	INC	DI

	MOV	AL,23H
	STOSB
	MOV	AL,75H
	STOSB
	MOV	AL,20H
	STOSB

	XOR	AX,AX
	MOV	ES,AX
	MOV	DS,AX

	MOV	BX,0319H
	MOV	DI,OFFSET REMI2
	CALL	PRINT

	MOV	BX,0402H
	MOV	DI,OFFSET NAME
	CALL	PRINT

MODE_1:
	MOV	BL,BYTE PTR MODE
	MOV	DL,12
	CALL	LCDC			;カ－ソル
	CALL	BREAK_KEY_CHECK

        MOV     AX,0080H
        MOV     DX,00200H               ;KOPORT
        OUT     DX,AX
        CALL    K_WAIT
        MOV     DL,2
        IN      AX,DX
        AND	AX,0020H
        JZ      MODE_2
	MOV	DL,11
	CALL	LCDC			;カ－ソル消す
	MOV	BYTE PTR MODE,1 	;ＡＧＲＥＥ　ＭＩＸ
MODE_2:
        MOV     AX,0200H
        MOV     DX,00200H               ;KOPORT
        OUT     DX,AX
        CALL    K_WAIT
        MOV     DL,2
        IN      AX,DX
        AND	AX,0040H
        JZ      MODE_3
	MOV	DL,11
	CALL	LCDC
	MOV	BYTE PTR MODE,14	;ＭＯＤＥ＝14　Ｆ・２・Ｆ　ＭＩＸ
MODE_3:
        MOV     AX,0080H
        MOV     DX,00200H               ;KOPORT
        OUT     DX,AX
        CALL    K_WAIT
        MOV     DL,2
        IN      AX,DX
        AND	AX,0200H
	JZ	MODE_1
	MOV	AH,10H
	INT	41H

	MOV	BYTE PTR LASTKEY,0
	XOR	BX,BX
	MOV	SI,OFFSET BRAM
M_ARROW:				;問題制作
	CALL	RND
	AND	DX,0007H		;０＜＝ＤＸ＜＝７
	INC	DX
	MOV	CX,DX
MAKE_RND:
	CALL	RND			;重複を避ける
	LOOP	MAKE_RND
	AND	DL,3			;０＜＝ＤＬ＜＝３
	MOV	[SI+BX],DL
	INC	BX
	CMP	BX,160
	JNE	M_ARROW

DISP:					;ブロック表示
	MOV	SI,OFFSET BRAM
	XOR	BH,BH			;矢印
DISP_1:
	XOR	BL,BL
DISP_2:
	MOV	DL,[SI] 		;読み込み
	CALL	LCDC
	INC	SI
	INC	BL
	CMP	BL,32
	JNE	DISP_2
	INC	BH
	CMP	BH,5
	JNE	DISP_1

	XOR	BX,BX			;ゲ－ムオ－バ－判定
	XOR	CX,CX			;ＣＸ＝矢印Ｂ
	XOR	DX,DX			;ＤＸ＝残りの矢印
	MOV	SI,OFFSET BRAM
OVER_1:
	MOV	AL,[SI+BX]
	CMP	AL,4
	JE	OVER_2
	INC	DX
	PUSH	BX
	CALL	CHECK
	POP	BX
	CMP	AL,4
	JE	OVER_2
	INC	CX			;矢印Ｂを探す
OVER_2:
	INC	BX
	CMP	BX,160
	JNE	OVER_1
	OR	CX,CX			;ゲ－ムオ－バ－でない
	JZ	OVER_3
	JMP	KEYIN

OVER_3:
	MOV	BX,0109H
	MOV	DI,OFFSET MSG1
	CALL	PRINT
	MOV	BX,0209H
	OR	DX,DX
	JZ	OVER_4
	MOV	DI,OFFSET MSG2
	CALL	PRINT

	MOV	CH,0
	MOV	BX,0211H
				;AX/CL=AL...AH
	MOV	AX,DX
	MOV	CL,100
	DIV	CL
	CMP	AL,0
	JNZ	K_100
	CMP	CH,0
	JZ	DL_1
K_100:
	MOV	DL,AL
	ADD	DL,30H
	CALL	LCDC
	MOV	CH,1
DL_1:
	INC	BL
	MOV	AL,AH
	XOR	AH,AH
	MOV	CL,10
	DIV	CL
	CMP	AL,0
	JNZ	K_10
	CMP	CH,0
	JZ	DL_1
K_10:
	MOV	DL,AL
	ADD	DL,30H
	CALL	LCDC
DL_2:
	INC	BL
	MOV	DL,AH
	ADD	DL,30H
	CALL	LCDC

	JMP	SHORT	OVER_5
OVER_4:
	MOV	DI,OFFSET MSG3
	CALL	PRINT
OVER_5:
        MOV     AX,0080H
        MOV     DX,00200H               ;KOPORT
        OUT     DX,AX
        CALL    K_WAIT
        MOV     DL,2
        IN      AX,DX
        AND	AX,0200H
	JZ	OVER_5
OVER_6:
        MOV     AX,0080H
        MOV     DX,00200H               ;KOPORT
        OUT     DX,AX
        CALL    K_WAIT
        MOV     DL,2
        IN      AX,DX
        AND	AX,0200H
	JNZ	OVER_6
	JMP	BEGIN
KEYIN:					;キ－入力

	CALL	BREAK_KEY_CHECK

	MOV	BH,0FFH 		;２，４，６，８，ＳＰＣ以外の時
        MOV     AX,0100H
        MOV     DX,00200H               ;KOPORT
        OUT     DX,AX
        CALL    K_WAIT
        MOV     DL,2
        IN      AX,DX
        AND	AX,0010H
	JZ	KEY_1
	XOR	BH,BH
KEY_1:
        MOV     AX,0200H
        MOV     DX,00200H               ;KOPORT
        OUT     DX,AX
        CALL    K_WAIT
        MOV     DL,2
        IN      AX,DX
        AND	AX,0040H
	JZ	KEY_2
	MOV	BH,1
KEY_2:
        MOV     AX,0100H
        MOV     DX,00200H               ;KOPORT
        OUT     DX,AX
        CALL    K_WAIT
        MOV     DL,2
        IN      AX,DX
        AND	AX,0040H
	JZ	KEY_3
	MOV	BH,2
KEY_3:
        MOV     AX,0080H
        MOV     DX,00200H               ;KOPORT
        OUT     DX,AX
        CALL    K_WAIT
        MOV     DL,2
        IN      AX,DX
        AND	AX,0020H
	JZ	KEY_4
	MOV	BH,3
KEY_4:
        MOV     AX,0004H
        MOV     DX,00200H               ;KOPORT
        OUT     DX,AX
        CALL    K_WAIT
        MOV     DL,2
        IN      AX,DX
        AND	AX,0008H
	JZ	KEY_5
	CMP	BYTE PTR MODE,1 	;ＡＧＲＥＥ　ＭＩＸ
	JE	KEY_5
	MOV	BH,4
KEY_5:
	CMP	BYTE PTR LASTKEY,BH
	JE	KEYIN
	MOV	BYTE PTR LASTKEY,BH
	CMP	BH,255
	JZ	KEYIN
	MOV	DH,BH
INIT:					;フラグ初期化
	MOV	DI,OFFSET FLAG
	XOR	AX,AX
	MOV	CX,160
	REP	STOSB
	XOR	BX,BX
	MOV	SI,OFFSET BRAM
	MOV	DI,OFFSET FLAG
ATARI_1:
	PUSH	BX
	MOV	CX,BX			;ＰＵＳＨ　ＢＸ
	MOV	AL,[SI+BX]		;ＡＬ＝矢印Ａ
	MOV	DL,AL			;ＤＬ＝矢印Ａ
	CMP	AL,4			;ＳＰＣ
	JE	ATARI_E
	CALL	CHECK			;ＡＬ＝矢印Ｂ
	CMP	AL,4
	JE	ATARI_E
	XOR	AL,DL

;F.2.F
	CMP	DH,4
	JNE	C_2468
	CMP	AL,2			;Ｆ・２・Ｆ　ＭＩＸ
	JNE	ATARI_E
	XCHG	BX,CX			;ＰＯＰ　ＢＸ
	MOV	BYTE PTR [DI+BX],1
	XCHG	BX,CX			;ＰＵＳＨ　ＢＸ
	JMP	SHORT	ARROW_B

C_2468:
	CMP	DH,DL
	JNE	ATARI_E
	OR	AL,AL
	JNE	TURN
	CMP	BYTE PTR MODE,1
	JNE	TURN
ARROW_B:
	MOV	BYTE PTR [DI+BX],1
	JMP	SHORT	ATARI_E
TURN:
	MOV	BYTE PTR [DI+BX],2
ATARI_E:				;反応なし、または終了
	POP	BX
	INC	BX
	CMP	BX,160
	JNE	ATARI_1

EXE:
	XOR	BX,BX
EXE_1:
	MOV	AL,[DI+BX]		;読み込み
	OR	AL,AL			;０＝何もしない
	JE	EXE_E
	CMP	AL,2			;２＝回転
	JE	EXE_2

	MOV	BYTE PTR [SI+BX],4	;1=Vanish
	JMP	SHORT	EXE_E

EXE_2:
	MOV	AL,[SI+BX]
	INC	AL
	AND	AL,3
	MOV	[SI+BX],AL

EXE_E:
	INC	BX
	CMP	BX,160
	JNE	EXE_1

	MOV	DL,13
VANISH:
	XOR	AH,AH
	MOV	DI,OFFSET FLAG

	MOV	BH,0
VANISH_1:
	MOV	BL,0
VANISH_2:
	CMP	BYTE PTR [DI],1
	JNE	VANISH_N
	CALL	LCDC
	MOV	AH,1			;ＡＨ＝１　アニメ処理
VANISH_N:
	INC	DI
	INC	BL
	CMP	BL,32
	JNE	VANISH_2
	INC	BH
	CMP	BH,5
	JNE	VANISH_1
	OR	AH,AH
	JE	VANISH_E

	MOV	CX,2800H
WAIT:
	LOOP	WAIT			;ＷＡＩＴ
	INC	DL
	CMP	DL,19
	JNE	VANISH
VANISH_E:
	JMP	DISP

PRINT:
	PUSHA
PRINT_LOOP:
	MOV	DL,[DI]
	CMP	DL,0
	JZ	PRINT_END
	CALL	LCDC
	INC	DI
	INC	BL
	JMP	SHORT	PRINT_LOOP
PRINT_END:
	POPA
	RET
;**************************************
;LCDCアクセス
;**************************************

LCDC:					;ＤＬ＝ＮＵＭ、ＢＨ＝Ｙ、ＢＬ＝Ｘ
	PUSHA
	PUSH	ES
	PUSH	DS
	XOR	DI,DI
	MOV	DS,DI
	MOV	AX,0A000H		;LCDCレジスタのセグメント
	MOV	ES,AX
	MOV	AL,21H			;XAD設定
	STOSB
	MOV	AL,BL
	AND	AL,0FH			;下位4ビット
	ADD	AL,6			;足すことの6
	STOSB
	MOV	AL,22H			;YAD設定
	STOSB
	MOV	AL,BH			;Ｙ座標を
	SAL	BH,1
	DB	0C0H,0D0H,002H		;SAL AL,2
	ADD	AL,BH			;6倍する
	SAL	BL,1
	AND	BL,20H			;右半分の時は
	ADD	AL,BL			;Ｙ座標に20H加算する
	INC	AL			;一番上の空きの分
	STOSB
	CMP	DL,65
	JC	FONT_1
	SUB	DL,7
FONT_1:
	CMP	DL,48
	JC	FONT_2
	SUB	DL,29
FONT_2:
	XOR	DH,DH			;キャラクタコードを
	SAL	DX,1
	MOV	CX,DX
	SAL	DX,1			;6倍して
	ADD	DX,CX
	ADD	DX,OFFSET CHR		;フォントのオフセットを加算
	MOV	SI,DX
	MOV	CX,6			;6回ループ
WRITE_S:
	MOV	AL,20H			;DRAM設定
	STOSB
WRITE_L:
	LODSB				;フォントデータの読み込み
	PUSH	BX
	POP	BX
	STOSB				;LCDCに転送
	DEC	DI
	LOOP	WRITE_L 		;6回ループ
	POP	DS
	POP	ES
	POPA
	RET

RND:					;０＜＝ＤＬ＜＝２５５
	PUSH	AX
	PUSH	BX
	PUSH	CX
RNDDT:
	MOV	CX,0ABC5H
	MOV	BH,CH
	MOV	BL,CL
	ADD	CX,BX
	ADD	CX,BX
	MOV	DL,CL
	ADD	DL,CH
	MOV	CH,DL
	ADD	CX,0038H
	MOV	BX,0001H
	DB	089H,08FH		;ＭＯＶ　［ＢＸ＋ＲＮＤＤＴ］、ＣＸ
	DW	RNDDT			;自己書き換え
	MOV	DL,CH
	POP	CX
	POP	BX
	POP	AX
	RET

CHECK:
	PUSH	CX
	MOV	CX,BX

CHECK_1:
	OR	AL,AL			;上
	JNE	CHECK_2
	SUB	CX,32
	JNC	CHECK_2
	ADD	CX,160

CHECK_2:
	CMP	AL,1			;右
	JNE	CHECK_4
	INC	CX
	CMP	CX,32
	JE	CHECK_3
	CMP	CX,64
	JE	CHECK_3
	CMP	CX,96
	JE	CHECK_3
	CMP	CX,128
	JE	CHECK_3
	CMP	CX,160
	JNE	CHECK_4
CHECK_3:
	SUB	CX,32

CHECK_4:
	CMP	AL,2			;下
	JNE	CHECK_5
	ADD	CX,32
	CMP	CX,160
	JC	CHECK_5
	SUB	CX,160

CHECK_5:
	CMP	AL,3			;左
	JNE	CHECK_7
	SUB	CX,1
	JC	CHECK_6
	CMP	CX,31
	JE	CHECK_6
	CMP	CX,63
	JE	CHECK_6
	CMP	CX,95
	JE	CHECK_6
	CMP	CX,127
	JNE	CHECK_7

CHECK_6:
	ADD	CX,32

CHECK_7:
	MOV	BX,CX
	MOV	AL,[SI+BX]
	POP	CX
	RET

K_WAIT:                                 ;キー入力のときのウエイト
        PUSH    CX
        MOV     CX,00009H
KK_WAIT:
        LOOP    KK_WAIT
        POP     CX
        RET

BREAK_KEY_CHECK:
        MOV     AX,0001H
        MOV     DX,00200H               ;KOPORT
        OUT     DX,AX
        CALL    K_WAIT
        MOV     DL,2
        IN      AX,DX
        AND	AX,0001H
	JZ	BREAK_KEY_CHECK_END
	MOV	AH,7FH
	INT	41H
BREAK_KEY_CHECK_END:
	RET

;**************************************
;タイトルのでかい文字
;上→下、左→右、８ビット
;**************************************
TITLE_GRAPH:
	DB	000H,001H,007H,006H,00CH,018H,018H,018H
	DB	018H,018H,018H,00CH,007H,000H,000H,000H
	DB	07CH,0C7H,003H,003H,003H,003H,003H,003H
	DB	006H,006H,00CH,038H,0E0H,000H,000H,000H
	DB	000H,000H,000H,000H,000H,03EH,018H,018H
	DB	00DH,00DH,00FH,00EH,00CH,000H,000H,000H
	DB	000H,000H,000H,000H,000H,0F1H,063H,0C6H
	DB	08FH,08CH,00CH,00EH,007H,000H,000H,000H
	DB	000H,000H,000H,000H,000H,0F1H,038H,018H
	DB	0F1H,001H,031H,063H,0C7H,000H,000H,000H
	DB	000H,000H,000H,000H,000H,0FDH,0ECH,0C0H
	DB	081H,081H,081H,003H,087H,000H,000H,000H
	DB	000H,000H,000H,000H,000H,0FEH,0E6H,0C6H
	DB	08CH,08CH,08CH,018H,0BCH,000H,000H,000H
	DB	00EH,00CH,000H,000H,000H,038H,018H,018H
	DB	030H,030H,030H,060H,0F3H,001H,000H,000H
	DB	000H,000H,000H,000H,000H,01FH,073H,063H
	DB	066H,07CH,0C0H,0FCH,086H,086H,0FCH,000H
	DB	00EH,006H,00CH,00CH,00CH,09FH,01CH,018H
	DB	031H,031H,031H,063H,0F7H,000H,000H,000H
	DB	000H,000H,001H,001H,003H,0CFH,0C3H,0C3H
	DB	086H,086H,086H,007H,087H,000H,000H,000H
	DB	000H,000H,080H,080H,080H,0C0H,000H,000H
	DB	000H,000H,000H,080H,080H,000H,000H,000H
	DB	001H,003H,006H,006H,006H,007H,001H,000H
	DB	000H,018H,018H,018H,03FH,000H,000H,000H
	DB	0FCH,018H,000H,000H,000H,000H,0C0H,0E1H
	DB	063H,063H,063H,0C3H,081H,000H,000H,000H
	DB	000H,000H,000H,000H,000H,07CH,0CEH,086H
	DB	0FCH,000H,00CH,098H,0F1H,000H,000H,000H
	DB	000H,000H,000H,000H,000H,07FH,039H,031H
	DB	063H,063H,063H,0C6H,0EFH,000H,000H,000H
	DB	000H,000H,000H,000H,000H,087H,08CH,08CH
	DB	00FH,003H,000H,019H,03FH,000H,000H,000H
	DB	000H,000H,000H,000H,000H,0E3H,066H,061H
	DB	007H,08CH,0CCH,08CH,00FH,000H,000H,000H
	DB	000H,000H,000H,000H,000H,0F3H,030H,0F0H
	DB	061H,061H,061H,0F1H,0F1H,000H,000H,000H
	DB	000H,000H,060H,060H,0E0H,0F1H,0C0H,0C0H
	DB	081H,081H,081H,0E3H,0E7H,000H,000H,000H
	DB	070H,060H,000H,000H,000H,0C1H,0C3H,0C6H
	DB	08CH,08CH,08CH,00EH,087H,000H,000H,000H
	DB	000H,000H,000H,000H,000H,0F0H,018H,018H
	DB	018H,018H,018H,071H,0C3H,000H,000H,000H
	DB	000H,000H,000H,000H,000H,0FFH,073H,063H
	DB	0C6H,0C6H,0C6H,08CH,0DEH,000H,000H,000H
	DB	000H,000H,000H,000H,000H,000H,000H,000H
	DB	000H,000H,000H,000H,000H,000H,000H,000H

CHR:

        DB	008H,01CH,02AH,008H,008H,000H       ;矢印（上）
        DB	008H,004H,03EH,004H,008H,000H       ;矢印（右）
        DB	008H,008H,02AH,01CH,008H,000H       ;矢印（下）
        DB	008H,010H,03EH,010H,008H,000H       ;矢印（左）
	DB	000H,000H,000H,000H,000H,000H

;ゲームオーバーを囲う文字＝6文字

	DB	000H,01FH,010H,010H,010H,010H	;NO.5
	DB	000H,03FH,000H,000H,000H,000H
	DB	000H,03EH,002H,002H,002H,002H
	DB	010H,010H,010H,010H,01FH,000H
	DB	000H,000H,000H,000H,03FH,000H
	DB	002H,002H,002H,002H,03EH,000H

;SPC
	DB	000H,000H,000H,000H,000H,000H	;NO.11

;カーソル＝１文字

	DB	030H,038H,03CH,03CH,038H,030H	;NO.12

;VANISHING ANIME

	DB	000H,000H,00CH,00CH,000H,000H	;NO.13
	DB	000H,00CH,012H,012H,00CH,000H
	DB	000H,01EH,012H,012H,01EH,000H
	DB	01EH,021H,021H,021H,021H,01EH
	DB	03EH,021H,021H,021H,021H,03EH
	DB	000H,000H,000H,000H,000H,000H

	DB	01CH,026H,02AH,032H,01CH,000H	;０
	DB	008H,018H,008H,008H,008H,000H	;１
	DB	03CH,002H,01CH,020H,03EH,000H	;２
	DB	03CH,002H,01CH,002H,03CH,000H	;３
	DB	00CH,014H,024H,03EH,004H,000H	;４
	DB	03EH,020H,03CH,002H,03CH,000H	;５
	DB	01CH,020H,03CH,022H,01CH,000H	;６
	DB	03EH,022H,004H,008H,008H,000H	;７
	DB	01CH,022H,01CH,022H,01CH,000H	;８
	DB	01CH,022H,01EH,002H,01CH,000H	;９

	DB	01CH,022H,03EH,022H,022H,000H	;Ａ*
	DB	03CH,022H,03CH,022H,03CH,000H	;Ｂ
	DB	01CH,022H,020H,022H,01CH,000H	;Ｃ*
	DB	03CH,022H,022H,022H,03CH,000H	;Ｄ
	DB	03EH,020H,03CH,020H,03EH,000H	;Ｅ*
	DB	03EH,020H,03CH,020H,020H,000H	;Ｆ*
	DB	01EH,020H,026H,022H,01EH,000H	;Ｇ*
	DB	022H,022H,03EH,022H,022H,000H	;Ｈ
	DB	01CH,008H,008H,008H,01CH,000H	;Ｉ*
	DB	01EH,004H,004H,024H,018H,000H	;Ｊ
	DB	026H,028H,030H,028H,026H,000H	;Ｋ
	DB	020H,020H,020H,020H,03EH,000H	;Ｌ
	DB	022H,036H,02AH,022H,022H,000H	;Ｍ*
	DB	022H,032H,02AH,026H,022H,000H	;Ｎ
	DB	01CH,022H,022H,022H,01CH,000H	;Ｏ*
	DB	03CH,022H,03CH,020H,020H,000H	;Ｐ*
	DB	01CH,022H,02AH,024H,01AH,000H	;Ｑ
	DB	03CH,022H,03CH,024H,022H,000H	;Ｒ*
	DB	01EH,020H,01CH,002H,03CH,000H	;Ｓ*
	DB	03EH,008H,008H,008H,008H,000H	;Ｔ*
	DB	022H,022H,022H,022H,01CH,000H	;Ｕ
	DB	022H,022H,022H,014H,008H,000H	;Ｖ*
	DB	022H,02AH,02AH,02AH,014H,000H	;Ｗ
	DB	022H,014H,008H,014H,022H,000H	;Ｘ*
	DB	022H,022H,014H,008H,008H,000H	;Ｙ
	DB	03EH,004H,008H,010H,03EH,000H	;Ｚ

NAME:
	DB	'AGREE',11,'MIX',11,11,11,11,'FACE',11,'2',11,'FACE',11,'MIX',0
REMI2:
	DB	'REMI2',0
MSG1:
    	DB	5,6,'GAME',11,11,'OVER',6,7,0
MSG2:
    	DB	8,9,9,'REST',11,11,11,11,9,9,10,0
MSG3:
	DB	5,6,6,'PERFECT',6,6,6,7,0
COPYRIGHT:
	DB	'1997',11,'COPYRIGHT',11,'BY',11,'ABCP',0

MODE:
    	DB	1 DUP(?)
LASTKEY:
	DB	1 DUP(?)
BRAM	DB	160 DUP(?)
FLAG	DB	160 DUP(?)

CODE	ENDS
	END	START