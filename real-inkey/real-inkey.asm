;**************************************
;Ｒｅａｌ　ＩＮＫＥＹ＄　Ｖｅｒ．１．０
;内蔵アセンブラ対応ソースリスト
;Ｐｒｏｇｒａｍｍｅｄ　Ｂｙ　ＡＢＣＰ
;**************************************

        ORG     02000H
        DB      06AH,000H   ;PUSH +00H
        POP     DS               ;DS=0
                                        ;XOR AX,AX / MOV DS,AX より１バイト短い
                                        ;から ROM でもこの方法が使われています
                                        ;（標準 BIOS のエントリー付近）
                                        ;ROM は単にレジスタが使えないからかも
                                        ;しれませんが

;**************************************
;変数エリアのチェック
;**************************************

        MOV     AH,06BH                 ;変数エリアのトップアドレスを
        INT     041H                    ;BX に返す
FIND:
        CMP     WORD PTR [BX],00180H    ;80H= 精度情報（配列＆文字変数か）
                                        ;01H= 変数名長のチェック
        JNE     NEXT                    ;違っていたら次の変数へ
        DB      081H,07FH,002H          ;CMP WORD PTR [BX+2],0FF4BH
        DW      0FF4BH                  ;4BH= 文字変数が K$ か
                                        ;FFH= 変数名長が 1 のときはダミー
        JNE     NEXT                    ;違っていたら次の変数へ
        DB      08BH,047H,006H          ;MOV AX,[BX+6]
        MOV     ES,AX                   ;データアドレスのセグメント
        DB      08BH,07FH,004H          ;MOV DI,[BX+4]
                                        ;データアドレスのオフセット
        CMP     WORD PTR ES:[DI],00100H ;00H= ヘッダ
                                        ;01H= 次元数が 1 か
        JNE     ERROR                   ;違っていたらエラー発生
        DB      026H,081H,07DH,002H     ;CMP WORD PTR ES:[DI+2],90
        DW      90                      ;90= 1 次元上限のチェック
        JNE     ERROR                   ;違っていたらエラー発生
        DB      026H,081H,07DH,004H     ;CMP WORD PTR ES:[DI+4],000BCH
        DW      000BCH                  ;00BCH= 配列変数の全体のバイト数
        JNE     ERROR                   ;違っていたらエラー発生
        JE      READ                    ;正しければ読み込み
NEXT:                                   ;次の変数探し
        MOV     AX,[BX]
        TEST    AH,1                    ;変数名長が奇数のときは
        JZ      NEXT_2
        INC     AH                      ;偶数にする
NEXT_2:
        MOV     CL,AH                   ;変数テーブル全体のバイト数を計算
        XOR     CH,CH
        ADD     CX,6
        ADD     BX,CX
        XOR     AX,AX                   ;変数テーブルの終わりをチェック
        MOV     ES,AX
        MOV     SI,BX
        MOV     AH,04AH                 ;ポインタを標準形式に
        INT     041H
        DB      03BH,036H
        DW      01A62H                  ;CMP SI,[1A62H]
        JNE     FIND                    ;まだ探す余地がある
        DB      0A1H
        DW      01A64H                  ;MOV AX,[1A64H]
        MOV     CX,ES
        CMP     AX,CX
        JNE     FIND                    ;まだ探す余地がある

;**************************************
;エラー発生
;**************************************

ERROR:
        DB      0EAH                    ;JMP 0F000H:003AFH
        DW      003AFH,0F000H           ;BS error の発生

;**************************************
;変数の初期化
;**************************************

READ:
        DB      083H,0C7H,006H          ;ADD DI,6
                                        ;内蔵アセンブラでアセンブルさせると
                                        ;無駄が出てしまうんですね
                                        ;だからハンドアセンブル！
        MOV     BP,DI                   ;BP レジスタには 0 番目の要素のアドレス
        MOV     WORD PTR ES:[DI],00000H ;をいれて、そこを初期化する
        INC     DI                      ;ADD DI,2 より１バイト短い
        INC     DI

;**************************************
;キーポートの初期化
;**************************************

INIT:
        MOV     DX,00200H               ;キーポートの初期化
        MOV     AX,01FFFH
        OUT     DX,AX
        XOR     AX,AX
        OUT     DX,AX
        MOV     CX,90                   ;ループ回数の設定

;**************************************
;リロケータブル処理
;**************************************

        PUSH    CS                      ;DS=CS の設定はスタックを介する
        POP     DS
        CALL    IP                      ;IP: のアドレスをスタックに積む
IP:
        POP     SI                      ;SI=IP つまり、オフセットを得る
        DB      083H,0C6H,68            ;ADD SI,68
                                        ;68 バイト後からキーデータがある

;**************************************
;キー入力メイン
;**************************************

K_LOOP:
        MOV     AX,[SI]                 ;KO を指定する
        XOR     BX,BX                   ;結果格納領域の初期化
        MOV     DX,00200H               ;KOPORT
        OUT     DX,AX
        CALL    K_WAIT                  ;一定時間待たないと結果が正しく
                                        ;返ってこないことがあるようです
        MOV     DL,2                    ;既に DH=20H だから KIPORT 指定
        IN      AX,DX                   ;結果読み込み
        DB      023H,044H,002H          ;AND AX,[SI+2]
                                        ;余計なビットを殺す
        JZ      NOT_PUSH
        MOV     BX,02001H               ;20H= スペースのキャラクターコード
                                        ;01H= 文字列の長さ
        MOV     ES:[BP],BX              ;どれでもキーが押されてたら記憶させる
