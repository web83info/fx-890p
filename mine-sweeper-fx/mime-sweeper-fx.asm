;******************************************************************************
;                        ＭＩＮＥ　ＳＷＥＥＰＥＲ　ＦＸ
;
;         １９９７　（Ｃ）Ｃｏｐｙｒｉｇｈｔ　ＡＢＣＰ　ｓｏｆｔｗａｒｅ
;******************************************************************************

        ORG     2000H

;**************************************
;初期設定
;**************************************

        CLD
        XOR     AX,AX
        MOV     DS,AX
        MOV     ES,AX
        CALL    CLS
        MOV     AH,3AH                  ;ROMフォントアドレスを求める(BIOS)
        INT     41H
        DB      0BEH
        DW      OFFSET FONT             ;MOV SI,OFFSET FONT
        MOV     [SI],DI
        MOV     AX,ES
        DB      089H,044H,002H          ;MOV [SI+2],AX
        MOV     BYTE PTR X_SIZE,20
        MOV     BYTE PTR Y_SIZE,12
        MOV     WORD PTR NUM_MINE,40

;**************************************
;タイトル表示
;**************************************

        MOV     AX,0501H
        DB      0BFH
        DW      OFFSET CPYRIGHT         ;MOV DI,OFFSET CPYRIGHT
        CALL    ROMMOJI
        CALL    VRAM2LCD                ;これを呼ばないと画面に表示されない
        MOV     CX,4000H
CPY_L:
        CALL    RND
        LOOP    CPY_L
TITLE:
        CALL    CLS
        MOV     AX,0800H
        DB      0BFH
        DW      OFFSET M_DATA1          ;MOV DI,OFFSET M_DATA1
        CALL    ROMMOJI
        MOV     AX,0502H
        DB      0BFH
        DW      OFFSET LEVEL            ;MOV DI,OFFSET LEVEL
        CALL    ROMMOJI
        MOV     AX,0E03H
        DB      0BFH
        DW      OFFSET LEVEL2           ;MOV DI,OFFSET LEVEL2
        CALL    ROMMOJI
        MOV     AX,0D02H
        MOV     DL,62                   ;カーソル表示
        CALL    ONEMOJI
        CALL    VRAM2LCD
MENU_STR:
        CALL    RND
        PUSH    AX
        MOV     AX,0080H
        MOV     BX,0200H
        CALL    KEY                     ;リターンキーチェック
        POP     AX
        JNZ     MENU_END
        MOV     BX,AX
        CALL    KEY_KEY
        SHR     DH,1                    ;4
        JNC     MENU_1
        MOV     AH,13
MENU_1:
        SHR     DH,1                    ;6
        JNC     MENU_2
        MOV     AH,19
MENU_2:
        SHR     DH,1                    ;8
        JNC     MENU_3
        MOV     AL,2
MENU_3:
        SHR     DH,1                    ;2
        JNC     MENU_4
        MOV     AL,3
MENU_4:
        CMP     AX,BX
        JE      MENU_STR                ;カーソルの点滅防止
        PUSH    AX
        MOV     AX,BX
        MOV     DL,32
        CALL    ONEMOJI
        POP     AX
        MOV     DL,62
        CALL    ONEMOJI
        CALL    VRAM2LCD
        JMP     MENU_STR
MENU_END:
        MOV     CX,3
        CMP     AH,19
        JE      MENU_A
        SUB     CL,1
MENU_A:
        CMP     AL,3
        JE      MENU_B
        SUB     CL,2
MENU_B:
        CMP     CL,3
        JE      MENU_CUS
        DB      0BEH
        DW      OFFSET LV_DATA          ;MOV SI,OFFSET LV_DATA
        DB      0C0H,0E1H,2             ;SAL CL,2
        ADD     SI,CX
        DB      0BFH
        DW      OFFSET X_SIZE           ;MOV DI,OFFSET X_SIZE
        MOV     CL,4
        REP     MOVSB
        JMP     INIT

;**************************************
;カスタムモード
;**************************************

MENU_CUS:
        MOV     AX,0080H
        MOV     BX,0200H
        CALL    KEY                     ;RETを放すまで待つ
        JNZ     MENU_CUS
        CALL    CLS
        MOV     BYTE PTR K_R,15         ;キーリピートまでの待ち時間
        MOV     AX,0A00H
        DB      0BFH
        DW      OFFSET CUSTOM           ;MOV DI,OFFSET CUSTOM
        CALL    ROMMOJI
        MOV     AX,0601H
        DB      0BFH
        DW      OFFSET FIELDX           ;MOV DI,OFFSET FIELDX
        CALL    ROMMOJI
        MOV     AX,0602H
        DB      0BFH
        DW      OFFSET FIELDY           ;MOV DI,OFFSET FIELDY
        CALL    ROMMOJI
        MOV     AX,0603H
        DB      0BFH
        DW      OFFSET FIELDB           ;MOV DI,OFFSET FIELDB
        CALL    ROMMOJI
        MOV     AX,0501H
        MOV     DL,62
        CALL    ONEMOJI                 ;カーソル表示
        CALL    VRAM2LCD
CUSTOM_L:
        PUSH    AX
        MOV     AX,0080H
        MOV     BX,0200H
        CALL    KEY                     ;リターンキーチェック
        POP     AX
        JZ      CUS_C
        JMP     INIT
CUS_C:
        MOV     BX,AX
        CALL    KEY_KEY
        SHR     DH,1                    ;2
        JNC     CUSTOM_1
        CMP     AL,3
        JZ      CUSTOM_C
        CMP     AL,2
        JZ      CUSTOM_B
;CUSTOM_A:
        CMP     BYTE PTR X_SIZE,6       ;Xサイズの最低値
        JZ      CUSTOM_1
        DEC     BYTE PTR X_SIZE
        JMP     CUSTOM_1
CUSTOM_B:
        CMP     BYTE PTR Y_SIZE,6       ;Yサイズの最低値
        JZ      CUSTOM_1
        DEC     BYTE PTR Y_SIZE
        JMP     CUSTOM_1
CUSTOM_C:
        CMP     WORD PTR NUM_MINE,1     ;爆弾数の最低値
        JZ      CUSTOM_1
        DEC     WORD PTR NUM_MINE
CUSTOM_1:
        SHR     DH,1                    ;4
        JNC     CUSTOM_2
        CMP     AL,3
        JZ      CUSTOM_F
        CMP     AL,2
        JZ      CUSTOM_E
;CUSTOM_D:
        CMP     BYTE PTR X_SIZE,20      ;Xサイズの最大値
        JZ      CUSTOM_2
        INC     BYTE PTR X_SIZE
        JMP     CUSTOM_2
CUSTOM_E:
        CMP     BYTE PTR Y_SIZE,49      ;Yサイズの最大値
        JZ      CUSTOM_2
        INC     BYTE PTR Y_SIZE
        JMP     CUSTOM_2
CUSTOM_F:
        PUSH    AX
        MOV     AL,Y_SIZE
        DEC     AL
        MUL     BYTE PTR X_SIZE         ;AX=爆弾の最大値
        CMP     AX,NUM_MINE
        POP     AX
        JZ      CUSTOM_2
        INC     WORD PTR NUM_MINE
CUSTOM_2:
        SHR     DH,1                    ;8
        JNC     CUSTOM_3
        CMP     AL,1
        JZ      CUSTOM_3
        DEC     AL
CUSTOM_3:
        SHR     DH,1                    ;2
        JNC     CUSTOM_4
        CMP     AL,3
        JZ      CUSTOM_4
        INC     AL
CUSTOM_4:
        CMP     AX,BX
        JZ      CUSTOM_5                ;カーソルの点滅防止
        PUSH    AX
        MOV     AX,BX
        MOV     DL,32
        CALL    ONEMOJI
        POP     AX
        MOV     DL,62
        CALL    ONEMOJI
CUSTOM_5:
        PUSH    AX
        MOV     AL,Y_SIZE
        DEC     AL
        MUL     BYTE PTR X_SIZE
        CMP     AX,NUM_MINE
        JA      CUSTOM_6
        MOV     NUM_MINE,AX
CUSTOM_6:
        XOR     CH,CH
        MOV     AX,1601H
        MOV     CL,X_SIZE
        CALL    NUMBER
        MOV     AX,1602H
        MOV     CL,Y_SIZE
        CALL    NUMBER
        MOV     AX,1603H
        MOV     CX,NUM_MINE
        CALL    NUMBER
        POP     AX
        CALL    VRAM2LCD
        MOV     CX,800
CUS_WAIT:
        LOOP    CUS_WAIT
        JMP     CUSTOM_L

;**************************************
;ワークエリア初期化
;**************************************

INIT:
        CALL    CLS
        XOR     AX,AX
        MOV     NOW_X,AL
        MOV     NOW_Y,AL
        MOV     Y_SCROLL,AL
        MOV     K_REPEAT,AL
        MOV     BYTE PTR FIRST,1
        MOV     BOMB,AL
        MOV     BYTE PTR K_R,3
        DB      0BFH
        DW      OFFSET BRAM             ;MOV DI,OFFSET BRAM
        MOV     AL,080H
        MOV     CX,980
        REP     STOSB
PUT_MINE:                               ;爆弾を置く
        MOV     CX,NUM_MINE
        MOV     AL,X_SIZE
        MUL     BYTE PTR Y_SIZE         ;AX=マスの数
        SUB     AX,CX
        MOV     MASULEFT,AX
        MOV     BOMBLEFT,CX
PUT_L:
        CALL    P_M
        LOOP    PUT_L
        MOV     AX,1101H
        DB      0BFH
        DW      OFFSET M_DATA1          ;MOV DI,OFFSET M_DATA1
        CALL    ROMMOJI
        MOV     AX,1202H
        DB      0BFH
        DW      OFFSET M_DATA2          ;MOV DI,OFFSET M_DATA2
        CALL    ROMMOJI
        CALL    VRAM2LCD

;**************************************
;メイン
;**************************************

MAIN:
        MOV     DL,Y_SCROLL
        MOV     CH,0
        CALL    PRNTMINE                ;マス目表示
        MOV     AH,NOW_X
        MOV     AL,NOW_Y
        ADD     AL,Y_SCROLL
        CALL    XY
        MOV     DL,[DI]
        MOV     CH,1
        MOV     AL,NOW_Y
        CALL    WRITECHR                ;カーソル表示
KEY_READ:
        CALL    KEY_KEY
KEY_2:
        SHR     DH,1                    ;4
        JNC     KEY_3
        CMP     BYTE PTR NOW_X,0
        JE      KEY_3
        DEC     BYTE PTR NOW_X
KEY_3:
        SHR     DH,1                    ;6
        JNC     KEY_4
        MOV     BL,X_SIZE
        DEC     BL
        CMP     BL,NOW_X
        JE      KEY_4
        INC     BYTE PTR NOW_X
KEY_4:
        SHR     DH,1                    ;2
        JNC     KEY_5
        CMP     BYTE PTR NOW_Y,0
        JNZ     CUR_UP
        CMP     BYTE PTR Y_SCROLL,0
        JZ      KEY_5
        DEC     BYTE PTR Y_SCROLL       ;スクロール
        JMP     KEY_5
CUR_UP:
        DEC     BYTE PTR NOW_Y
