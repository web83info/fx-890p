;Overnight Sensation
;ー時代はあなたに委ねてるー
;
;PROGRAMMED BY ABCP
;
;FROM  95/12/31 20:32:24
;TILL  96/01/02 15:39:52

START:
        MOV     AH,10H                  ;CLS(BIOS)
        INT     41H
        MOV     BYTE PTR MODE,5         ;MODE=5 AGREE MIX
        MOV     DI,OFFSET TITLE_1       ;”Over...tion”
        CALL    PRINT
        MOV     BX,0107H
        MOV     DI,OFFSET TITLE_2

TITLE1:
        MOV     DL,[DI]
        OR      DL,DL
        JE      TITLE2
        CALL    LCDC                    ;平仮名表示
        INC     DI
        INC     BL
        JMP     TITLE1

TITLE2:
        MOV     BX,0306H
        CALL    LOCATE
        MOV     DI,OFFSET NAME
        CALL    PRINT

MODE_1:
        MOV     BL,MODE
        MOV     DL,5
        CALL    LCDC                    ;カ−ソル
        MOV     AH,04H                  ;INPUT$(1)
        INT     41H
        CMP     DL,34H                  ;”4”
        JNE     MODE_2
        MOV     DL,4
        CALL    LCDC                    ;カ−ソル消す
        MOV     BYTE PTR MODE,5         ;AGREE MIX

MODE_2:
        CMP     DL,36H                  ;”6”
        JNE     MODE_3
        MOV     DL,4
        CALL    LCDC
        MOV     BYTE PTR MODE,17        ;MODE=17 F・2・F MIX

MODE_3:
        CMP     DL,0DH                  ;CR
        JNE     MODE_1

        XOR     BX,BX
        MOV     SI,OFFSET BRAM
M_ARROW:                                ;問題制作
        MOV     AH,25H                  ;DX=TIMER
        INT     41H
        AND     DX,0007H                ;0<=DX<=7
        INC     DX
        MOV     CX,DX

MAKE_RND:
        CALL    RND                     ;重複を避ける
        LOOP    MAKE_RND
        AND     DL,3                    ;0<=DL<=3
        MOV     [SI+BX],DL
        INC     BX
        CMP     BX,96
        JNE     M_ARROW

DISP:                                   ;ブロック表示
        XOR     BH,BH
        MOV     DL,6

BLOCK_1:
        XOR     BL,BL

BLOCK_2:
        CALL    LCDC
        ADD     BL,28                   ;右側
        CALL    LCDC
        SUB     BL,27                   ;BL=BL−28+1
        CMP     BL,4
        JNE     BLOCK_2
        INC     BH
        CMP     BH,4                    ;Y=4?
        JNE     BLOCK_1

        XOR     BH,BH                   ;矢印
DISP_1:
        MOV     BL,4

DISP_2:
        MOV     DL,[SI]                 ;読み込み
        CALL    LCDC
        INC     SI
        INC     BL
        CMP     BL,28
        JNE     DISP_2
        INC     BH
        CMP     BH,4
        JNE     DISP_1

        XOR     BX,BX                   ;ゲ−ムオ−バ−判定
        XOR     CX,CX                   ;CX=矢印B
        XOR     DX,DX                   ;DX=残りの矢印
        MOV     SI,OFFSET BRAM

OVER_1:
        MOV     AL,[SI+BX]
        CMP     AL,4
        JE      OVER_2
        INC     DX
        PUSH    BX
        CALL    CHECK
        POP     BX
        CMP     AL,4
        JE      OVER_2
        INC     CX                      ;矢印Bを探す

OVER_2:
        INC     BX
        CMP     BX,96
        JNE     OVER_1
        OR      CX,CX                   ;ゲ−ムオ−バ−でない
        JNZ     KEYIN

OVER_3:
        MOV     BX,010BH
        CALL    LOCATE
        MOV     DI,OFFSET MSG1
        CALL    PRINT
        MOV     BX,020CH
        CALL    LOCATE
        OR      DX,DX
        JZ      OVER_4
        MOV     DI,OFFSET MSG2
        CALL    PRINT
        MOV     AH,36H                  ;10進数を16進数化
        INT     41H
        MOV     BX,0212H
        CALL    LOCATE
        MOV     AH,44H                  ;DLを16進で表示
        INT     41H
        JNZ     OVER_5                  ;JNZ=JMP

OVER_4:
        MOV     DI,OFFSET MSG3
        CALL    PRINT

OVER_5:
        MOV     AH,04H
        INT     41H
        CMP     DL,0DH                  ;CR
        JNE     OVER_5
        JMP     START

KEYIN:                                  ;キ−入力
        MOV     AH,04H
        INT     41H
        MOV     DH,0FFH                 ;2,4,6,8,SPC以外の時
        CMP     DL,38H                  ;”8”
        JNE     KEY_1
        XOR     DH,DH

