100 CLS:CLEAR
110 DEFCHR$(252)="8898BFBF9888"
120 DEFCHR$(253)="808080808080"
130 T$=" [�ݷ�  de  ����]    By ABCP " 
140 POKE 6005,L*32+7:LOCATE 1,1:PRINT T$:LOCATE 15,3:PRINT "[HIT SPACE KEY.]";:L=1-L:WAIT3:ON -(INKEY$<>" ") GOTO140
150 DIM M$(8):A=9:S=0
160 CLS:PRINT T$:FOR L=0 TO 7:M$(L+1)=" ":MODE50,(12*L+3,14)-(12*L+13,24):NEXT
170 LOCATE 20,2:PRINT "Score:    0"
180 LOCATE 3,2:FOR L=1 TO 6:A$=MID$("Ready?",L,1):PRINT A$CHR$(28);:WAIT1:NEXT:FOR L=0 TO 0:L=INKEY$="":NEXT
190 LOCATE 3,2:FOR L=1 TO 6:PRINT " "CHR$(28);:NEXT
200 FOR G=0 TO 0:A=A-1
210 FOR L=A TO 8:M$(L-1)=M$(L):NEXT:M$(8)=RIGHT$(STR$(INT(RAN#*9)+1),1)
220 LOCATE A*2-1,2:FOR L=A TO 8:PRINT M$(L)CHR$(28);:NEXT
230 LOCATE 26,2:PRINT USING "#####";S:F=0:TIMER=0:D=0
240 FOR K=0 TO 0:V=I:I=VAL(INKEY$):I=I+(ABS(I-5)>3)*I:ON -(I=0 OR F=1 OR V=I) GOTO280
250 FOR L=A TO 8:M$(L)=RIGHT$(STR$((VAL(M$(L))+I) MOD 10),1)
260 IF M$(L)="0" THEN LOCATE L*2-1,3:PRINT CHR$(252);:FOR J=L TO A STEP -1:M$(J)=M$(J-1):NEXT:LOCATE A*2-1,2:FOR J=A TO L:PRINT M$(J)CHR$(28);:NEXT:A=A+1:D=D+1
270 LOCATE L*2-1,2:PRINT M$(L)CHR$(29)CHR$(31)CHR$(253);:NEXT:F=F+1
280 K=TIMER<7:NEXT:S=S+(2^D)*D:G=A<>1:NEXT
290 LOCATE 1,2:FOR L=1 TO 8:A$=MID$("GAMEOVER",L,1):PRINT REVA$CHR$(29);:WAIT1:PRINT A$CHR$(28);:WAIT1:NEXT
300 FOR L=0 TO 0:L=INKEY$<>" ":NEXT:GOTO150
