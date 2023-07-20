;ＢＡＳＩＣ　Ｃｏｍｍａｎｄ　Ｃｏｎｖｅｒｔｅｒ　ソースリスト
;
;ＰＲＯＧＲＡＭＭＥＤ　ＢＹ　ＡＢＣＰ

        ORG     2000H
TITLE:
        MOV     AH,10H                  ;CLS
        INT     41H
        ;MOV    DI,OFFSET MSG1          ;ＴＩＴＬＥ
        DB      0BFH
        DW      OFFSET MSG1
        CALL    PRINT

        XOR     AL,AL                   ;P0指定

SUJI:
        CALL    KEY_WAIT
        CMP     DL,0DH                  ;リタ－ンを押したら終わり
        JE      SUJI_1
        MOV     AH,30H                  ;数字かどうか？
        INT     41H
        OR      DH,DH
        JNZ     SUJI                    ;やり直し
        MOV     AH,01H                  ;数字の表示
        INT     41H
        MOV     AL,DL
        SUB     AL,30H
        MOV     DL,29                   ;カ－ソルを手前に戻す
        INT     41H
        JNC     SUJI

SUJI_1:
        MOV     DL,AL
        MOV     AH,60H                  ;メモリ移動されるファイルを指定
        INT     41H
        MOV     AH,65H                  ;ファイルの長さ取得
        INT     41H
        OR      CX,CX                   ;空かどうかチェック
        JNZ     BEGIN

NO_FILE:                                ;ファイルがない
        MOV     BX,0207H
        CALL    LOCATE
        ;MOV    DI,OFFSET MSG2
        DB      0BFH
        DW      OFFSET MSG2
        CALL    PRINT
        CALL    KEY_WAIT
        JMP     TITLE

BEGIN:
        MOV     WORD PTR ERROR,0        ;エラー数初期化
        MOV     BX,0205H
        CALL    LOCATE
        ;MOV    DI,OFFSET MSG3          ;LINE=
        DB      0BFH
        DW      OFFSET MSG3
        CALL    PRINT
        MOV     AH,40H                  ;先頭アドレス取得
        INT     41H

LINE:
        MOV     DL,ES:[DI]              ;長さ
        MOV     LEN,DL
        MOV     START,DI                ;行の最初のアドレス
        INC     DI
        MOV     BX,020AH
        CALL    LOCATE
        MOV     AH,46H
        MOV     DX,ES:[DI]              ;行番号取得
        XOR     BL,BL
        INT     41H
        ADD     DI,3
        MOV     BYTE PTR NOT,0
        ;MOV    SI,OFFSET MOJI
        DB      0BEH
        DW      OFFSET MOJI

FIND:
        MOV     DX,ES:[DI]
        INC     DI
        CMP     DL,03H                  ;行番号
        JNE     FIND_1                  ;内部では03H+2Bytes
        INC     DI
        INC     DI
        ;MOV    SI,OFFSET MOJI
        DB      0BEH
        DW      OFFSET MOJI
        JMP     FIND_10

FIND_1:
        CMP     DL,02H                  ;シングルクオ－テ－ション？
        JE      FIND_2
        CMP     DX,08004H               ;DATA命令
        JE      FIND_2
        CMP     DX,0A904H               ;REM命令
        JE      FIND_2
        JNE     FIND_3

FIND_2:
        MOV     DI,START
        MOV     CL,LEN
        XOR     CH,CH
        ADD     DI,CX                   ;今の行をスキップ
        ;MOV    SI,OFFSET MOJI
        DB      0BEH
        DW      OFFSET MOJI
        JMP     FIND_10

FIND_3:                                 ;命令の後に行番号があるもの
        CMP     DX,04707H               ;THEN命令
        JE      BCD
        CMP     DX,04807H               ;ELSE命令
        JE      BCD
        CMP     DX,04904H               ;GOTO命令
        JE      BCD
        CMP     DX,04A04H               ;GOSUB命令
        JE      BCD
        CMP     DX,04B04H               ;RETURN命令
        JE      BCD
        CMP     DX,04C04H               ;RESUME命令
        JE      BCD
        CMP     DX,04D04H               ;RESTORE命令
        JE      BCD
        JMP     FIND_4
BCD:
        MOV     ADDRESS,DI
BCD_1:
        INC     DI
        MOV     DL,ES:[DI]
        CMP     DL,20H                  ;SPCはスキップ
        JE      BCD_1
        CMP     DL,03H                  ;既に行番号があるときも
        JE      BCD_2
        MOV     AH,30H                  ;数字じゃないとバイナリ化できない
        INT     41H
        OR      DH,DH
        JE      BCD_3
BCD_2:                                  ;変換不可能
        MOV     DI,ADDRESS
        ;MOV    DX,ES:[DI-1]
        DB      026H,08BH,055H,0FFH
        JMP     FIND_4
BCD_3:
        MOV     ADDRESS,DI              ;アドレス保存
        XOR     AL,AL
        ;MOV    SI,OFFSET MOJI
        DB      0BEH
        DW      OFFSET MOJI

BCD_4:                                  ;数字はいくつあるか
        MOV     DL,ES:[DI]              ;AL=個数
        INC     DI
        MOV     AH,30H
        INT     41H
        OR      DH,DH
        JNZ     BCD_5
        SUB     DL,30H
        MOV     [SI],DL
        INC     SI
        INC     AL
        JNC     BCD_4
BCD_5:
        CMP     AL,6                    ;６桁以上はダメ
        JNC     BCD_6
        CMP     AL,4                    ;４桁未満はＯＫ
        JNA     BCD_7
        ;CMP    BYTE PTR [SI-5],7       ;５桁で，一番上の桁が６以下ならＯＫ
        DB      080H,07CH,0FBH,007H
        JC      BCD_7
BCD_6:
        INC     WORD PTR ERROR          ;ＥＲＲＯＲカウント
        MOV     BX,0213H
        CALL    LOCATE
        ;MOV    DI,OFFSET MSG6
        DB      0BFH
        DW      OFFSET MSG6
        CALL    PRINT
        CALL    KEY_WAIT
        CALL    CLS_M
        JMP     FIND_2
BCD_7:                                  ;ＢＣＤから１６進へ
        XOR     DX,DX
        MOV     BX,1
        MOV     CL,AL
        MOV     CH,AL
BCD_8:                                  ;下の桁から１０倍，１００倍．．．して
        DEC     SI                      ;どんどん加算していく
        MOV     DI,DX
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
        CMP     DX,DI
        JB      BCD_6
        DEC     CL
        JNZ     BCD_8
        MOV     AL,CH
        MOV     AH,LEN                  ;オーバーフローチェック
        SUB     AH,AL
        ADD     AH,3
        MOV     BL,AH
        JNC     BCD_9
        CALL    LINE_OF                 ;ダメだった
        JMP     FIND_2
BCD_9:
        MOV     DI,ADDRESS
        MOV     CX,3                    ;3Bytes拡張して
        CALL    BIOS_61
        MOV     CL,AL                   ;数字の分縮小
        CALL    BIOS_62
        MOV     SI,START
        MOV     ES:[SI],BL
        MOV     LEN,BL
        MOV     BYTE PTR ES:[DI],03H
        INC     DI
        MOV     WORD PTR ES:[DI],DX     ;行番号挿入
        INC     DI
        INC     DI
        CMP     BYTE PTR ES:[DI],02CH   ;ON GOTO (GOSUB)対応
        JNE     BCD_11
        JMP     BCD
BCD_11:
        SUB     DI,3
BCD_12:
        DEC     DI
        CMP     BYTE PTR ES:[DI],20H
        JE      BCD_12
        ;MOV    DX,ES:[DI]
        DB      026H,08BH,055H,0FFH
        ;MOV    SI,OFFSET MOJI
        DB      0BEH
        DW      OFFSET MOJI

