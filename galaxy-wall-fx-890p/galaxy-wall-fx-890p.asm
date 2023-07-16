ソースリスト
;**************************************
;ＧＡＬＡＸＹ　ＷＡＬＬ　ＦＸ－８９０Ｐ
;PC-E200 By 咳止組
;PC-E500 By 佐伯　俊道
;FX-890P By ABCP
;From 1995/09/20 21:00:26
;Till 1995/10/24 22:10:52
;**************************************

        ORG 2000H

;**************************************
;ＳＴＡＲＴ
;**************************************

START:
        MOV     AH,10H                  ;CLS(BIOS)
        INT     41H
        CLI                             ;スクリ－ンモ－ドの変換
        MOV     AX,0A000H
        MOV     ES,AX
        XOR     DI,DI
        MOV     AL,023H
        STOSB
        MOV     AL,035H
        STOSB
        STI
        MOV     BX,0001H
        MOV     AH,3AH                  ;フォントアドレス=ES:[DI]
        INT     41H
        DB      089H,0BFH               ;MOV [BX+FONTO],DI
        DW      FONTO
        MOV     DI,ES
        SUB     DI,10H                  ;ＣＨＲ＄（３２）のアドレスが返るから
        DB      089H,0BFH               ;１００　ＢＹＴＥ引く
        DW      FONTS                   ;MOV [BX+FONTS],DI
        DEC     BX                      ;BX=0
        MOV     ES,BX
        MOV     AX,07800H
        LEA     DI,SCREEN               ;LEA=MOV (REGISTER),OFFSET LABEL
PR_LOOP:
        CALL    PRINT
        INC     DI
        ADD     AL,8
        CMP     AL,32
        JNE     PR_LOOP
        CLD
        LEA     SI,WRITE                ;まとめて転送
        LEA     DI,Y
        MOV     CX,14                   ;１４　ＢＹＴＥ
        REP     MOVSB
        LEA     DI,BRAM
        XOR     AX,AX
        MOV     CX,32
        REP     STOSW

;**************************************
;ＭＡＩＮ
;**************************************

L_1:
        MOV     DX,LINE                 ;SC=-(LINE\5)+50
        MOV     WORD PTR WARI1,5        ;(20=<SC=<50)
        CALL    WARI
        MOV     AX,DX
        NEG     AX
        ADD     AX,50
        CMP     AX,20
        JGE     SC_1
        MOV     AX,20
SC_1:
        MOV     SC,AL

        XOR     CH,CH                   ;ＴＩＭＥＲに応じてランダムル－プ
        DB      08AH,00EH
        DW      016EEH                  ;MOV CL,[16EE]
        INC     CL
RND_LOOP:
        CALL    RND
        LOOP    RND_LOOP
        MOV     AH,0                    ;自機クリア
        MOV     AL,Y
        MOV     DL,0
        CALL    PUT8CHR
        MOV     CH,LK                   ;LK=LAST KEY
        CALL    INKEY
        MOV     CL,AL
        CMP     WORD PTR ITEMT,0        ;"STOP!"チェック
        JE      L_K
        CMP     BYTE PTR ITEMG,2
        JE     L_S
L_K:                                    ;上移動
        TEST    BL,10H                  ;8
        JZ      L_2
        TEST    CH,10H                  ;押しっぱなし禁止
        JNZ     L_2
        OR      CL,CL                   ;=CMP CL,0
        JE      L_2
        DEC     CL                      ;Y=Y-1
L_2:                                    ;下移動
        TEST    BL,40H                  ;2
        JZ      L_S
        TEST    CH,40H
        JNZ     L_S
        CMP     CL,3
        JE      L_S
        INC     CL
L_S:                                    ;自機表示
        MOV     Y,CL
        MOV     AH,0
        MOV     AL,CL
        MOV     DL,2
        CALL    PUT8CHR
PS_CHK:                                 ;ポ－ズチェック
        TEST    BL,02H                  ;P
        JZ      NOT_PS
        TEST    CH,04H                  ;CR
        JNZ     NOT_PS
        LEA     DI,PAUSE                ;PRINT "PAUSE"
        MOV     AX,0A218H
        CALL    PRINT
        CALL    BDISP                   ;こうしないと見えない
PS_CHK2:
        CALL    INKEY
        TEST    BL,04H
        JZ      PS_CHK2
NOT_PS:                                 ;高速移動
        TEST    BL,08H                  ;6
        JZ      L_3
        INC     BYTE PTR TIMING
        CMP     BYTE PTR TIMING,4       ;４回押し続けないとダメ
        JNE     L_3
        MOV     BYTE PTR TIMING,0
        MOV     BYTE PTR SCROLLC,1      ;１＝スクロ－ル可能
L_3:                                    ;弾発射
        TEST    BL,01H                  ;SPC
        JZ      L_4
        TEST    CH,01H
        JNZ     L_4
        MOV     AL,ITEMG                ;ITEM GET=持ってるアイテム
        CMP     WORD PTR ITEMT,0        ;ITEM TIME=残り時間
        JNE     PLUS_1
        MOV     AL,2
PLUS_1:
        CMP     AL,SHOT
        JNA     L_4
        MOV     AL,SHOT
        INC     BYTE PTR SHOT
        LEA     DI,SHOTXY
        XOR     AH,AH
        SAL     AL,1
        ADD     DI,AX
        MOV     [DI],AH
        MOV     AL,Y
        DB      088H,045H,001H          ;MOV [DI+1],AL
L_4:                                    ;スクロ－ル
        DEC     BYTE PTR SCROLLC
        JNZ     L_5
        MOV     DL,SC
        MOV     SCROLLC,DL
        MOV     AL,0
SCRL_1:
        MOV     AH,1
SCRL_2:
        CALL    XY
        MOV     CL,[BP]
        DB      088H,04EH,0FFH          ;MOV     [BP-1],CL
        INC     AH
        CMP     AH,16
        JNE     SCRL_2
        INC     AL
        CMP     AL,4
        JNE     SCRL_1
        MOV     AX,0F00H
NEWBL_1:                                ;新しいブロック出現場所クリア
        CALL    XY
        MOV     BYTE PTR [BP],0
        INC     AL
        CMP     AL,4
        JNE     NEWBL_1
        MOV     CL,3
NEWBL_2:
        MOV     AH,15
        CALL    RND                     ;DL=RND
        AND     DL,03H                  ;DL=(0-3)
        MOV     AL,DL
        CALL    XY
        MOV     BYTE PTR [BP],1
        DEC     CL
        JNE     NEWBL_2
        CALL    BRAMPUT
L_5:
        DEC     BYTE PTR SHOTC
        JZ      CO_DOWN
        JMP     L_6
CO_DOWN:
        MOV     BYTE PTR SHOTC,4
        MOV     BL,SHOT
        OR      BL,BL                   ;CMP BL,0
        JNE     SHM_R
        JMP     L_6
SHM_R:
        LEA     DI,SHOTXY
SHM_1:
        MOV     AH,[DI]
        DB      08AH,045H,001H          ;MOV AL,[DI+1]
        MOV     DL,00H
        CALL    PUT8CHR
        INC     AH
        CALL    XY
        DEC     AH
        CMP     BYTE PTR [BP],0
        JNE     SHM_P
        INC     AH
        CMP     AH,15
        JE      SHM_N
        INC     BYTE PTR [DI]
        INC     AH
        CALL    XY
        DEC     AH
        CMP     BYTE PTR [BP],0
        JNE     SHM_P
        MOV     DL,3
        CALL    PUT8CHR
        JMP     SHM_4
SHM_P:
        DB      0C6H,046H,0FFH,001H     ;MOV [BP-1],1
        MOV     DL,01H
        CALL    PUT8CHR
SHM_N:
        MOV     CH,BL
        DEC     CH
        MOV     SI,DI
SHM_2:
        OR      CH,CH                   ;CMP CH,0
        JE      SHM_3
        ADD     SI,2
        MOV     DX,[SI]
        DB  089H,054H,0FEH              ;MOV [SI-2],DX
        DEC     CH
        JNZ     SHM_2                   ;JMPでもJNZでもＯＫ
SHM_3:
        DEC     BYTE PTR SHOT
        SUB     DI,2

;**************************************
;当り判定
;**************************************

        MOV     AL,0
        MOV     CH,AL
ATA_1:
        CALL    XY
        ADD     CH,[BP]
        INC     AL
        CMP     AL,4
        JNE     ATA_1
        CMP     CH,4                    ;揃った？
        JE      ATA_S
        JMP     SHM_4
ATA_S:
        MOV     AL,0
        MOV     DL,8                    ;消えたとき黒くなる
ATA_C:
        CALL    PUT8CHR
        INC     AL
        CMP     AL,4
        JNE     ATA_C
        CALL    BDISP
        MOV     CX,00800H               ;WAIT
ATA_L:
        LOOP    ATA_L
        OR      AH,AH                   ;CMP AH,0
        JE      ADD
        MOV     AL,0
        MOV     BH,AH
ATA_2:
        MOV     AH,BH
ATA_3:
        CALL    XY
        DB      08AH,06EH,0FFH          ;MOV CH,[BP-1]
        MOV     [BP],CH
        DEC     AH
        JNZ     ATA_3
        INC     AL
        CMP     AL,4
        JNE     ATA_2
        CALL    BRAMPUT
ADD:
        MOV     DL,BH
        XOR     DH,DH
        XOR     DL,0FH                  ;下位４ｂｉｔ反転
        SHR     DL,1                    ;DL=DL\2
        ADD     SCORE,DX
        MOV     DX,SCORE
        MOV     AX,0A808H
        CALL    SUJI
        INC     WORD PTR LINE
        MOV     DX,LINE
        MOV     AL,10H
        CALL    SUJI
;ITEM
        MOV     WORD PTR WARI1,10
        CALL    WARI
        OR      CX,CX                   ;CMP CX,0
        JNE     SHM_4
        MOV     BYTE PTR ITEMF,1
        MOV     BYTE PTR ITEMX,14
        MOV     BYTE PTR ITEMI,4
        CALL    RND
        AND     DL,03H
        MOV     BYTE PTR ITEMY,DL
        CALL    RND
        AND     DL,3
        INC     DL
        MOV     BYTE PTR ITEMW,DL
SHM_4:
        ADD     DI,2
        DEC     BL
        JZ      L_6
        JMP     SHM_1

;**************************************
;アイテム処理
;**************************************

L_6:
        LEA     DI,ITEMM
        MOV     DL,ITEMG                ;×６
        SAL     DL,1
        MOV     DH,DL
        SAL     DL,1
        ADD     DL,DH
        XOR     DH,DH
        ADD     DI,DX
        MOV     AX,0A218H
        CALL    PRINT                   ;アイテム表示
        CMP     BYTE PTR ITEMF,0
        JE      ITEM_3
        MOV     AH,ITEMX
        MOV     AL,ITEMY
        DEC     BYTE PTR ITEMI
        JNZ     ITEM_3
        CALL    XY
        MOV     DL,[BP]
        CALL    PUT8CHR
        DEC     BYTE PTR ITEMX
        DEC     AH
        MOV     BYTE PTR ITEMI,4
        CMP     AH,0FFH
        JNE     ITEM_1
        MOV     BYTE PTR ITEMF,0
        JMP     ITEM_3
ITEM_1:
        MOV     DL,ITEMW
        OR      AH,AH                   ;CMP AH,0
        JNE     ITEM_2
        CMP     AL,Y
        JNE     ITEM_2
        MOV     BYTE PTR ITEMF,AH       ;必ずAH=0になっている
        MOV     WORD PTR ITEMT,500
        MOV     ITEMG,DL
        CMP     BYTE PTR ITEMG,2
        JNE     ITEM_2
        MOV     WORD PTR ITEMT,200
ITEM_2:
        ADD     DL,3                    ;持っているアイテム表示
        CALL    PUT8CHR
ITEM_3:
        MOV     AH,0
        CMP     BYTE PTR ITEMG,0
        JE      ITEM_4
        DEC     WORD PTR ITEMT
        JNZ     ITEM_4
        MOV     BYTE PTR ITEMG,AH       ;必ずAH=0です
ITEM_4:
        MOV     AH,0
        MOV     AL,Y
        MOV     DL,2
        CALL    PUT8CHR
        MOV     BL,KEY_DAT
        MOV     LK,BL

;**************************************
;ＧＡＭＥ　ＯＶＥＲ
;**************************************

        MOV     DL,0
        XOR     AX,AX
OVER_1:
        CALL    XY
        ADD     DL,[BP]
        INC     AL
        CMP     AL,4
        JNE     OVER_1
        OR      DL,DL                   ;CMP DL,0
        JE      NO_OVER
        MOV     AX,080CH
        LEA     DI,OVER
        CALL    PRINT
        CALL    BDISP
OVER_2:
        CALL    INKEY
        TEST    BL,04H                  ;CR
        JZ      OVER_2
        JMP     START
NO_OVER:
        CALL    BDISP
        JMP     L_1

;**************************************
;サブル－チンズ
;**************************************

BDISP:                                  ;VRAM=>LCD
        PUSHA
        MOV     SI,630H
        CLI
        MOV     AX,0A000H
        MOV     ES,AX
        XOR     DI,DI
        MOV     DL,4
        MOV     AL,021H
        STOSB
        MOV     AL,DL
        STOSB
        MOV     AL,022H
        STOSB
        MOV     AL,0
        STOSB
        MOV     AL,020H
        STOSB
        MOV     CX,32
BDISP_1:
        LODSB
        DB      0C0H,0E8H,004H          ;SHR AL,4
        STOSB
        INC     DI
        LOOP    BDISP_1
BDISP_2:
        INC     DL
        INC     DI
        MOV     AL,021H
        STOSB
        MOV     AL,DL
        STOSB
        MOV     AL,022H
        STOSB
        MOV     AL,0
        STOSB
        MOV     AL,020H
        STOSB
        MOV     CX,32
BDISP_3:
        DB      08AH,064H,0E0H
        LODSB
        DB      0C1H,0E8H,004H
        STOSB
        INC     DI
        LOOP    BDISP_3
        CMP     DL,16
        JNZ     BDISP_2
        MOV     DL,3
        SUB     SI,32
BDISP_4:
        INC     DL
        INC     DI
        MOV     AL,021H
        STOSB
        MOV     AL,DL
        STOSB
        MOV     AL,022H
        STOSB
        MOV     AL,32
        STOSB
        MOV     AL,020H
        STOSB
        MOV     CX,32
BDISP_5:
        DB      08AH,064H,0E0H
        LODSB
        DB      0C1H,0E8H,004H
        STOSB
        INC     DI
        LOOP    BDISP_5
        CMP     DL,16
        JNZ     BDISP_4
        XOR     AX,AX
        MOV     ES,AX
        POPA
        STI
        RET

BRAMPUT:                                ;ブロックプット
        PUSH    AX
        XOR     AX,AX
        LEA     BP,BRAM
BRAM_1:
        MOV     DL,[BP]
        CALL    PUT8CHR
        INC     BP
        INC     AH
        CMP     AH,15
        JNE     BRAM_1
        MOV     AH,0
        INC     BP
        INC     AL
        CMP     AL,4
        JNE     BRAM_1
        MOV     AH,0
        MOV     AL,Y
        MOV     DL,2
        CALL    PUT8CHR
        POP AX
        RET

PRINT:                                  ;ＰＲＩＮＴ
        PUSH    AX
        PUSH    DX
PRINT2:
        MOV     DL,ES:[DI]
        OR      DL,DL                   ;CMP DL,0
        JZ      PR_END
        INC     DI
        PUSH    ES
        PUSH    DI
        PUSH    AX
FONTS:
        MOV     AX,0E000H               ;自己書き換え
        MOV     ES,AX
        MOV     AL,DL
        XOR     AH,AH
        DB      0C1H,0E0H,003H
FONTO:
        ADD AX,08F4H                    ;自己書き換え
        MOV     DI,AX
        POP     AX
        CALL    GPRINT
        POP     DI
        POP     ES
        ADD     AH,6                    ;Ｘ座標加算
        CMP     AH,191
        JC      PRINT2
        AND     AH,7                    ;CR+LF
        ADD     AL,8
        CMP     AL,32
        JC      PRINT2
PR_END:
        POP     DX
        POP     AX
        RET

PUT8CHR:
        PUSHA
        XOR     DH,DH
        DB      0C0H,0D2H,003H          ;SHL DL,3
        LEA     SI,CHR8
        ADD     SI,DX
        DB      0C0H,0E0H,006H          ;SHL AX,6
        DB      0C1H,0E8H,003H          ;SHR AX,3
        MOV     DI,AX
        ADD     DI,630H
        MOV     CX,8
        REP     MOVSB
        POPA
        RET

GPRINT:                                 ;活研参照
        PUSHA
        MOV     DL,08H
        XOR     BH,BH
        MOV     BL,AL
        MOV     CH,AH
        AND     CH,07H
        AND     AX,0F800H
        DB      0C1H,0E8H,006H
        ADD     AX,BX
        ADD     AX,630H
        MOV     SI,AX
        MOV     BX,0FF00H
        MOV     CL,CH
        SHR     BX,CL
        NOT     BX
        MOV     AX,DX
GPRINT_1:
        MOV     DH,ES:[DI]
        INC     DI
        XOR     DL,DL
        MOV     CL,CH
        SHR     DX,CL
        DB      0C1H,0E2H,002H          ;SHL DX,2
        AND     [SI],BH
        DB      020H,05CH,020H
        OR      [SI],DH
        DB      008H,054H,020H
        INC     SI
        DEC     AL
        JNZ     GPRINT_1
        POPA
        RET

XY:                                     ;仮想配列変数
        PUSH    AX
        DB      0C0H,0E0H,004H          ;SHL AL,4
        OR      AL,AH
        XOR     AH,AH
        LEA     BP,BRAM
        ADD     BP,AX
        POP     AX
        RET
RND:                                    ;ランダム
        PUSH    AX
        PUSH    BX
        PUSH    CX
RNDDT:
        MOV     CX,03DBH
        MOV     BH,CH
        MOV     BL,CL
        ADD     CX,BX
        ADD     CX,BX
        MOV     DL,CL
        ADD     DL,CH
        MOV     CH,DL
        ADD     CX,0038H
        MOV     BX,0001H
        DB      089H,08FH
        DW      RNDDT                   ;MOV [BX+RNDDT],CX
        MOV     DL,CH
        POP     CX
        POP     BX
        POP     AX
        RET

INKEY:                                  ;INKEY$
        CLI
        PUSH    AX
        PUSH    DX
        MOV     DX,200H
        MOV     AX,1FFFH
        OUT     DX,AX
        XOR     AX,AX
        OUT     DX,AX
        MOV     AX,0001H
        CALL    KEY
        XOR     AL,AH
        TEST    AL,41H
        JZ      K_1
        MOV     AH,07FH
        INT     41H
K_1:
        XOR     BX,BX
        MOV     AX,0100H                ;8,2
        CALL    KEY
        AND     AL,50H
        MOV     BL,AL
        MOV     AX,0200H                ;6
        CALL    KEY
        DB      0C1H,0D8H,003H
        AND     AL,08H
        OR      BL,AL
        MOV     AX,0040H                ;P
        CALL    KEY
        AND     AL,02H
        OR      BL,AL
        MOV     AX,0010H                ;SPC
        CALL    KEY
        DB      0C0H,0D8H,007H
        AND     AL,01H
        OR      BL,AL
        MOV     AX,0080H                ;CR
        CALL    KEY
        DB      0C1H,0D8H,007H
        AND     AL,04H
        OR      BL,AL
        MOV     KEY_DAT,BL
        XOR     AX,AX
        OUT     46H,AX
        MOV     DX,200H
        MOV     AX,007FFH
        OUT     DX,AX
        CALL    K_WAIT
        MOV     DX,204H
        MOV     AL,03H
        OUT     DX,AL
        DEC     AL
        OUT     DX,AL
        POP     DX
        POP     AX
        STI
        RET
