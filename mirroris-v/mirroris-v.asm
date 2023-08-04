;**************************************
;MIRRORIS-V
;Ver. 1996-06-06 00:36:35
;**************************************

        ORG 2000H

;**************************************
;ABCP PRESENT Ë®³¼Þ
;**************************************

FIRST:
        MOV     BYTE PTR REV,0
        CALL    CLS                     ;¶ÞÒÝ ¸Ø±
        MOV     DI,OFFSET ABCP
        MOV     BX,0107H                ;(X,Y)=(BL,BH)
        CALL    MOJIPUT
        MOV     CX,00600H
ABCP_LP:                                ;³´²Ä
        CALL    KEYIN                   ;¼Þ¶Ý¶¾·Þ & BREAK ³¹Â¹
        LOOP    ABCP_LP

;**************************************
;À²ÄÙ Ë®³¼Þ
;**************************************

TITLE1:
        MOV     BYTE PTR REV,0
        CALL    CLS
        XOR     CX,CX                   ;CX=0
        MOV     DX,0020H
        MOV     SI,OFFSET TITLE
        MOV     BL,8
T_LP2:
        MOV     BH,0
T_LP:
        CALL    LCDC
        INC     BH
        CMP     BH,3
        JNE     T_LP                    ;ÀÃ ²ÁÚÂ Ë®³¼Þ¼À?
        INC     BL
        CMP     BL,24
        JNE     T_LP2                   ;Öº²ÁÚÂ Ë®³¼Þ¼ÀÉ?
        CALL    KEYIN
        MOV     LK,AL
T_1:
        MOV     CX,0060H                ;ÃÝÒÂÖ³ ³´²Ä
T_E:                                    ;PUSH [RET] KEY!
        MOV     BX,0309H
        MOV     DI,OFFSET PUSH
        CALL    MOJIPUT
        CALL    RND                     ;×Ý½³ ¼®·¶
        LOOP    NOT_REV
        XOR     BYTE PTR REV,1          ;BYTE PTR [REV]=0,1,0,1...
        JMP     T_1
NOT_REV:
        MOV     LK,AL
        CALL    KEYIN
        TEST    AL,04H                  ;"O"·-?
        JNE     OPTION                  ;b3=1 ÉÄ· OPTION:
        TEST    AL,01H                  ;RET·-?
        JZ      T_E
        TEST    BYTE PTR LK,1
        JNZ     T_E
        JMP     START

;**************************************
;µÌß¼®Ý Ó-ÄÞ
;**************************************

OPTION:                                 ;µÌß¼®Ý ¶ÞÒÝ ¾²»¸
        MOV     BYTE PTR REV,0          ;Â³¼Þ®³ Ó-ÄÞ
        MOV     BX,0503H
        MOV     CX,1249H
        MOV     DL,4
        CALL    SEN
        MOV     DL,0
        CALL    SEN
        MOV     DI,OFFSET OPT
        MOV     BX,0101H
        CALL    MOJIPUT
        MOV     BX,0558H
        MOV     CX,1ABCH
        MOV     DL,4
        CALL    SEN
        MOV     DL,0
        CALL    SEN
        MOV     DI,OFFSET GAME_M
        MOV     BX,0110H
        CALL    MOJIPUT
        MOV     DI,OFFSET BALLL
        MOV     BX,0210H
        CALL    MOJIPUT
        MOV     BYTE PTR Y,1
OP_LP:
        MOV     BX,011EH
        MOV     DL,GAME
        ADD     DL,65
        CALL    MJ_ONE
        MOV     BX,021DH
        MOV     AL,FB
        XOR     AH,AH
        MOV     DL,10
        DIV     DL
        ADD     AX,03030H
        MOV     DL,AL
        CALL    MJ_ONE
        INC     BL
        MOV     DL,AH
        CALL    MJ_ONE
        CALL    KEYIN
        TEST    LK,AL
        MOV     LK,AL                   ;LK=LAST KEY
        JNZ     OP_LP                   ;¾ÞÝ¶² µ»ÚÀ ·-
        MOV     BH,Y
        MOV     BL,15
        MOV     DL,32
        CALL    MJ_ONE                  ;¶-¿Ù ¹½
        TEST    AL,10H                  ;"8"·-?
        JZ      OP_1
        MOV     BYTE PTR Y,1
        JMP     OP_6
OP_1:
        TEST    AL,40H                  ;"2"·-?
        JZ      OP_2
        MOV     BYTE PTR Y,2
        JMP     OP_6
OP_2:
        TEST    AL,20H                  ;"4"·-?
        JZ      OP_4
        CMP     BYTE PTR Y,1
        JNE     OP_3
        CMP     BYTE PTR GAME,0         ;GAME=¹Þ-ÑÓ-ÄÞ
        JE      OP_4                    ;    =CHR$(65+GAME)
        DEC     BYTE PTR GAME
        JMP     OP_6
OP_3:
        CMP     BYTE PTR Y,2
        JNE     OP_4
        CMP     BYTE PTR FB,2           ;FB=FALL BLOCK ÉØ¬¸,»²Ã²Á 2
        JE      OP_4                    ;FB¶²Æ ²ÁÄÞ Ì×¯¼­ÎÞ-Ù
        DEC     BYTE PTR FB
        JMP     OP_6
OP_4:
        TEST    AL,08H                  ;"6"·-?
        JZ      OP_6
        CMP     BYTE PTR Y,1
        JNE     OP_5
        CMP     BYTE PTR GAME,2
        JE      OP_5
        INC     BYTE PTR GAME
        JMP     OP_6
OP_5:
        CMP     BYTE PTR Y,2
        JNE     OP_6
        CMP     BYTE PTR FB,60          ;FB »²º³Á 60
        JE      OP_6
        INC     BYTE PTR FB
OP_6:
        MOV     BL,15
        MOV     BH,Y
        MOV     DL,61
        CALL    MJ_ONE                  ;¶-¿Ù ¶¸
        TEST    BYTE PTR LK,01H         ;RET·-?
        JZ      STILL
        JMP     TITLE1
STILL:                                  ;ÌÞÝ·»·¶Þ Äµ½·ÞÙ¶×...
        JMP     OP_LP

;**************************************
;¼®·¾¯Ã²
;**************************************

