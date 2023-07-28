;******************************************************************************
;Ｌｅｔ’ｓ　Ｓｃｒｅｅｎ　Ｃａｐｔｕｒｅ　Ｖｅｒ．０．５１
;                        Ｐｒｏｇｒａｍｍｅｄ　ｂｙ　ＡＢＣＰ　ｓｏｆｔｗａｒｅ
;
;                        内蔵アセンブラ対応ソースリスト
;******************************************************************************

;**************************************
;オプション解析
;**************************************

        ORG     2000H
INST:
        CLD
        CLI
        CALL    IP_                     ;リロケート処理
IP_:
        POP     BP
        SUB     BP,2005H
        DB      26H                     ;ES:
        LODSB
        CMP     AL,2CH                  ;カンマがあるか
        JNE     VECTINST
        DB      26H                     ;ES:
        LODSB
        MOV     DL,AL
        CMP     DL,30H                  ;0 から
        JC      ERROR
        CMP     DL,39H                  ;9 の間だけ有効
        JA      ERROR
        SUB     DL,38                   ;30H を引いて 10 を足す
        MOV     AH,60H                  ;メモリ移動の対象となるファイル
        INT     41H
        MOV     AH,40H                  ;ES:DI= ファイルの先頭アドレス
        INT     41H
        MOV     AH,65H                  ;BX:CX= ファイルの長さ
        INT     41H
        OR      BX,BX                   ;ファイルが空のときだけ処理
        JNZ     ERROR
        OR      CX,CX
        JZ      HEAD
ERROR:
        MOV     AH,20H                  ;エラー表示
        DB      0BFH
        DW      OFFSET ERR1             ;MOV DI,OFFSET ERR1
        ADD     DI,BP
        INT     41H
        JMP     TOBASIC                 ;BASIC へ

;**************************************
;ファイルエリアのフォーマット
;**************************************

HEAD:
        MOV     AH,61H                  ;ファイルエリアの確保
        MOV     CX,830
        INT     41H
        DB      0BEH
        DW      OFFSET HEADER           ;MOV SI,OFFSET HEADER
        ADD     SI,BP
        MOV     CX,62
        REP     MOVSB                   ;ヘッダーの書き込み
        XOR     AL,AL
        MOV     CX,768
        REP     STOSB                   ;クリア
        MOV     AH,20H                  ;成功メッセージ
        DB      0BFH
        DW      OFFSET SUCCESS          ;MOV DI,OFFSET SUCCESS
        ADD     DI,BP
        INT     41H

;**************************************
;システムにリターン
;**************************************

TOBASIC:
        MOV     BP,SP                   ;BASIC 処理先の変更
        DB      083H,0C5H,06H           ;ADD BP,6
        MOV     SI,[BP]                 ;詳しくはＣＦ２を読んでね (^^)
        INC     SI                      ;ADD SI,2 より短くなる
        INC     SI
        MOV     [BP],SI
        IRET

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
        DW      OFFSET SAVE             ;MOV AX,OFFSET SAVE
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
        DW      OFFSET SAVE             ;MOV AX,OFFSET SAVE
        ADD     AX,BP
        MOV     [BX],AX
        DB      089H,04FH,002H          ;MOV [BX+2],CX(=0)
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
;実際のセーブルーチン
;(注意) ここから BIOS は使えない
;**************************************

        ORG     20BEH
SAVE:
        PUSHA
        PUSH    ES
        PUSH    DS
        CALL    GET_IP                  ;IP を求める
GET_IP:
        POP     BP
        SUB     BP,20C4H
        CLD
        XOR     AX,AX                   ;キーポートの読み込み
        MOV     DS,AX
        MOV     ES,AX
        MOV     DX,200H
        MOV     AX,0100H                ;[CALC] キーのチェック
        OUT     DX,AX
        PUSH    AX                      ;ウエイト
        POP     AX
        MOV     DL,2
        IN      AX,DX
        TEST    AL,02H
        JNZ     SHIFT
        JMP     RET_INT
SHIFT:
        MOV     DL,0
        MOV     AX,0800H                ;[SHIFT] キーのチェック
        OUT     DX,AX
        PUSH    AX
        POP     AX
        MOV     DL,2
        IN      AX,DX
        TEST    AH,08H
        JNZ     WRERE_TO
        JMP     RET_INT
WRERE_TO:
        CALL    TENKEY
        CMP     CX,0FFFFH
        JZ      WRERE_TO

;**************************************
;ファイルのチェック
;**************************************

OK:                                     ;CX= ファイルエリアの番号
        MOV     BX,1A96H
        DB      0C1H,0E1H,2             ;SAL CX,2
        ADD     BX,CX
        MOV     DX,BX
        LDS     SI,[BX]                 ;DS:SI= ファイルの先頭の番地
        DB      0BFH
        DW      OFFSET HEADER           ;MOV DI,OFFSET HEADER
        ADD     DI,BP
        MOV     CX,62
        REPZ    CMPSB                   ;ヘッダーが正しく書き込まれているか
        JZ      B_MAIN
        JMP     NOREPEAT
B_MAIN:
        PUSH    SI
        PUSH    DS
        MOV     SI,DX                   ;先頭番地が書かれている番地
        MOV     DS,CX;CX=0
        MOV     BX,[SI]
        DB      8BH,44H,2               ;MOV AX,[SI+2]
                                        ;アドレス = XXXX:000X
        DB      0C1H,0E3H,12            ;SAL BX,12
                                        ;アドレス = XXXX:X000
        MOV     CX,12
AD_L:
        SHR     AX,1
        RCR     BX,1
        LOOP    AD_L                    ;アドレス= 000X:XXXX
        MOV     CX,AX
        MOV     DX,BX
        DB      8BH,5CH,4               ;MOV BX,[SI+4]
        DB      08BH,44H,6              ;MOV AX,[SI+6]
        DB      0C1H,0E3H,12            ;SAL BX,12
        MOV     CH,12
AD_L2:
        SHR     AX,1
        RCR     BX,1
        DEC     CH
        JNZ     AD_L2
        XOR     CH,CH
        POP     DS
        POP     SI
        SUB     BX,DX
        SBB     AX,CX                   ;AX:BX= ファイルサイズ
        OR      AX,AX
        JNZ     RET_SYS
        CMP     BX,831                  ;EOF がついてしまう
        JZ      MAIN
RET_SYS:
        JMP     NOREPEAT

;**************************************
;読み込み＆書き込みのメイン
;**************************************

MAIN:                                   ;FCR,XAR,YAR の保存
        MOV     AX,0A000H
        MOV     ES,AX
        XOR     DI,DI
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
        MOV     DL,31                   ;BMP の構造上、下から読み込む
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
        MOV     AH,ES:[DI]              ;ダミーリード
        PUSH    BX                      ;ウエイト
        POP     BX
        PUSH    BX
        POP     BX
        MOV     AH,ES:[DI]              ;最初の左の 4 ビット
        PUSH    BX                      ;ウエイト
        POP     BX
        PUSH    BX
        POP     BX
        MOV     CX,12
READ2:
        MOV     AL,ES:[DI]
        PUSH    BX
        POP     BX
        PUSH    BX
        POP     BX
        DB      0C1H,0E0H,4             ;SAL AX,4
        NOT     AH
        MOV     [SI],AH                 ;ファイルにセーブ
        INC     SI
        MOV     AH,AL                   ;次のデータに備える
        DB      0C0H,0ECH,4             ;SHR AH,4
        LOOP    READ2
        INC     DI
        ADD     DL,32                   ;左から右へ
        CMP     DL,64
        JC      DLP
        SUB     DL,65                   ;64+1, 下から上へ
        JNC     DLP
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
NOREPEAT:
        CALL    TENKEY
        INC     CX
        JNZ     NOREPEAT
RET_INT:
        POP     DS
        POP     ES
        POPA
        DB      0EAH                    ;本来のルーチンへ
BACKUP:
        DW      0,0

;**************************************
;テンキーで入力
;**************************************

TENKEY:                                 ;CX=-1 押されていない
        XOR     AX,AX
        MOV     DS,AX
        MOV     CX,10
        DB      0BEH
        DW      OFFSET K_DAT            ;MOV SI,OFFSET K_DAT
        ADD     SI,BP
K_0TO9:
        MOV     DX,200H
        LODSW
        OUT     DX,AX
        PUSH    AX
        POP     AX
        MOV     DL,2
        IN      AX,DX
        MOV     BX,AX
        LODSW
        TEST    BX,AX
        JNZ     TENKEY_R
        LOOP    K_0TO9
TENKEY_R:
        DEC     CX
        RET

;**************************************
;データ
;**************************************

K_DAT:
        DW      0200H,0020H             ;9
        DW      0100H,0010H             ;8
        DW      0080H,0010H             ;7
        DW      0200H,0040H             ;6
        DW      0100H,0020H             ;5
        DW      0080H,0020H             ;4
        DW      0100H,0080H             ;3
        DW      0100H,0040H             ;2
        DW      0080H,0040H             ;1
        DW      0040H,0100H             ;0
STAY:
        DB      12
        DB      'Let'
        DB      27H
        DB      's Screen '
        DB      'Capture '
        DB      'by ABCP'
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
SUCCESS:
        DB      'Succeed'
        DB      13,0
ERR1:
        DB      'Can'
        DB      27H
        DB      't Format'
        DB      13,0
HEADER:
        DB      42H,4DH,3EH,03H
        DB      0,0,0,0,0,0
        DB      3EH,0,0,0,28H,0,0,0
        DB      0C0H,0,0,0,20H,0,0,0,1
        DB      0,1,0,0,0,0,0,0,0,0,0
        DB      0,0,0,0,0,0,0,0,0,0,0
        DB      0,0,0,0,0,0,0,0,0
        DB      255,255,255,0