FIND_4:
        CMP     DX,04807H               ;ELSEの前に01Hがあるか
        JNE     FIND_5
        MOV     ADDRESS,DI
        ;CMP    BYTE PTR ES:[DI-2],01H
        DB      026H,080H,07DH,0FEH,001H
        JNE     ADD_5
ADD_1:
        ;CMP    BYTE PTR ES:[DI-4],03H
        DB      026H,080H,07DH,0FCH,003H
        JE      ADD_5
        ;CMP    BYTE PTR ES:[DI-6],03H
        DB      026H,080H,07DH,0FAH,003H
        JE      ADD_4
ADD_5:
        MOV     AL,LEN
        CMP     AL,0FFH
        JNE     ADD
        CALL    LINE_OF
        JMP     FIND_2
ADD:
        DEC     DI                      ;なかった
        MOV     CX,1
        CALL    BIOS_61
        MOV     BYTE PTR ES:[DI],01H
        MOV     SI,START
        INC     BYTE PTR ES:[SI]
        INC     AL
        MOV     LEN,AL
        ADD     DI,3
        ;MOV    SI,OFFSET MOJI
        DB      0BEH
        DW      OFFSET MOJI
        JMP     FIND_10
ADD_4:
        MOV     DI,ADDRESS

FIND_5:
        CMP     DL,04H                  ;命令
        JC      FIND_6
        CMP     DL,07H
        JA      FIND_6
        INC     DI
        ;MOV    SI,OFFSET MOJI
        DB      0BEH
        DW      OFFSET MOJI
        JMP     FIND_10

FIND_6:
        MOV     AH,34H                  ;小文字から大文字に変換
        INT     41H
        MOV     AH,32H                  ;アルファベットかどうか？
        INT     41H
        OR      DH,DH
        JE      FIND_8
        CMP     DL,2EH                  ;ピリオド
        JE      FIND_8
        CMP     DL,22H                  ;ダブルクオ－テ－ション
        JE      FIND_7
        ;MOV    SI,OFFSET MOJI
        DB      0BEH
        DW      OFFSET MOJI
        JMP     FIND_10

FIND_7:
        NOT     BYTE PTR NOT            ;ダブルクオ－テ－ションの中は対象外
        ;MOV    SI,OFFSET MOJI
        DB      0BEH
        DW      OFFSET MOJI
        JMP     FIND_10

FIND_8:
        MOV     [SI],DL
        INC     SI
        CMP     DL,2EH                  ;ピリオド
        JNE     FIND_9
        CMP     BYTE PTR NOT,0
        JNE     FIND_9
        MOV     BYTE PTR [SI],0         ;文字列の終わりのコ－ド=00H
        JMP     PERIOD
FIND_9:
        JMP     FIND_10

PERIOD:
        MOV     ADDRESS,DI
        ;MOV    DI,OFFSET MOJI
        DB      0BFH
        DW      OFFSET MOJI
        SUB     SI,DI
        MOV     CX,SI
        MOV     DL,[DI]
        DEC     CX
        JNZ     PERIOD_1
        JMP     PERIOD_9

PERIOD_1:                               ;最初のアドレス
        SUB     DL,41H
        SAL     DL,1
        XOR     DH,DH
        ;MOV    BX,OFFSET TABLE
        DB      0BBH
        DW      OFFSET TABLE
        ADD     BX,DX
        MOV     SI,[BX]

PERIOD_2:
        ;MOV    DI,OFFSET MOJI
        DB      0BFH
        DW      OFFSET MOJI
        MOV     BYTE PTR FLAG,0
        CMP     BYTE PTR [SI],0
        JNE     PERIOD_3
        JMP     PERIOD_9

PERIOD_3:                               ;探す
        MOV     DL,[DI]
        CMP     DL,02EH                 ;ピリオドでおしまい
        JE      PERIOD_5
        CMP     BYTE PTR [SI],0         ;比較されるほうが終わった
        JE      PERIOD_7
        CMP     DL,[SI]
        JE      PERIOD_4
        MOV     BYTE PTR FLAG,1

