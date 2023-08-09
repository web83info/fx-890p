;******************************************************************************
;            ナンプレ自動解答プログラム「ＮＡＰ」 for MS-DOS Ver.0.1
;
;                     Number-place Auto-answering Program
;
;                        1998 (C) Copyright by ABCP.
;                           All Rights Reserved.
;******************************************************************************

CODE	SEGMENT
	ASSUME	CS:CODE,DS:CODE,SS:CODE,ES:CODE

	ORG	0100H
START:

;******************************************************************************
;初期設定
;******************************************************************************
INIT:
	CLD

;******************************************************************************
;タイトル
;******************************************************************************
TITLE:
	MOV	AH,9
	MOV	DX,OFFSET COPYRIGHT
	INT	21H

;******************************************************************************
;問題入力
;******************************************************************************
INPUT:
	MOV	DI,OFFSET NUMBER
	MOV	CX,9
INPUT_1:
	MOV	AH,10
	MOV	DX,OFFSET BUF
	INT	21H
	MOV	AH,2
	MOV	DL,0AH
	INT	21H

	PUSH	CX
	MOV	SI,OFFSET BUF+2
	MOV	CX,9
TRANS:
	MOV	AL,[SI]
	SUB	AL,30H
	MOV	[DI],AL
	INC	SI
	INC	DI
	LOOP	TRANS
	POP	CX
	LOOP	INPUT_1

	CALL	FILLED			;既に埋められている数字の個数を記録する
	MOV	BYTE PTR FINISH_CHECK,AL

;******************************************************************************
;解析ＬＶ１
;******************************************************************************
LEVEL_1:				;確定しやすい数字を見つける
	CALL	LEVEL_1_MAIN

;******************************************************************************
;ＬＶ１で解けたかな？
;******************************************************************************
	MOV	BYTE PTR CLEAR_CHECK_FLAG,0
	CALL	CLEAR_CHECK
	CALL	PARADOX

	MOV	AL,BYTE PTR CLEAR_CHECK_FLAG
	CMP	AL,0
	JNZ	LEVEL_1_CLEAR_1
	JMP	LEVEL_1
LEVEL_1_CLEAR_1:
	CMP	AL,1			;CLEAR_CHECK_FLAG=1矛盾が生じた
	JNZ	LEVEL_1_CLEAR_2
	JMP	ERROR_END
LEVEL_1_CLEAR_2:
	CMP	AL,-1
	JNZ	LEVEL_2
	JMP	CLEAR

;******************************************************************************
;解析ＬＶ２
;******************************************************************************
LEVEL_2:				;確定しやすいマスを見つける
	CALL	LEVEL_2_MAIN

;******************************************************************************
;ＬＶ２で解けたかな？
;******************************************************************************
	MOV	BYTE PTR CLEAR_CHECK_FLAG,0
	CALL	CLEAR_CHECK
	CALL	PARADOX

	MOV	AL,BYTE PTR CLEAR_CHECK_FLAG
	CMP	AL,0
	JNZ	LEVEL_2_CLEAR_1
	JMP	LEVEL_1
LEVEL_2_CLEAR_1:
	CMP	AL,1			;CLEAR_CHECK_FLAG=1矛盾が生じた
	JNZ	LEVEL_2_CLEAR_2
	JMP	ERROR_END
LEVEL_2_CLEAR_2:
	CMP	AL,-1
	JNZ	LEVEL_3
	JMP	CLEAR

;******************************************************************************
;解析ＬＶ３
;******************************************************************************
LEVEL_3:

	CALL	FLAG_CLEAR

	MOV	BYTE PTR NOW_NUMBER,1	;すべての数字についてフラグを立てる
LEVEL_3_A:
	CALL	FLAG_CHECK_BEGIN_2
	INC	BYTE PTR NOW_NUMBER
	CMP	BYTE PTR NOW_NUMBER,10
	JNZ	LEVEL_3_A


	MOV	BH,1
TRY_A:
	MOV	BL,1
TRY_1:
	MOV	BYTE PTR NOW_NUMBER,1
TRY_2:
	CALL	XY
	CMP	BYTE PTR [DI+OFFSET NUMBER],0
	JZ	TRY_TEMP_2		;既に数字が入っている
	JMP	TRY_PUT_3