KEY_5:
        SHR     DH,1
        JNC     KEY_6
        CMP     BYTE PTR NOW_Y,5
        JNZ     CUR_DW
        MOV     BH,Y_SIZE
        SUB     BH,6
        CMP     BH,Y_SCROLL
        JE      KEY_6
        INC     BYTE PTR Y_SCROLL       ;スクロール
        JMP     KEY_6
CUR_DW:
        INC     BYTE PTR NOW_Y
KEY_6:
        SHR     DH,1                    ;S
        JC      KEY_S
        JMP     KEY_7

;**************************************
;マスの自動展開
;**************************************

KEY_ENDS:
        NOP
        JMP     KEY_END
KEY_S:
        MOV     AH,NOW_X
        MOV     AL,NOW_Y
        ADD     AL,Y_SCROLL
        CALL    XY
        TEST    BYTE PTR [DI],080H      ;そのマスが空の時は同時クリック処理
        JNZ     KEY_S_ER
        JMP     KEY_Z
KEY_S_ER:
        CALL    XY
        MOV     DL,[DI]
        TEST    DL,060H                 ;フラグがなかったら掘る
        JZ      KEY_S_S
        JMP     KEY_ENDS
KEY_S_S:
        TEST    DL,80H                  ;掘ってなかったら掘る
        JNZ     KEY_S_S2
        JMP     KEY_ENDS
KEY_S_S2:
        AND     DL,01H
        MOV     [DI],DL                 ;掘った
        CMP     DL,01H
        JNZ     NF_BOMB
        JMP     F_BOMB                  ;爆弾を掘ってしまったら;F_BOMB
NF_BOMB:
        DEC     WORD PTR MASULEFT       ;掘られていないマスの数を計算
        PUSH    AX
        PUSH    DI
        DB      0BFH
        DW      OFFSET BRAMBRAM         ;MOV DI,OFFSET BRAMBRAM
        MOV     CX,980
        XOR     AL,AL
        REP     STOSB                   ;通り道チェック領域初期化
        POP     DI
        POP     AX
        MOV     BYTE PTR FIRST,0        ;いきなり爆弾防止はもう必要ない
        MOV     DH,1                    ;自分のマスの周りの爆弾探し
        CALL    AROUND_B
        MOV     CH,0
        PUSH    AX
        MOV     AH,NOW_X
        MOV     AL,NOW_Y
        SAL     DL,1
        CALL    WRITECHR                ;自分のマスの情報を表示
        POP     AX
        MOV     [DI],DL
        CMP     DL,0
        JE      NEAR
        JMP     NOT_NEAR                ;自分のマスが空でなかったら処理しない
NEAR:
        SUB     DI,OFFSET BRAM
        ADD     DI,OFFSET BRAMBRAM
        MOV     BYTE PTR [DI],1
        DB      0BEH
        DW      OFFSET PLACE            ;MOV SI,OFFSET PLACE
        MOV     CL,7
SEARCH_B:
        CALL    MY_PUSH                 ;マスの情報を記録
SEARCH:
        MOV     CL,0
SEARCH_1:
        DB      0BFH
        DW      OFFSET VECTOR           ;MOV DI,OFFSET VECTOR
        PUSH    CX                      ;次のマスの情報を読む
        XOR     CH,CH
        SAL     CL,1
        ADD     DI,CX                   ;上から時計周りに調べる
        POP     CX
        PUSH    AX                      ;そのマスが存在するか
        ADD     AH,[DI]
        JS      SEARCH_E                ;座標がマイナスならばマスは存在しない
        CMP     AH,X_SIZE               ;座標が飛び出していたらマスは存在しない
        JE      SEARCH_E
        DB      02H,45H,01H             ;ADD AL,[DI+1]
        JS      SEARCH_E
        CMP     AL,Y_SIZE
        JE      SEARCH_E
        CALL    XY
        TEST    BYTE PTR [DI],060H      ;そのマスにフラグがあったら処理しない
        JNZ     SEARCH_E
        TEST    BYTE PTR [DI],080H      ;そのマスが開いていたら処理しない
        JZ      SEARCH_E
        MOV     BX,DI
        SUB     BX,OFFSET BRAM          ;通り道は処理しない
        ADD     BX,OFFSET BRAMBRAM
        CMP     BYTE PTR [BX],0
        JNZ     SEARCH_E
        MOV     BYTE PTR [BX],1
        MOV     DH,1
        CALL    AROUND_B                ;周りの爆弾の数を求める
        SAL     DL,1
        MOV     [DI],DL                 ;周りの爆弾数記録
        DEC     WORD PTR MASULEFT
        CMP     DL,0
        JNZ     SEARCH_E
        MOV     BX,AX
        POP     AX
        CALL    MY_PUSH                 ;座標を記録して
        MOV     AX,BX
        JMP     SEARCH                  ;更に掘る
SEARCH_E:
        POP     AX
SEARCH_N:
        INC     CL                      ;次はどの方向を調べるか
        CMP     CL,8
        JNE     SEARCH_1
        CALL    MY_POP                  ;手前の座標を呼び出す
        CMP     SI,OFFSET PLACE
        JNE     SEARCH_N
NOT_NEAR:
        JMP     KEY_ENDS

;**************************************
;爆弾を掘ってしまった！
;**************************************

F_BOMB:
        CMP     BYTE PTR FIRST,1
        JE      NOT_BOMB                ;いきなり爆弾の時はなかったことにする
        MOV     BYTE PTR BOMB,1
        JMP     KEY_ENDS
NOT_BOMB:
        MOV     BYTE PTR FIRST,0
NOTBOMB1:
        MOV     BYTE PTR [DI],080H      ;爆弾をなかったことにする
        PUSH    DI
        CALL    P_M
        POP     SI
        CMP     DI,SI                   ;同じ場所を選んでしまったらもう一度
        JE      NOTBOMB1
        JMP     KEY_S