PERIOD_4:
        INC     SI
        INC     DI
        JMP     PERIOD_3                ;次の文字

PERIOD_5:
        CMP     BYTE PTR [SI],0         ;いらないデ－タを捨てる
        JE      PERIOD_6
        INC     SI
        JMP     PERIOD_5

PERIOD_6:
        CMP     BYTE PTR FLAG,0
        JE      PERIOD_8

PERIOD_7:
        INC     SI
        CMP     BYTE PTR [SI],0         ;もうない？
        JE      PERIOD_9
        INC     SI
        INC     SI
        JMP     PERIOD_2

PERIOD_8:                               ;見つかった！
        INC     SI
        MOV     DX,[SI]                 ;中間コ－ド読み込み
        MOV     DI,ADDRESS
        SUB     DI,CX
        DEC     DI
        MOV     ES:[DI],DX              ;中間コ－ド書き込み
        INC     DI
        INC     DI
        DEC     CX
        CALL    BIOS_62                 ;移動
        MOV     SI,START
        MOV     DL,LEN
        XOR     DH,DH
        SUB     DX,CX
        MOV     ES:[SI],DL
        MOV     LEN,DL
        ;MOV    SI,OFFSET MOJI
        DB      0BEH
        DW      OFFSET MOJI
        DEC     DI
        DEC     DI
        JMP     FIND

PERIOD_9:                               ;終わり
        MOV     DI,ADDRESS
        ;MOV    SI,OFFSET MOJI
        DB      0BEH
        DW      OFFSET MOJI

FIND_10:
        MOV     AH,1FH                  ;ＢＲＫと電源のチェック
        INT     41H
        OR      DL,DL
        JE      FIND_11
        JMP     FIND

FIND_11:
        CMP     BYTE PTR ES:[DI],0      ;［Ｐ？］の終わりかどうかのチェック
        JE      FIND_12
        JMP     LINE

FIND_12:
        MOV     BX,0212H
        CALL    LOCATE
        MOV     DX,ERROR
        OR      DX,DX
        JNZ     BAD_END
        ;MOV    DI,OFFSET MSG4          ;エラーなし
        DB      0BFH
        DW      OFFSET MSG4
        CALL    PRINT
        IRET
BAD_END:
        MOV     AH,46H
        XOR     BL,BL
        INT     41H
        ;MOV    DI,OFFSET MSG7
        DB      0BFH
        DW      OFFSET MSG7
        CALL    PRINT
        MOV     AH,1
        DEC     DX                      ;芸が細かいよね
        JZ      BAD_END1
        MOV     DL,115
        INT     41H
BAD_END1:
        MOV     DL,13
        INT     41H
        IRET

LINE_OF:
        INC     WORD PTR ERROR
        MOV     BX,0213H
        CALL    LOCATE
        ;MOV    DI,OFFSET MSG5
        DB      0BFH
        DW      OFFSET MSG5
        CALL    PRINT
        CALL    KEY_WAIT
        CALL    CLS_M
        RET

LOCATE:
        MOV     AH,0FH
        INT     41H
        RET

PRINT:
        MOV     AH,20H
        INT     41H
        RET

BIOS_61:
        MOV     AH,61H
        INT     41H
        RET

BIOS_62:
        MOV     AH,62H
        INT     41H
        RET

KAKE:                                   ;DX=DX+AX*BX
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
CLS_M:
        MOV     BX,0213H
        CALL    LOCATE
        MOV     DL,20H
        MOV     CX,8
        MOV     AH,01H
CLS_M_1:
        INT     41H
        LOOP    CLS_M_1
        RET

KEY_WAIT:
        MOV     AH,03H
        INT     41H
        RET

TABLE:
        DW      A
        DW      B
        DW      C
        DW      D
        DW      E
        DW      F
        DW      G
        DW      H
        DW      I
        DW      J
        DW      K
        DW      L
        DW      M
        DW      N
        DW      O
        DW      P
        DW      Q
        DW      R
        DW      S
        DW      T
        DW      U
        DW      V
        DW      W
        DW      X
        DW      Y
        DW      Z

A:
        DB      'AND'
        DB      0
        DB      007H,0C4H
        DB      'ABS'
        DB      0
        DB      005H,07BH
        DB      'ANGLE'
        DB      0
        DB      004H,06EH
        DB      'ACS'
        DB      0
        DB      005H,06FH
        DB      'ATN'
        DB      0
        DB      005H,070H
        DB      'APPEND'
        DB      0
        DB      007H,0BDH
        DB      0

B:
        DB      'BEEP'
        DB      0
        DB      004H,070H
        DB      'BSAVE'
        DB      0
        DB      004H,056H
        DB      'BLOAD'
        DB      0
        DB      004H,0A0H
        DB      0

C:
        DB      'CHR$'
        DB      0
        DB      006H,0A0H
        DB      'CALL'
        DB      0
        DB      004H,062H
        DB      'CLS'
        DB      0
        DB      004H,071H
        DB      'CLEAR'
        DB      0
        DB      004H,06AH
        DB      'CLOSE'
        DB      0
        DB      004H,072H
        DB      'CALC$'
        DB      0
        DB      006H,0ADH
        DB      'CHAIN'
        DB      0
        DB      004H,069H
        DB      'CNT'
        DB      0
        DB      005H,051H
        DB      0

D:
        DB      'DATA'
        DB      0
        DB      004H,080H
        DB      'DIM'
        DB      0
        DB      004H,07CH
        DB      'DRAW'
        DB      0
        DB      004H,07DH
        DB      'DRC'
        DB      0
        DB      004H,0A2H
        DB      'DSKF'
        DB      0
        DB      005H,061H
        DB      'DMS'
        DB      0
        DB      005H,082H
        DB      'DMS$'
        DB      0
        DB      006H,097H
        DB      0

E:
        DB      'ELSE'
        DB      0
        DB      007H,048H
        DB      'END'
        DB      0
        DB      004H,087H
        DB      'ERASE'
        DB      0
        DB      004H,085H
        DB      'EOF'
        DB      0
        DB      005H,08AH
        DB      'EXP'
        DB      0
        DB      005H,079H
        DB      0

F:
        DB      'FOR'
        DB      0
        DB      004H,081H
        DB      'FIX'
        DB      0
        DB      005H,07EH
        DB      'FILES'
        DB      0
        DB      004H,0B5H
        DB      'FRE'
        DB      0
        DB      005H,08DH
        DB      'FRAC'
        DB      0
        DB      005H,07FH
        DB      0

G:
        DB      'GOTO'
        DB      0
        DB      004H,049H
        DB      'GOSUB'
        DB      0
        DB      004H,04AH
        DB      0

H:
        DB      'HEX$'
        DB      0
        DB      006H,0A3H
        DB      'HYP'
        DB      0
        DB      005H,0ACH
        DB      0

I:
        DB      'IF'
        DB      0
        DB      004H,08DH
        DB      'INPUT'
        DB      0
        DB      006H,09BH
        DB      'INKEY$'
        DB      0
        DB      006H,0A8H
        DB      0

J:
        DB      0

K:
        DB      'KILL'
        DB      0
        DB      004H,08EH
        DB      0

L:
        DB      'LOCATE'
        DB      0
        DB      004H,091H
        DB      'LINE'
        DB      0
        DB      004H,090H
        DB      'LEN'
        DB      0
        DB      005H,095H
        DB      'LPRINT'
        DB      0
        DB      004H,0A4H
        DB      'LEFT$'
        DB      0
        DB      006H,09EH
        DB      0

M:
        DB      'MID$'
        DB      0
        DB      006H,09CH
        DB      'MERGE'
        DB      0
        DB      004H,05AH
        DB      'MODE'
        DB      0
        DB      004H,0B0H
        DB      0

