;******************************************************************************
;Here comes the Boss
;for FX-890P/Z-1GR
;******************************************************************************

	.186
CODE	SEGMENT
	ASSUME	CS:CODE,DS:CODE,SS:CODE,ES:CODE

	ORG	0100H
START:
	ORG	2000H
INST:
	CLD
	CLI
	CALL	IP			;リロケート処理
IP:
	POP	BP
	SUB	BP,2005H

;**************************************
;インストールの初期化
;**************************************

VECTINST:
	XOR	BX,BX
	XOR	CX,CX
	MOV	ES,BX
	MOV	DS,BX
	MOV	BL,30H			;キー割り込みベクタのアドレス
	DB	0B8H
	DW	OFFSET BOSS		;MOV AX,OFFSET BOSS
	ADD	AX,BP			;リロケート処理
	CMP	[BX],AX 		;既にインストールされてるか
	JNZ	INSTALL
	DB	039H,04FH,002H		;CMP [BX+2],CX(=0)
	JZ	REMOVE

;**************************************
;インストール
;**************************************

INSTALL:
	MOV	SI,BX			;元のベクタを保存
	DB	0BFH
	DW	OFFSET BACKUP		;MOV DI,OFFSET BACKUP
	ADD	DI,BP
	MOV	CL,2
	REP	MOVSW
	DB	0B8H			;新しい割り込み先を書き込む
	DW	OFFSET BOSS		;MOV AX,OFFSET BOSS
	ADD	AX,BP
	MOV	[BX],AX
	DB	089H,04FH,002H		;MOV [BX+2],CX(=0)
	MOV	AH,3AH
	INT	41H
	DB	0BEH
	DW	OFFSET FONT		;MOV SI,OFFSET FONT
	ADD	SI,BP
	MOV	[SI],DI
	DB	8CH,44H,02H		;MOV [SI+2],ES
	MOV	AH,20H
	DB	0BFH
	DW	OFFSET STAY		;MOV DI,OFFSET STAY
	ADD	DI,BP
	INT	41H			;メッセージを表示
	STI
	IRET

;**************************************
;常駐解除
;**************************************

REMOVE:
	DB	0BEH			;リストアする
	DW	OFFSET BACKUP		;MOV SI,OFFSET BACKUP
	ADD	SI,BP
	MOV	DI,BX
	MOV	CL,2
	REP	MOVSW
	MOV	AH,20H
	DB	0BFH
	DW	OFFSET DISSTAY		;MOV DI,OFFSET DISSTAY
	ADD	DI,BP
	INT	41H			;メッセージを表示
	STI
	IRET

;**************************************
;実際の常駐ルーチン
;**************************************

	ORG	2066H
BOSS:
	PUSH	ES
	PUSH	DS
	PUSHA
	CALL	KEY
	JNZ	MAIN
	JMP	RET

;**************************************
;画面の待避
;**************************************

MAIN:					;FCR,XAR,YAR の保存
	MOV	AX,0A000H
	MOV	ES,AX
	XOR	DI,DI
	DB	0BEH
	DW	OFFSET VRAM		;MOV SI,OFFSET VRAM
	ADD	SI,BP
	MOV	AL,21H
	STOSB
	MOV	AL,ES:[DI]
	PUSH	AX
	INC	DI
	MOV	AL,22H
	STOSB
	MOV	AL,ES:[DI]
	PUSH	AX
	INC	DI
	MOV	AL,23H
	STOSB
	MOV	AL,ES:[DI]
	PUSH	AX
	INC	DI
	MOV	AL,23H			;FCR の変更
	STOSB
	MOV	AL,0B5H 		;8 ビット X インクリメント
	STOSB

	MOV	DL,0
DLP:
	MOV	AL,21H			;XAR
	STOSB
	MOV	AL,4
	STOSB
	MOV	AL,22H			;YAR
	STOSB
	MOV	AL,DL
	STOSB
	MOV	AL,20H			;DRAM
	STOSB
READ1:
	MOV	AL,ES:[DI]		;ダミーリード
	PUSH	BX			;ウエイト
	POP	BX
	PUSH	BX
	POP	BX
	MOV	CX,13
READ2:
	MOV	AL,ES:[DI]
	PUSH	BX
	POP	BX
	PUSH	BX
	POP	BX
	MOV	[SI],AL 		;メモリに待避
	INC	SI
	LOOP	READ2
	INC	DI
	ADD	DL,32			;左から右へ
	CMP	DL,64
	JC	DLP
	SUB	DL,63			;64-1, 上から下へ
	CMP	DL,32
	JNZ	DLP

	MOV	AL,23H
	STOSB
	MOV	AL,75H
	STOSB

;**************************************
;メイン
;**************************************

					;あらかじめ用意した画面を表示する
					;フォントはROMから直接読み込む
	XOR	AX,AX
	MOV	DS,AX
	MOV	DI,OFFSET DUMMY_MOJI

	XOR	BH,BH
MOJI_Y:
	XOR	BL,BL
MOJI_X:
	MOV	DL,[DI]
	CALL	LETTER
	INC	DI
	INC	BL
	CMP	BL,32
	JNZ	MOJI_X
	INC	BH
	CMP	BH,4
	JNZ	MOJI_Y

LOOP2:
	CALL	KEY
	JNZ	LOOP2
LOOP3:
	CALL	KEY
	JZ	LOOP3
LOOP4:
	CALL	KEY
	JNZ	LOOP4

;**************************************
;画面の復帰
;**************************************

	MOV	AX,0A000H
	MOV	ES,AX
	XOR	DI,DI
	MOV	DS,DI
	DB	0BEH
	DW	OFFSET VRAM		;MOV SI,OFFSET VRAM
	ADD	SI,BP

	MOV	AL,23H			;FCR の変更
	STOSB
	MOV	AL,0B5H 		;8 ビット X インクリメント
	STOSB
	MOV	DL,0
DLP2:
	MOV	AL,21H			;XAR
	STOSB
	MOV	AL,4
	STOSB
	MOV	AL,22H			;YAR
	STOSB
	MOV	AL,DL
	STOSB
	MOV	AL,20H			;DRAM
	STOSB
	MOV	CX,13
WRITE:
	MOVSB
	PUSH	BX
	POP	BX
	PUSH	BX
	POP	BX
	INC	DI
	LOOP	WRITE
	INC	DI
	ADD	DL,32			;左から右へ
	CMP	DL,64
	JC	DLP2
	SUB	DL,63			;64-1, 上から下へ
	CMP	DL,32
	JNZ	DLP2

	MOV	AL,23H			;FCR,XAR,YAR の呼び出し
	STOSB
	POP	DX
	MOV	AL,DL
	STOSB
	MOV	AL,22H
	STOSB
	POP	DX
	MOV	AL,DL
	STOSB
	MOV	AL,21H
	STOSB
	POP	DX
	MOV	AL,DL
	STOSB
	MOV	AL,20H
	STOSB
RET:
	POPA
	POP	DS
	POP	ES
	DB	0EAH			;本来のルーチンへ
BACKUP:
	DW	0,0

;**************************************
;サブルーチンｓ
;**************************************

KEY:
	XOR	AX,AX			;キーポートの読み込み
	MOV	ES,AX
	MOV	DX,200H
	MOV	AX,0010H		;[SPACE] キーのチェック
	OUT	DX,AX
	PUSH	AX			;ウエイト
	POP	AX
	MOV	DL,2
	IN	AX,DX
	TEST	AL,80H
	JNZ	SHIFT
	RET
SHIFT:
	MOV	DL,0
	MOV	AX,0800H		;[SHIFT] キーのチェック
	OUT	DX,AX
	PUSH	AX
	POP	AX
	MOV	DL,2
	IN	AX,DX
	TEST	AH,08H
	RET

LETTER:
	PUSH	DS
	PUSH	ES
	PUSHA
	SUB	DL,20H
	XOR	DH,DH
	DB	0C1H,0E2H,003H		;SAL DX,3
	MOV	SI,WORD PTR [FONT]
	MOV	DS,WORD PTR [FONT+2]
	ADD	SI,DX
	MOV	AX,0A000H
	MOV	ES,AX
	XOR	DI,DI
	MOV	AL,21H
	STOSB
	MOV	AL,BL
	AND	AL,0FH
	ADD	AL,6
	STOSB
	MOV	AL,22H
	STOSB
	MOV	AL,BH
	DB	0C0H,0E0H,003H		;SAL AL,3
	TEST	BL,10H
	JE	LEFT
	OR	AL,20H
LEFT:
	STOSB
	MOV	AL,20H
	STOSB
	MOV	AH,8
P_LP:
	MOVSB
	PUSH	BX
	POP	BX
	PUSH	BX
	POP	BX
	DEC	DI
	DEC	AH
	JNZ	P_LP
	DEC	DI
	MOV	AL,20H
	STOSB
	POPA
	POP	ES
	POP	DS
	RET

;**************************************
;データ
;**************************************

DUMMY_MOJI:
	DB	'            < MENU >            '
	DB	'                                '
	DB	'1:F.COM 2:BASIC 3:C     4:CASL  '
	DB	'5:ASMBL 6:FX    7:MODE          '

STAY:
	DB	12,'Here comes the Boss by ABCP',13,'Stayed on Memory',13,0
DISSTAY:
	DB	12,'Thank You for Using',13,'Removed from Memory',13,0
FONT:
	DW	0,0
VRAM:
	DB	832 DUP(?)

CODE	ENDS
	END	START