KEY_7:
        SHR     DH,1                    ;A
        JC      KEY_A
        JMP     KEY_END

;**************************************
;フラグ立て
;**************************************

KEY_A:
        MOV     AH,NOW_X
        MOV     AL,NOW_Y
        ADD     AL,Y_SCROLL
        CALL    XY
        MOV     DL,[DI]
        TEST    DL,0E0H                 ;掘ってあるマスは処理しない
        JNZ     KEY_A_2
        JMP     KEY_END
KEY_A_2:
        MOV     BL,DL                   ;爆弾フラグを保存
        AND     BL,01H
        AND     DL,0E0H
        SAL     DL,1
        JNC     N_O_F
        MOV     DL,020H
        DEC     WORD PTR BOMBLEFT       ;残り爆弾数の調整
N_O_F:
        TEST    DL,080H
        JZ      N_O_F2
        INC     WORD PTR BOMBLEFT       ;残り爆弾数の調整
N_O_F2:
        OR      DL,BL                   ;爆弾フラグの復帰
        MOV     AL,NOW_Y
        MOV     [DI],DL
        MOV     CH,0
        CALL    WRITECHR
        JMP     KEY_END

;**************************************
;同時クリック処理
;**************************************

KEY_ENDZ:
        JMP     KEY_END
KEY_Z:
        MOV     AH,NOW_X
        MOV     AL,NOW_Y
        ADD     AL,Y_SCROLL
        CALL    XY
        TEST    BYTE PTR [DI],0E0H      ;マスが開いているときだけ処理
        JNZ     KEY_ENDZ
        MOV     DL,[DI]
        SHR     DL,1                    ;DL=そのマスの周りの爆弾数
        MOV     CL,DL
        MOV     DH,020H                 ;周りの旗の数を調べる
        CALL    AROUND_B
        CMP     CL,DL                   ;周りの旗の数と周りの爆弾数が一致したら
        JNE     KEY_ENDZ                ;周り8マスを掘る
        MOV     CL,0
KEY_Z_L:
        PUSH    AX
        DB      0BFH
        DW      OFFSET VECTOR           ;MOV DI,OFFSET VECTOR
        PUSH    CX
        XOR     CH,CH
        SAL     CL,1
        ADD     DI,CX
        POP     CX
        ADD     AH,[DI]                 ;掘るマスが存在するかどうか
        JS      KEY_Z_E
        CMP     AH,X_SIZE
        JE      KEY_Z_E
        DB      02H,45H,01H             ;ADD AL,[DI+1]
        JS      KEY_Z_E
        CMP     AL,Y_SIZE
        JE      KEY_Z_E
        MOV     BYTE PTR KEY_ENDS,0C3H  ;RET
        PUSH    CX
        CALL    KEY_S_ER                ;サブルーチンとして呼び出す
        POP     CX
        MOV     BYTE PTR KEY_ENDS,090H  ;NOP
KEY_Z_E:
        POP     AX
        INC     CL
        CMP     CL,8
        JNE     KEY_Z_L
        JMP     KEY_ENDZ

;**************************************
;ゲームオーバー判定
;**************************************

KEY_END:
        MOV     AX,1C02H
        MOV     CX,BOMBLEFT             ;残り爆弾数表示
        MOV     DL,32
        CMP     CX,08000H
        JC      NOT_PLUS
        NEG     CX
        MOV     DL,45
NOT_PLUS:
        CALL    ONEMOJI                 ;符号表示（SPCか-）
        INC     AH
        CALL    NUMBER
        CALL    VRAM2LCD
        CMP     BYTE PTR BOMB,0         ;ゲームオーバーフラグが立っていたらゲームオーバー
        JNE     OVER
        CMP     WORD PTR MASULEFT,0     ;すべてのマスを掘ってしまったらクリア
        JNZ     TO_MAIN
        JMP     CLEAR
TO_MAIN:
        JMP     MAIN

;**************************************
;ゲームオーバー
;**************************************

OVER:
        DB      0BFH
        DW      OFFSET BRAM             ;MOV DI,OFFSET BRAM
        MOV     AL,X_SIZE
        MUL     BYTE PTR Y_SIZE
        MOV     CX,AX
OVER_1:
        MOV     DL,[DI]
        TEST    DL,020H                 ;旗があって
        JZ      OVER_3
        TEST    DL,01H                  ;爆弾なしのときは
        JNZ     OVER_4
        MOV     DL,26                   ;×を表示
        JMP     OVER_4
OVER_3:
        TEST    DL,20H                  ;旗がなくて
        JNZ     OVER_4
        TEST    DL,01H                  ;爆弾があるときは
        JZ      OVER_4
        MOV     DL,1                    ;爆弾の表示
OVER_4:
        MOV     [DI],DL
        INC     DI
        LOOP    OVER_1
        MOV     BH,4
        MOV     CH,0FFH                 ;反転表示
OVER_5:
        MOV     DL,Y_SCROLL
        CALL    PRNTMINE
        CALL    VRAM2LCD
        NOT     CH                      ;反転と通常の切り替え
        DEC     BH
        JNZ     OVER_5
        DB      0BEH
        DW      OFFSET G_OVER           ;MOV SI,OFFSET G_OVER
        MOV     DI,69BH
        DB      0BDH
        DW      OFFSET PLACE            ;MOV BP,OFFSET PLACE
        MOV     BL,6
OVER_6:
        MOV     CX,9
OVER_7:
        MOV     AL,[DI]
        MOV     DS:[BP],AL              ;VRAM待避
        MOV     AL,[SI]
        MOV     [DI],AL                 ;FAILURE表示
        INC     DI
        INC     SI
        INC     BP
        LOOP    OVER_7
        DB      083H,0C7H,23            ;ADD DI,23
        DEC     BL
        JNZ     OVER_6
        CALL    VRAM2LCD
        MOV     AL,4
