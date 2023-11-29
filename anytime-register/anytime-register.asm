;******************************************************************************
;Ａｎｙｔｉｍｅ　Ｒｅｇｉｓｔｅｒ　Ｖｅｒ．０．２４
;                        Ｐｒｏｇｒａｍｍｅｄ　ｂｙ　ＡＢＣＰ　ｓｏｆｔｗａｒｅ
;
;                        内蔵アセンブラ対応ソースリスト
;******************************************************************************

        ORG     2000H
INST:
        CLD
        CLI
        CALL    IP                      ;リロケート処理
IP:
        POP     BP
        SUB     BP,2005H

;**************************************
;インストールの初期化
;**************************************

VECTINST:
        XOR     BX,BX
        XOR     CX,CX
        MOV     ES,BX
        MOV     DS,BX
        MOV     BL,30H                  ;キー割り込みベクタのアドレス
        DB      0B8H
        DW      OFFSET RGST             ;MOV AX,OFFSET RGST
        ADD     AX,BP                   ;リロケート処理
        CMP     [BX],AX                 ;既にインストールされてるか
        JNZ     INSTALL
        DB      039H,04FH,002H          ;CMP [BX+2],CX(=0)
        JZ      REMOVE

;**************************************
;インストール
;**************************************

INSTALL:
        MOV     SI,BX                   ;元のベクタを保存
        DB      0BFH
        DW      OFFSET BACKUP           ;MOV DI,OFFSET BACKUP
        ADD     DI,BP
        MOV     CL,2
        REP     MOVSW
        DB      0B8H                    ;新しい割り込み先を書き込む
        DW      OFFSET RGST             ;MOV AX,OFFSET RGST
        ADD     AX,BP
        MOV     [BX],AX
        DB      089H,04FH,002H          ;MOV [BX+2],CX(=0)
        MOV     AH,3AH
        INT     41H
        DB      0BEH
        DW      OFFSET FONT             ;MOV SI,OFFSET FONT
        ADD     SI,BP
        MOV     [SI],DI
        DB      8CH,44H,02H             ;MOV [SI+2],ES
        MOV     AH,20H
        DB      0BFH
        DW      OFFSET STAY             ;MOV DI,OFFSET STAY
        ADD     DI,BP
        INT     41H                     ;メッセージを表示
        STI
        IRET

;**************************************
;常駐解除
;**************************************

REMOVE:
        DB      0BEH                    ;リストアする
        DW      OFFSET BACKUP           ;MOV SI,OFFSET BACKUP
        ADD     SI,BP
        MOV     DI,BX
        MOV     CL,2
        REP     MOVSW
        MOV     AH,20H
        DB      0BFH
        DW      OFFSET DISSTAY          ;MOV DI,OFFSET DISSTAY
        ADD     DI,BP
        INT     41H                     ;メッセージを表示
        STI
        IRET

;**************************************
;実際の常駐ルーチン
;(注) ここから BIOS は使えない
;**************************************

        ORG     2066H
RGST:
        PUSH    SS
        PUSH    ES
        PUSH    DS
        PUSHA
        CALL    GET_IP                  ;IP を求める
GET_IP:
        POP     BP
        SUB     BP,206DH
        CALL    KEY
        JNZ     OK
        JMP     RET_INT

;**************************************
;レジスタの値をコピー
;**************************************

OK:
        CLD
        XOR     AX,AX
        MOV     DS,AX
        MOV     ES,AX
        MOV     SI,SP
        DB      083H,0C6H,14            ;ADD SI,14
        DB      0BFH
        DW      OFFSET AXTOFL           ;MOV DI,OFFSET AXTOFL
        ADD     DI,BP
        MOV     CX,8
SP_LP:
        MOV     AX,SS:[SI]
        MOV     [DI],AX
        DEC     SI
        DEC     SI
        INC     DI
        INC     DI
        LOOP    SP_LP
        DB      083H,0C6H,18            ;ADD SI,18
        MOV     CL,6