N:
        DB      'NEXT'
        DB      0
        DB      004H,082H
        DB      'NCR'
        DB      0
        DB      005H,0ABH
        DB      'NPR'
        DB      0
        DB      005H,0AAH
        DB      'NOT'
        DB      0
        DB      007H,0C3H
        DB      'NORM'
        DB      0
        DB      007H,0C3H
        DB      'NAME'
        DB      0
        DB      004H,096H
        DB      0

O:
        DB      'ON'
        DB      0
        DB      004H,09AH
        DB      'OPEN'
        DB      0
        DB      004H,097H
        DB      'OUT'
        DB      0
        DB      004H,099H
        DB      0

P:
        DB      'PRINT'
        DB      0
        DB      004H,0A3H
        DB      'PEEK'
        DB      0
        DB      05H,86H
        DB      'PASS'
        DB      0
        DB      004H,053H
        DB      'POKE'
        DB      0
        DB      004H,063H
        DB      'POINT'
        DB      0
        DB      005H,08FH
        DB      0

Q:
        DB      0

R:
        DB      'RAN#'
        DB      0
        DB      005H,093H
        DB      'READ'
        DB      0
        DB      004H,0A8H
        DB      'ROUND'
        DB      0
        DB      005H,090H
        DB      'RIGHT$'
        DB      0
        DB      006H,09DH
        DB      'RETURN'
        DB      0
        DB      004H,04BH
        DB      'RESTORE'
        DB      0
        DB      004H,04DH
        DB      'RESUME'
        DB      0
        DB      004H,04CH
        DB      0

S:
        DB      'STR$'
        DB      0
        DB      006H,0A1H
        DB      'SIN'
        DB      0
        DB      005H,06BH
        DB      'SQR'
        DB      0
        DB      005H,07AH
        DB      'SGN'
        DB      0
        DB      005H,07CH
        DB      'SYSTEM'
        DB      0
        DB      004H,052H
        DB      'SET'
        DB      0
        DB      004H,0ACH
        DB      'STOP'
        DB      0
        DB      004H,0AEH
        DB      'STAT'
        DB      0
        DB      004H,0ADH
        DB      0

T:
        DB      'TO'
        DB      0
        DB      007H,0C1H
        DB      'TAN'
        DB      0
        DB      005H,06DH
        DB      'TIMER'
        DB      0
        DB      005H,0A6H
        DB      'THEN'
        DB      0
        DB      007H,047H
        DB      0

U:
        DB      'USING'
        DB      0
        DB      007H,0C2H
        DB      0

V:
        DB      'VAL'
        DB      0
        DB      005H,096H
        DB      'VF'
        DB      0
        DB      005H,092H
        DB      0

W:
        DB      'WAIT'
        DB      0
        DB      004H,054H
        DB      'WRITE#'
        DB      0
        DB      004H,04EH
        DB      0

X:
        DB      'XOR'
        DB      0
        DB      007H,0C6H
        DB      0

Y:
        DB      0

Z:
        DB      0

MSG1    DB      'Basic Com'
        DB      'mand Conv'
        DB      'erter ver'
        DB      '1.01a    '
        DB      '   Which '
        DB      'P-Area? ['
        DB      'P0]'
        DB      29,29,0
MSG2    DB      'Program '
        DB      'Not Found!'
        DB      0
MSG3    DB      'Line='
        DB      0
MSG4    DB      'Completed!'
        DB      13,0
MSG5    DB      'OV error'
        DB      0
MSG6    DB      'LN error'
        DB      0
MSG7    DB      ' error'
        DB      0
LEN     DB      1 DUP(?)
NOT     DB      1 DUP(?)
START   DW      1 DUP(?)
ADDRESS DW      1 DUP(?)
FLAG    DB      1 DUP(?)
MOJI    DB      255 DUP(?)
ERROR   DW      1 DUP(?)
        END
