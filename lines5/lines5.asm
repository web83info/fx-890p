;**************************************
;ＬＩＮＥＳ－５　ｆｏｒ　ＦＸ－８９０Ｐ
;内蔵アセンブラ対応ソースリスト
;ＰＲＯＧＲＡＭＭＥＤ　ＢＹ　ＡＢＣＰ
;**************************************

        ORG     2000H

;**************************************
;初期設定
;**************************************

        CLD                             ;ストリング系の命令の方向＝＋
        MOV     BYTE PTR REV,0          ;反転フラグリセット
        MOV     BYTE PTR N_CR,1         ;改行フラグセット
                                        ;座標指定だけしたの時のため

;**************************************
;命令解析開始
;**************************************

SUJI:                                   ;カンマ以下のデータがあるか
        MOV     AX,2C85H                ;カンマのサーチ
        CALL    RCALL                   ;ROMルーチンをCALL
        CMP     DL,AH
        JZ      SUJI_1                  ;カンマがなかったら
        JMP     RETBAS                  ;BASICにリターン
SUJI_1:                                 ;データの省略をしているか
        INC     SI
        MOV     AL,85H                  ;カンマのサーチ
        CALL    RCALL
        CMP     DL,AH                   ;省略されていたらば
        JZ      READ_1                  ;読み飛ばし
        PUSH    SI                      ;BASICのポインタ保存

;**************************************
;SET,FORMATがあるかな
;**************************************

        DEC     SI                      ;ポインタ=ES:[DI]
SKIP_1:
        INC     SI
        CMP     BYTE PTR ES:[SI],20H    ;スペースは
        JE      SKIP_1                  ;スキップしましょう
        MOV     DX,ES:[SI]              ;中間コード読み込み
        DEC     SI
        CMP     DX,08B04H               ;FORMAT
        JE      SKIP_4
        CMP     DX,0AC04H               ;SETの中間コード
        JNE     SKIP_2
SKIP_3:
        POP     DX                      ;ポインタは破棄する
                                        ;DXでなくても別に良い
        ADD     SI,3                    ;中間コードの後のアドレス
        JMP     CHANGE
SKIP_4:
        POP     DX
        ADD     SI,3
        JMP     NORMAL

;**************************************
;表示ルーチンをご指名でした
;**************************************

SKIP_2:
        POP     SI                      ;ポインタ復帰させて
        CALL    GET
        CMP     DX,31                   ;31より大きいときは
        JNA     N_ERROR1
        MOV     DL,16                   ;BS error発生
        CALL    ERROR
N_ERROR1:
        MOV     BYTE PTR CURSOL_X,DL    ;Ｘ座標を記憶
READ_1:                                 ;Ｙ座標の読み込みです
        MOV     AX,02C85H               ;基本的なアルゴリズムは
        CALL    RCALL                   ;Ｘ座標読み込みと同じです
        CMP     DL,AH
        JZ      SUJI_3
        JMP     RETBAS                  ;データがないとき
SUJI_3:
        INC     SI
        MOV     AL,85H
        CALL    RCALL
        CMP     DL,AH
        JZ      READ_A                  ;省略したとき
        CALL    GET
        CMP     DX,4                    ;Ｙ座標が4より大きいなら
        JNA     N_ERROR2
        MOV     DL,16                   ;BS error発生
        CALL    ERROR
N_ERROR2:
        MOV     BYTE PTR CURSOL_Y,DL    ;Ｙ座標記憶

;**************************************
;表示データ解析
;**************************************

READ_A:
        MOV     AL,85H                  ;データがあるか
        CALL    RCALL
        CMP     DL,02CH
        JZ      READ_4
        CMP     DL,3BH                  ;セミコロンなら
        JNZ     READ_5
        INC     SI                      ;ポインタをセミコロンの次にして
        MOV     BYTE PTR N_CR,1         ;改行しないフラグを立てて
READ_5:
        JMP     RETBAS                  ;BASICへリターン
READ_4:
        INC     SI
        CMP     BYTE PTR ES:[SI],20H    ;スペースは
        JE      READ_4                  ;スキップする
        MOV     BYTE PTR N_CR,0         ;ここでフラグを消すと
                                        ;座標指定だけの時は改行処理をしない
        MOV     DX,ES:[SI]              ;中間コード読み込み
        DEC     SI
        MOV     AL,1                    ;REVならAL=1
        CMP     DX,0B907H               ;REVの中間コード
        JE      READ_7
        XOR     AL,AL                   ;NORMならAL=0
        CMP     DX,0BA07H               ;NORMの中間コード
        JNE     READ_6