SP_LP2:
        MOV     AX,SS:[SI]
        MOV     [DI],AX
        INC     SI
        INC     SI
        INC     DI
        INC     DI
        LOOP    SP_LP2
        DB      8BH,045H,0FAH           ;MOV AX,[DI-6]
        DB      87H,45H,0FCH            ;XCHG [DI-4],AX
        DB      89H,45H,0FAH            ;MOV [DI-6],AX
        DB      8BH,45H,0E6H            ;MOV AX,[DI-26]
        DB      8BH,5DH,0E8H            ;MOV BX,[DI-24]
        DB      8BH,4DH,0EAH            ;MOV CX,[DI-22]
        DB      89H,4DH,0E6H            ;MOV [DI-26],CX
        DB      89H,45H,0E8H            ;MOV [DI-24],AX
        DB      89H,5DH,0EAH            ;MOV [DI-22],BX
        DB      83H,45H,0ECH,0CH        ;ADD [DI-20],0CH
                                        ;表示順に揃った

;**************************************
;画面の待避
;**************************************

MAIN:                                   ;FCR,XAR,YAR の保存
        MOV     AX,0A000H
        MOV     ES,AX
        XOR     DI,DI
        DB      0BEH
        DW      OFFSET VRAM             ;MOV SI,OFFSET VRAM
        ADD     SI,BP
        MOV     AL,21H
        STOSB
        MOV     AL,ES:[DI]
        PUSH    AX
        INC     DI
        MOV     AL,22H
        STOSB
        MOV     AL,ES:[DI]
        PUSH    AX
        INC     DI
        MOV     AL,23H
        STOSB
        MOV     AL,ES:[DI]
        PUSH    AX
        INC     DI
        MOV     AL,23H                  ;FCR の変更
        STOSB
        MOV     AL,0B5H                 ;8 ビット X インクリメント
        STOSB

        MOV     DL,0
DLP:
        MOV     AL,21H                  ;XAR
        STOSB
        MOV     AL,4
        STOSB
        MOV     AL,22H                  ;YAR
        STOSB
        MOV     AL,DL
        STOSB
        MOV     AL,20H                  ;DRAM
        STOSB
READ1:
        MOV     AL,ES:[DI]              ;ダミーリード
        PUSH    BX                      ;ウエイト
        POP     BX
        PUSH    BX
        POP     BX
        MOV     CX,13
READ2:
        MOV     AL,ES:[DI]
        PUSH    BX
        POP     BX
        PUSH    BX
        POP     BX
        MOV     [SI],AL                 ;メモリに待避
        INC     SI
        LOOP    READ2
        INC     DI
        ADD     DL,32                   ;左から右へ
        CMP     DL,64
        JC      DLP
        SUB     DL,63                   ;64-1, 上から下へ
        CMP     DL,32
        JNZ     DLP

        MOV     AL,23H
        STOSB
        MOV     AL,75H
        STOSB

;**************************************
;メイン
;**************************************

RGSTMAIN:
        XOR     BX,BX
        MOV     DS,BX
        DB      0BEH
        DW      OFFSET RGSTNAME         ;MOV SI,OFFSET RGSTNAME
        ADD     SI,BP
        DB      0BFH
        DW      OFFSET AXTOFL           ;MOV DI,OFFSET AXTOFL
        ADD     DI,BP
PUT:
        MOV     CX,2
PUT_1:
        MOV     DL,[SI]
        CALL    LETTER                  ;レジスタの名前
        INC     BL
        INC     SI
        LOOP    PUT_1
        MOV     DL,3DH;=
        CALL    LETTER
        INC     BL
        MOV     AX,[DI]
        INC     DI
        INC     DI
        MOV     CL,4
HEX_L1:
        MOV     CH,4
HEX_L2:
        SAL     AX,1
        RCL     DL,1
        DEC     CH
        JNZ     HEX_L2
        AND     DL,00FH
        ADD     DL,30H
        CMP     DL,3AH
        JC      HEX_3
        ADD     DL,7
HEX_3:
        CALL    LETTER                  ;4 ビットずつ数字に変換して 4 回表示
        INC     BL
        LOOP    HEX_L1
        MOV     DL,32
        CALL    LETTER                  ;スペース
        INC     BL
        CMP     BL,32
        JNZ     HEX_4
        INC     BH
        XOR     BL,BL
HEX_4:
        PUSH    DI
        DB      0BFH
        DW      OFFSET NAME_END         ;MOV DI,OFFSET NAME_END
        ADD     DI,BP
        CMP     SI,DI
        POP     DI
        JE      HEX_5
        JMP     PUT
HEX_5:
        MOV     CX,16
HEX_6:
        MOV     DL,32
        CALL    LETTER                  ;右下の表示を消す
        INC     BL
        LOOP    HEX_6

REPEAT:
        CALL    KEY                     ;キーが放されるまでループ
        JNZ     REPEAT

;**************************************
;画面の復帰
;**************************************

        MOV     AX,0A000H
        MOV     ES,AX
        XOR     DI,DI
        MOV     DS,DI
        DB      0BEH
        DW      OFFSET VRAM             ;MOV SI,OFFSET VRAM
        ADD     SI,BP

        MOV     AL,23H                  ;FCR の変更
        STOSB
        MOV     AL,0B5H                 ;8 ビット X インクリメント
        STOSB
        MOV     DL,0
DLP2:
        MOV     AL,21H                  ;XAR
        STOSB
        MOV     AL,4
        STOSB
        MOV     AL,22H                  ;YAR
        STOSB
        MOV     AL,DL
        STOSB
        MOV     AL,20H                  ;DRAM
        STOSB
        MOV     CX,13
WRITE:
        MOVSB
        PUSH    BX
        POP     BX
        PUSH    BX
        POP     BX
        INC     DI
        LOOP    WRITE
        INC     DI
        ADD     DL,32                   ;左から右へ
        CMP     DL,64
        JC      DLP2
        SUB     DL,63                   ;64-1, 上から下へ
        CMP     DL,32
        JNZ     DLP2

        MOV     AL,23H                  ;FCR,XAR,YAR の呼び出し
        STOSB
        POP     DX
        MOV     AL,DL
        STOSB
        MOV     AL,22H
        STOSB
        POP     DX
        MOV     AL,DL
        STOSB
        MOV     AL,21H
        STOSB
        POP     DX
        MOV     AL,DL
        STOSB
        MOV     AL,20H
        STOSB
RET_INT:
        POPA
        POP     DS
        POP     ES
        POP     SS
        DB      0EAH                    ;本来のルーチンへ
BACKUP:
        DW      0,0

;**************************************
;サブルーチンｓ
;**************************************

KEY:
        XOR     AX,AX                   ;キーポートの読み込み
        MOV     ES,AX
        MOV     DX,200H
        MOV     AX,0010H                ;[SPACE] キーのチェック
        OUT     DX,AX
        PUSH    AX                      ;ウエイト
        POP     AX
        MOV     DL,2
        IN      AX,DX
        TEST    AL,80H
        JNZ     SHIFT
        RET
SHIFT:
        MOV     DL,0
        MOV     AX,0800H                ;[SHIFT] キーのチェック
        OUT     DX,AX
        PUSH    AX
        POP     AX
        MOV     DL,2
        IN      AX,DX
        TEST    AH,08H
        RET

LETTER:
        PUSH    DS
        PUSH    ES
        PUSHA
        SUB     DL,20H
        XOR     DH,DH
        DB      0C1H,0E2H,003H          ;SAL DX,3
        DB      0BFH
        DW      OFFSET FONT             ;MOV DI,OFFSET FONT
        ADD     DI,BP
        MOV     SI,[DI]
        DB      8EH,5DH,02H             ;MOV DS,[DI+2]
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
        MOVSB
        NOP                             ;時間稼ぎ
        NOP
        DEC     DI
        DEC     AH
        JNZ     P_LP
        DEC     DI
        MOV     AL,20H
        STOSB
        POPA
        POP     ES
        POP     DS
        RET

;**************************************
;データ
;**************************************

STAY:
        DB      12
        DB      'Anytime '
        DB      'Register'
        DB      ' by ABCP'
        DB      13
        DB      'Stayed on '
        DB      'Memory'
        DB      13,0
DISSTAY:
        DB      12
        DB      'Thank You '
        DB      'for Using'
        DB      13
        DB      'Removed from'
        DB      ' Memory'
        DB      13,0
RGSTNAME:
        DB      'AXBXCXDXSPBP'
        DB      'SIDIDSESSSCS'
        DB      'IPFL'
NAME_END:
FONT:
        DW      2 DUP(?)
AXTOFL:
        DW      14 DUP(?)
VRAM:
        DB      832 DUP(?)