KEY_1:
        CMP     DL,36H                  ;”6”
        JNE     KEY_2
        MOV     DH,1

KEY_2:
        CMP     DL,32H                  ;”2”
        JNE     KEY_3
        MOV     DH,2

KEY_3:
        CMP     DL,34H                  ;”4”
        JNE     KEY_4
        MOV     DH,3

KEY_4:
        CMP     DL,20H                  ;”SPC”
        JNE     KEY_5
        CMP     BYTE PTR MODE,5         ;AGREE MIX
        JE      KEY_5
        MOV     DH,4

KEY_5:
        CMP     DH,255
        JZ      KEYIN

INIT:                                   ;フラグ初期化
        MOV     DI,OFFSET FLAG
        XOR     AX,AX
        MOV     CX,96
        REP     STOSB

        XOR     BX,BX
        MOV     SI,OFFSET BRAM
        MOV     DI,OFFSET FLAG

ATARI_1:
        PUSH    BX
        MOV     CX,BX                   ;PUSH BX
        MOV     AL,[SI+BX]              ;AL=矢印A
        MOV     DL,AL                   ;DL=矢印A
        CMP     AL,4                    ;SPC
        JE      ATARI_E
        CALL    CHECK                   ;AL=矢印B
        CMP     AL,4
        JE      ATARI_E
        XOR     AL,DL
        CMP     DH,4
        JNE     C_2468
;F.2.F
        CMP     AL,2                    ;F・2・F MIX
        JNE     ATARI_E
        XCHG    BX,CX                   ;POP BX
        MOV     BYTE PTR [DI+BX],1
        XCHG    BX,CX                   ;PUSH BX
        JE      ARROW_B                 ;JE=JMP

C_2468:
        CMP     DH,DL
        JNE     ATARI_E
        OR      AL,AL
        JNE     TURN
        CMP     BYTE PTR MODE,5
        JNE     TURN

ARROW_B:
        MOV     BYTE PTR [DI+BX],1
        JZ      ATARI_E                 ;JZ=JMP

TURN:
        MOV     BYTE PTR [DI+BX],2

ATARI_E:                                ;反応なし、または終了
        POP     BX
        INC     BX
        CMP     BX,96
        JNE     ATARI_1

EXE:
        XOR     BX,BX

EXE_1:
        MOV     AL,[DI+BX]              ;読み込み
        OR      AL,AL                   ;0=何もしない
        JE      EXE_E
        CMP     AL,2                    ;2=回転
        JE      EXE_2

        MOV     BYTE PTR [SI+BX],4
        JNE     EXE_E                   ;JNE=JMP

EXE_2:
        MOV     AL,[SI+BX]
        INC     AL
        AND     AL,3
        MOV     [SI+BX],AL

EXE_E:
        INC     BX
        CMP     BX,96
        JNE     EXE_1

        MOV     DL,7

VANISH:
        XOR     AH,AH
        MOV     DI,OFFSET FLAG
        MOV     BX,0004H

VANISH_1:
        CMP     BYTE PTR [DI],1
        JNE     VANISH_N
        CALL    LCDC
        MOV     AH,1                    ;AH=1 アニメ処理

VANISH_N:
        INC     DI
        INC     BL
        CMP     BL,28
        JNE     VANISH_1
        MOV     BL,4
        INC     BH
        CMP     BH,4
        JNE     VANISH_1
        OR      AH,AH
        JE      VANISH_E

        MOV     CX,4000H

WAIT:
        LOOP    WAIT                    ;WAIT
        INC     DL
        CMP     DL,11
        JNE     VANISH

VANISH_E:
        JMP     DISP

LCDC:                                   ;DL=NUM、BH=Y、BL=X
        PUSHA
        DB      0C0H,0E2H,003H          ;SAL DL,3
        XOR     DH,DH
        MOV     SI,OFFSET CHR
        ADD     SI,DX
        MOV     AX,0A000H
        MOV     ES,AX
        XOR     DI,DI
        MOV     AL,21H
        STOSB
        MOV     AL,BL
        AND     AL,0FH
        ADD     AL,6
        STOSB
        MOV     AL,22H
        STOSB
        MOV     AL,BH
        DB      0C0H,0E0H,003H          ;SAL AL,3
        TEST    BL,10H
        JE      LEFT
        OR      AL,20H
LEFT:
        STOSB
        MOV     AL,20H
        STOSB
        MOV     AH,8
P_LP:
        LODSB
        STOSB
        NOP                             ;時間稼ぎ
        NOP
        DEC     DI
        DEC     AH
        JNZ     P_LP
        XOR     AX,AX
        MOV     ES,AX
        POPA
        RET

RND:                                    ;0<=DL<=255
        PUSH    AX
        PUSH    BX
        PUSH    CX

