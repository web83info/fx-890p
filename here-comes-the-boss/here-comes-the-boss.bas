90 'Here comes the Boss Installer
100 CLS:CLEAR:L=1000:FOR I=&H2000 TO &H22B1 STEP 8
110 READ A$:C=0:LOCATE 0,0:PRINT "LINE:";STR$(L)
120 FOR J=0 TO 7
130 P$=MID$(A$,J*2+1,2):IF P$="##" THEN 150
140 P=VAL("&H"+P$):POKE I+J,P:C=C+P*(J+1)
150 NEXT:READ A$:IF VAL("&H"+A$)-(C AND 255) THEN PRINT "ERROR IN ";L:END
160 L=L+10:NEXT
170 PRINT "COMPLETED END!":END
1000 DATA FCFAE800005D81ED,C5
1010 DATA 052033DB33C98EC3,F9
1020 DATA 8EDBB330B8662003,11
1030 DATA C539077505394F02,C8
1040 DATA 742E8BF3BF642103,4F
1050 DATA FDB102F3A5B86620,84
1060 DATA 03C58907894F02B4,79
1070 DATA 3ACD41BEB22203F5,92
1080 DATA 893C8C4402B420BF,CF
1090 DATA 592203FDCD41FBCF,76
1100 DATA BE642103F58BFBB1,65
1110 DATA 02F3A5B420BF8822,89
1120 DATA 03FDCD41FBCF061E,43
1130 DATA 60E8FC007503E9EF,56
1140 DATA 00B800A08EC033FF,93
1150 DATA BEB62203F5B021AA,BC
1160 DATA 268A055047B022AA,4A
1170 DATA 268A055047B023AA,51
1180 DATA 268A055047B023AA,51
1190 DATA B0B5AAB200B021AA,37
1200 DATA B004AAB022AA8AC2,F2
1210 DATA AAB020AA268A0553,C7
1220 DATA 5B535BB90D00268A,91
1230 DATA 05535B535B880446,4B
1240 DATA E2F44780C22080FA,79
1250 DATA 4072D280EA3F80FA,F6
1260 DATA 2075CAB023AAB075,4B
1270 DATA AA33C08ED8BFD921,31
1280 DATA 32FF32DB8A15E8A3,D2
1290 DATA 0047FEC380FB2075,7E
1300 DATA F3FEC780FF0475EA,DA
1310 DATA E86D0075FBE86800,C5
1320 DATA 74FBE8630075FBB8,09
1330 DATA 00A08EC033FF8EDF,BD
1340 DATA BEB62203F5B023AA,CA
1350 DATA B0B5AAB200B021AA,37
1360 DATA B004AAB022AA8AC2,F2
1370 DATA AAB020AAB90D00A4,1D
1380 DATA 535B535B47E2F847,1D
1390 DATA 80C22080FA4072DD,CC
1400 DATA 80EA3F80FA2075D5,8E
1410 DATA B023AA5A8AC2AAB0,C0
1420 DATA 22AA5A8AC2AAB021,4A
1430 DATA AA5A8AC2AAB020AA,A6
1440 DATA 611F07EA00000000,5C
1450 DATA 33C08EC0BA0002B8,CD
1460 DATA 1000EF5058B202ED,77
1470 DATA A8807501C3B200B8,C6
1480 DATA 0008EF5058B202ED,77
1490 DATA F6C408C31E066080,FC
1500 DATA EA2032F6C1E2038B,16
1510 DATA 36B2228E1EB42203,0C
1520 DATA F2B800A08EC033FF,85
1530 DATA B021AA8AC3240F04,48
1540 DATA 06AAB022AA8AC7C0,F1
1550 DATA E003F6C31074020C,4A
1560 DATA 20AAB020AAB408A4,E6
1570 DATA 535B535B4FFECC75,29
1580 DATA F64FB020AA61071F,E5
1590 DATA C320202020202020,23
1600 DATA 20202020203C204D,90
1610 DATA 454E55203E202020,36
1620 DATA 2020202020202020,80
1630 DATA 2020202020202020,80
1640 DATA 2020202020202020,80
1650 DATA 2020202020202020,80
1660 DATA 2020202020202020,80
1670 DATA 20313A462E434F4D,51
1680 DATA 20323A4241534943,88
1690 DATA 20333A4320202020,80
1700 DATA 20343A4341534C20,8D
1710 DATA 20353A41534D424C,D7
1720 DATA 20363A4658202020,AA
1730 DATA 20373A4D4F444520,76
1740 DATA 2020202020202020,80
1750 DATA 200C486572652063,34
1760 DATA 6F6D657320746865,9C
1770 DATA 20426F7373206279,32
1780 DATA 20414243500D5374,37
1790 DATA 61796564206F6E20,4E
1800 DATA 4D656D6F72790D00,85
1810 DATA 0C5468616E6B2059,C0
1820 DATA 6F7520666F722055,B0
1830 DATA 73696E670D52656D,83
1840 DATA 6F7665642066726F,B4
1850 DATA 6D204D656D6F7279,C9
1860 DATA 0D00############,0D