READ_7:
        ADD     SI,3                    ;中間コードを読み飛ばして
        MOV     REV,AL                  ;フラグセットして
        JMP     READ_A                  ;新たなデータの読み込みへ旅立つ

;**************************************
;純粋な文字列でした
;**************************************

READ_6:
        MOV     AL,86H
        CALL    RCALL
        MOV     AL,0D4H                 ;表示データの解析を
        CALL    RCALL                   ;ROMルーチンにやってもらう
        JC      READ_3                  ;おっと，数字だったら
        MOV     AL,37H                  ;STR$で文字列に変換
        CALL    RCALL
READ_3:
        PUSH    DS
        PUSH    ES                      ;ポインタの
        PUSH    SI                      ;保存
        XOR     AX,AX
        MOV     ES,AX
        MOV     DS,AX
        DB      8AH,0EH                 ;MOV CL,[0407]
        DW      0407H                   ;CL=文字列の長さ
        XOR     CH,CH
        DB      0A1H                    ;MOV AX,[0405]
        DW      0405H                   ;AX=表示データのあるセグメント
        DB      8BH,3EH                 ;MOV DI,[0403]
        DW      0403H                   ;DI=表示データのあるオフセット
        MOV     DS,AX                   ;DS=AX=表示データのあるセグメント
        POP     SI
        POP     ES

;**************************************
;表示ルーチンメイン
;**************************************

FUNK_2_1:
        MOV     DL,[DI]                 ;表示コード読み込み
        INC     DI                      ;表示コードのポインタ進めて
        SUB     CL,1                    ;DEC,INCだとCFが変化しないんです
        JNC     FUNK_2_3
        JMP     FUNK_2_2                ;データがなくなったらおしまい
FUNK_2_3:
        PUSHA
        PUSH    ES
        PUSH    DS
        XOR     DI,DI
        MOV     DS,DI
        MOV     AX,0A000H               ;LCDCレジスタのセグメント
        MOV     ES,AX
        MOV     CX,CURSOL_X

;**************************************
;VRAMのアドレス計算（面倒）
;**************************************

        MOV     BX,630H                 ;仮想VRAMのトップ
                                        ;以降，BX=書き込みアドレスの計算用
        DB      0A0H                    ;MOV AL,[1779]
        DW      01779H                  ;仮想画面の何行目を表示しているか
SC:
        SUB     AL,1
        JC      SC_1
        ADD     BX,100H                 ;仮想画面が一行下にいくごとに
        JMP     SC                      ;8×32=256=100H加算
                                        ;ここまでで現在表示している画面の
                                        ;左上のアドレスが分かった
SC_1:
        MOV     AL,CH                   ;Ｙ座標値を
        SAL     AL,1                    ;2倍して
        MOV     AH,AL                   ;それを保存して
        SAL     AH,1                    ;さらに2倍して
        ADD     AH,AL                   ;加えると6倍になるんです
        MOV     AL,AH                   ;いったん保存して
        DB      0C0H,0E8H,003H          ;SHR AL,3
                                        ;ALを8で割って余りは使わない
KAKE:
        SUB     AL,1
        JC      KAKE_2                  ;左上から離れている分のアドレスを
        ADD     BX,0100H                ;BXに加算
        JMP     KAKE
KAKE_2:
        MOV     AL,AH                   ;（Ｙ座標×6）を
        AND     AL,07H                  ;8で割った余りを加算
        XOR     AH,AH
        ADD     BX,AX
        MOV     AL,CL                   ;Ｘ座標値を
        DB      0C1H,0E0H,003H          ;SAL AX,3
                                        ;8倍して
        ADD     BX,AX                   ;さらに加算
        INC     BX                      ;一番上の空きの分

;**************************************
;LCDCアクセス
;**************************************

        MOV     AL,21H                  ;XAD設定
        STOSB
        MOV     AL,CL
        AND     AL,0FH                  ;下位4ビット
        ADD     AL,6                    ;足すことの6
        STOSB
        MOV     AL,22H                  ;YAD設定
        STOSB
        MOV     AL,CH                   ;Ｙ座標を
        SAL     CH,1
        DB      0C0H,0D0H,002H          ;SAL AL,2
        ADD     AL,CH                   ;6倍する
        SAL     CL,1
        AND     CL,20H                  ;右半分の時は
        ADD     AL,CL                   ;Ｙ座標に20H加算する
        INC     AL                      ;一番上の空きの分
        STOSB
        XOR     DH,DH                   ;キャラクタコードを
        SAL     DX,1
        MOV     CX,DX
        SAL     DX,1                    ;6倍して
        ADD     DX,CX
        ADD     DX,OFFSET FONT          ;フォントのオフセットを加算
        MOV     SI,DX
        MOV     CX,6                    ;6回ループ
        MOV     AH,REV                  ;フラグの読み込み
WRITE_S:
        MOV     AL,20H                  ;DRAM設定
        STOSB
WRITE_L:
        LODSB                           ;フォントデータの読み込み
        OR      AH,AH                   ;AH=1(REV)ならば
        JE      NOT_REV 
        NOT     AL                      ;データの反転
NOT_REV:
        STOSB                           ;LCDCに転送
        MOV     [BX],AL                 ;VRAMに転送
        INC     BX                      ;次のアドレス
        TEST    BX,0007H                ;仮想VRAMはＹ座標が
        JNZ     CR                      ;8の倍数になると
        ADD     BX,000F8H               ;100H加算しなきゃならない
CR:
        DEC     DI
        LOOP    WRITE_L                 ;6回ループ
        POP     DS
        POP     ES

;**************************************
;カーソル改行処理
;**************************************

        MOV     CX,CURSOL_X
        INC     CL
        CMP     CL,32                   ;X<>32ならＯＫ
        JNE     MOJI_Q
        XOR     CL,CL                   ;X=0にして
        INC     CH                      ;Y=Y+1
        CMP     CH,5                    ;Y<>5ならＯＫ
        JE      MOJI_N
MOJI_Q:
        CLC                             ;CF=0（ＯＫ）
        JNC     FUNK_1_R
MOJI_N:
        MOV     CX,041FH                ;カーソルポインタは右下のまま
        STC                             ;CF=1（ＥＲＲＯＲ）
FUNK_1_R:
        MOV     CURSOL_X,CX
        POPA
        JC      FUNK_2_2                ;ＥＲＲＯＲなら強制終了
        JMP     FUNK_2_1                ;ＯＫならまだ頑張る
FUNK_2_2:
        POP     DS
        JMP     READ_A                  ;続くデータはあるかな

;**************************************
;BASICへリターン
;**************************************

RETBAS:
        MOV     BP,SP                   ;ポインタ書き換え
        DB      089H,076H,006H          ;MOV [BP+6],SI
        CMP     BYTE PTR N_CR,0         ;改行しないのなら
        JNZ     RETBAS_2                ;とっととお帰り
        MOV     CX,CURSOL_X
        XOR     CL,CL                   ;X=0
        INC     CH                      ;Y=Y+1
        CMP     CH,5                    ;IF Y=5
        JNE     RETBAS_3
        DEC     CH                      ;THEN Y=Y-1
RETBAS_3:
        MOV     CURSOL_X,CX
RETBAS_2:
        IRET

;**************************************
;フォント書き換え
;**************************************

CHANGE:
        MOV     AX,02C85H               ;カンマのサーチ
        CALL    RCALL
        CMP     DL,AH                   ;カンマがないと
        JNZ     RETBAS                  ;BASICへリターン
        INC     SI
        MOV     AL,85H                  ;カンマのサーチ
        CALL    RCALL
        CMP     DL,AH                   ;データが省略されていると
        JZ      RETBAS
        CALL    GET
        CMP     DX,256                  ;256より小さくなかったら
        JC      FORMAT_A
        MOV     DL,16                   ;BS error発生
        CALL    ERROR
FORMAT_A:
        DB      0BFH                    ;MOV DI,OFFSET FONT
        DW      OFFSET FONT             ;書き換えアドレス計算
                                        ;NOPを出力するからハンドアセンブル
        SAL     DX,1                    ;キャラクタコードの2倍を
        ADD     DI,DX                   ;加算
        SAL     DX,1                    ;さらに2倍して
        ADD     DI,DX                   ;加算
                                        ;つまり6倍したことになる
        MOV     AL,86H
        CALL    RCALL
        MOV     AL,0D4H                 ;文字変数解析
        CALL    RCALL
        JC      DATA                    ;数値だったら
        MOV     DL,19                   ;TM error発生
        CALL    ERROR
DATA:
        PUSH    DS
        PUSH    ES                      ;ポインタ
        PUSH    SI                      ;保存
        XOR     AX,AX
        MOV     ES,AX
        MOV     DS,AX
        DB      8AH,0EH                 ;MOV CL,[0407]
        DW      0407H                   ;CL=データ長
        XOR     CH,CH
        DB      0A1H                    ;MOV AX,[0405]
        DW      0405H
        DB      8BH,36H                 ;MOV SI,[0403]
        DW      0403H
        MOV     DS,AX                   ;DS:[SI]=表示データアドレス
        MOV     DH,6                    ;6回ループ
        XOR     BX,BX                   ;エラーフラグ
DATA_2:
        XOR     DL,DL                   ;結果格納
        LODSB                           ;AL=データ上位
        OR      CL,CL                   ;データ長が0ならば
        JE      DATA_5
        CMP     BH,1                    ;BH=1，データ不足
        JNE     DATA_3
DATA_5:
        MOV     AL,30H                  ;0を補う
        MOV     BH,1                    ;一度足りないと，ずっと足りない
DATA_3:
        DEC     CL                      ;データ長を減らす
        CALL    CK_DATA                 ;アスキーコードからバイナリコードへ
        JNC     N_BAD
        MOV     BL,1                    ;エラー発生
N_BAD:
        MOV     DL,AL
        DB      0C0H,0E2H,004H          ;SAL DL,4
                                        ;上位4ビットに移動
        LODSB                           ;今度は下位4ビット分
        OR      CL,CL
        JZ      DATA_6
        CMP     BH,1
        JNE     DATA_4
DATA_6:
        MOV     AL,30H
        MOV     BH,1
DATA_4:
        DEC     CL
        CALL    CK_DATA
        JNC     N_BAD1
        MOV     BL,1
N_BAD1:
        OR      AL,DL                   ;下位4ビット設定
        STOSB                           ;実際に書き換え
        DEC     DH
        JNZ     DATA_2                  ;ここまでループ
        POP     SI
        POP     ES
        POP     DS
        OR      BL,BL
        JZ      GOOD
        XOR     AX,AX                   ;使えないデータがあったら
        MOV     ES,AX
        SUB     DI,6
        MOV     CX,6
        REP     STOSB                   ;そのデータを0クリアして
        MOV     DL,22                   ;DA error発生
        CALL    ERROR
GOOD:
        JMP     RETBAS                  ;BASICへリターン

CK_DATA:
        SUB     AL,30H                  ;"0"の手前ならば
        JC      CK_NG                   ;ダメ
        CMP     AL,9                    ;"9"までの文字は
        JNA     CK_OK                   ;よろしい
        SUB     AL,7
        CMP     AL,9                    ;"9"の次から"A"の手前までは
        JNA     CK_NG                   ;ダメ
        CMP     AL,15                   ;"A"から"F"までは
        JNA     CK_OK                   ;よろしい
        SUB     AL,32
        CMP     AL,9                    ;"F"の次から"a"の手前までは
        JNA     CK_NG                   ;失格
        CMP     AL,15                   ;"a"から"f"までは
        JNA     CK_OK                   ;ＯＫ
CK_NG:                                  ;それ以外は
        STC                             ;失格
        RET                             ;失格の時はCF=1
CK_OK:
        CLC                             ;正解の時は
        RET                             ;CF=0

;**************************************
;フォント初期化（これは簡単）
;**************************************

NORMAL:
        PUSH    DS
        PUSH    ES                      ;ポインタ
        PUSH    SI                      ;保存
        XOR     AX,AX
        MOV     ES,AX                   ;DS:[SI]から
        MOV     DS,AX                   ;ES:[DI]に
        DB      0BEH                    ;MOV SI,OFFSET OFF_5
        DW      OFFSET OFF_5
        DB      0BFH                    ;MOV DI,OFFSET FONT
        DW      OFFSET FONT
        MOV     CX,1536                 ;6×256バイト分
        REP     MOVSB                   ;転送する
        POP     SI                      ;ポインタ
        POP     ES                      ;復帰
        POP     DS
        MOV     CURSOL_X,CX             ;カーソル初期化
        JMP     RETBAS                  ;BASICへリターン

;**************************************
;便利なサブルーチンｓ
;**************************************

GET:
        MOV     AX,09F1FH               ;AL=ROM CALL用,AH=BIOS用
        CALL    RCALL                   ;変数を数字に
        INT     41H                     ;数字をレジスタに
        RET

RCALL:                                  ;ROMのルーチンをコール
        DB      0A2H,0BCH,016H
        DB      09AH
        DW      00006H,0F000H
        RET

ERROR:                                  ;エラー発生ルーチン
        PUSHF                           ;VERTEBRAさん
        MOV     AX,0F000H               ;Thanks!
        PUSH    AX
        MOV     AX,373H
        DEC     DL
        JNZ     ERROR_1
        DEC     AX
ERROR_1:
        XOR     DH,DH
        DB      0C1H,0E2H,002H          ;SAL DX,2
        ADD     AX,DX
        PUSH    AX
        IRET

;**************************************
;フォントデータ
;**************************************

OFF_5   DB  000H,000H,000H,000H,000H,000H
        DB  000H,000H,000H,000H,000H,000H
        DB  000H,000H,000H,000H,000H,000H
        DB  000H,000H,000H,000H,000H,000H
        DB  000H,000H,000H,000H,000H,000H
        DB  000H,000H,000H,000H,000H,000H
        DB  000H,000H,000H,000H,000H,000H
        DB  000H,000H,000H,000H,000H,000H
        DB  000H,000H,000H,000H,000H,000H
        DB  000H,000H,000H,000H,000H,000H
        DB  000H,000H,000H,000H,000H,000H
        DB  000H,000H,000H,000H,000H,000H
        DB  000H,000H,000H,000H,000H,000H
        DB  000H,000H,000H,000H,000H,000H
        DB  000H,000H,000H,000H,000H,000H
        DB  000H,000H,000H,000H,000H,000H
        DB  000H,000H,000H,000H,000H,000H
        DB  000H,000H,000H,000H,000H,000H
        DB  000H,000H,000H,000H,000H,000H
        DB  000H,000H,000H,000H,000H,000H
        DB  000H,000H,000H,000H,000H,000H
        DB  000H,000H,000H,000H,000H,000H
        DB  000H,000H,000H,000H,000H,000H
        DB  000H,000H,000H,000H,000H,000H
        DB  000H,000H,000H,000H,000H,000H
        DB  000H,000H,000H,000H,000H,000H
        DB  000H,000H,000H,000H,000H,000H
        DB  000H,000H,000H,000H,000H,000H
        DB  000H,000H,000H,000H,000H,000H
        DB  000H,000H,000H,000H,000H,000H
        DB  000H,000H,000H,000H,000H,000H
        DB  000H,000H,000H,000H,000H,000H
        DB  000H,000H,000H,000H,000H,000H       ;ＳＰＣ
        DB  008H,008H,008H,000H,008H,000H       ;！
        DB  014H,014H,000H,000H,000H,000H       ;”
        DB  014H,03EH,014H,03EH,014H,000H       ;＃
        DB  01EH,028H,01CH,00AH,03CH,000H       ;＄
        DB  022H,004H,008H,010H,022H,000H       ;％
        DB  018H,024H,01AH,024H,01AH,000H       ;＆
        DB  00CH,004H,008H,000H,000H,000H       ;’
        DB  008H,010H,010H,010H,008H,000H       ;（
        DB  008H,004H,004H,004H,008H,000H       ;）
        DB  008H,02AH,01CH,02AH,008H,000H       ;＊
        DB  008H,008H,03EH,008H,008H,000H       ;＋
        DB  000H,000H,000H,00CH,004H,008H       ;，
        DB  000H,000H,03EH,000H,000H,000H       ;－
        DB  000H,000H,000H,00CH,00CH,000H       ;．
        DB  002H,004H,008H,010H,020H,000H       ;／
        DB  01CH,026H,02AH,032H,01CH,000H       ;０
        DB  008H,018H,008H,008H,008H,000H       ;１
        DB  03CH,002H,01CH,020H,03EH,000H       ;２
        DB  03CH,002H,01CH,002H,03CH,000H       ;３
        DB  00CH,014H,024H,03EH,004H,000H       ;４
        DB  03EH,020H,03CH,002H,03CH,000H       ;５
        DB  01CH,020H,03CH,022H,01CH,000H       ;６
        DB  03EH,022H,004H,008H,008H,000H       ;７
        DB  01CH,022H,01CH,022H,01CH,000H       ;８
        DB  01CH,022H,01EH,002H,01CH,000H       ;９
        DB  00CH,00CH,000H,00CH,00CH,000H       ;：
        DB  00CH,00CH,000H,00CH,004H,008H       ;；
        DB  004H,008H,010H,008H,004H,000H       ;＜
        DB  000H,03EH,000H,03EH,000H,000H       ;＝
        DB  010H,008H,004H,008H,010H,000H       ;＞
        DB  01CH,022H,00CH,000H,008H,000H       ;？
        DB  03CH,002H,01AH,02AH,01CH,000H       ;＠
        DB  01CH,022H,03EH,022H,022H,000H       ;Ａ
        DB  03CH,022H,03CH,022H,03CH,000H       ;Ｂ
        DB  01CH,022H,020H,022H,01CH,000H       ;Ｃ
        DB  03CH,022H,022H,022H,03CH,000H       ;Ｄ
        DB  03EH,020H,03CH,020H,03EH,000H       ;Ｅ
        DB  03EH,020H,03CH,020H,020H,000H       ;Ｆ
        DB  01EH,020H,026H,022H,01EH,000H       ;Ｇ
        DB  022H,022H,03EH,022H,022H,000H       ;Ｈ
        DB  01CH,008H,008H,008H,01CH,000H       ;Ｉ
        DB  01EH,004H,004H,024H,018H,000H       ;Ｊ
        DB  026H,028H,030H,028H,026H,000H       ;Ｋ
        DB  020H,020H,020H,020H,03EH,000H       ;Ｌ
        DB  022H,036H,02AH,022H,022H,000H       ;Ｍ
        DB  022H,032H,02AH,026H,022H,000H       ;Ｎ
        DB  01CH,022H,022H,022H,01CH,000H       ;Ｏ
        DB  03CH,022H,03CH,020H,020H,000H       ;Ｐ
        DB  01CH,022H,02AH,024H,01AH,000H       ;Ｑ
        DB  03CH,022H,03CH,024H,022H,000H       ;Ｒ
        DB  01EH,020H,01CH,002H,03CH,000H       ;Ｓ
        DB  03EH,008H,008H,008H,008H,000H       ;Ｔ
        DB  022H,022H,022H,022H,01CH,000H       ;Ｕ
        DB  022H,022H,022H,014H,008H,000H       ;Ｖ
        DB  022H,02AH,02AH,02AH,014H,000H       ;Ｗ
        DB  022H,014H,008H,014H,022H,000H       ;Ｘ
        DB  022H,022H,014H,008H,008H,000H       ;Ｙ
        DB  03EH,004H,008H,010H,03EH,000H       ;Ｚ
        DB  00CH,008H,008H,008H,00CH,000H       ;［
        DB  022H,01CH,008H,03EH,008H,000H       ;￥
        DB  018H,008H,008H,008H,018H,000H       ;］
        DB  008H,014H,000H,000H,000H,000H       ;＾
        DB  000H,000H,000H,000H,03EH,000H       ;＿
        DB  00CH,008H,004H,000H,000H,000H       ;‘
        DB  000H,018H,024H,024H,01AH,000H       ;ａ
        DB  010H,010H,01CH,012H,01CH,000H       ;ｂ
        DB  000H,00CH,010H,012H,00CH,000H       ;ｃ
        DB  004H,004H,01CH,024H,01CH,000H       ;ｄ
        DB  000H,018H,024H,038H,01EH,000H       ;ｅ
        DB  00CH,010H,038H,010H,010H,000H       ;ｆ
        DB  000H,01CH,024H,01CH,004H,018H       ;ｇ
        DB  020H,020H,038H,024H,024H,000H       ;ｈ
        DB  008H,000H,008H,008H,008H,000H       ;ｉ
        DB  004H,000H,004H,004H,024H,018H       ;ｊ
        DB  010H,014H,018H,014H,012H,000H       ;ｋ
        DB  018H,008H,008H,008H,00CH,000H       ;ｌ
        DB  000H,034H,02AH,02AH,02AH,000H       ;ｍ
        DB  000H,02CH,032H,022H,022H,000H       ;ｎ
        DB  000H,018H,024H,024H,018H,000H       ;ｏ
        DB  000H,01CH,012H,01CH,010H,010H       ;ｐ
        DB  000H,01CH,024H,01CH,004H,004H       ;ｑ
        DB  000H,014H,018H,010H,010H,000H       ;ｒ
        DB  000H,01CH,030H,00CH,038H,000H       ;ｓ
        DB  010H,03CH,010H,012H,00CH,000H       ;ｔ
        DB  000H,024H,024H,024H,01CH,000H       ;ｕ
        DB  000H,022H,022H,014H,008H,000H       ;ｖ
        DB  000H,022H,02AH,02AH,014H,000H       ;ｗ
        DB  000H,032H,00CH,018H,026H,000H       ;ｘ
        DB  000H,012H,012H,00EH,002H,01CH       ;ｙ
        DB  000H,01CH,004H,008H,01CH,000H       ;ｚ
        DB  018H,010H,020H,010H,018H,000H       ;｛
        DB  008H,008H,000H,008H,008H,000H       ;｜
        DB  00CH,004H,002H,004H,00CH,000H       ;｝
        DB  010H,02AH,004H,000H,000H,000H       ;￣
        DB  000H,000H,000H,000H,000H,000H
        DB  008H,01CH,022H,03EH,022H,000H       ;Å（オングストローム）
        DB  004H,008H,008H,008H,010H,000H       ;∫（インテグラル）
        DB  00EH,008H,008H,028H,010H,000H       ;√（ルート）
        DB  004H,008H,010H,000H,000H,000H       ;ダッシュ
        DB  03EH,012H,008H,012H,03EH,000H       ;Σ（シグマ）
        DB  01CH,022H,022H,014H,036H,000H       ;Ω（オーム）
        DB  02AH,015H,02AH,015H,02AH,015H       ;市松模様
        DB  03FH,03FH,03FH,03FH,03FH,03FH       ;真黒
        DB  000H,01AH,024H,024H,01AH,000H       ;α（アルファ）
        DB  01CH,022H,02CH,032H,02CH,000H       ;β（ベータ）
        DB  006H,028H,010H,010H,010H,000H       ;γ（ガンマ）
        DB  01CH,020H,01CH,020H,01CH,000H       ;ε（エプシロン）
        DB  018H,024H,03CH,024H,018H,000H       ;θ（シータ）
        DB  000H,024H,024H,03AH,020H,020H       ;μ（ミュー）
        DB  002H,004H,018H,024H,018H,000H       ;σ（シグマ）
        DB  004H,01CH,02AH,01CH,010H,000H       ;φ（ファイ）
        DB  038H,028H,028H,028H,038H,000H       ;０乗
        DB  010H,030H,010H,010H,038H,000H       ;１乗
        DB  038H,008H,038H,020H,038H,000H       ;２乗
        DB  038H,008H,038H,008H,038H,000H       ;３乗
        DB  028H,028H,038H,008H,008H,000H       ;４乗
        DB  038H,020H,038H,008H,038H,000H       ;５乗
        DB  038H,020H,038H,028H,038H,000H       ;６乗
        DB  038H,028H,008H,008H,008H,000H       ;７乗
        DB  038H,028H,038H,028H,038H,000H       ;８乗
        DB  038H,028H,038H,008H,038H,000H       ;９乗
        DB  010H,038H,010H,000H,000H,000H       ;小さいプラス
        DB  000H,038H,000H,000H,000H,000H       ;小さいマイナス
        DB  028H,034H,024H,024H,000H,000H       ;ｎ乗
        DB  034H,008H,010H,02CH,000H,000H       ;ｘ乗
        DB  004H,034H,004H,004H,000H,000H       ;マイナス１乗
        DB  008H,000H,03EH,000H,008H,000H       ;÷
        DB  000H,000H,000H,000H,000H,000H
        DB  000H,000H,038H,028H,038H,000H       ;。
        DB  00EH,008H,008H,000H,000H,000H       ;「
        DB  000H,000H,008H,008H,038H,000H       ;」
        DB  000H,000H,020H,010H,008H,000H       ;、
        DB  000H,000H,00CH,00CH,000H,000H       ;・
        DB  03EH,002H,03EH,004H,008H,000H       ;ヲ
        DB  000H,01EH,002H,00CH,008H,000H       ;ァ
        DB  000H,004H,008H,018H,008H,000H       ;ィ
        DB  000H,008H,01CH,014H,004H,000H       ;ゥ
        DB  000H,000H,01CH,008H,01CH,000H       ;ェ
        DB  000H,008H,03CH,018H,028H,000H       ;ォ
        DB  000H,010H,03CH,014H,010H,000H       ;ャ
        DB  000H,000H,018H,008H,03CH,000H       ;ュ
        DB  000H,000H,03CH,01CH,03CH,000H       ;ョ
        DB  000H,028H,02AH,002H,00CH,000H       ;ッ
        DB  000H,000H,03EH,000H,000H,000H       ;ー
        DB  03EH,002H,00CH,008H,010H,000H       ;ア
        DB  004H,008H,018H,028H,008H,000H       ;イ
        DB  008H,03EH,022H,004H,008H,000H       ;ウ
        DB  000H,01CH,008H,008H,03EH,000H       ;エ
        DB  004H,03EH,00CH,014H,024H,000H       ;オ
        DB  008H,03EH,00AH,012H,024H,000H       ;カ
        DB  008H,03EH,008H,03EH,008H,000H       ;キ
        DB  01EH,012H,022H,004H,008H,000H       ;ク
        DB  010H,01EH,024H,004H,008H,000H       ;ケ
        DB  000H,03EH,002H,002H,03EH,000H       ;コ
        DB  014H,03EH,014H,004H,008H,000H       ;サ
        DB  030H,002H,032H,002H,01CH,000H       ;シ
        DB  03EH,004H,008H,014H,022H,000H       ;ス
        DB  010H,03EH,012H,010H,00EH,000H       ;セ
        DB  022H,022H,012H,004H,008H,000H       ;ソ
        DB  01EH,012H,02EH,002H,00CH,000H       ;タ
        DB  004H,018H,004H,03EH,004H,000H       ;チ
        DB  02AH,02AH,02AH,002H,00CH,000H       ;ツ
        DB  01CH,000H,03EH,008H,010H,000H       ;テ
        DB  010H,010H,018H,014H,010H,000H       ;ト
        DB  008H,03EH,008H,008H,010H,000H       ;ナ
        DB  000H,01CH,000H,000H,03EH,000H       ;ニ
        DB  03EH,002H,014H,008H,034H,000H       ;ヌ
        DB  008H,03CH,004H,03AH,008H,000H       ;ネ
        DB  004H,004H,004H,008H,010H,000H       ;ノ
        DB  008H,024H,024H,022H,022H,000H       ;ハ
        DB  020H,03EH,020H,020H,01EH,000H       ;ヒ
        DB  03EH,002H,002H,004H,008H,000H       ;フ
        DB  000H,010H,028H,004H,002H,000H       ;ヘ
        DB  008H,03EH,008H,02AH,02AH,000H       ;ホ
        DB  03EH,002H,014H,008H,004H,000H       ;マ
        DB  01CH,000H,01CH,000H,03EH,000H       ;ミ
        DB  008H,008H,012H,03EH,002H,000H       ;ム
        DB  002H,00AH,004H,00AH,030H,000H       ;メ
        DB  03EH,010H,03EH,010H,01EH,000H       ;モ
        DB  010H,03EH,012H,010H,010H,000H       ;ヤ
        DB  03CH,004H,004H,004H,03EH,000H       ;ユ
        DB  03EH,002H,01EH,002H,03EH,000H       ;ヨ
        DB  01CH,000H,03EH,002H,00CH,000H       ;ラ
        DB  024H,024H,024H,008H,010H,000H       ;リ
        DB  028H,028H,028H,02AH,024H,000H       ;ル
        DB  010H,010H,012H,014H,018H,000H       ;レ
        DB  03EH,022H,022H,022H,03EH,000H       ;ロ
        DB  03EH,022H,002H,004H,008H,000H       ;ワ
        DB  030H,002H,002H,004H,038H,000H       ;ン
        DB  008H,024H,010H,000H,000H,000H       ;゛
        DB  038H,028H,038H,000H,000H,000H       ;゜
        DB  008H,004H,03EH,000H,03EH,000H       ;≧
        DB  008H,010H,03EH,000H,03EH,000H       ;≦
        DB  010H,03EH,008H,03EH,004H,000H       ;≠
        DB  008H,01CH,02AH,008H,008H,000H       ;矢印（上）
        DB  008H,010H,03EH,010H,008H,000H       ;矢印（左）
        DB  008H,008H,02AH,01CH,008H,000H       ;矢印（下）
        DB  008H,004H,03EH,004H,008H,000H       ;矢印（右）
        DB  03EH,014H,014H,014H,026H,000H       ;π（パイ）
        DB  008H,01CH,03EH,008H,01CH,000H       ;スペード
        DB  014H,03EH,03EH,01CH,008H,000H       ;ハート
        DB  008H,01CH,03EH,01CH,008H,000H       ;ダイヤ
        DB  01CH,03EH,03EH,008H,01CH,000H       ;クラブ
        DB  03EH,022H,022H,022H,03EH,000H       ;四角
        DB  01CH,022H,022H,022H,01CH,000H       ;円
        DB  000H,008H,014H,03EH,000H,000H       ;三角
        DB  020H,010H,008H,004H,002H,000H       ;逆スラッシュ
        DB  022H,014H,008H,014H,022H,000H       ;×（かける）
        DB  03EH,02AH,03EH,022H,026H,000H       ;円（漢字）
        DB  020H,03EH,014H,03EH,004H,000H       ;年（漢字）
        DB  01EH,012H,01EH,01EH,022H,000H       ;月（漢字）
        DB  03EH,022H,03EH,022H,03EH,000H       ;日（漢字）
        DB  004H,018H,008H,03EH,008H,000H       ;千（漢字）
        DB  03EH,010H,01EH,012H,022H,000H       ;万（漢字）
        DB  00CH,010H,03CH,010H,03EH,000H       ;￡
        DB  008H,01CH,028H,01CH,008H,000H       ;￠
        DB  008H,01CH,008H,000H,01CH,000H       ;±
        DB  01CH,000H,008H,01CH,008H,000H       ;±の逆
        DB  000H,038H,028H,028H,038H,000H       ;左下の小さな四角
        DB  000H,000H,000H,000H,000H,000H
        DB  000H,000H,000H,000H,000H,000H
        DB  000H,000H,000H,000H,000H,000H
        DB  000H,000H,000H,000H,000H,000H

;**************************************
;ワークエリア
;**************************************

CURSOL_X        DB      0               ;Ｘ座標
CURSOL_Y        DB      0               ;Ｙ座標
                                        ;順番を崩してはならない
N_CR            DB      0               ;改行可判定フラグ
REV             DB      0               ;反転フラグ
FONT            DB      1536 DUP(?)     ;フォント