TRY_TEMP_2:
	CALL	XY2
	MOV	CL,BYTE PTR NOW_NUMBER
	MOV	AX,WORD PTR [DI+OFFSET NUMBER_FLAG]
	RCR	AX,CL
	JNC	TRY_TEMP
	JMP	TRY_3			;既にその数字は入れないことが判っている
TRY_TEMP:
	MOV	SI,OFFSET NUMBER
	MOV	DI,OFFSET NUMBER_BACKUP
	MOV	CX,81
	REP	MOVSB
	MOV	SI,OFFSET NUMBER_FLAG
	MOV	DI,OFFSET NUMBER_FLAG_BACKUP
	MOV	CX,162
	REP	MOVSB
	MOV	AL,BYTE PTR NOW_NUMBER
	MOV	BYTE PTR NOW_NUMBER_BACKUP,AL
	MOV	AL,BYTE PTR FINISH_CHECK
	MOV	BYTE PTR FINISH_CHECK_BACKUP,AL

	CALL	XY
	MOV	AL,BYTE PTR NOW_NUMBER	;仮に入れてみて周りの様子を調べる
	MOV	BYTE PTR [DI+OFFSET NUMBER],AL

LEVEL_3_LOOP:
	CALL	LEVEL_1_MAIN
	MOV	BYTE PTR CLEAR_CHECK_FLAG,0
	CALL	CLEAR_CHECK
	CALL	PARADOX
	MOV	AH,BYTE PTR CLEAR_CHECK_FLAG
	CMP	AH,0
	JZ	LEVEL_3_LOOP

	CALL	LEVEL_2_MAIN
	MOV	BYTE PTR CLEAR_CHECK_FLAG,0
	CALL	CLEAR_CHECK
	CALL	PARADOX
	MOV	AH,BYTE PTR CLEAR_CHECK_FLAG
	CMP	AH,0
	JZ	LEVEL_3_LOOP

	MOV	SI,OFFSET NUMBER_BACKUP
	MOV	DI,OFFSET NUMBER
	MOV	CX,81
	REP	MOVSB
	MOV	SI,OFFSET NUMBER_FLAG_BACKUP
	MOV	DI,OFFSET NUMBER_FLAG
	MOV	CX,162
	REP	MOVSB
	MOV	AL,BYTE PTR NOW_NUMBER_BACKUP
	MOV	BYTE PTR NOW_NUMBER,AL
	MOV	AL,BYTE PTR FINISH_CHECK_BACKUP
	MOV	BYTE PTR FINISH_CHECK,AL

	CMP	AH,1
	JNZ	TRY_3
	XOR	AX,AX
	STC
	MOV	CL,BYTE PTR NOW_NUMBER
	RCL	AX,CL			;0000 0009 8765 4321
	CALL	XY2
	OR	WORD PTR [DI+OFFSET NUMBER_FLAG],AX
TRY_3:
	INC	BYTE PTR NOW_NUMBER
	CMP	BYTE PTR NOW_NUMBER,10
	JZ	TRY_4
	JMP	TRY_2
TRY_4:
	XOR	DL,DL
	CALL	XY2
	MOV	AX,WORD PTR [DI+OFFSET NUMBER_FLAG]
	XOR	CX,CX
	MOV	CL,1
TRY_PUT_1:
	RCR	AX,1
	JC	TRY_PUT_2
	INC	DL
	MOV	DH,CL
TRY_PUT_2:
	INC	CL
	CMP	CL,10
	JNZ	TRY_PUT_1

	CMP	DL,1
	JNZ	TRY_PUT_3
	CALL	XY
	MOV	BYTE PTR [DI+OFFSET NUMBER],DH
	JMP	LEVEL_1

TRY_PUT_3:
	INC	BL
	CMP	BL,10
	JZ	TRY_5
	JMP	TRY_1
TRY_5:
	INC	BH
	CMP	BH,10
	JZ	TRY_6
	JMP	TRY_A
TRY_6:

;******************************************************************************
;ＬＶ３で解けたかな？
;******************************************************************************
	MOV	BYTE PTR CLEAR_CHECK_FLAG,0
	CALL	CLEAR_CHECK
	CALL	PARADOX

	MOV	AL,BYTE PTR CLEAR_CHECK_FLAG
	CMP	AL,0
	JNZ	LEVEL_3_CLEAR_1
	JMP	LEVEL_1
