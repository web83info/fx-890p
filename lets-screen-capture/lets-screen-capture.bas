100 CLS:CLEAR:L=1000:FOR I=&H2000 TO &H22E5 STEP 8
110 READ A$:C=0:LOCATE 0,0:PRINT "LINE:";STR$(L)
120 FOR J=0 TO 7
130 P$=MID$(A$,J*2+1,2):IF P$="##" THEN 150
140 P=VAL("&H"+P$):POKE I+J,P:C=C+P*(J+1)
150 NEXT:READ A$:IF VAL("&H"+A$)-(C AND 255) THEN PRINT "ERROR IN ";L:END
160 L=L+10:NEXT
170 PRINT "COMPLETED END!":END
1000 DATA FCFAE800005D81ED,C5
1010 DATA 052026AC3C2C7560,CE
1020 DATA 26AC8AD080FA3072,98
1030 DATA 1C80FA39771780EA,9B
1040 DATA 26B460CD41B440CD,87
1050 DATA 41B465CD410BDB75,38
1060 DATA 040BC9740CB420BF,91
1070 DATA 9A2203FDCD41E921,C9
1080 DATA 00B461B93E03CD41,5A
1090 DATA BEA82203F5B93E00,51
1100 DATA F3A432C0B90003F3,1B
1110 DATA AAB420BF912203FD,0C
1120 DATA CD418BEC83C5068B,4F
1130 DATA 76004646897600CF,49
1140 DATA 33DB33C98EC38EDB,B8
1150 DATA B330B8BE2003C539,10
1160 DATA 077505394F027420,A7
1170 DATA 8BF3BFEA2103FDB1,80
1180 DATA 02F3A5B8BE2003C5,6A
1190 DATA 8907894F02B420BF,88
1200 DATA 372203FDCD41FBCF,54
1210 DATA BEEA2103F58BFBB1,71
1220 DATA 02F3A5B420BF6722,A2
1230 DATA 03FDCD41FBCF6006,F9
1240 DATA 1EE800005D81EDC4,60
1250 DATA 20FC33C08ED88EC0,69
1260 DATA BA0002B80001EF50,AF
1270 DATA 58B202EDA8027503,15
1280 DATA E90301B200B80008,4A
1290 DATA EF5058B202EDF6C4,D1
1300 DATA 087503E9F000E8F5,4F
1310 DATA 0081F9FFFF74F7BB,35
1320 DATA 961AC1E10203D98B,F4
1330 DATA D3C537BFA82203FD,0F
1340 DATA B93E00F3A67403E9,54
1350 DATA C600561E8BF28ED9,4D
1360 DATA 8B1C8B4402C1E30C,99
1370 DATA B90C00D1E8D1DBE2,90
1380 DATA FA8BC88BD38B5C04,99
1390 DATA 8B4406C1E30CB50C,33
1400 DATA D1E8D1DBFECD75F8,37
1410 DATA 32ED1F5E2BDA1BC1,99
1420 DATA 0BC0750681FB3F03,3A
1430 DATA 7403E98300B800A0,91
1440 DATA 8EC033FFB021AA26,AF
1450 DATA 8A055047B022AA26,B2
1460 DATA 8A055047B023AA26,B8
1470 DATA 8A055047B023AAB0,08
1480 DATA B5AAB21FB021AAB0,F7
1490 DATA 04AAB022AA8AC2AA,1C
1500 DATA B020AA268A25535B,33
1510 DATA 535B268A25535B53,63
1520 DATA 5BB90C00268A0553,A6
1530 DATA 5B535BC1E004F6D4,E8
1540 DATA 8824468AE0C0EC04,3E
1550 DATA E2EA4780C22080FA,65
1560 DATA 4072C180EA4173BC,84
1570 DATA B023AA5A8AC2AAB0,C0
1580 DATA 22AA5A8AC2AAB021,4A
1590 DATA AA5A8AC2AAB020AA,A6
1600 DATA E80B004175FA1F07,38
1610 DATA 61EA0000000033C0,9A
1620 DATA 8ED8B90A00BE0F22,7E
1630 DATA 03F5BA0002ADEF50,3C
1640 DATA 58B202ED8BD8AD85,20
1650 DATA D87502E2ED49C300,FC
1660 DATA 0220000001100080,A7
1670 DATA 0010000002400000,AA
1680 DATA 0120008000200000,01
1690 DATA 0180000001400080,86
1700 DATA 004000400000010C,E7
1710 DATA 4C65742773205363,6A
1720 DATA 7265656E20436170,7C
1730 DATA 7475726520627920,83
1740 DATA 414243500D537461,35
1750 DATA 796564206F6E204D,F6
1760 DATA 656D6F72790D000C,5F
1770 DATA 5468616E6B20596F,BD
1780 DATA 7520666F72205573,88
1790 DATA 696E670D52656D6F,19
1800 DATA 7665642066726F6D,07
1810 DATA 204D656D6F72790D,2B
1820 DATA 0053756363656564,C1
1830 DATA 0D0043616E277420,96
1840 DATA 466F726D61740D00,26
1850 DATA 424D3E0300000000,A2
1860 DATA 00003E0000002800,D2
1870 DATA 0000C00000002000,20
1880 DATA 0000010001000000,08
1890 DATA 0000000000000000,00
1900 DATA 0000000000000000,00
1910 DATA 0000000000000000,00
1920 DATA 0000FFFFFF00####,F4