OVER_8:
        XOR     CX,CX
OVER_9:
        LOOP    OVER_9
        DEC     AL
        JNZ     OVER_8
        DB      0BEH
        DW      OFFSET PLACE            ;MOV SI,OFFSET PLACE
        MOV     DI,69BH
        MOV     BL,6
OVER_10:
        MOV     CX,9
OVER_11:
        MOV     AL,[SI]
        MOV     [DI],AL                 ;元の画面表示
        INC     DI
        INC     SI
        LOOP    OVER_11
        DB      083H,0C7H,23            ;ADD DI,23
        DEC     BL
        JNZ     OVER_10
        CALL    VRAM2LCD
        JMP     END_

;**************************************
;ゲームクリア
;**************************************

CLEAR:
        DB      0BFH
        DW      OFFSET BRAM             ;MOV DI,OFFSET BRAM
        MOV     AL,X_SIZE
        MUL     BYTE PTR Y_SIZE
        MOV     CX,AX
CLEAR_1:
        MOV     DL,[DI]
        TEST    DL,080H                 ;開いていないマスは
        JZ      CLEAR_2
        AND     DL,07FH                 ;開いて
        OR      DL,020H                 ;フラグを立てる
        MOV     [DI],DL
CLEAR_2:
        INC     DI
        LOOP    CLEAR_1
        MOV     DL,Y_SCROLL
        MOV     CH,0
        CALL    PRNTMINE
        MOV     AX,1D02H
        XOR     CX,CX
        CALL    NUMBER
        DB      0BEH
        DW      OFFSET G_CLEAR          ;MOV SI,OFFSET G_CLEAR
        MOV     DI,69BH
        DB      0BDH
        DW      OFFSET PLACE            ;MOV BP,OFFSET PLACE
        MOV     BL,6
CLEAR_3:
        MOV     CX,9
CLEAR_4:
        MOV     AL,[DI]
        MOV     DS:[BP],AL              ;VRAM待避
        MOV     AL,[SI]
        MOV     [DI],AL                 ;SUCCESS表示
        INC     DI
        INC     SI
        INC     BP
        LOOP    CLEAR_4
        DB      083H,0C7H,23            ;ADD DI,23
        DEC     BL
        JNZ     CLEAR_3
        CALL    VRAM2LCD
        MOV     AL,4
CLEAR_5:
        XOR     CX,CX
CLEAR_6:
        LOOP    CLEAR_6
        DEC     AL
        JNZ     CLEAR_5
        DB      0BEH
        DW      OFFSET PLACE            ;MOV SI,OFFSET PLACE
        MOV     DI,69BH
        MOV     BL,6
CLEAR_7:
        MOV     CX,9
CLEAR_8:
        MOV     AL,[SI]
        MOV     [DI],AL                 ;元の画面を表示
        INC     DI
        INC     SI
        LOOP    CLEAR_8
        DB      083H,0C7H,23            ;ADD DI,23
        DEC     BL
        JNZ     CLEAR_7
        CALL    VRAM2LCD

;**************************************
;ゲームエンド&リトライ
;**************************************

END_:
        MOV     DL,Y_SCROLL
        CALL    PRNTMINE
        CALL    VRAM2LCD
        MOV     BYTE PTR K_R,200
END_END:
        MOV     DL,Y_SCROLL
        CALL    KEY_KEY
        DB      0C0H,0EEH,3             ;SHR DH,3 / 2
        JNC     N_UP_B
        CMP     DL,0
        JZ      N_UP_B
        DEC     DL
N_UP_B:
        SHR     DH,1                    ;8
        JNC     N_DW_B
        MOV     BH,Y_SIZE
        SUB     BH,6
        CMP     BH,DL
        JE      N_DW_B
        INC     DL
N_DW_B:
        CMP     DL,Y_SCROLL
        JE      N_PRINT
        MOV     Y_SCROLL,DL
        MOV     CH,0
        CALL    PRNTMINE                ;スクロールして表示
        CALL    VRAM2LCD
N_PRINT:
        MOV     AX,0080H                ;[RET]
        MOV     BX,0200H
        CALL    KEY
        JNZ     N_PRINT2
        MOV     AX,0400H                ;[CLS]
        MOV     BX,0010H
        CALL    KEY
        JNZ     N_PRINT3
        JMP     END_END
N_PRINT2:
        JMP     INIT
N_PRINT3:
        JMP     TITLE

;**************************************
;サブルーチンの大群
;**************************************

NUMBER:                                 ;数字の表示
        PUSHA
        CMP     CX,08000H
        JC      NUMBER1
        NEG     CX
NUMBER1:
        MOV     BX,100
        CALL    WARI16
        CALL    ONEMOJI
        INC     AH
        MOV     BX,10
        CALL    WARI16
        CALL    ONEMOJI
        INC     AH
        MOV     BX,1
        CALL    WARI16
        CALL    ONEMOJI
        POPA
        RET

WARI16:                                 ;数字表示用割り算
        XOR     DL,DL
WARI16C:
        SUB     CX,BX
        JC      WARI16E
        INC     DL
        JMP     WARI16C
WARI16E:
        ADD     CX,BX
        ADD     DL,48
        RET

ONEMOJI:                                ;ROM文字の１文字表示
        PUSHA
        PUSH    ES
        MOV     BX,AX
        SAL     BH,1
        DB      0C0H,0E4H,2             ;SAL AH,2
        ADD     AH,BH                   ;6倍
        MOV     AL,8
        CALL    WARI
        MOV     CL,AL
        MOV     SI,0630H
        MOV     AL,AH
        XOR     AH,AH
        DB      0C1H,0E0H,5             ;SAL AX,5
        ADD     SI,AX
        XOR     BH,BH
        DB      0C1H,0E3H,3             ;SAL BX,3
        ADD     SI,BX
        SUB     DL,32
        DB      0BBH
        DW      OFFSET FONT             ;MOV BX,OFFSET FONT
        MOV     DI,[BX]
        DB      08BH,047H,2             ;MOV AX,[BX+2]
        MOV     ES,AX
        XOR     DH,DH
        DB      0C1H,0E2H,3             ;SAL DX,3
        ADD     DI,DX
        MOV     AH,8