LEVEL_3_CLEAR_1:
	CMP	AL,1			;CLEAR_CHECK_FLAG=1矛盾が生じた
	JNZ	LEVEL_3_CLEAR_2
	JMP	ERROR_END
LEVEL_3_CLEAR_2:
	CMP	AL,-1
	JZ	CLEAR

;******************************************************************************
;限界です。ごめんなさい _(._.)_
;******************************************************************************
LIMIT:
	MOV	DX,OFFSET MOJI_SORRY
	JMP	CONT
;******************************************************************************
;クリア！
;******************************************************************************
CLEAR:
	MOV	DX,OFFSET MOJI_CLEAR
	JMP	CONT

;******************************************************************************
;エラー
;******************************************************************************
ERROR_END:
	MOV	DX,OFFSET MOJI_ERROR
	JMP	CONT

CONT:
	MOV	AH,9
	INT	21H

	MOV	DI,OFFSET NUMBER
	MOV	CL,9
CONT_1:
	MOV	CH,3
CONT_2:
	MOV	BL,3
CONT_3:
	MOV	AH,2
	MOV	DL,[DI]
	ADD	DL,30H
	INT	21H
	INC	DI
	DEC	BL
	JNZ	CONT_3
	MOV	AH,2
	MOV	DL,20H
	INT	21H
	DEC	CH
	JNZ	CONT_2
	MOV	AH,2
	MOV	DL,0DH
	INT	21H
	MOV	AH,2
	MOV	DL,0AH
	INT	21H
	LOOP	CONT_1

	MOV	AH,04CH
	INT	21H

;******************************************************************************
;確定しやすい数字を探して埋めていく。
;******************************************************************************
LEVEL_1_MAIN:
	MOV	BYTE PTR NOW_NUMBER,1
SEARCH_NOW_NUMBER:
	CALL	FLAG_CHECK_BEGIN
	CALL	PUT_BEGIN
	INC	BYTE PTR NOW_NUMBER
	CMP	BYTE PTR NOW_NUMBER,10
	JNZ	SEARCH_NOW_NUMBER
	RET

;******************************************************************************
;ある数字が埋められないところにフラグを立てる。
;******************************************************************************
FLAG_CHECK_BEGIN:
	CALL	FLAG_CLEAR
					;0000 0009 8765 4321 フラグの形式
FLAG_CHECK_BEGIN_2:
	PUSH	AX
	PUSH	BX
	PUSH	CX
	PUSH	DX
	PUSH	SI
	PUSH	DI
	MOV	BH,1
SEARCH_1:
	MOV	BL,1
SEARCH_2:
	CALL	XY
	MOV	AL,BYTE PTR NOW_NUMBER
	MOV	DL,BYTE PTR [DI+OFFSET NUMBER]
	CMP	DL,AL
	JZ	FLAG_BEGIN
	CMP	DL,0
	JNZ	FLAG_ONE
	JMP	SEARCH_3
FLAG_ONE:
	CALL	XY2
	XOR	AX,AX
	STC
	MOV	CL,BYTE PTR NOW_NUMBER
	RCL	AX,CL
	OR	WORD PTR [DI+OFFSET NUMBER_FLAG],AX
	JMP	SEARCH_3

FLAG_BEGIN:				;縦,横,３＊３にフラグを立てる
	PUSH	BX
	MOV	BL,1
FLAG_1:					;横にフラグを立てる
	CALL	XY2
	XOR	AX,AX
	STC
	MOV	CL,BYTE PTR NOW_NUMBER
	RCL	AX,CL
	OR	WORD PTR [DI+OFFSET NUMBER_FLAG],AX
	INC	BL
	CMP	BL,10
	JNZ	FLAG_1
	POP	BX

	PUSH	BX
	MOV	BH,1
FLAG_2:					;縦にフラグを立てる
	CALL	XY2
	XOR	AX,AX
	STC
	MOV	CL,BYTE PTR NOW_NUMBER
	RCL	AX,CL
	OR	WORD PTR [DI+OFFSET NUMBER_FLAG],AX
	INC	BH
	CMP	BH,10
	JNZ	FLAG_2
	POP	BX

	PUSH	BX
	MOV	AH,BL			;X,Yを３＊３の左上に調整
	ADD	AH,2
	MOV	AL,3
	CALL	WARI
	MOV	AL,AH
	ADD	AH,AH
	ADD	AH,AL
	SUB	AH,2
	MOV	BL,AH

	MOV	AH,BH
	ADD	AH,2
	MOV	AL,3
	CALL	WARI
	MOV	AL,AH
	ADD	AH,AH
	ADD	AH,AL
	SUB	AH,2
	MOV	BH,AH

	MOV	CL,3
FLAG_3_3_1:
	MOV	CH,3
FLAG_3_3_2:
	CALL	XY2
	PUSH	CX
	XOR	AX,AX
	STC
	MOV	CL,BYTE PTR NOW_NUMBER
	RCL	AX,CL
	OR	WORD PTR [DI+OFFSET NUMBER_FLAG],AX
	POP	CX
	INC	BL
	DEC	CH
	JNZ	FLAG_3_3_2
	SUB	BL,3
	INC	BH
	LOOP	FLAG_3_3_1
	POP	BX
SEARCH_3:
	INC	BL
	CMP	BL,10
	JZ	SEARCH_4
	JMP	SEARCH_2
SEARCH_4:
	INC	BH
	CMP	BH,10
	JZ	SEARCH_5
	JMP	SEARCH_1
SEARCH_5:
	POP	DI
	POP	SI
	POP	DX
	POP	CX
	POP	BX
	POP	AX
	RET

FLAG_CLEAR:
	PUSH	AX
	PUSH	BX
	PUSH	CX
	PUSH	DX
	PUSH	SI
	PUSH	DI
	XOR	AX,AX			;フラグ初期化
	MOV	CX,162
	MOV	DI,OFFSET NUMBER_FLAG
	REP	STOSB
	POP	DI
	POP	SI
	POP	DX
	POP	CX
	POP	BX
	POP	AX
	RET

;******************************************************************************
;確定しやすいマスに数字を入れる。
;******************************************************************************
PUT_BEGIN:
	PUSH	AX
	PUSH	BX
	PUSH	CX
	PUSH	DX
	PUSH	SI
	PUSH	DI

	MOV	BH,1
PUT_1:
	MOV	BL,1
	XOR	AL,AL			;AL=空いてるマスの数
PUT_2:
	CALL	XY2
	CMP	WORD PTR [DI+OFFSET NUMBER_FLAG],0
	JNZ	PUT_3
	INC	AL
	MOV	DX,BX			;DX=空いてるマスの座標
PUT_3:
	CMP	AL,2
	JNZ	PUT_A
	MOV	BL,9
PUT_A:
	INC	BL
	CMP	BL,10
	JNZ	PUT_2

	CMP	AL,1
	JNZ	PUT_4
	PUSH	BX
	MOV	BX,DX
	CALL	XY
	MOV	AL,BYTE PTR NOW_NUMBER
	MOV	BYTE PTR [DI+OFFSET NUMBER],AL
	POP	BX
PUT_4:
	INC	BH
	CMP	BH,10
	JNZ	PUT_1

	MOV	BL,1
PUT_5:
	MOV	BH,1
	XOR	AL,AL			;AL=空いてるマスの数
PUT_6:
	CALL	XY2
	CMP	WORD PTR [DI+OFFSET NUMBER_FLAG],0
	JNZ	PUT_7
	INC	AL
	MOV	DX,BX			;DX=空いてるマスの座標
PUT_7:
	CMP	AL,2
	JNZ	PUT_B
	MOV	BH,9
PUT_B:
	INC	BH
	CMP	BH,10
	JNZ	PUT_6
	CMP	AL,1
	JNZ	PUT_8
	PUSH	BX
	MOV	BX,DX
	CALL	XY
	MOV	AL,BYTE PTR NOW_NUMBER
	MOV	BYTE PTR [DI+OFFSET NUMBER],AL
	POP	BX
PUT_8:
	INC	BL
	CMP	BL,10
	JNZ	PUT_5

	MOV	BX,0101H
	MOV	CL,3
PUT_3_3_1:
	MOV	CH,3
PUT_3_3_2:
	PUSH	CX
	XOR	AL,AL
	MOV	CL,3
PUT_3_3_3:
	MOV	CH,3
PUT_3_3_5:
	CALL	XY2
	CMP	WORD PTR [DI+OFFSET NUMBER_FLAG],0
	JNZ	PUT_3_3_6
	INC	AL
	MOV	DX,BX			;DX=空いてるマスの座標
PUT_3_3_6:
	INC	BL
	DEC	CH
	JNZ	PUT_3_3_5
	SUB	BL,3
	INC	BH
	LOOP	PUT_3_3_3

	CMP	AL,1
	JNZ	PUT_3_3_7

	PUSH	BX
	MOV	BX,DX
	CALL	XY
	MOV	AL,BYTE PTR NOW_NUMBER
	MOV	BYTE PTR [DI+OFFSET NUMBER],AL
	POP	BX
PUT_3_3_7:
	POP	CX
	SUB	BH,3
	ADD	BL,3
	DEC	CH
	JNZ	PUT_3_3_2
	SUB	BL,9
	ADD	BH,3
	LOOP	PUT_3_3_1
	POP	DI
	POP	SI
	POP	DX
	POP	CX
	POP	BX
	POP	AX
	RET

;******************************************************************************
;入れやすいマスを探す。
;******************************************************************************
LEVEL_2_MAIN:
	PUSH	AX
	PUSH	BX
	PUSH	CX
	PUSH	DX
	PUSH	SI
	PUSH	DI
	CALL	FLAG_CLEAR
	MOV	BYTE PTR NOW_NUMBER,1
MASU_B:
	CALL	FLAG_CHECK_BEGIN_2
	INC	BYTE PTR NOW_NUMBER
	CMP	BYTE PTR NOW_NUMBER,10
	JNZ	MASU_B

	MOV	BH,1
MASU_A:
	MOV	BL,1
MASU_1:
	CALL	XY
	CMP	BYTE PTR [DI+OFFSET NUMBER],0
	JNZ	MASU_PUT_3
	XOR	DL,DL
	CALL	XY2
	MOV	AX,WORD PTR [DI+OFFSET NUMBER_FLAG]
	XOR	CX,CX
	MOV	CL,1
MASU_PUT_1:
	RCR	AX,1
	JC	MASU_PUT_2
	INC	DL
	MOV	DH,CL
MASU_PUT_2:
	INC	CL
	CMP	CL,10
	JNZ	MASU_PUT_1

	CMP	DL,1
	JNZ	MASU_PUT_3
	CALL	XY
	MOV	BYTE PTR [DI+OFFSET NUMBER],DH
MASU_PUT_3:
	INC	BL
	CMP	BL,10
	JNZ	MASU_1
	INC	BH
	CMP	BH,10
	JNZ	MASU_A
	POP	DI
	POP	SI
	POP	DX
	POP	CX
	POP	BX
	POP	AX
	RET

;******************************************************************************
;解析が進んでいるか？
;******************************************************************************
CLEAR_CHECK:
	PUSH	AX
	PUSH	BX
	PUSH	CX
	PUSH	DX
	PUSH	SI
	PUSH	DI
	CALL	FILLED			;数字の埋まっているマスの数を数える
	CMP	AL,81			;CLEAR_CHECK_FLAG=-1 クリア
	JNZ	CLEAR_CHECK_1
	MOV	AH,-1
	JMP	CLEAR_CHECK_2
CLEAR_CHECK_1:
	CMP	AL,BYTE PTR FINISH_CHECK
	JNZ	CLEAR_CHECK_2
	MOV	AH,2			;CLEAR_CHECK_FLAG=2 前回から変化なし
CLEAR_CHECK_2:
	MOV	BYTE PTR CLEAR_CHECK_FLAG,AH
	MOV	BYTE PTR FINISH_CHECK,AL
	POP	DI
	POP	SI
	POP	DX
	POP	CX
	POP	BX
	POP	AX
	RET

FILLED:
	XOR	AX,AX
	MOV	CX,81
	MOV	DI,OFFSET NUMBER
FILLED_1:
	CMP	BYTE PTR [DI],0
	JZ	FILLED_2
	INC	AL
FILLED_2:
	INC	DI
	LOOP	FILLED_1
	RET

;******************************************************************************
;矛盾が生じないかを調べる。
;******************************************************************************
PARADOX:				;CLEAR_CHECK_FLAG=1 矛盾
	PUSH	AX
	PUSH	BX
	PUSH	CX
	PUSH	DX
	PUSH	SI
	PUSH	DI

	MOV	BH,1
PARADOX_1:
	MOV	BL,1
	XOR	DX,DX			;同じ数字がダブってないか
	XOR	SI,SI