RNDDT:
        MOV     CX,0ABC5H
        MOV     BH,CH
        MOV     BL,CL
        ADD     CX,BX
        ADD     CX,BX
        MOV     DL,CL
        ADD     DL,CH
        MOV     CH,DL
        ADD     CX,0038H
        MOV     BX,0001H
        DB      089H,08FH               ;MOV [BX+RNDDT]、CX
        DW      RNDDT                   ;自己書き換え
        MOV     DL,CH
        POP     CX
        POP     BX
        POP     AX
        RET

CHECK:
        MOV     AH,BL

CHECK_1:
        OR      AL,AL                   ;上
        JNE     CHECK_2
        SUB     AH,24
        JNC     CHECK_2
        ADD     AH,96

CHECK_2:
        CMP     AL,1                    ;右
        JNE     CHECK_4
        INC     AH
        CMP     AH,24
        JE      CHECK_3
        CMP     AH,48
        JE      CHECK_3
        CMP     AH,72
        JE      CHECK_3
        CMP     AH,96
        JNE     CHECK_4

CHECK_3:
        SUB     AH,24

CHECK_4:
        CMP     AL,2                    ;下
        JNE     CHECK_5
        ADD     AH,24
        CMP     AH,96
        JC      CHECK_5
        SUB     AH,96

CHECK_5:
        CMP     AL,3                    ;左
        JNE     CHECK_7
        SUB     AH,1
        JC      CHECK_6
        CMP     AH,23
        JE      CHECK_6
        CMP     AH,47
        JE      CHECK_6
        CMP     AH,71
        JNE     CHECK_7

CHECK_6:
        ADD     AH,24

CHECK_7:
        MOV     AL,AH
        XOR     AH,AH
        MOV     BX,AX
        MOV     AL,[SI+BX]
        RET

LOCATE:
        MOV     AH,0FH
        INT     41H
        RET

PRINT:
        MOV     AH,20H
        INT     41H
        RET

CHR     DB      08H,1CH,3EH,1CH
        DB      1CH,1CH,1CH,00H
        DB      00H,08H,3CH,3EH
        DB      3CH,08H,00H,00H
        DB      1CH,1CH,1CH,1CH
        DB      3EH,1CH,08H,00H
        DB      00H,08H,1EH,3EH
        DB      1EH,08H,00H,00H
        DB      00H,00H,00H,00H
        DB      00H,00H,00H,00H
        DB      20H,30H,38H,3CH
        DB      38H,30H,20H,00H
        DB      3BH,3BH,3BH,00H
        DB      2FH,2FH,2FH,00H
        DB      00H,00H,0CH,12H
        DB      12H,0CH,00H,00H
        DB      00H,0CH,12H,21H
        DB      21H,12H,0CH,00H
        DB      00H,1EH,21H,21H
        DB      21H,21H,1EH,00H
        DB      1EH,21H,21H,21H
        DB      21H,21H,21H,1EH
        DB      00H,00H,10H,2AH
        DB      04H,00H,00H,00H
        DB      20H,20H,20H,20H
        DB      22H,22H,1CH,00H
        DB      00H,28H,28H,00H
        DB      00H,00H,00H,00H
        DB      10H,3CH,10H,16H
        DB      20H,28H,26H,00H
        DB      00H,24H,22H,22H
        DB      22H,20H,10H,00H
        DB      00H,24H,2EH,24H
        DB      2EH,34H,2CH,00H
        DB      10H,3CH,10H,1AH
        DB      34H,36H,1AH,00H
        DB      08H,3CH,10H,2AH
        DB      18H,2CH,18H,00H
        DB      00H,20H,2EH,20H
        DB      20H,28H,26H,00H
        DB      08H,2CH,3AH,2AH
        DB      2AH,0CH,08H,00H
        DB      00H,10H,38H,1CH
        DB      12H,36H,16H,00H
        DB      00H,3EH,04H,08H
        DB      10H,08H,04H,00H
        DB      00H,3CH,08H,14H
        DB      22H,1AH,1CH,00H

TITLE_1 DB      '  Overnight '
        DB      'Sensation  '
        DB      'FX-890P'
        DB      0
TITLE_2 DB      11,12,13,14,13
        DB      15,16,17,18,14
        DB      19,20,14,13,21
        DB      22,23,11,0
NAME    DB      'AGREE MIX   '
        DB      'F'
        DB      165
        DB      '2'
        DB      165
        DB      'F MIX'
        DB      0
MSG1    DB      '-Game Over-'
        DB      0
MSG2    DB      '-Rest:  -'
        DB      0
MSG3    DB      '-Perfect-'
        DB      0
MODE    DB      1 DUP(?)
BRAM    DB      96 DUP(?)
FLAG    DB      96 DUP(?)
        END
