1 'Real INKEY$ Installer
100 CLS:CLEAR:L=1000:FOR I=&H2000 TO &H222F STEP 8
110 READ A$:C=0:LOCATE 0,0:PRINT "LINE:";STR$(L)
120 FOR J=0 TO 7
130 P$=MID$(A$,J*2+1,2):IF P$="##" THEN 150
140 P=VAL("&H"+P$):POKE I+J,P:C=C+P*(J+1)
150 NEXT:READ A$:IF VAL("&H"+A$)-(C AND 255) THEN PRINT "ERROR IN ";L:END
160 L=L+10:NEXT
170 PRINT "COMPLETED END!":END
1000 DATA 6A001FB46BCD4181,4B
1010 DATA 3F80017528817F02,6D
1020 DATA 4BFF75218B47068E,27
1030 DATA C08B7F0426813D00,D2
1040 DATA 01753E26817D025A,8E
1050 DATA 00753626817D04BC,93
1060 DATA 00752E74318B07F6,5C
1070 DATA C4017402FEC48ACC,DE
1080 DATA 32ED81C1060003D9,8E
1090 DATA 33C08EC08BF3B44A,02
1100 DATA CD413B36621A75AF,09
1110 DATA A1641A8CC13BC175,FD
1120 DATA A6EAAF0300F083C7,00
1130 DATA 068BEF26C7050000,82
1140 DATA 4747BA0002B8FF1F,4E
1150 DATA EF33C0EFB95A000E,7A
1160 DATA 1FE800005E83C644,61
1170 DATA 8B0433DBBA0002EF,C0
1180 DATA E82D00B202ED2344,B7
1190 DATA 027407BB01202689,02
1200 DATA 5E0026891D474783,38
1210 DATA C604E2DCBA0002B8,54
1220 DATA FF07EFE80A00BA04,E2
1230 DATA 02B003EEFEC8EECF,C3
1240 DATA 51B90900E2FE59C3,C3
1250 DATA 0008000802002000,1A
1260 DATA 0400800004000001,A0
1270 DATA 0800800008000001,B8
1280 DATA 4000040000020002,68
1290 DATA 0200020080000001,90
1300 DATA 8000020000041000,0E
1310 DATA 8000000200010200,9C
1320 DATA 0004020000040400,42
1330 DATA 4000400020004000,60
1340 DATA 0004080080000400,BC
1350 DATA 0001040000020200,28
1360 DATA 0002040000042000,08
1370 DATA 0004000280000800,C8
1380 DATA 0001080040008000,DA
1390 DATA 2000800040002000,C0
1400 DATA 2000000110008000,F4
1410 DATA 0004400000048000,60
1420 DATA 0100010000000000,04
1430 DATA 0000000000000000,00
1440 DATA 0000000000020800,44
1450 DATA 0002100000028000,C0
1460 DATA 0001000120002000,86
1470 DATA 0001000280008000,0A
1480 DATA 0002000140000001,50
1490 DATA 8000400000014000,06
1500 DATA 0001800080002000,E2
1510 DATA 0001200000024000,2E
1520 DATA 8000100000011000,26
1530 DATA 0002200040001000,14
1540 DATA 4000080000000000,58
1550 DATA 1000000100000000,14
1560 DATA 0000000000000000,00
1570 DATA 0200100008004000,1A
1580 DATA 0400400004001000,48
1590 DATA 0400040008000800,70
1600 DATA 0800100010000800,C0
1610 DATA 2000020010001000,E6
1620 DATA 2000080020001000,48
1630 DATA 1000400010002000,00
1640 DATA 2000040040000200,7A
1650 DATA 0200040008000200,44
1660 DATA 0400080008000400,60
1670 DATA 1000040008002000,24
1680 DATA 0400020004002000,FE
1690 DATA 1000020002004000,E0