KEY:
        MOV     DX,200H
        OUT     DX,AX
        CALL    K_WAIT
        MOV     DX,202H
        IN      AX,DX
        RET
K_WAIT:
        PUSH    CX
        MOV     CX,0009H
K_LOOP:
        LOOP    K_LOOP
        POP     CX
        RET

SUJI:                                   ;１０進４桁表示
        PUSHA
        LEA     DI,SJWORK
        MOV     BP,3
        MOV     WORD PTR WARI1,10
SJ_1:
        CALL    WARI
        ADD     CL,48
        MOV     [DI+BP],CL
        SUB     BP,1
        JNC     SJ_1
SJ_2:
        CALL    PRINT
        POPA
        RET

WARI:                                   ;DX/[WARI1]=DX...CX
        PUSH    AX
        XOR     CX,CX
        MOV     AL,16
WARLP1:
        ADD     DX,DX
        XCHG    CX,DX
        ADC     DX,DX
        SBB     DX,WORD PTR WARI1
        JC      WARSK1
        INC     CX
        JMP     WARSK2
WARSK1:
        ADD     DX,WORD PTR WARI1
WARSK2:
        XCHG    CX,DX
        SUB     AL,1
        JNZ     WARLP1
        POP     AX
        RET

;**************************************
;DATA
;**************************************

CHR8    DB      000H,000H,000H,000H
        DB      000H,000H,000H,000H
        DB      0FFH,081H,0ABH,097H
        DB      0ABH,097H,0BFH,0FFH
        DB      077H,092H,09EH,0F5H
        DB      09FH,0FEH,0F2H,077H
        DB      000H,03FH,021H,023H
        DB      023H,02FH,03FH,000H
        DB      07EH,0F7H,0E7H,0F7H
        DB      0F7H,0F7H,0E3H,07EH
        DB      042H,0A5H,05AH,03CH
        DB      03CH,05AH,0A5H,042H
        DB      07EH,0C3H,0FBH,0C3H
        DB      0FBH,0FBH,0C3H,07EH
        DB      07EH,0DBH,0DBH,0C3H
        DB      0FBH,0FBH,0FBH,07EH
        DB      0FFH,0FFH,0FFH,0FFH
        DB      0FFH,0FFH,0FFH,0FFH

SCREEN  DB      '|Galaxy Wall'
        DB      0
        DB      '| Score:0000'
        DB      0
        DB      '| Lines:0000'
        DB      0
        DB      '| Item:     '
        DB      0

OVER    DB      ' G A M E O V'
        DB      ' E R '
        DB      0

PAUSE   DB      'PAUSE'
        DB      0

ITEMM   DB      '     '
        DB      0
        DB      '1SHOT'
        DB      0
        DB      'STOP!'
        DB      0
        DB      '3SHOT'
        DB      0
        DB      '4SHOT'
        DB      0

WRITE   DB      1,0,0,4,0
        DW      0,0
        DB      0
        DW      0
        DB      0,1

BRAM    DB      64 DUP(?)
SHOTXY  DB      8 DUP(?)
Y       DB      1 DUP(?)
LK      DB      1 DUP(?)
SHOT    DB      1 DUP(?)
SHOTC   DB      1 DUP(?)
TIMING  DB      1 DUP(?)
LINE    DW      1 DUP(?)
SCORE   DW      1 DUP(?)
ITEMF   DB      1 DUP(?)
ITEMT   DW      1 DUP(?)
ITEMG   DB      1 DUP(?)
SCROLLC DB      1 DUP(?)
SC      DB      1 DUP(?)
ITEMI   DB      1 DUP(?)
KEY_DAT DB      1 DUP(?)
WARI1   DW      1 DUP(?)
ITEMX   DB      1 DUP(?)
ITEMY   DB      1 DUP(?)
ITEMW   DB      1 DUP(?)
SJWORK  DB      4 DUP(?)
        DB      0
        END