PARADOX_2:
	CALL	XY
	MOV	CL,BYTE PTR [DI+OFFSET NUMBER]
	CMP	CL,0
	JZ	PARADOX_3
	XOR	AX,AX
	STC
	RCL	AX,CL
	OR	DX,AX

	CMP	SI,DX
	JNZ	PARADOX_3
	MOV	BYTE PTR CLEAR_CHECK_FLAG,1
PARADOX_3:
	MOV	SI,DX
	INC	BL
	CMP	BL,10
	JNZ	PARADOX_2
	INC	BH
	CMP	BH,10
	JNZ	PARADOX_1

	MOV	BL,1
PARADOX_4:
	MOV	BH,1
	XOR	DX,DX			;同じ数字がダブってないか
	XOR	SI,SI
PARADOX_5:
	CALL	XY
	MOV	CL,BYTE PTR [DI+OFFSET NUMBER]
	CMP	CL,0
	JZ	PARADOX_6
	XOR	AX,AX
	STC
	RCL	AX,CL
	OR	DX,AX

	CMP	SI,DX
	JNZ	PARADOX_6
	MOV	BYTE PTR CLEAR_CHECK_FLAG,1
PARADOX_6:
	MOV	SI,DX
	INC	BH
	CMP	BH,10
	JNZ	PARADOX_5
	INC	BL
	CMP	BL,10
	JNZ	PARADOX_4

	MOV	BX,0101H
	MOV	CL,3
PARADOX_3_3_1:
	MOV	CH,3
PARADOX_3_3_2:
	XOR	SI,SI
	XOR	DX,DX
	PUSH	CX
	MOV	CL,3
PARADOX_3_3_3:
	MOV	CH,3
PARADOX_3_3_5:
	CALL	XY
	CMP	BYTE PTR [DI+OFFSET NUMBER],0
	JZ	PARADOX_3_3_6
	PUSH	CX
	MOV	CL,BYTE PTR [DI+OFFSET NUMBER]
	XOR	AX,AX
	STC
	RCL	AX,CL
	POP	CX
	OR	DX,AX

	CMP	SI,DX
	JNZ	PARADOX_3_3_6
	MOV	BYTE PTR CLEAR_CHECK_FLAG,1

PARADOX_3_3_6:
	MOV	SI,DX
	INC	BL
	DEC	CH
	JNZ	PARADOX_3_3_5
	SUB	BL,3
	INC	BH
	LOOP	PARADOX_3_3_3

PARADOX_3_3_7:
	POP	CX
	SUB	BH,3
	ADD	BL,3
	DEC	CH
	JNZ	PARADOX_3_3_2
	SUB	BL,9
	ADD	BH,3
	LOOP	PARADOX_3_3_1

	MOV	BYTE PTR NOW_NUMBER,1	;空いてるマスに数字を入れる余地があるか
	CALL	FLAG_CHECK_BEGIN

	MOV	BH,1
SPACE_1:
	MOV	BL,1
	XOR	AL,AL
SPACE_2:
	CALL	XY
	MOV	AH,BYTE PTR NOW_NUMBER
	CMP	BYTE PTR [DI+OFFSET NUMBER],AH
	JZ	SPACE_4			;その数字が既にあるときは
					;入る余地について考える必要はない
	CALL	XY2
	CMP	WORD PTR [DI+OFFSET NUMBER_FLAG],0
	JNZ	SPACE_3
	INC	AL
SPACE_3:
	INC	BL
	CMP	BL,10
	JNZ	SPACE_2
	CMP	AL,0
	JNZ	SPACE_4
	MOV	BYTE PTR CLEAR_CHECK_FLAG,1
SPACE_4:
	INC	BH
	CMP	BH,10
	JNZ	SPACE_1

	MOV	BL,1
SPACE_5:
	MOV	BH,1
	XOR	AL,AL
SPACE_6:
	CALL	XY
	MOV	AH,BYTE PTR NOW_NUMBER
	CMP	BYTE PTR [DI+OFFSET NUMBER],AH
	JZ	SPACE_8			;その数字が既にあるときは
					;入る余地について考える必要はない
	CALL	XY2
	CMP	WORD PTR [DI+OFFSET NUMBER_FLAG],0
	JNZ	SPACE_7
	INC	AL
SPACE_7:
	INC	BH
	CMP	BH,10
	JNZ	SPACE_6
	CMP	AL,0
	JNZ	SPACE_8
	MOV	BYTE PTR CLEAR_CHECK_FLAG,1
SPACE_8:
	INC	BL
	CMP	BL,10
	JNZ	SPACE_5

	MOV	BX,0101H
	MOV	CL,3
SPACE_3_3_1:
	MOV	CH,3
SPACE_3_3_2:
	PUSH	CX
	XOR	AL,AL
	MOV	CL,3
SPACE_3_3_3:
	MOV	CH,3
SPACE_3_3_5:
	CALL	XY
	MOV	AH,BYTE PTR NOW_NUMBER
	CMP	BYTE PTR [DI+OFFSET NUMBER],AH
	JNZ	SPACE_3_3_A		;その数字が既にあるときは
					;入る余地について考える必要はない
	MOV	AL,1
SPACE_3_3_A:
	CALL	XY2
	CMP	WORD PTR [DI+OFFSET NUMBER_FLAG],0
	JNZ	SPACE_3_3_6
	INC	AL
SPACE_3_3_6:
	INC	BL
	DEC	CH
	JNZ	SPACE_3_3_5
	SUB	BL,3
	INC	BH
	LOOP	SPACE_3_3_3

	CMP	AL,0
	JNZ	SPACE_3_3_7
	MOV	BYTE PTR CLEAR_CHECK_FLAG,1

SPACE_3_3_7:
	POP	CX
	SUB	BH,3
	ADD	BL,3
	DEC	CH
	JNZ	SPACE_3_3_2
	SUB	BL,9
	ADD	BH,3
	LOOP	SPACE_3_3_1
	POP	DI
	POP	SI
	POP	DX
	POP	CX
	POP	BX
	POP	AX
	RET

;******************************************************************************
;サブルーチンズ
;******************************************************************************
XY:					;BL=X座標、BH=Y座標
	PUSH	AX
	XOR	DI,DI
	MOV	AL,BH
	DEC	AL
	MOV	AH,9
	MUL	AH
	ADD	AL,BL
	DEC	AL
	MOV	DI,AX
	POP	AX
	RET

XY2:
	CALL	XY
	ADD	DI,DI
	RET

WARI:					;AH/AL=AH...AL
	PUSH	BX
	PUSH	CX
	XOR	BX,BX
	MOV	BL,AH
	MOV	CX,8
WARI_L:
	SAL	BX,1
	MOV	AH,BH
	SUB	AH,AL
	JC	WARI_S
	INC	BL
	MOV	BH,AH
WARI_S:
	LOOP	WARI_L
	MOV	AH,BL
	MOV	AL,BH
	POP	CX
	POP	BX
	RET

;******************************************************************************
;データ
;******************************************************************************
MOJI_CLEAR:
	DB	'CLEAR.',0DH,0AH,'$'
MOJI_SORRY:
	DB	'SORRY.',0DH,0AH,'$'
MOJI_ERROR:
	DB	'ERROR.',0DH,0AH,'$'
COPYRIGHT:
	DB	'Number-place Auto-answering Program. Ver.0.1',0DH,0AH
	DB	'1998 (C) Copyright by ABCP.',0DH,0AH,'$'
;******************************************************************************
;ワークエリア
;******************************************************************************
NUMBER:
;	DB	81 DUP(?)

	DB	0,0,0,0,0,0,0,0,0
	DB	0,0,4,9,7,8,6,0,0
	DB	0,2,0,4,0,1,0,8,0
	DB	0,5,8,0,0,0,9,1,0
	DB	0,4,0,0,0,0,0,3,0
	DB	0,1,2,0,0,0,5,6,0
	DB	0,6,0,8,0,5,0,9,0
	DB	0,0,1,3,9,2,8,0,0
	DB	0,0,0,0,0,0,0,0,0

NUMBER_BACKUP:
	DB	81 DUP(?)
NUMBER_FLAG:
	DB	162 DUP(?)
NUMBER_FLAG_BACKUP:
	DB	162 DUP(?)
FINISH_CHECK:
	DB	1 DUP(?)
FINISH_CHECK_BACKUP:
	DB	1 DUP(?)
NOW_NUMBER:
	DB	1 DUP(?)
NOW_NUMBER_BACKUP:
	DB	1 DUP(?)
CLEAR_CHECK_FLAG:
	DB	1 DUP(?)
BUF:
	DB	10,11 DUP(?)

CODE	ENDS
	END	START
