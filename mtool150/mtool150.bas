100 'Machine Language
110 'Writer Maker "MTOOL" V1.50
120 'Presented By ABCP software
130 CLEAR:CLS:DEFSEG=0
140 PRINT "WHICH FILE AREA [F?]"+CHR$(29)+CHR$(29);
150 C$=INPUT$(1):IF C$<"0" OR C$>"9" THEN 150
160 PRINT C$
170 RESTORE#("F"+C$):C$=CHR$(34)
180 INPUT "START";S$:S=VAL("&H"+S$)
190 INPUT "END";E$:E=VAL("&H"+E$)
200 IF S>E THEN 180
210 PRINT USING "START @ / END @";HEX$(S);HEX$(E)
220 PRINT "HIT ANY KEY TO START.":I$=INPUT$(1)
230 WRITE# "100 CLS:CLEAR:L=1000:FOR I=&H"+HEX$(S)+" TO &H"+HEX$(E)+" STEP 8"
240 WRITE# "110 READ A$:C=0:LOCATE 0,0:PRINT "+C$+"LINE:"+C$+";STR$(L)"
250 WRITE# "120 FOR J=0 TO 7"
260 WRITE# "130 P$=MID$(A$,J*2+1,2):IF P$="+C$+"##"+C$+" THEN 150"
270 WRITE# "140 P=VAL("+C$+"&H"+C$+"+P$):POKE I+J,P:C=C+P*(J+1)"
280 WRITE# "150 NEXT:READ A$:IF VAL("+C$+"&H"+C$+"+A$)-(C AND 255) THEN PRINT "+C$+"ERROR IN "+C$+";L:END"
290 WRITE# "160 L=L+10:NEXT"
300 WRITE# "170 PRINT "+C$+"COMPLETED END!"+C$+":END"
310 A=1000
320 FOR I=S TO E STEP 8:C=0:B$=""
330 FOR J=0 TO 7
340 IF I+J<=E THEN P=PEEK(I+J):C=C+P*(J+1):B$=B$+RIGHT$(HEX$(P),2) ELSE B$=B$+"##"
350 NEXT
360 WRITE# RIGHT$(STR$(A),LEN(STR$(A)-1)+" DATA "+B$+","+RIGHT$(HEX$(C),2)
370 PRINT USING "Working @ to @ / @"+CHR$(30);HEX$(I);HEX$(I+7);HEX$(E)
380 A=A+10:NEXT:PRINT