OM_L:
        MOV     DH,ES:[DI]
        DB      0C0H,0E6H,2             ;SAL DH,2
        INC     DI
        XOR     DL,DL
        MOV     BX,0FC00H
        SHR     BX,CL
        SHR     DX,CL
        NOT     BX
        AND     [SI],BH
        DB      020H,05CH,020H          ;AND [SI+20H],BL
        OR      [SI],DH
        DB      008H,054H,020H          ;OR [SI+20H],DL
        INC     SI
        DEC     AH
        JNZ     OM_L
        POP     ES
        POPA
        RET

ROMMOJI:                                ;ROM文字の表示
        PUSHA
ROMMOJIL:
        MOV     DL,[DI]
        INC     DI
        CMP     DL,0
        JZ      ROMMOJIE
        CALL    ONEMOJI
        INC     AH
        JMP     ROMMOJIL
ROMMOJIE:
        POPA
        RET

MY_PUSH:                                ;座標の記憶
        PUSH    BX
        MOV     BL,AH
        DB      0C0H,0E3H,3             ;SAL BL,3
        OR      BL,CL
        MOV     BH,AL
        MOV     [SI],BX
        INC     SI
        INC     SI
        POP     BX
        RET

MY_POP:                                 ;座標の呼び出し
        PUSH    BX
        DEC     SI
        DEC     SI
        MOV     BX,[SI]
        MOV     CL,BL
        AND     CL,07H
        MOV     AH,BL
        DB      0C0H,0ECH,3             ;SHR    AH,3
        MOV     AL,BH
        POP     BX
        RET

P_M:                                    ;マスに爆弾を置く
        CALL    RND
        AND     DL,1FH
        CMP     DL,X_SIZE
        JNC     P_M
        MOV     AH,DL
P_M_L2:
        CALL    RND
        CMP     DL,Y_SIZE
        JNC     P_M_L2
        MOV     AL,DL
        CALL    XY
        CMP     BYTE PTR [DI],080H
        JNZ     P_M
        MOV     BYTE PTR [DI],081H
        RET

KEY:                                    ;キー入力
        PUSH    DX
        MOV     DX,200H
        OUT     DX,AX
        PUSH    AX
        POP     AX
        MOV     DL,2
        IN      AX,DX
        AND     AX,BX
        POP     DX
        RET

KEY_KEY:                                ;リピート付きキー入力
        PUSH    AX
        PUSH    BX
        MOV     AX,1
        MOV     BX,AX
        CALL    KEY
        JZ      KEY_K
        MOV     AH,7FH                  ;電源を切る
        INT     41H
KEY_K:
        XOR     DH,DH
        DB      0BFH
        DW      OFFSET K_DAT            ;MOV DI,OFFSET K_DAT
        MOV     CX,2
KEY_KL:
        SAL     DH,1
        MOV     AX,[DI]
        DB      08BH,05DH,002H          ;MOV BX,[DI+2]
        DB      083H,0C7H,004H          ;ADD DI,4
        CALL    KEY
        JZ      KEY_K1                  ;そのキーが押されていないとき
        OR      DH,1
KEY_K1:
        LOOP    KEY_KL
        MOV     CL,4
KEY_KL2:
        SAL     DH,1
        MOV     AX,[DI]
        DB      08BH,05DH,002H          ;MOV BX,[DI+2]
        DB      083H,0C7H,004H          ;ADD DI,4
        CALL    KEY
        JZ      KEY_K2                  ;そのキーが押されていないとき
        CMP     DH,0
        JNZ     KEY_K2                  ;他のキーが押されているとき
        OR      DH,1
KEY_K2:
        LOOP    KEY_KL2
        MOV     AL,LASTKEY
        TEST    AL,070H                 ;前回A,S,Zを押してなかったら
        JZ      REPEAT_1
        MOV     LASTKEY,DH
        AND     DH,0FH                  ;A,S,Zのリピート禁止
        JMP     REPEAT_F
REPEAT_1:
        AND     AL,0FH                  ;前回テンキーを押していなかったら
        JZ      REPEAT_3
        TEST    DH,AL                   ;前回と同じキーを押していなかったら
        JZ      REPEAT_R
        INC     BYTE PTR K_REPEAT
        JMP     REPEAT_2
REPEAT_R:
        MOV     BYTE PTR K_REPEAT,0
        JMP     REPEAT_3
REPEAT_2:
        CMP     BYTE PTR K_REPEAT,0     ;最初は反応
        JE      REPEAT_3
        DB      080H,03EH
        DW      OFFSET K_REPEAT
K_R:
        DB      3                       ;CMP BYTE PTR K_REPEAT,x
        JNC     REPEAT_4
        MOV     LASTKEY,DH
        AND     DH,30H
        JMP     REPEAT_F
REPEAT_4:
        DEC     BYTE PTR K_REPEAT
REPEAT_3:
        MOV     LASTKEY,DH
REPEAT_F:
        POP     BX
        POP     AX
        RET

CLS:                                    ;CLS
        XOR     AX,AX
        MOV     ES,AX
        MOV     DI,630H
        MOV     CX,1024
        REP     STOSB
        CALL    VRAM2LCD
        RET

PRNTMINE:                               ;全てのマスの表示
        XOR     AX,AX
        ADD     AL,DL
        CALL    XY
        XOR     CL,CL
        XOR     AX,AX