NOT_PUSH:
        MOV     ES:[DI],BX              ;こちらはそのキー自身の情報を記憶
        INC     DI                      ;次の要素へ
        INC     DI
        DB      083H,0C6H,4             ;ADD SI,4
                                        ;次のキー情報に
        LOOP    K_LOOP                  ;次のキー読み込みに

;**************************************
;キー入力後処理
;**************************************

        MOV     DX,00200H               ;キーポートの後処理
        MOV     AX,007FFH
        OUT     DX,AX
        CALL    K_WAIT
        MOV     DX,204H                 ;キー割り込み許可
        MOV     AL,03H
        OUT     DX,AL
        DEC     AL
        OUT     DX,AL
        IRET                            ;お疲れ様でした
                                        ;BASIC へお帰りです

;**************************************
;サブルーチン
;**************************************

K_WAIT:                                 ;キー入力のときのウエイト
        PUSH    CX
        MOV     CX,00009H
WAIT:
        LOOP    WAIT
        POP     CX
        RET

;**************************************
;キーデータ
;**************************************

K_DATA:
        DW      0800H,0800H             ;SHIFT
        DW      0002H,0020H             ;CAPS
        DW      0004H,0080H             ;SRCH
        DW      0004H,0100H             ;IN
        DW      0008H,0080H             ;OUT
        DW      0008H,0100H             ;CALC
        DW      0040H,0004H             ;S （赤い方）
        DW      0200H,0200H             ;BS
        DW      0002H,0002H             ;TAB
        DW      0080H,0100H             ;E （リターンの隣）
        DW      0080H,0002H             ;MENU
        DW      0400H,0010H             ;CLS
        DW      0080H,0200H             ;RET
        DW      0100H,0002H             ;CAL
        DW      0400H,0002H             ;SQR
        DW      0400H,0004H             ;X^2
        DW      0040H,0040H             ;DEL
        DW      0020H,0040H             ;INS
        DW      0400H,0008H             ;ENG
        DW      0080H,0004H             ;log
        DW      0100H,0004H             ;ln
        DW      0200H,0002H             ;DEGR
        DW      0200H,0004H             ;sin
        DW      0400H,0020H             ;cos
        DW      0400H,0200H             ;tan
        DW      0080H,0008H             ;MR
        DW      0100H,0008H             ;M+
        DW      0040H,0080H             ;→
        DW      0020H,0080H             ;←
        DW      0040H,0020H             ;↑
        DW      0020H,0100H             ;↓
        DW      0010H,0080H             ;SPC
        DW      0400H,0040H             ;^
        DW      0400H,0080H             ;STOP
        DW      0001H,0001H             ;BRK
        DW      0000H,0000H             ;ダミー
        DW      0000H,0000H             ;ダミー
        DW      0000H,0000H             ;ダミー
        DW      0000H,0000H             ;ダミー
        DW      0200H,0008H             ;(
        DW      0200H,0010H             ;)
        DW      0200H,0080H             ;*
        DW      0100H,0100H             ;+
        DW      0020H,0020H             ;,
        DW      0100H,0200H             ;-
        DW      0080H,0080H             ;.
        DW      0200H,0100H             ;/
        DW      0040H,0100H             ;0
        DW      0080H,0040H             ;1
        DW      0100H,0040H             ;2
        DW      0100H,0080H             ;3
        DW      0080H,0020H             ;4
        DW      0100H,0020H             ;5
        DW      0200H,0040H             ;6
        DW      0080H,0010H             ;7
        DW      0100H,0010H             ;8
        DW      0200H,0020H             ;9
        DW      0040H,0010H             ;:
        DW      0040H,0008H             ;;
        DW      0000H,0000H             ;ダミー
        DW      0010H,0100H             ;=
        DW      0000H,0000H             ;ダミー
        DW      0000H,0000H             ;ダミー
        DW      0000H,0000H             ;ダミー
        DW      0002H,0010H             ;A
        DW      0008H,0040H             ;B
        DW      0004H,0040H             ;C
        DW      0004H,0010H             ;D
        DW      0004H,0004H             ;E
        DW      0008H,0008H             ;F
        DW      0008H,0010H             ;G
        DW      0010H,0008H             ;H
        DW      0020H,0002H             ;I
        DW      0010H,0010H             ;J
        DW      0020H,0008H             ;K
        DW      0020H,0010H             ;L
        DW      0010H,0040H             ;M
        DW      0010H,0020H             ;N
        DW      0020H,0004H             ;O
        DW      0040H,0002H             ;P
        DW      0002H,0004H             ;Q
        DW      0008H,0002H             ;R
        DW      0004H,0008H             ;S
        DW      0008H,0004H             ;T
        DW      0010H,0004H             ;U
        DW      0008H,0020H             ;V
        DW      0004H,0002H             ;W
        DW      0004H,0020H             ;X
        DW      0010H,0002H             ;Y
        DW      0002H,0040H             ;Z
EOP:
