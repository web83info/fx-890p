90 'BCC INSTALLER BY ABCP
100 CLS:DEFSEG=0:L=1000:FOR I=&H2000 TO &H26DF STEP 8
110 READ A$:C=0:LOCATE 0,0:PRINT "LINE:";STR$(L)
120 FOR J=0 TO 7
130 P=VAL("&H"+MID$(A$,J*2+1,2))
140 POKE I+J,P:C=C+P*(J+1)
150 NEXT
160 READ A$:IF VAL("&H"+A$)-(C AND 255) THEN PRINT "ERROR IN ";L:END
170 L=L+10:NEXT
180 PRINT "COMPLETED END!":END
1000 DATA B410CD41BF6426E8,9C
1010 DATA 640332C0E8900380,FD
1020 DATA FA0D7416B430CD41,0F
1030 DATA 0AF675F0B401CD41,42
1040 DATA 8AC22C30B21DCD41,1D
1050 DATA 73E28AD0B460CD41,7C
1060 DATA B465CD410BC97512,99
1070 DATA BB0702E82B03BFA0,91
1080 DATA 26E82A03E85803E9,75
1090 DATA B6FFC706E4270000,7F
1100 DATA BB0502E81303BFB3,AD
1110 DATA 26E81203B440CD41,DF
1120 DATA 268A158816DE2689,8D
1130 DATA 3EE02647BB0A02E8,BD
1140 DATA F702B446268B1532,52
1150 DATA DBCD4181C70300C6,61
1160 DATA 06DF2600BEE52626,84
1170 DATA 8B154780FA037508,F1
1180 DATA 4747BEE526E97702,28
1190 DATA 80FA02740E81FA04,8C
1200 DATA 80740881FA04A974,BD
1210 DATA 0275128B3EE0268A,1E
1220 DATA 0EDE2632ED03F9BE,76
1230 DATA E526E9520281FA07,52
1240 DATA 47742781FA074874,4C
1250 DATA 2181FA0449741B81,0B
1260 DATA FA044A741581FA04,15
1270 DATA 4B740F81FA044C74,12
1280 DATA 0981FA044D7403E9,9F
1290 DATA E800893EE2264726,EA
1300 DATA 8A1580FA2074F780,35
1310 DATA FA037408B430CD41,C3
1320 DATA 0AF6740B8B3EE226,07
1330 DATA 268B55FFE9C30089,9E
1340 DATA 3EE22632C0BEE526,E3
1350 DATA 268A1547B430CD41,DC
1360 DATA 0AF6750A80EA3088,09
1370 DATA 1446FEC073EA3C06,29
1380 DATA 730A3C04761F807C,B3
1390 DATA FB077219FF06E427,56
1400 DATA BB1302E82302BFCE,EB
1410 DATA 26E82202E85002E8,1A
1420 DATA 3B02E956FF33D2BB,15
1430 DATA 01008AC88AE84E8B,5B
1440 DATA FA32E48A0453E814,30
1450 DATA 025B5233D2B80A00,2A
1460 DATA E80A028BDA5A3BD7,E1
1470 DATA 72C2FEC975E08AC5,8B
1480 DATA 8A26DE262AE080C4,BA
1490 DATA 038ADC7306E8C201,5B
1500 DATA E918FF8B3EE226B9,96
1510 DATA 0300E8D6018AC8E8,0C
1520 DATA D6018B36E0262688,DF
1530 DATA 1C881EDE2626C605,32
1540 DATA 0347268915474726,5B
1550 DATA 803D2C7503E92AFF,F5
1560 DATA 81EF03004F26803D,3F
1570 DATA 2074F9268B55FFBE,29
1580 DATA E52681FA0748754D,0A
1590 DATA 893EE22626807DFE,5C
1600 DATA 01750E26807DFC03,17
1610 DATA 740726807DFA0374,F6
1620 DATA 308A06DE263CFF75,95
1630 DATA 06E85601E9ACFE4F,DB
1640 DATA B90100E86D0126C6,BC
1650 DATA 05018B36E02626FE,BE
1660 DATA 04FEC08806DE2681,C4
1670 DATA C70300BEE526E9EE,F1
1680 DATA 008B3EE22680FA04,0C
1690 DATA 720C80FA07770747,48
1700 DATA BEE526E9D900B434,67
1710 DATA CD41B432CD410AF6,B0
1720 DATA 741A80FA2E741580,41
1730 DATA FA227406BEE526E9,18
1740 DATA BD00F616DF26BEE5,90
1750 DATA 26E9B30088144680,1B
1760 DATA FA2E750D803EDF26,26
1770 DATA 007506C60400E903,9F
1780 DATA 00E99B00893EE226,22
1790 DATA BFE5262BF78BCE8A,AE
1800 DATA 15497503E9810080,A5
1810 DATA EA41D0E232F6BBA4,5F
1820 DATA 2303DA8B37BFE526,E3
1830 DATA C606E42600803C00,BA
1840 DATA 7503E963008A1580,91
1850 DATA FA2E7413803C0074,86
1860 DATA 1E3A147405C606E4,A5
1870 DATA 26014647E9E6FF80,00
1880 DATA 3C00740446E9F7FF,35
1890 DATA 803EE42600740B46,75
1900 DATA 803C0074334646E9,9D
1910 DATA BBFF468B148B3EE2,1F
1920 DATA 262BF94F26891547,62
1930 DATA 4749E88B008B36E0,79
1940 DATA 268A16DE2632F62B,F0
1950 DATA D12688148816DE26,73
1960 DATA BEE5264F4FE97FFD,98
1970 DATA 8B3EE226BEE526B4,03
1980 DATA 1FCD410AD27403E9,D3
1990 DATA 6DFD26803D007403,4E
2000 DATA E93DFDBB1202E840,04
2010 DATA 008B16E4270BD275,53
2020 DATA 07BFB926E83700CF,92
2030 DATA B44632DBCD41BFD7,BA
2040 DATA 26E82A00B4014A74,A4
2050 DATA 04B273CD41B20DCD,29
2060 DATA 41CFFF06E427BB13,07
2070 DATA 02E80D00BFC526E8,9C
2080 DATA 0C00E83A00E82500,1F
2090 DATA C3B40FCD41C3B420,4F
2100 DATA CD41C3B461CD41C3,FA
2110 DATA B462CD41C30BDB74,91
2120 DATA 0BD1EB730203D0D1,8E
2130 DATA E0E9F1FFC3BB1302,47
2140 DATA E8D6FFB220B90800,87
2150 DATA B401CD41E2FCC3B4,68
2160 DATA 03CD41C3D8230224,A4
2170 DATA 1A2455248424A624,07
2180 DATA C824D824E624FD24,89
2190 DATA FE2406252E254525,BB
2200 DATA 6D258025A625A725,A0
2210 DATA E3251A2635263E26,E2
2220 DATA 4A265B2662266326,F2
2230 DATA 414E440007C44142,3B
2240 DATA 5300057B414E474C,B8
2250 DATA 4500046E41435300,25
2260 DATA 056F41544E000570,1F
2270 DATA 415050454E440007,3B
2280 DATA BD00424545500004,F0
2290 DATA 7042534156450004,5D
2300 DATA 56424C4F41440004,F7
2310 DATA A000434852240006,2B
2320 DATA A043414C4C000462,C1
2330 DATA 434C53000471434C,C3
2340 DATA 45415200046A434C,82
2350 DATA 4F53450004724341,61
2360 DATA 4C43240006AD4348,7F
2370 DATA 41494E000469434E,8C
2380 DATA 5400055100444154,A6
2390 DATA 4100048044494D00,72
2400 DATA 047C445241570004,7F
2410 DATA 7D4452430004A244,AD
2420 DATA 534B46000561444D,5E
2430 DATA 53000582444D5324,F1
2440 DATA 00069700454C5345,5F
2450 DATA 000748454E440004,38
2460 DATA 8745524153450004,68
2470 DATA 85454F4600058A45,20
2480 DATA 585000057900464F,CB
2490 DATA 5200048146495800,DE
2500 DATA 057E46494C455300,56
2510 DATA 04B546524500058D,6C
2520 DATA 4652414300057F00,50
2530 DATA 474F544F00044947,6C
2540 DATA 4F53554200044A00,1A
2550 DATA 484558240006A348,43
2560 DATA 59500005AC004946,98
2570 DATA 00048D494E505554,2C
2580 DATA 00069B494E4B4559,F4
2590 DATA 240006A800004B49,2B
2600 DATA 4C4C00048E004C4F,46
2610 DATA 434154450004914C,44
2620 DATA 494E450004904C45,64
2630 DATA 4E0005954C505249,93
2640 DATA 4E540004A44C4546,15
2650 DATA 542400069E004D49,2D
2660 DATA 442400069C4D4552,F1
2670 DATA 474500045A4D4F44,BA
2680 DATA 450004B0004E4558,88
2690 DATA 540004824E435200,BE
2700 DATA 05AB4E50520005AA,92
2710 DATA 4E4F540007C34E4F,37
2720 DATA 524D0007C34E414D,DA
2730 DATA 45000496004F4E00,A5
2740 DATA 049A4F50454E0004,B2
2750 DATA 974F555400049900,CB
2760 DATA 5052494E540004A3,DF
2770 DATA 5045454B00058650,1D
2780 DATA 415353000453504F,8E
2790 DATA 4B45000463504F49,25
2800 DATA 4E5400058F000052,65
2810 DATA 414E230005935245,37
2820 DATA 41440004A8524F55,DE
2830 DATA 4E44000590524947,DD
2840 DATA 48542400069D5245,8E
2850 DATA 5455524E00044B52,E1
2860 DATA 4553544F52450004,7B
2870 DATA 4D524553554D4500,66
2880 DATA 044C005354522400,74
2890 DATA 06A153494E00056B,66
2900 DATA 53515200057A5347,5D
2910 DATA 4E00057C53595354,E7
2920 DATA 454D000452534554,FE
2930 DATA 0004AC53544F5000,06
2940 DATA 04AE535441540004,06
2950 DATA AD00544F0007C154,F6
2960 DATA 414E00056D54494D,71
2970 DATA 45520005A6544845,53
2980 DATA 4E00074700555349,0A
2990 DATA 4E470007C2005641,24
3000 DATA 4C00059656460005,2D
3010 DATA 9200574149540004,20
3020 DATA 5457524954452300,53
3030 DATA 044E00584F520007,AF
3040 DATA C600000042617369,C3
3050 DATA 6320436F6D6D616E,EE
3060 DATA 6420436F6E766572,66
3070 DATA 7465722076657231,66
3080 DATA 2E30316120202020,E5
3090 DATA 2020205768696368,8F
3100 DATA 20502D417265613F,82
3110 DATA 205B50305D1D1D00,D0
3120 DATA 50726F6772616D20,98
3130 DATA 4E6F7420466F756E,A3
3140 DATA 6421004C696E653D,22
3150 DATA 00436F6D706C6574,A2
3160 DATA 6564210D004F5620,F8
3170 DATA 6572726F72004C4E,19
3180 DATA 206572726F720020,DF
3190 DATA 6572726F72000000,95