PRNTMN_1:
        MOV     AH,0
PRNTMN_2:
        MOV     DL,[DI]
        INC     DI
        CALL    WRITECHR
        INC     AH
        CMP     AH,X_SIZE
        JNE     PRNTMN_2
        INC     AL
        INC     CL
        CMP     CL,6
        JNE     PRNTMN_1
        RET

WRITECHR:                               ;5*5キャラの表示
        PUSHA
        MOV     BX,AX
        DB      0C0H,0E4H,2             ;SAL AH,2
        ADD     AH,BH                   ;5倍
        MOV     AL,8
        CALL    WARI
        MOV     CL,AL
        MOV     SI,0630H
        MOV     AL,AH
        XOR     AH,AH
        DB      0C1H,0E0H,5             ;SAL AX,5
        ADD     SI,AX
        XOR     BH,BH
        ADD     SI,BX
        DB      0C1H,0E3H,2             ;SAL BX,2
        ADD     SI,BX
        INC     SI
        TEST    DL,0E0H
        JZ      MASK_2
        DB      0C0H,0EAH,5             ;SHR DL,5
        CMP     DL,4
        JNE     MASK_1
        DEC     DL
MASK_1:
        ADD     DL,8                    ;マスクする
        JMP     MASK_3
MASK_2:
        TEST    DL,1
        JNZ     MASK_4
        SHR     DL,1
        JMP     MASK_3
MASK_4:
        MOV     DL,12
MASK_3:
        MOV     DH,DL
        DB      0C0H,0E2H,2             ;SAL DL,2
        ADD     DL,DH                   ;5倍
        DB      0BFH
        DW      OFFSET CHR5             ;MOV DI,OFFSET CHR5
        XOR     DH,DH
        ADD     DI,DX
        MOV     AH,5
W_C_L:
        MOV     DH,[DI]
        CMP     CH,0
        JZ      W_C_LL
        NOT     DH
        AND     DH,0F8H
W_C_LL:
        INC     DI
        XOR     DL,DL
        MOV     BX,0F800H
        SHR     BX,CL
        SHR     DX,CL
        NOT     BX
        AND     [SI],BH
        DB      020H,05CH,020H          ;AND [SI+20H],BL
        OR      [SI],DH
        DB      008H,054H,020H          ;OR [SI+20H],DL
        INC     SI
        DEC     AH
        JNZ     W_C_L
        POPA
        RET

XY:                                     ;仮想配列変数
        PUSH    AX
        PUSH    BX
        MOV     BL,X_SIZE
        XOR     BH,BH
        DB      0BFH
        DW      OFFSET BRAM             ;MOV DI,OFFSET BRAM
XY_2:
        SUB     AL,1
        JC      XY_3
        ADD     DI,BX
        JMP     XY_2
XY_3:
        INC     AL
        XCHG    AL,AH
        ADD     DI,AX
        POP     BX
        POP     AX
        RET

AROUND_B:                               ;周りの爆弾か旗の数を求める
        PUSH    DI
        PUSH    CX
        MOV     CL,0
        MOV     DL,CL
AROUND_L:
        PUSH    AX
        DB      0BFH
        DW      OFFSET VECTOR           ;MOV DI,OFFSET VECTOR
        PUSH    CX
        XOR     CH,CH
        SAL     CL,1
        ADD     DI,CX
        POP     CX
        ADD     AH,[DI]
        JS      AROUND_E
        CMP     AH,X_SIZE
        JE      AROUND_E
        DB      02H,45H,01H             ;ADD AL,[DI+1]
        JS      AROUND_E
        CMP     AL,Y_SIZE
        JE      AROUND_E
        CALL    XY
        TEST    BYTE PTR [DI],DH
        JZ      AROUND_E
        INC     DL
AROUND_E:
        POP     AX
        INC     CL
        CMP     CL,8
        JNE     AROUND_L
        POP     CX
        POP     DI
        RET

RND:                                    ;乱数を発生する
        PUSH    AX
        PUSH    BX
        PUSH    CX
        DB      0B9H                    ;CX=?
RNDDT:
        DW      12DBH
        MOV     BH,CH
        MOV     BL,CL
        SAL     BX,1
        ADD     CX,BX
        MOV     DL,CL
        ADD     DL,CH
        MOV     CH,DL
        DB      083H,0C1H,038H          ;ADD CX,0038H
        MOV     RNDDT,CX
        MOV     DL,CH
        POP     CX
        POP     BX
        POP     AX
        RET

VRAM2LCD:                               ;VRAMをLCDに表示
        PUSH    ES
        PUSHA
        MOV     SI,630H
        MOV     AX,0A000H
        MOV     ES,AX
        XOR     DI,DI
        MOV     AL,23H
        STOSB
        MOV     AL,35H
        STOSB
        MOV     AL,21H
        STOSB
        MOV     AL,4
        STOSB
        MOV     AL,22H
        STOSB
        MOV     AL,0
        STOSB
        MOV     AL,20H
        STOSB
        MOV     CX,32
V2L_0:
        LODSB
        DB      0C0H,0E8H,004H              ;SHR AL,4
        STOSB
        INC     DI
        LOOP    V2L_0
        MOV     DL,5
V2L_1:
        INC     DI
        MOV     AL,21H
        STOSB
        MOV     AL,DL
        STOSB
        MOV     AL,22H
        STOSB
        MOV     AL,0
        STOSB
        MOV     AL,20H
        STOSB
        MOV     CX,32
V2L_2:
        DB      08AH,064H,0E0H              ;MOV AH,[SI-20H]
        LODSB
        DB      0C1H,0E8H,004H              ;SHR AX,4
        STOSB
        INC     DI
        LOOP    V2L_2
        INC     DL
        CMP     DL,17
        JNZ     V2L_1
        SUB     SI,32
        MOV     DL,4
