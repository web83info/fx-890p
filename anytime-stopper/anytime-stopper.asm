;**************************************
;Anytime Stopper Ver.1.1
;Programmed by ABCP software
;for FX-890P/Z-1GR/(Z-1)
;**************************************

        ORG     2000H

        CLD
        CLI                             ;割り込み禁止
        CALL    WHATISIP                ;IP を求める
WHATISIP:
        POP     BP
        SUB     BP,2005H
        XOR     BX,BX
        XOR     CX,CX
        MOV     ES,BX
        MOV     DS,BX
        MOV     BL,30H                  ;キー割り込みベクタのアドレス
        DB      0B8H
        DW      OFFSET STOP             ;MOV AX,OFFSET STOP
                                        ;ROM のアセンブラは NOP を出力する
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
        DW      OFFSET STOP             ;MOV AX,OFFSET STOP
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
;メッセージ
;**************************************

STAY:
        DB      12
        DB      '[Anytime '
        DB      'Stopper]'
        DB      13
        DB      'Stayed on'
        DB      ' Memory.'
        DB      13,0
DISSTAY:
        DB      12
        DB      'Removed from'
        DB      ' Memory.'
        DB      13,0

;**************************************
;メインルーチン
;**************************************

STOP:
        PUSHA
        CALL    KEY
        JZ      RET                     ;キーが押されていないならリターン
LOOP:
        CALL    KEY
        JNZ     LOOP                    ;キーが放されるまでループ
LOOP2:
        CALL    KEY
        JZ      LOOP2                   ;また押されるまでループ
LOOP3:
        CALL    KEY
        JNZ     LOOP3                   ;もう一度放されるまでループ
RET:
        POPA
        DB      0EAH                    ;JMP XXXX:XXXX
BACKUP:
        DW      0,0                     ;こうしないと本来のルーチンに飛ばない
                                        ;し、バックアップも兼ねて一石二鳥！

;**************************************
;同時キー入力チェック
;**************************************

KEY:                                    ;押されていないなら ZF=1
        MOV     DX,200H                 ;CAL が押されているか
        MOV     AX,0100H
        OUT     DX,AX
        PUSH    AX
        POP     AX
        MOV     DL,2
        IN      AX,DX
        AND     AL,02H
        JNZ     SHIFT
        RET
SHIFT:
        MOV     AX,0800H                ;SHIFT が押されているか
        MOV     DL,0
        OUT     DX,AX
        PUSH    AX
        POP     AX
        MOV     DL,2
        IN      AX,DX
        AND     AH,08H
        RET
EOP:
