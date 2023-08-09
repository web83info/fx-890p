;−−−−−−−−−−−−−−−−−−−
;ＮＥＷ　ＦＸ−ＢＣＳ
;ＰＲＯＧＲＡＭＭＥＤ　ＢＹ　ＡＢＣＰ
;−−−−−−−−−−−−−−−−−−−

        ORG     2000H

;−−−−−−−−−−−−−−−−−−−
;初期設定
;−−−−−−−−−−−−−−−−−−−

        MOV     AH,05H                  ;ＢＲＫ時の処理先指定
        XOR     CX,CX
        LEA     BX,BRK
        INT     41H
        MOV     AH,10H                  ;ＣＬＳ
        INT     41H
        MOV     BX,000BH
        CALL    LOCATE
        LEA     DI,MSG1                 ;タイトル
        CALL    PRINT

;−−−−−−−−−−−−−−−−−−−
;Ｐ−ＡＲＥＡ選択
;−−−−−−−−−−−−−−−−−−−

P_CHECK:
        MOV     BX,0107H
        CALL    LOCATE
        LEA     DI,MSG3
        CALL    PRINT
        CALL    SUJI                    ;数字入力
        MOV     PX,AL                   ;退避
        MOV     AH,60H
        MOV     DL,AL
        INT     41H
        MOV     AH,65H                  ;対象ファイルの長さ
        INT     41H
        OR      CX,CX                   ;プログラムが存在するか
        JNZ     SOC
        MOV     BX,0107H
        CALL    LOCATE
        LEA     DI,MSG4                 ;からっぽ
        CALL    PRINT
        MOV     AH,03H                  ;キ−入力
        INT     41H
        JMP     P_CHECK

;−−−−−−−−−−−−−−−−−−−
;計算準備
;−−−−−−−−−−−−−−−−−−−

SOC:
        MOV     BX,0307H
        CALL    LOCATE
        LEA     DI,MSG5
        CALL    PRINT
        MOV     AH,40H
        MOV     DL,PX
        INT     41H
        MOV     AH,46H
        MOV     DX,CX
        INT     41H
        MOV     DX,ES
        MOV     DS,DX
        XOR     DX,DX
        MOV     ES,DX
        MOV     WORD PTR SKIP,0         ;０＝スキップＯＦＦ

;−−−−−−−−−−−−−−−−−−−
;計算開始
;−−−−−−−−−−−−−−−−−−−

BCS_1:
        XOR     CH,CH
        MOV     CL,[DI]                 ;ＣＬ＝行の長さ
        SUB     CL,4                    ;先頭はダミ−
        INC     DI
        MOV     DX,[DI]
        MOV     BX,0207H
        CALL    LOCATE
        MOV     AH,46H
        INT     41H                     ;行番号表示
        MOV     LINE,DX
        ADD     DI,3
        XOR     AX,AX
        XOR     DX,DX                   ;結果格納
BCS_2:
        INC     AX
        MOV     BH,0
        MOV     BL,[DI]
        PUSH    AX
        CALL    KAKE
        POP     AX
        INC     DI
        DEC     CL
        JNZ     BCS_2
        MOV     BX,0212H
        CALL    LOCATE
        MOV     AH,45H
        MOV     BL,01H
        INT     41H                     ;結果表示
        INC     DI
        MOV     AL,[DI]
        MOV     BX,0107H
        CALL    LOCATE
        PUSH    DI
        LEA     DI,MSG2
        CALL    PRINT
        POP     DI
        MOV     DX,LINE
        CMP     SKIP,DX                 ;スキップするか
        JBE     AGAIN
        MOV     DL,13                   ;自動的にＣＲ
        JMP     AGAIN_2

;−−−−−−−−−−−−−−−−−−−
;計算終了
;−−−−−−−−−−−−−−−−−−−

AGAIN:
        MOV     AH,04H
        INT     41H
AGAIN_2:
        CMP     AL,0
        JE      EOC
        CMP     DL,13                   ;ＣＲ
        JE      BCS_C
        CMP     DL,31                   ;ＵＮＤＥＲ
        JE      BCS_C
        CMP     DL,83                   ;Ｓ
        JNE     AGAIN

;−−−−−−−−−−−−−−−−−−−
;スキップ処理
;−−−−−−−−−−−−−−−−−−−

        PUSH    DI
        MOV     BX,0107H
        CALL    LOCATE
        LEA     DI,MSG6
        CALL    PRINT
        CALL    INPUT                   ;行番号入力
        POP     DI
        JMP     BCS_C
EOC:
        JMP     BRK

BCS_C:
        JMP     BCS_1

;−−−−−−−−−−−−−−−−−−−
;ＢＲＫ押した
;−−−−−−−−−−−−−−−−−−−