V2L_3:
        INC     DI
        MOV     AL,21H
        STOSB
        MOV     AL,DL
        STOSB
        MOV     AL,22H
        STOSB
        MOV     AL,32
        STOSB
        MOV     AL,20H
        STOSB
        MOV     CX,32
V2L_4:
        DB      08AH,064H,0E0H          ;MOV AH,[SI-20H]
        LODSB
        DB      0C1H,0E8H,004H          ;SHR AX,4
        STOSB
        INC     DI
        LOOP    V2L_4
        INC     DL
        CMP     DL,17
        JNZ     V2L_3
        INC     DI
        MOV     AL,23H
        STOSB
        MOV     AL,75H
        STOSB
        POPA
        POP     ES
        RET

WARI:                                   ;AH/AL=AH...AL
        PUSH    BX
        PUSH    CX
        XOR     BX,BX
        MOV     BL,AH
        MOV     CX,8
WARI_L:
        SAL     BX,1
        MOV     AH,BH
        SUB     AH,AL
        JC      WARI_S
        INC     BL
        MOV     BH,AH
WARI_S:
        LOOP    WARI_L
        MOV     AH,BL
        MOV     AL,BH
        POP     CX
        POP     BX
        RET

;**************************************
;データ
;**************************************

M_DATA1:
                DB      'MINE '
                DB      'SWEEPER FX'
                DB      0
M_DATA2:
                DB      'BOMB LEFT:'
                DB      0
CPYRIGHT:
                DB      '1997 (C) ABC'
                DB      'P software'
                DB      0
LEVEL:
                DB      'LEVEL    '
                DB      'EASY  NORMAL'
                DB      0
LEVEL2:
                DB      'HARD  CUSTOM'
                DB      0
CUSTOM:
                DB      'CUSTOM MODE'
                DB      0
FIELDX:
                DB      'FIELD X SIZE'
                DB      '   [   ]'
                DB      0
FIELDY:
                DB      'FIELD Y SIZE'
                DB      '   [   ]'
                DB      0
FIELDB:
                DB      'NUMBER OF BO'
                DB      'MB [   ]'
                DB      0
CHR5:
                DB      000H,000H,020H,000H,000H        ;0
                DB      020H,060H,020H,020H,070H        ;1
                DB      070H,010H,070H,040H,070H        ;2
                DB      070H,010H,070H,010H,070H        ;3
                DB      050H,050H,070H,010H,010H        ;4
                DB      070H,040H,070H,010H,070H        ;5
                DB      070H,040H,070H,050H,070H        ;6
                DB      070H,050H,010H,010H,010H        ;7
                DB      070H,050H,070H,050H,070H        ;8
                DB      0F8H,0A8H,0F8H,0A8H,0F8H        ;旗
                DB      070H,088H,030H,000H,020H        ;?
                DB      0F8H,088H,088H,088H,0F8H        ;空いてないマス
                DB      010H,060H,0F0H,0F0H,060H        ;爆弾
                DB      088H,050H,020H,050H,088H        ;×
G_CLEAR:
                DB      0FFH,080H,087H,088H,087H,080H,08FH,080H,0FFH
                DB      0FFH,000H,0A2H,022H,022H,0A2H,01CH,000H,0FFH
                DB      0FFH,000H,071H,08AH,082H,08AH,071H,000H,0FFH
                DB      0FFH,000H,0CFH,028H,00FH,028H,0CFH,000H,0FFH
                DB      0FFH,000H,09EH,020H,09CH,002H,0BCH,000H,0FFH
                DB      0FFH,001H,079H,081H,071H,009H,0F1H,001H,0FFH
G_OVER:
                DB      0FFH,080H,087H,084H,087H,084H,084H,080H,0FFH
                DB      0FFH,000H,0C4H,00AH,091H,01FH,011H,000H,0FFH
                DB      0FFH,000H,074H,024H,024H,024H,077H,000H,0FFH
                DB      0FFH,000H,022H,022H,022H,022H,09CH,000H,0FFH
                DB      0FFH,000H,0F3H,08AH,0F3H,092H,08BH,000H,0FFH
                DB      0FFH,001H,0E1H,001H,0E1H,001H,0E1H,001H,0FFH
K_DAT:
                DW      0002H,0010H
                DW      0004H,0008H
                DW      0100H,0040H
                DW      0100H,0010H
                DW      0200H,0040H
                DW      0080H,0020H
VECTOR:
                DB      0,255,1,255,1,0,1,1
                DB      0,1,255,1,255,0,255,255
LV_DATA:
                DB      20,6
                DW      20
                DB      20,12
                DW      40
                DB      20,20
                DW      100

;**************************************
;ワークエリア
;**************************************

BRAM            DB      980 DUP(?)      ;マスの状態
BRAMBRAM        DB      980 DUP(?)      ;そのマスを処理したか
PLACE           DW      980 DUP(?)      ;自動展開用ワーク
X_SIZE          DB      0               ;X方向のマス数
Y_SIZE          DB      0               ;Y方向のマス数
NUM_MINE        DW      0               ;爆弾数
NOW_X           DB      0               ;カーソルのある場所
NOW_Y           DB      0               ;カーソルのある場所
Y_SCROLL        DB      0               ;スクロールして何行目か
LASTKEY         DB      0               ;前回押されたキー
K_REPEAT        DB      0               ;キーリピート時間調整用
FIRST           DB      0               ;1発目に爆弾を防ぐ
BOMB            DB      0               ;爆発フラグ
BOMBLEFT        DW      0               ;残りの爆弾
MASULEFT        DW      0               ;掘られていないマスの数
FONT            DW      0,0             ;ROMフォントアドレス