START:
        MOV     BYTE PTR REV,0
        CALL    CLS
        XOR     AL,AL
        XOR     SI,SI
VRAM_1:                                 ;ÌÞÛ¯¸ ·µ¸ Ø®³²· ¼®·¶
        MOV     BX,OFFSET VRAM
        MOV     [BX+SI],AL
        INC     SI
        CMP     SI,64
        JNE     VRAM_1
        MOV     BYTE PTR LEVEL,0
        MOV     BYTE PTR WT,1CH         ;WT=SPEED
        XOR     AX,AX
        MOV     BALL,AL
        MOV     LK,AL
        MOV     DI,OFFSET SCORE
        MOV     [DI],AX
        DB      89H,45H,02H             ;MOV [DI+2],AX É ÊÝÄÞ±¾ÝÌÞ× ¹¯¶
        MOV     WORD PTR BLOCK,AX
        MOV     BX,0113H
        MOV     DI,OFFSET NXT
        CALL    MOJIPUT
        MOV     BX,0012H
        MOV     DI,OFFSET SCR
        CALL    MOJIPUT
        MOV     BX,0010H
KABE:                                   ;¶ÍÞ Ë®³¼Þ
        MOV     DL,60                   ;¶ÍÞ É º-ÄÞ=60
        CALL    MJ_ONE
        INC     BH
        CMP     BH,4
        JNE     KABE
        MOV     DI,OFFSET BLOCKS
        MOV     BX,0212H
        CALL    MOJIPUT
        MOV     DI,OFFSET LEVELS
        MOV     BX,0312H
        CALL    MOJIPUT
        CALL    NEXT

;**************************************
;READY - SET - GO!
;**************************************

        MOV     DI,OFFSET READY
        MOV     DH,3
READYOK:
        MOV     BX,0105H
        CALL    MOJIPUT
        MOV     CX,0300H
READY_1:
        CALL    KEYIN
        LOOP    READY_1
        INC     DI                      ;MOJIPUT ¶× Ç¹ÀÄ· [DI]=0
        DEC     DH
        JNZ     READYOK
        CALL    SCRPUT                  ;ÌÞÌÞÝ¸Ø±Æ ØÖ³.

;**************************************
;MAIN
;**************************************

SET:
        CALL    NEXT                    ;NEXT ¾²»¸
PUT:                                    ;·¬× Ë®³¼Þ
        MOV     DL,BR                   ;BR=BLOCK NUMBER
        MOV     BL,X
        MOV     BH,Y
        CALL    PRINT
        MOV     CX,2000H                ;³´²Ä
        CALL    WAITS
        XOR     DL,DL
        CALL    PRINT                   ;·¬× ¼®³·®
        CALL    KEYIN                   ;·- Æ­³Ø®¸
        CALL    CHK                     ;·- Áª¯¸
        CALL    PS_CHK                  ;Îß-½Þ Áª¯¸
        CMP     BYTE PTR W,0            ;½Ëß-ÄÞ Á®³¾²
        JNE     PUT
        CMP     BYTE PTR X,15           ;(X=15)=Ð·ÞÊ¼Þ
        JE      OWARI
        MOV     BL,X                    ;(M(X+1,Y)<>0)=µÁ×ÚÅ²
        INC     BL
        MOV     BH,Y
        CALL    XY
        CMP     BYTE PTR [DI],0
        JNE     OWARI
        INC     BYTE PTR X              ;X=X+1
        MOV     AL,WT                   ;WT=¼®·Á
        MOV     W,AL
        JMP     PUT
OWARI:                                  ;Ð·ÞÊ¼Þ OR Ð·ÞÆ ÌÞÛ¯¸
        MOV     DL,BR                   ;·¬×¸À-Ìß¯Ä
        MOV     BL,X
        MOV     BH,Y
        CALL    PRINT
        MOV     AL,BR                   ;M(X,Y)=BR
        CALL    XY                      ;ÌÞÛ¯¸ ·µ¸
        MOV     [DI],AL
        CALL    VANISH                  ;±ÀØ ÊÝÃ²
        MOV     BX,0100H                ;GAME OVER?
        CALL    XY                      ;(M(0,1)<>0)=GAME OVER
        CMP     BYTE PTR [DI],0
        JNE     END
        MOV     CX,0B000H
        CALL    WAITS
        JMP     SET

;**************************************
;GAME OVER
;**************************************

END:
        MOV     CL,9                    ;CL TIMES ¶ÞÒÝ ÊÝÃÝ
BAKU_OV:
        PUSH    CX
        MOV     CX,5000H
        CALL    WAITS
        POP     CX
        XOR     BYTE PTR REV,1
        CALL    SCRPUT
        DEC     CL
        JNZ     BAKU_OV
        MOV     BX,050FH
        MOV     CX,124FH
        MOV     DL,3
        CALL    SEN
        MOV     DL,1
        CALL    SEN
        MOV     DI,OFFSET OVER
        MOV     BX,0103H
        CALL    MOJIPUT
OVER_LP:
        CALL    RND
        CALL    KEYIN
        TEST    AL,01H                  ;RET·-?
        JE      OVER_LP
        JMP     TITLE1

;**************************************
;±ÀØ ÊÝÃ²
;**************************************

VANISH:
        MOV     BL,X
        MOV     BH,Y
        CALL    XY
        CMP     BYTE PTR [DI],5
        JE      VAN1                    ;IF M(X,Y)<>5
        RET                             ; THEN RETURN

;**************************************
;±ÀØ ÊÝÃ² Ò²Ý
;**************************************

VAN1:
        MOV     BYTE PTR [DI],0
        MOV     BYTE PTR XADD,1         ;Ì×¯¼­ÎÞ-Ù X¶»ÝÁ
        MOV     BYTE PTR YADD,0         ;Ì×¯¼­ÎÞ-Ù Y¶»ÝÁ
        MOV     BYTE PTR RENSA,1
        XOR     AX,AX
        MOV     DI,OFFSET SCOREP        ;SCOREP=SCORE PLUS
        MOV     [DI],AX
        DB      89H,45H,02H             ;MOV [DI+2],AX
        MOV     DL,43                   ;PRINT "+"
        MOV     BX,0017H
        CALL    MJ_ONE
VAN2:
        MOV     BL,X
        MOV     BH,Y
        CALL    XY
        MOV     DL,[DI]                 ;DL=M(X,Y)
        CMP     DL,1
        JE      KURO
        CMP     DL,2
        JE      SHIRO
        CMP     DL,3
        JE      NANAME
        CMP     DL,4
        JE      NANAME
NOTHING:                                ;ÅÆÓÅ²Ä·
        JMP     VAN4
SHIRO:                                  ;¼Û²ÌÞÛ¯¸ÉÄ·
        MOV     BYTE PTR [DI],0
        INC     WORD PTR BLOCK
        CALL    SCOREADD
        JMP     VAN3
KURO:                                   ;¸Û²ÌÞÛ¯¸ÉÄ·
        MOV     BYTE PTR [DI],2
        CALL    SCOREADD
        JMP     VAN3
NANAME:                                 ;Ð×-ÉÄ·
        MOV     BYTE PTR [DI],0
        INC     WORD PTR BLOCK
        CALL    SCOREADD
        INC     BYTE PTR RENSA
        CMP     BYTE PTR YADD,0
        JNE     NANAME2
NANAME1:
        MOV     AL,BYTE PTR XADD
        MOV     BYTE PTR YADD,AL
        MOV     BYTE PTR XADD,0
        CMP     DL,4
        JE      VAN3
        NEG     BYTE PTR YADD
        JMP     VAN3
NANAME2:
        MOV     AL,BYTE PTR YADD
        MOV     BYTE PTR XADD,AL
        MOV     BYTE PTR YADD,0
        CMP     DL,4
        JE      VAN3
        NEG     BYTE PTR XADD
        JMP     VAN3
VAN3:                                   ;±Ä¼®Ø & Î³º³ÃÝ¶Ý
        CMP     BYTE PTR GAME,1         ;MODE "B" = FALL EVERY TIME
        JNE     VAN4
        CALL    F_ONE
VAN4:
        MOV     DL,6

;**************************************
;Ì×¯¼­ÎÞ-Ù ±ÆÒ (ÓÄÞ·)
;**************************************

BAKU:
        MOV     BL,X
        MOV     BH,Y
        CALL    PRINT
        MOV     CX,0020H
        PUSH    DX
BAKU_PS:
        CALL    KEYIN
        CALL    PS_CHK
        LOOP    BAKU_PS
        POP     DX
        INC     DL
        CMP     DL,12
        JNE     BAKU
        MOV     BL,X
        MOV     BH,Y
        CALL    XY

;**************************************
;Ú³ÞªÙ ¹²»Ý Ë®³¼Þ
;**************************************

LEVELCAL:
        XOR     DX,DX
        MOV     DX,BLOCK
        MOV     BX,10
        CALL    WARI
        CMP     DX,99
        JBE     LV_NOF
        MOV     DX,99
LV_NOF:
        MOV     LEVEL,DL
        MOV     BX,031FH
LV_LP:
        PUSH    BX
        MOV     BX,000AH
        CALL    WARI
        POP     BX
        PUSH    DX
        MOV     DL,CL
        ADD     DL,48
        CALL    MJ_ONE
        POP     DX
        DEC     BL
        CMP     BL,1DH
        JNE     LV_LP
        MOV     BX,021FH
        MOV     DX,BLOCK
        CMP     DX,9999
        JBE     BL_PUT
        MOV     DX,9999
BL_PUT:
        PUSH    BX
        MOV     BX,000AH
        CALL    WARI
        POP     BX
        PUSH    DX
        MOV     DL,CL
        ADD     DL,48
        CALL    MJ_ONE
        POP     DX
        DEC     BL
        CMP     BL,1BH
        JNE     BL_PUT

;**************************************
;Î³º³ ÃÝ¶Ý
;**************************************

        MOV     AL,XADD
        MOV     AH,YADD
        ADD     X,AL
        ADD     Y,AH
        CMP     BYTE PTR X,0FFH         ;¶ÞÒÝ¶Þ²?
        JE      V_END
        CMP     BYTE PTR X,16
        JE      V_END
        CMP     BYTE PTR Y,0FFH
        JE      V_END
        CMP     BYTE PTR Y,4
        JE      V_END

;**************************************
;SCORE (Ì¸»ÞÂ ÃÞ½)
;**************************************

        MOV     DI,OFFSET SCOREP
        MOV     AX,[DI]
        DB      8BH,55H,02H
                 ;MOV DX,[DI+2]
        CALL    SCOREPUT
        CALL    SCRPUT
        JMP     VAN2

;**************************************
;OUT OF SCREEN
;**************************************

V_END:
        MOV     DL,32                   ;"+" ¹½
        MOV     BX,0017H
        CALL    MJ_ONE
        MOV     DI,OFFSET SCORE
        MOV     AX,[DI]
        DB      8BH,55H,02H             ;MOV DX,[DI+2]
        MOV     DI,OFFSET SCOREP
        ADD     AX,[DI]
        DB      13H,55H,02H             ;ADC DX,[DI+2]
        CMP     DX,05F5H
        JB      NOT_OV
        JA      OV
        CMP     AX,0E0FFH
        JBE     NOT_OV
OV:                                     ;SCORE OVER FLOW
        MOV     AX,0E0FFH               ;DX:AX=05F5E0FFh=99999999
        MOV     DX,05F5H
NOT_OV:                                 ;NOT OVER FLOW
        MOV     DI,OFFSET SCORE
        MOV     [DI],AX
        DB      89H,55H,02H             ;MOV [DI+2],DX
        CALL    SCOREPUT
        CMP     BYTE PTR GAME,2         ;MODE C = DON'T FALL
        JE      DONTFALL
        CALL    F_START
DONTFALL:
        CALL    SCRPUT
        RET

;**************************************
;SCORE PRINT
;**************************************

SCOREPUT:
        MOV     CX,10000
        DIV     CX
        MOV     BX,001FH
SCORECAL:
        PUSH    BX
        MOV     BX,000AH
        CALL    WARI                    ;DX=¼®³,CX=±ÏØ
        POP     BX
        PUSH    DX
        MOV     DL,CL
        ADD     DL,48                   ;±½·-º-ÄÞ ÍÝ¶Ý
        PUSH    AX
        CALL    MJ_ONE
        POP     AX
        POP     DX
        DEC     BL
        CMP     BL,17H
        JE      SCORE_E
        CMP     BL,1BH
        JNZ     SCORECAL
        MOV     DX,AX
        JMP     SCORECAL
SCORE_E:
        RET

;**************************************
;ÌÞÛ¯¸ ½·Ï ÂÒ Ù-ÁÝ (ÒÝÄÞ³)
;**************************************

F_START:
        MOV     BX,15                   ;X=15,Y=0
FALLS:
        CALL    XY
        CMP     BYTE PTR [DI],0
        JNE     FALLNEXT                ;µÄ½¼®Ø ÌÖ³ÉÄ· ±Ø
        PUSH    BX
        CALL    FALLLINE
        POP     BX
        XOR     AX,AX                   ;²ÏÉ»ÞË®³ÖØ³´Æ
        PUSH    BX                      ;  ÌÞÛ¯¸¶Þ±Ù¶?
MORE:
        CALL    XY
        MOV     AH,[DI]
        ADD     AL,AH
        SUB     BL,1
        JNZ     MORE
        POP     BX
        CMP     AL,0                    ;AL=0 ÌÞÛ¯¸¶ÞÅ²
        JNE     FALLS
FALLNEXT:                               ;ÄÅØÉÌÞÛ¯¸
        SUB     BL,1
        JNZ     FALLS
        MOV     BL,15
        INC     BH
        CMP     BH,4
        JNE     FALLS
F_END:
        RET
F_ONE:
        CALL    XY
        CMP     BYTE PTR [DI],0
        JNE     NOFALL
        CALL    FALLLINE
NOFALL:
        RET
FALLLINE:
        CALL    XY
        DEC     DI
        MOV     AL,[DI]
        INC     DI
        MOV     [DI],AL
        SUB     BL,1
        JNZ     FALLLINE
        CALL    XY
        MOV     BYTE PTR [DI],0
        RET

;**************************************
;SCORE ¿Þ³ÌÞÝ ¹²»Ý
;**************************************

SCOREADD:
        MOV     AL,LEVEL                ;(LEVEL+1)*RENSA
        INC     AL
        MUL     BYTE PTR RENSA
        MOV     DI,OFFSET SCOREP
        ADD     DI,2
        ADD     SCOREP,AX
        ADC     WORD PTR [DI],0
        RET

;**************************************
;ÜØ»ÞÝ (16ËÞ¯Ä)
;**************************************

WARI:                                   ;DX/BX=DX...CX
        PUSH    AX
        XOR     CX,CX
        MOV     AL,16
WARLP1:
        ADD     DX,DX
        XCHG    CX,DX
        ADC     DX,DX
        SBB     DX,BX
        JC      WARSK1
        INC     CX
        JMP     WARSK2
WARSK1:
        ADD     DX,BX
WARSK2:
        XCHG    CX,DX
        SUB     AL,1
        JNZ     WARLP1
        POP     AX
        RET

;**************************************
;SCReen PUT
;**************************************

SCRPUT:
        XOR     BX,BX
SCREEN:                                 ;¶¿³VRAM Ë®³¼Þ
        CALL    XY
        MOV     DL,[DI]
        CALL    PRINT
        INC     BL
        CMP     BL,16
        JNE     SCREEN
        XOR     BL,BL
        INC     BH
        CMP     BH,4
        JNE     SCREEN
        RET

;**************************************
;NEXT Ë®³¼Þ
;**************************************

NEXT:                                   ;Â·ÞÉ ÌÞÛ¯¸
        XOR     DX,DX
        MOV     DL,LEVEL                ;WT=-(LEVEL\5)+24 É ²Á¼Þ ¶Ý½³ ÓÄÞ·
        MOV     BX,0005H
        CALL    WARI
        NEG     DL
        ADD     DL,24
        MOV     WT,DL
        MOV     AL,NX
        MOV     BR,AL
        CALL    RND
        AND     DL,03H                  ;DL=FROM 0 TO 3
        INC     DL
        MOV     DH,FB
        INC     BYTE PTR BALL
        CMP     BYTE PTR BALL,DH
        JNE     NXPUT
        MOV     BYTE PTR BALL,0
        MOV     DL,5
NXPUT:                                  ;NEXT Ë®³¼Þ
        MOV     NX,DL
        MOV     BX,011BH
        CALL    PRINT
        MOV     BYTE PTR X,0
        MOV     BYTE PTR Y,1
        MOV     AL,WT
        MOV     W,AL
        RET

;**************************************
;¶× Ù-Ìß CX TIMES
;**************************************

WAITS:                                  ;³´²Ä
        LOOP    WAITS
        RET

;**************************************
;RANDOM
;**************************************

RND:                                    ;DX=RND
        PUSH    AX
        PUSH    BX
        PUSH    CX
RNDDT:
        MOV     AX,02DBH
        MOV     BX,0383H
        XOR     CX,CX
        MOV     DL,10
RNDLP:
        ADD     CX,CX
        SAL     AH,1
        RCL     AL,1
        JC      RNDSK
        ADD     CX,BX
RNDSK:
        DEC     DL
        JNZ     RNDLP
        XCHG    BX,CX
        MOV     DI,OFFSET RNDDT
        INC     DI
        MOV     [DI],BX                 ;¼Þº ¶·¶´
        MOV     DL,BH
        POP     CX
        POP     BX
        POP     AX
        RET

;**************************************
;CLS
;**************************************

CLS:
        PUSH    BX
        PUSH    DX
        XOR     BX,BX
CLS_LP:
        MOV     DL,32                   ;½Íß-½ ÚÝ¿Þ¸ Ë®³¼Þ
        CALL    MJ_ONE
        INC     BL
        CMP     BL,32
        JNE     CLS_LP
        XOR     BL,BL
        INC     BH
        CMP     BH,4
        JNE     CLS_LP
        POP     DX
        POP     BX
        RET

;**************************************
;Ó¼ÞÚÂ PRINT (END OF STRING=0)
;**************************************

MOJIPUT:
        MOV     DL,[DI]
        CMP     DL,0
        JE      MJ_END
        INC     DI
        CALL    MJ_ONE
        INC     BL
        CMP     BL,32
        JNE     MOJIPUT
MJ_END:
        RET
MJ_ONE:                                 ;²ÁÓ¼Þ Ë®³¼Þ
        SUB     DL,32
        PUSH    AX
        PUSH    DI
        PUSH    DX
        XOR     DH,DH
        SHL     DX,1
        SHL     DX,1
        SHL     DX,1
        MOV     SI,OFFSET FONT
        ADD     DX,SI
        MOV     SI,DX
        MOV     AX,SEG FONT
        MOV     DS,AX                   ;DS:[SI]=LOAD
        CALL    LCDC
        XOR     AX,AX
        MOV     DS,AX
        POP     DX
        POP     DI
        POP     AX
        RET
PRINT:
        ;±ÄÞÚ½(OFFSET)¹²»Ý
        PUSH    DX
        XOR     DH,DH
        SHL     DX,1                    ;*2
        SHL     DX,1                    ;*4
        SHL     DX,1                    ;*8
        MOV     SI,OFFSET CHR0
        ADD     SI,DX
        POP     DX
        CALL    LCDC
        RET

;**************************************
;Ë®³¼Þ Ò²Ý
;**************************************

LCDC:                                   ;SI=OFFSET DATA,BL=X,BH=Y
        MOV     AX,0A000H
        MOV     ES,AX
        XOR     DI,DI
        MOV     AL,21H                  ;X»ÞË®³
        STOSB
        MOV     AL,BL
        AND     AL,0FH
        ADD     AL,6
        STOSB
        MOV     AL,22H                  ;Y»ÞË®³
        STOSB
        MOV     AL,BH
        DB      0C0H,0E0H,003H          ;SHL AL,3
        TEST    BL,10H
        JE      OK
        ADD     AL,20H                  ;X>15 É Ä·
OK:
        STOSB
        MOV     AL,20H
        STOSB
        MOV     AH,8                    ;ÀÃ 8¶² LOOP
P_LP:
        LODSB
        CMP     BYTE PTR REV,0
        JZ      P_1
        NOT     AL                      ;ÊÝÃÝ Ë®³¼Þ
P_1:
        STOSB
        SUB     DI,1
        DEC     AH
        JNZ     P_LP

        XOR     AX,AX
        MOV     ES,AX
        RET

SEN:
        PUSH    BX
        PUSH    CX
        CMP     BL,CL
        JE      SEN_E
        JC      SEN_1
        XCHG    BL,CL
SEN_1:
        CMP     BH,CH
        JE      SEN_E
        JC      SEN_2
        XCHG    BH,CH
SEN_2:
        CMP     DL,3
        JAE     BOX_FS
        INC     BH
        DEC     CH
        CMP     BH,CH
        JA      SEN_3
        CALL    TATE
        XCHG    BL,CL
        CALL    TATE
        XCHG    BL,CL
SEN_3:
        DEC     BH
        INC     CH
BOX_FS:
        CALL    YOKO
        CMP     DL,3
        JC      NOT_FL
FULL:
        CMP     BH,CH
        JE      SEN_E
        INC     BH
        JMP     BOX_FS
NOT_FL:
        CMP     BH,CH
        JE      SEN_E
        MOV     BH,CH
        JMP     BOX_FS
SEN_E:
        POP     CX
        POP     BX
        RET

TATE:
        PUSH    BX
TATE_1:

TEN:
        PUSHA
        PUSH    ES
        MOV     AX,0A000H
        MOV     ES,AX
        XOR     DI,DI
        CALL    LCDC_Z
        MOV     AL,21H
        STOSB
        MOV     AL,BL
        STOSB
        MOV     AL,22H
        STOSB
        MOV     AL,BH
        STOSB
        MOV     AL,20H
        STOSB
        MOV     AH,ES:[DI]
        MOV     AL,20H                  ;NOT NEED!
        SHR     AL,CL
        CMP     DL,1
        JE      DOT_R
        JA      DOT_X
;DOT_S
        MOV     AH,ES:[DI]
        OR      AH,AL
        JNC     TEN_2
DOT_R:
        MOV     AH,ES:[DI]
        NOT     AL
        AND     AH,AL
        JNC     TEN_2
DOT_X:
        MOV     AH,ES:[DI]
        XOR     AH,AL
TEN_2:
        DEC     DI
        MOV     AL,21H
        STOSB
        MOV     AL,BL
        STOSB
        MOV     AL,22H
        STOSB
        MOV     AL,BH
        STOSB
        MOV     AL,20H
        STOSB
        MOV     AL,AH
        STOSB
        POP     ES
        POPA
        CMP     BH,CH
        JE      TATE_E
        INC     BH
        JMP     TATE_1
TATE_E:
        POP     BX
        RET

YOKO:
        PUSHA
        PUSH    ES
        MOV     AX,0A000H
        MOV     ES,AX
        XOR     DI,DI
BOX_LP:
        PUSH    BX
        PUSH    CX
LINE_FS:
        MOV     DH,03FH
        MOV     AH,BL
        MOV     AL,6
        CALL    WARI8
        NEG     AH
        MOV     CH,AH
        PUSH    CX
        MOV     CL,AL
        SHR     DH,CL
        POP     CX
        MOV     AH,CL
        MOV     AL,6
        CALL    WARI8
        MOV     CL,AL
        ADD     CH,AH
        AND     CH,CH
        JNZ     LINE_RD
        INC     CH
        JMP     LINE_RT2
LINE_MD:
        MOV     DH,03FH
LINE_LP:
        SUB     CH,1
        JNC     LINE_RD
        JMP     LINE_END
LINE_RD:
        PUSH    BX
        PUSH    CX
        CALL    LCDC_Z
        POP     CX
        MOV     AL,21H
        STOSB
        MOV     AL,BL
        STOSB
        MOV     AL,22H
        STOSB
        MOV     AL,BH
        STOSB
        MOV     AL,20H
        STOSB
        MOV     AH,ES:[DI]
        NOP
        CMP     DL,1
        JC      LINE_S
        JE      LINE_R
        CMP     DL,3
        JC      LINE_X
        JE      LINE_S
        CMP     DL,5
        JC      LINE_R
        JE      LINE_X
LINE_S:
        MOV     AH,ES:[DI]
        OR      DH,AH
        JNC     LINE_WT
