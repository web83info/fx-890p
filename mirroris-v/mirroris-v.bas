100 '**************************
110 'MIRRORIS-V
120 'PROGRAMMED BY ABCP
130 '**************************
140 CLS:DEFSEG=0:LOCATE 10,1:PRINT "ABCP PRESENTS":WAIT 16
150 CLS:RESTORE:FOR L=0 TO 47:READ A$:DEFCHR$(252)=A$:LOCATE 8+L MOD 16,L�_16:PRINT CHR$(252):NEXT L
160 I=0:FOR J=0 TO 0:I=1-I:POKE 6005,32*I+7:LOCATE 8,3:PRINT " PUSH [RET] KEY ";:FOR L=1 TO 10:J=J-(INKEY$=CHR$(13)):NEXT L:J=J+(J=0):NEXT J
170 CLS:CLEAR:DIM M$(3)
180 FOR I=0 TO 3:DEFCHR$(252+I)=MID$("FFABD5ABD5FFFF81818181FF060C183060C0C06030180C06",I*12+1,12):D$=D$+CHR$(252+I):NEXT I
190 FOR J=1 TO 15:M$(0)=M$(0)+" ":NEXT J:FOR J=1 TO 3:M$(J)=M$(J-1):NEXT J
200 D$=D$+CHR$(237):N=INT(RAN#*4+1):P=1
210 MODE 50,(96,0)-(96+6,31):MODE 50,(0,0)-(5,7):MODE 50,(0,16)-(5,31)
220 LOCATE 19,0:PRINT "NEXT: [   ]"
230 LOCATE 18,1:PRINT "BLOCK:      0"
240 LOCATE 18,2:PRINT "LEVEL:      0"
250 LOCATE 18,3:PRINT "SCORE:0000000";
260 FOR G=0 TO 0:X=0:Y=1:T=10-(K�_10):T=T+(T<1)*(T-1):B=N:N=INT(RAN#*4+1):P=P+1:P=P+(P=(18-T)�_2)*P:N=N+(P=0)*(N-5)
270 LOCATE 27,0:PRINT MID$(D$,N,1)
280 FOR F=0 TO 0:LOCATE X,Y:PRINT " "MID$(D$,B,1);:X=X+1:FOR D=0 TO T:Z=0:I=VAL(INKEY$)
290 IF (I=2)*(Y<3) THEN IF MID$(M$(Y+1),X,1)=" " THEN Z=1
300 IF (I=8)*(Y>0) THEN IF MID$(M$(Y-1),X,1)=" " THEN Z=-1
310 IF Z THEN LOCATE X,Y:PRINT " "CHR$(29)CHR$(30-(I=2))MID$(D$,B,1);:Y=Y+Z
320 IF I=6 THEN D=T:T=-T
330 NEXT D:F=-(X<15)*(MID$(M$(Y),X-(X<15),1)=" "):NEXT F
340 IF B=5 THEN GOSUB 400 ELSE M$(Y)=LEFT$(M$(Y),X-1)+MID$(D$,B,1)+RIGHT$(M$(Y),15-X)
350 G=PEEK(1360)=32:NEXT G
360 F=S+5E5:FOR I=4 TO 0 STEP -1:J=F�_26^I:F=F-(26^I)*J:B$=B$+CHR$(65+J+(I MOD 2)*(25-J*2)):NEXT I
370 LOCATE 3,1:PRINT "GAME OVER  ":LOCATE 3,2:PRINT " PASS:"B$
380 MODE 50,(17,7)-(84,24)
390 FOR L=0 TO 0:L=INKEY$<>CHR$(13):NEXT L:GOTO 150
400 U=1:V=0:R=1:C=0:T=ABS T
410 FOR H=0 TO 0:Q=PEEK(1327+X+Y*32)-252
420 LOCATE X,Y:PRINT "o";
430 IF Q+220 THEN M$(Y)=MID$(" ",1,-(Q<>0))+LEFT$(M$(Y),X-1)+MID$(CHR$(253),1,-(Q=0))+RIGHT$(M$(Y),15-X):K=K-(ABS(2-Q)<=1.5):C=C-R*(11-T)*((Q=0)*5+(ABS(2-Q)<=1)*10)
440 R=R-(ABS(2.5-Q)=.5)
450 IF Q=2 THEN IF V=0 THEN V=-U:U=0 ELSE U=-V:V=0
460 IF Q=3 THEN IF V=0 THEN V=U:U=0 ELSE U=V:V=0
470 LOCATE 26,1:PRINT USING "#####";K:LOCATE 27,2:PRINT USING "####";K�_10
480 LOCATE 24,3:PRINT USING "+######";C;
490 LOCATE 1,Y:PRINT M$(Y);
500 X=X+U:Y=Y+V:H=-(ABS(8-X)<=7)*(ABS(1.5-Y)<=1.5):NEXT H
510 S=S+C:S=S+(S>1E7-1)*(S-1E7+1):LOCATE 24,3:PRINT RIGHT$("0000000"+RIGHT$(STR$(S),LEN(STR$(S)-1,7);:RETURN
520 DATA FF300C030000,0000030C307F
530 DATA 404020202020,3F2020201010
540 DATA 0F0808080808,080808080807
550 DATA 030202020202,020202020201
560 DATA 010202020202,020202020201
570 DATA 070808080808,080808080807
580 DATA 10102020203F,202020204040
590 DATA 7F8080808080,808080808080
600 DATA FF000000C020,20C0000000FF
610 DATA 000000000000,FF0000000000
620 DATA FF0406060505,0404040404F8
630 DATA FF0808080C0C,0A0A090908F0
640 DATA FF0000000000,0000000000FF
650 DATA FF0406060505,0404040404F8
660 DATA 0000000000FF,000000000000
670 DATA F00808080808,080808080807
680 DATA FF0000000000,0000000000FE
690 DATA 020204040404,FC0404040808
700 DATA F00000000000,808040402020
710 DATA C00000000000,000000008080
720 DATA 008080808080,808080808000
730 DATA E00000000000,808040202010
740 DATA 0808040404FC,040404040202
750 DATA 010101010101,0101010101FE