BRK:
        XOR     BX,BX
        CALL    LOCATE
        XOR     AH,AH
        INT     41H

;−−−−−−−−−−−−−−−−−−−
;数字入力
;−−−−−−−−−−−−−−−−−−−

SUJI:
        XOR     AL,AL
PCHK_2:
        MOV     AH,03H
        INT     41H
        CMP     DL,0DH
        JE      PCHK_3
        MOV     AH,30H
        INT     41H
        OR      DH,DH
        JNZ     PCHK_2
        MOV     BX,0117H
        CALL    LOCATE
        MOV     AH,01H
        INT     41H
        MOV     AL,DL
        SUB     AL,30H                  ;ＡＳＣＩＩから数字に
        JMP     PCHK_2
PCHK_3:
        RET

;−−−−−−−−−−−−−−−−−−−
;１６ＢＩＴ　かけ算
;−−−−−−−−−−−−−−−−−−−

KAKE:                                   ;ＤＸ＝ＤＸ＋ＡＸ＊ＢＸ
        OR      BX,BX
        JZ      KAKE_2
        SHR     BX,1
        JNC     KAKE_1
        ADD     DX,AX
KAKE_1:
        SHL     AX,1
        JMP     KAKE
KAKE_2:
        RET

;−−−−−−−−−−−−−−−−−−−
;ＬＯＣＡＴＥ
;−−−−−−−−−−−−−−−−−−−

LOCATE:
        MOV     AH,0FH
        INT     41H
        RET

;−−−−−−−−−−−−−−−−−−−
;ＰＲＩＮＴ
;−−−−−−−−−−−−−−−−−−−

PRINT:
        MOV     AH,20H
        INT     41H
        RET

;−−−−−−−−−−−−−−−−−−−
;ＩＮＰＵＴ（行番号入力用）
;−−−−−−−−−−−−−−−−−−−

INPUT:
        MOV     BX,0113H
        CALL    LOCATE
        LEA     SI,SLINE
        XOR     CL,CL
INPUT_1:
        MOV     AH,03H
        INT     41H
        CMP     DL,0DH
        JE      INPUT_3
        CMP     DL,29
        JE      INPUT_2
        CMP     DL,8
        JE      INPUT_2
        MOV     AH,30H
        INT     41H
        CMP     DH,0
        JNE     INPUT_1
        CMP     CL,5
        JE      INPUT_1
        MOV     AH,1
        INT     41H
        SUB     DL,30H
        MOV     [SI],DL
        INC     SI
        INC     CL
        JMP     INPUT_1
INPUT_2:
        CMP     CL,0
        JE      INPUT_1
        DEC     CL
        DEC     SI
        MOV     AH,01H
        MOV     DL,29
        INT     41H
        MOV     DL,32
        INT     41H
        MOV     DL,29
        INT     41H
        JMP     INPUT_1
INPUT_3:
        MOV     BX,1
        XOR     DX,DX
        CMP     CL,0
        JE      INPUT_5
        CMP     CL,5
        JNE     INPUT_4
        SUB     SI,5
        CMP     BYTE PTR [SI],7         ;７００００行以上か
        JNB     INPUT_6
        ADD     SI,5
INPUT_4:
        DEC     SI
        MOV     SKIP,DX
        XOR     AH,AH
        MOV     AL,[SI]
        PUSH    BX
        CALL    KAKE
        POP     BX
        PUSH    DX
        XOR     DX,DX
        MOV     AX,10
        CALL    KAKE
        MOV     BX,DX
        POP     DX
        CMP     DX,SKIP
        JB      INPUT_5
        DEC     CL
        JNZ     INPUT_4
        MOV     SKIP,DX
        JMP     INPUT_6
INPUT_5:
        MOV     WORD PTR SKIP,0         ;無効
INPUT_6:
        RET

;−−−−−−−−−−−−−−−−−−−
;メッセ−ジ
;−−−−−−−−−−−−−−−−−−−

MSG1    DB      'New FX-BCS'
        DB      0
MSG2    DB      'Line  /  '
        DB      'Check Sum'
        DB      0
MSG3    DB      'Which P-A'
        DB      'rea? [P0]'
        DB      29,0
MSG4    DB      'Program '
        DB      'Not Found!'
        DB      0
MSG5    DB      'Program Si'
        DB      'ze='
        DB      0
MSG6    DB      'SKIP MODE'
        DB      ': [     ]'
        DB      0

;−−−−−−−−−−−−−−−−−−−
;ワ−クエリア
;−−−−−−−−−−−−−−−−−−−

PX      DB      1 DUP(?)
SLINE   DB      5 DUP(?)
LINE    DW      1 DUP(?)
SKIP    DW      1 DUP(?)
        END