LINE_R:
        MOV     AH,ES:[DI]
        NOT     DH
        AND     DH,AH
        JNC     LINE_WT
LINE_X:
        MOV     AH,ES:[DI]
        XOR     DH,AH
LINE_WT:
        DEC     DI
        MOV     AL,21H
        STOSB
        MOV     AL,BL
        STOSB
        MOV     AL,22H
        STOSB
        MOV     AL,BH
        STOSB
        MOV     AL,20H
        STOSB
        MOV     AL,DH
        STOSB
        POP     BX
        ADD     BL,6
        CMP     CH,1
        JNE     LINE_MD
LINE_RT:
        MOV     DH,03FH
LINE_RT2:
        NEG     CL
        ADD     CL,5
        SHR     DH,CL
        SHL     DH,CL
        JMP     LINE_LP
LINE_END:
        POP     CX
        POP     BX

LINE_RET:
        POP     ES
        POPA
        RET

WARI8:                                  ;AH/AL=AH...AL
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

LCDC_Z:                                 ;IN BX,OUT BX,CL
        CMP     BL,96
        JC      LCDC_Z_1
        ADD     BH,32
LCDC_Z_1:
        MOV     AH,BL
        MOV     AL,6
        CALL    WARI8
        MOV     CL,AL
        AND     AH,0FH
        ADD     AH,6
        MOV     BL,AH
        RET

;**************************************
;DI=M(X,Y) ¶¿³ Ê²ÚÂÍÝ½³
;**************************************

XY:
        PUSH    AX
        PUSH    BX
        DB      0C0H,0E7H,004H          ;SHL BH,4
        ADD     BL,BH
        XOR     BH,BH
        MOV     DI,BX
        MOV     AX,OFFSET VRAM
        ADD     DI,AX                   ;+OFFSET VRAM
        POP     BX
        POP     AX
        RET

;**************************************
;PAUSE CHECK
;**************************************

PS_CHK:
        TEST    AL,02H                  ;"P"·-?
        JE      PS_END
PAUSE:
PAUSE_1:
        PUSH    CX
        MOV     BX,0503H
        MOV     CX,1A5CH
        MOV     DL,4
        CALL    SEN
        MOV     DL,0
        CALL    SEN
        POP     CX
PAUSE_2:
        MOV     DI,OFFSET PUS
        MOV     BX,0106H
        CALL    MOJIPUT
        MOV     BX,0201H
        MOV     DI,OFFSET PUSH
        CALL    MOJIPUT
PAUSE_3:
        CALL    KEYIN
        TEST    AL,01H
        JE      PAUSE_3
        TEST    AL,02H                  ;µ¼¯ÊßÅ¼ ÎÞ³¼»¸
        JNE     PAUSE_3
        CALL    SCRPUT                  ;¶ÞÒÝ Ì¯·
PS_END:
        RET

;**************************************
;KEY CHECK
;**************************************

CHK:
        DEC     BYTE PTR W
        TEST    AL,10H                  ;"8"·-?
        JNE     UP
        TEST    AL,40H                  ;"2"·-?
        JNE     DOWN
        MOV     BYTE PTR LK,0
        TEST    AL,08H                  ;"6"·-?
        JNE     RIGHT
        RET
RIGHT:                                  ;"6"·-
        MOV     BYTE PTR W,0
        RET
UP:                                     ;"8"·-
        CMP     BYTE PTR LK,0
        JNE     M_NON
        CMP     BYTE PTR Y,0
        JE      M_NON
        MOV     BL,X
        MOV     BH,Y
        DEC     BH
        CALL    XY
        CMP     BYTE PTR [DI],0
        JNE     M_NON
        DEC     BYTE PTR Y
        MOV     BYTE PTR LK,3
        RET
DOWN:                                   ;"2"·-
        CMP     BYTE PTR LK,0
        JNE     M_NON
        CMP     BYTE PTR Y,3
        JE      M_NON
        MOV     BL,X
        MOV     BH,Y
        INC     BH
        CALL    XY
        CMP     BYTE PTR [DI],0
        JNE     M_NON
        INC     BYTE PTR Y
        MOV     BYTE PTR LK,2
        RET
M_NON:                                  ;ÊÝ²¶Þ²
        DEC     BYTE PTR LK
        CMP     BYTE PTR LK,0FFH        ;0FFH=-1
        JNE     M_RET
        MOV     BYTE PTR LK,0
M_RET:
        RET

;**************************************
;ÄÞ³¼Þ ·-Æ­³Ø®¸
;**************************************

KEYIN:                                  ;¹¯¶=AL
        CLI
        PUSH    BX
        PUSH    DX
        MOV     DX,200H
        MOV     AX,1FFFH
        OUT     DX,AX
        XOR     AX,AX
        OUT     DX,AX
        MOV     AX,0001H                ;ÃÞÝ¹ÞÝ & BREAK Áª¯¸
        CALL    KEY
        XOR     AL,AH
        TEST    AL,41H
        JZ      K_1
        MOV     AH,7FH                  ;SWITCH OFF
        INT     41H
K_1:
        XOR     BX,BX
        MOV     AX,0100H                ;"8","2"
        CALL    KEY
        AND     AL,50H
        MOV     BL,AL
        MOV     AX,0200H                ;"6"
        CALL    KEY
        DB      0C1H,0D8H,3             ;SHR AX,3
        AND     AL,08H
        OR      BL,AL
        MOV     AX,0040H                ;"P"
        CALL    KEY
        AND     AL,02H
        OR      BL,AL
        MOV     AX,0080H                ;"RET"
        CALL    KEY
        DB      0C1H,0D8H,9             ;SHR AX,9
        AND     AL,01H
        OR      BL,AL
        MOV     AX,0080H                ;"4"
        CALL    KEY
        AND     AL,20H
        OR      BL,AL
        MOV     AX,0020H
        CALL    KEY
        AND     AL,04H
        OR      BL,AL
        XOR     AX,AX                   ;±Ä¼®Ø
        OUT     46H,AX
        MOV     DX,200H
        MOV     AX,07FFH
        OUT     DX,AX
        CALL    K_WAIT
        MOV     DX,204H
        MOV     AL,03H
        OUT     DX,AL
        DEC     AL
        OUT     DX,AL
        MOV     AX,BX
        POP     DX
        POP     BX
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

;**************************************
;Ó¼Þ DATA
;**************************************

PUSH    DB      ' PUSH RET'
        DB      ' KEY '
        DB      0
NXT     DB      'NEXT  (   )'
        DB      0
SCR     DB      'SCORE '
        DB      '00000000'
        DB      0
BLOCKS  DB      'BLOCK '
        DB      '    0000'
        DB      0
LEVELS  DB      'LEVEL '
        DB      '      00'
        DB      0
PUS     DB      'PAUSE'
        DB      0
ABCP    DB      '1996 ABCP '
        DB      'SOFTWARE'
        DB      0
OVER    DB      'GAME  OVER'
        DB      0
OPT     DB      'OPTION '
        DB      'MODE'
        DB      0
GAME_M  DB      'GAME MODE'
        DB      0
BALLL   DB      'BALL'
        DB      0
READY   DB      'READY'
        DB      0
        DB      ' SET '
        DB      0
        DB      ' GO! '
        DB      0

;**************************************
;FONT DATA
;**************************************

FONT    DB      00H,00H,00H,00H;SPC
        DB      00H,00H,00H,00H
        DB      0CH,0CH,0CH,0CH         ;!
        DB      0CH,00H,0CH,0CH
        DB      00H,00H,00H,00H
        DB      00H,00H,00H,00H
        DB      00H,00H,00H,00H
        DB      00H,00H,00H,00H
        DB      00H,00H,00H,00H
        DB      00H,00H,00H,00H
        DB      00H,00H,00H,00H
        DB      00H,00H,00H,00H
        DB      00H,00H,00H,00H
        DB      00H,00H,00H,00H
        DB      00H,00H,00H,00H
        DB      00H,00H,00H,00H
        DB      00H,3EH,20H,20H         ;(
        DB      20H,20H,3EH,00H
        DB      00H,1FH,01H,01H         ;)
        DB      01H,01H,1FH,00H
        DB      00H,00H,00H,00H
        DB      00H,00H,00H,00H
        DB      0CH,0CH,0CH,3FH         ;+
        DB      3FH,0CH,0CH,0CH
        DB      00H,00H,00H,00H
        DB      00H,00H,00H,00H
        DB      00H,00H,00H,00H
        DB      00H,00H,00H,00H
        DB      00H,00H,00H,00H
        DB      00H,00H,00H,00H
        DB      00H,00H,00H,00H
        DB      00H,00H,00H,00H
        DB      1EH,33H,33H,37H         ;0
        DB      3BH,33H,33H,1EH
        DB      0CH,1CH,0CH,0CH         ;1
        DB      0CH,0CH,0CH,1EH
        DB      1EH,33H,03H,06H         ;2
        DB      0CH,18H,33H,3FH
        DB      1EH,33H,03H,0EH         ;3
        DB      03H,03H,33H,1EH
        DB      06H,0EH,0EH,16H         ;4
        DB      16H,36H,3FH,06H
        DB      3FH,30H,30H,3EH         ;5
        DB      03H,03H,33H,1EH
        DB      1EH,33H,30H,3EH         ;6
        DB      33H,33H,33H,1EH
        DB      3FH,33H,03H,03H         ;7
        DB      06H,06H,0CH,0CH
        DB      1EH,33H,33H,1EH         ;8
        DB      33H,33H,33H,1EH
        DB      1EH,33H,33H,33H         ;9
        DB      1FH,03H,33H,1EH
        DB      00H,00H,00H,00H
        DB      00H,00H,00H,00H
        DB      00H,00H,00H,00H
        DB      00H,00H,00H,00H
        DB      2FH,2FH,00H,3DH         ;¶ÍÞ
        DB      3DH,3DH,00H,2FH
        DB      10H,18H,1CH,1EH         ;->
        DB      1EH,1CH,18H,10H
        DB      00H,00H,00H,00H
        DB      00H,00H,00H,00H
        DB      00H,00H,00H,00H
        DB      00H,00H,00H,00H
        DB      00H,00H,00H,00H
        DB      00H,00H,00H,00H
        DB      1CH,22H,22H,3EH         ;A
        DB      22H,22H,22H,22H
        DB      3CH,22H,22H,3CH         ;B
        DB      22H,22H,22H,3CH
        DB      1CH,22H,22H,20H         ;C
        DB      20H,22H,22H,1CH
        DB      3CH,22H,22H,22H         ;D
        DB      22H,22H,22H,3CH
        DB      3EH,20H,20H,3CH         ;E
        DB      20H,20H,20H,3EH
        DB      3EH,20H,20H,3CH         ;F
        DB      20H,20H,20H,20H
        DB      1EH,20H,20H,26H         ;G
        DB      22H,22H,22H,1CH
        DB      22H,22H,22H,3EH         ;H
        DB      22H,22H,22H,22H
        DB      08H,08H,08H,08H         ;I
        DB      08H,08H,08H,08H
        DB      04H,04H,04H,04H         ;J
        DB      04H,04H,24H,18H
        DB      22H,24H,28H,30H         ;K
        DB      28H,24H,22H,22H
        DB      20H,20H,20H,20H         ;L
        DB      20H,20H,20H,3EH
        DB      22H,36H,2AH,2AH         ;M
        DB      22H,22H,22H,22H
        DB      22H,22H,32H,2AH         ;N
        DB      26H,22H,22H,22H
        DB      1CH,22H,22H,22H         ;O
        DB      22H,22H,22H,1CH
        DB      3CH,22H,22H,3CH         ;P
        DB      20H,20H,20H,20H
        DB      1CH,22H,22H,22H         ;Q
        DB      22H,2AH,24H,1AH
        DB      3CH,22H,22H,3CH         ;R
        DB      30H,28H,24H,22H
        DB      1EH,20H,20H,1CH         ;S
        DB      02H,02H,02H,3CH
        DB      3EH,08H,08H,08H         ;T
        DB      08H,08H,08H,08H
        DB      22H,22H,22H,22H         ;U
        DB      22H,22H,22H,1CH
        DB      22H,22H,22H,22H         ;V
        DB      22H,22H,14H,08H
        DB      22H,2AH,2AH,2AH         ;W
        DB      2AH,2AH,2AH,14H
        DB      22H,22H,14H,08H         ;X
        DB      14H,22H,22H,22H
        DB      22H,22H,14H,14H         ;Y
        DB      08H,08H,08H,08H
        DB      3EH,02H,04H,08H         ;Z
        DB      10H,20H,20H,3EH

;**************************************
;TITLE DATA
;**************************************

TITLE   DB      20H,20H,30H,30H
        DB      28H,28H,24H,24H
        DB      22H,22H,21H,20H
        DB      20H,20H,20H,20H
        DB      20H,20H,20H,20H
        DB      20H,20H,20H,20H
        DB      00H,01H,03H,03H
        DB      05H,05H,09H,09H
        DB      11H,11H,21H,01H
        DB      01H,01H,01H,01H
        DB      01H,01H,01H,01H
        DB      01H,01H,01H,01H
        DB      00H,30H,0FH,00H
        DB      00H,00H,00H,00H
        DB      00H,00H,00H,00H
        DB      00H,00H,00H,00H
        DB      00H,00H,00H,00H
        DB      00H,0FH,30H,00H
        DB      00H,00H,3CH,23H
        DB      20H,20H,20H,20H
        DB      20H,20H,20H,20H
        DB      20H,20H,20H,20H
        DB      20H,20H,20H,20H
        DB      23H,3CH,00H,00H
        DB      00H,00H,00H,00H
        DB      3FH,20H,20H,20H
        DB      20H,20H,20H,20H
        DB      20H,3FH,2CH,23H
        DB      20H,20H,20H,20H
        DB      00H,00H,00H,00H
        DB      00H,00H,00H,00H
        DB      3EH,01H,01H,01H
        DB      01H,01H,01H,01H
        DB      01H,3EH,00H,00H
        DB      30H,0CH,03H,00H
        DB      00H,00H,00H,00H
        DB      00H,00H,00H,00H
        DB      00H,00H,3FH,20H
        DB      20H,20H,20H,20H
        DB      3FH,23H,20H,20H
        DB      20H,20H,00H,00H
        DB      00H,00H,00H,00H
        DB      00H,00H,00H,00H
        DB      00H,00H,3EH,01H
        DB      01H,01H,01H,01H
        DB      3EH,00H,30H,0CH
        DB      03H,00H,00H,00H
        DB      00H,00H,00H,00H
        DB      00H,00H,00H,00H
        DB      00H,00H,1FH,20H
        DB      20H,20H,20H,20H
        DB      20H,20H,20H,20H
        DB      1FH,00H,00H,00H
        DB      00H,00H,00H,00H
        DB      00H,00H,00H,00H
        DB      00H,00H,3EH,01H
        DB      01H,01H,01H,01H
        DB      01H,01H,01H,01H
        DB      3EH,00H,00H,00H
        DB      00H,00H,00H,00H
        DB      00H,00H,00H,00H
        DB      1FH,20H,20H,20H
        DB      20H,20H,20H,20H
        DB      20H,3FH,2CH,23H
        DB      20H,20H,20H,00H
        DB      00H,00H,00H,00H
        DB      00H,00H,00H,00H
        DB      3EH,01H,01H,01H
        DB      01H,01H,01H,01H
        DB      01H,3EH,00H,00H
        DB      30H,08H,06H,01H
        DB      00H,00H,00H,00H
        DB      00H,00H,0FH,31H
        DB      01H,01H,01H,01H
        DB      01H,01H,01H,01H
        DB      01H,01H,01H,01H
        DB      01H,01H,01H,01H
        DB      31H,0FH,00H,00H
        DB      00H,03H,3CH,00H
        DB      00H,00H,00H,00H
        DB      00H,00H,00H,00H
        DB      00H,00H,00H,00H
        DB      00H,00H,00H,00H
        DB      00H,3CH,03H,00H
        DB      1FH,20H,20H,20H
        DB      20H,20H,20H,20H
        DB      20H,20H,20H,20H
        DB      1FH,00H,00H,00H
        DB      00H,00H,00H,00H
        DB      00H,00H,00H,3FH
        DB      3FH,00H,00H,00H
        DB      00H,00H,00H,00H
        DB      00H,00H,00H,00H
        DB      3EH,01H,01H,01H
        DB      01H,01H,01H,01H
        DB      01H,01H,01H,3EH

;**************************************
;BLOCK DATA
;**************************************

CHR0    DB      00H,00H,00H,00H
        DB      00H,00H,00H,00H
CHR1    DB      3FH,2BH,35H,2BH
        DB      35H,2BH,35H,3FH
CHR2    DB      3FH,21H,21H,21H
        DB      21H,21H,21H,3FH
CHR3    DB      01H,03H,06H,0CH
        DB      18H,30H,20H,00H
CHR4    DB      20H,30H,18H,0CH
        DB      06H,03H,01H,00H
CHR5    DB      00H,1CH,22H,22H
        DB      22H,1CH,00H,00H
CHR6    DB      00H,00H,00H,0CH
        DB      0CH,00H,00H,00H
CHR7    DB      00H,00H,0CH,12H
        DB      12H,0CH,00H,00H
CHR8    DB      00H,0CH,12H,21H
        DB      21H,12H,0CH,00H
CHR9    DB      00H,1EH,21H,21H
        DB      21H,21H,1EH,00H
CHR10   DB      1EH,21H,21H,21H
        DB      21H,21H,21H,1EH
CHR11   DB      00H,00H,00H,00H
        DB      00H,00H,00H,00H
FB      DB      10
GAME    DB      0

;**************************************
;WORK AREA
;**************************************

X       DB      1   DUP(?)
Y       DB      1   DUP(?)
W       DB      1   DUP(?)
LK      DB      1   DUP(?)
NX      DB      1   DUP(?)
BR      DB      1   DUP(?)
WT      DB      1   DUP(?)
REV     DB      1   DUP(?)
BALL    DB      1   DUP(?)
XADD    DB      1   DUP(?)
YADD    DB      1   DUP(?)
SCORE   DW      2   DUP(?)
SCOREP  DW      2   DUP(?)
RENSA   DB      1   DUP(?)
LEVEL   DB      1   DUP(?)
BLOCK   DW      1   DUP(?)
VRAM    DB      64  DUP(?)
EOP:                                    ;END OF PROGRAM
        END
