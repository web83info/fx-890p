100 DEFSEG=0:CLS:CLEAR:L=1000:FOR I=&H2000 TO &H2B52 STEP 8
110 READ A$:C=0:LOCATE 0,0:PRINT "LINE:";STR$(L)
120 FOR J=0 TO 7
130 P$=MID$(A$,J*2+1,2):IF P$="##" THEN 150
140 P=VAL("&H"+P$):POKE I+J,P:C=C+P*(J+1)
150 NEXT:READ A$:IF VAL("&H"+A$)-(C AND 255) THEN PRINT "ERROR IN ";L:END
160 L=L+10:NEXT
170 PRINT "COMPLETED END!":END
1000 DATA FC33C08ED88EC0E8,E6
1010 DATA F007B43ACD41BEB2,4B
1020 DATA 3A893C8CC0894402,12
1030 DATA C606A33A14C606A4,F5
1040 DATA 3A0CC706A53A2800,6C
1050 DATA B80105BFE829E8CD,03
1060 DATA 06E8F308B90040E8,6C
1070 DATA CC08E2FBE8BB07B8,49
1080 DATA 0008BFCD29E8B606,E8
1090 DATA B80205BFFF29E8AD,78
1100 DATA 06B8030EBF152AE8,56
1110 DATA A406B8020DB23EE8,3F
1120 DATA 3D06E8C208E89E08,33
1130 DATA 50B88000BB0002E8,35
1140 DATA E7065875358BD8E8,42
1150 DATA ED06D0EE7302B40D,C0
1160 DATA D0EE7302B413D0EE,23
1170 DATA 7302B002D0EE7302,68
1180 DATA B0033BC374CF508B,19
1190 DATA C3B220E8010658B2,48
1200 DATA 3EE8FB05E88008E9,1B
1210 DATA BBFFB9030080FC13,6C
1220 DATA 740380E9013C0374,C0
1230 DATA 0380E90280F90374,D1
1240 DATA 12BE472BC0E10203,3B
1250 DATA F1BFA33AB104F3A4,92
1260 DATA E93001B88000BB00,C9
1270 DATA 02E87D0675F5E819,88
1280 DATA 07C606E2270FB800,52
1290 DATA 0ABF222AE80F06B8,62
1300 DATA 0106BF2E2AE80606,9E
1310 DATA B80206BF432AE8FD,55
1320 DATA 05B80306BF582AE8,C7
1330 DATA F405B80105B23EE8,61
1340 DATA 8D05E8120850B880,A7
1350 DATA 00BB0002E83A0658,4C
1360 DATA 7403E9DE008BD8E8,17
1370 DATA 3D06D0EE73303C03,8C
1380 DATA 74203C02740E803E,78
1390 DATA A33A067421FE0EA3,0C
1400 DATA 3AE91A00803EA43A,9A
1410 DATA 067413FE0EA43AE9,1B
1420 DATA 0C00813EA53A0100,23
1430 DATA 7404FF0EA53AD0EE,66
1440 DATA 733A3C0374203C02,5F
1450 DATA 740E803EA33A1474,BF
1460 DATA 2BFE06A33AE92400,59
1470 DATA 803EA43A31741DFE,38
1480 DATA 06A43AE91600508A,8E
1490 DATA 06A43AFEC8F626A3,C2
1500 DATA 3A3B06A53A587404,D4
1510 DATA FF06A53AD0EE7306,DB
1520 DATA 3C017402FEC8D0EE,68
1530 DATA 73063C037402FEC0,81
1540 DATA 3BC3740E508BC3B2,0C
1550 DATA 20E8E30458B23EE8,7F
1560 DATA DD04508A06A43AFE,79
1570 DATA C8F626A33A3B06A5,88
1580 DATA 3A77048906A53A32,7A
1590 DATA EDB801168A0EA33A,03
1600 DATA E88104B802168A0E,9A
1610 DATA A43AE87704B80316,D5
1620 DATA 8B0EA53AE86D0458,70
1630 DATA E82C07B92003E2FE,09
1640 DATA E912FFE8F40533C0,F1
1650 DATA 8806A73A8806A83A,A5
1660 DATA 8806A93A8806AB3A,C0
1670 DATA C606AC3A018806AD,85
1680 DATA 3AC606E22703BF53,06
1690 DATA 2BB080B9D403F3AA,1A
1700 DATA 8B0EA53A8A06A33A,99
1710 DATA F626A43A2BC18906,62
1720 DATA B03A890EAE3AE8EB,69
1730 DATA 04E2FBB80111BFCD,A5
1740 DATA 29E8AA04B80212BF,21
1750 DATA DD29E8A104E8C706,90
1760 DATA 8A16A93AB500E8A1,82
1770 DATA 058A26A73A8A06A8,EF
1780 DATA 3A0206A93AE83606,30
1790 DATA 8A15B5018A06A83A,15
1800 DATA E8AC05E8E104D0EE,8C
1810 DATA 730B803EA73A0074,40
1820 DATA 04FE0EA73AD0EE73,E2
1830 DATA 108A1EA33AFECB3A,7D
1840 DATA 1EA73A7404FE06A7,54
1850 DATA 3AD0EE7319803EA8,DF
1860 DATA 3A00750E803EA93A,34
1870 DATA 00740BFE0EA93AE9,1B
1880 DATA 0400FE0EA83AD0EE,FA
1890 DATA 731F803EA83A0575,98
1900 DATA 148A3EA43A80EF06,4D
1910 DATA 3A3EA93A740BFE06,41
1920 DATA A93AE90400FE06A8,46
1930 DATA 3AD0EE7207E91D01,D8
1940 DATA 90E9C7018A26A73A,B2
1950 DATA 8A06A83A0206A93A,13
1960 DATA E8AB05F605807503,89
1970 DATA E95001E8A0058A15,D8
1980 DATA F6C2607403E9D8FF,CF
1990 DATA F6C2807503E9D0FF,FB
2000 DATA 80E201881580FA01,AE
2010 DATA 7503E9BD00FF0EB0,06
2020 DATA 3A5057BF272FB9D4,67
2030 DATA 0332C0F3AA5F58C6,97
2040 DATA 06AC3A00B601E882,08
2050 DATA 05B500508A26A73A,A6
2060 DATA 8A06A83AD0E2E8D6,DA
2070 DATA 0458881580FA0074,9C
2080 DATA 03E9830081EF532B,1A
2090 DATA 81C7272FC60501BE,33
2100 DATA FB32B107E89A03B1,4F
2110 DATA 00BF372B5132EDD0,8B
2120 DATA E103F95950022578,95
2130 DATA 4D3A26A33A744702,9A
2140 DATA 450178423A06A43A,49
2150 DATA 743CE81105F60560,E8
2160 DATA 7534F60580742F8B,AC
2170 DATA DF81EB532B81C327,58
2180 DATA 2F803F007520C607,97
2190 DATA 01B601E80D05D0E2,2F
2200 DATA 8815FF0EB03A80FA,03
2210 DATA 00750B8BD858E840,D7
2220 DATA 038BC3E9A1FF58FE,7D
2230 DATA C180F908759BE840,0F
2240 DATA 0381FEFB3275F0E9,7B
2250 DATA 06FF803EAC3A0174,DB
2260 DATA 08C606AD3A01E9F7,99
2270 DATA FEC606AC3A00C605,00
2280 DATA 8057E82F035E3BFE,72
2290 DATA 74F4E9E7FED0EE72,9B
2300 DATA 03E9A7008A26A73A,C1
2310 DATA 8A06A83A0206A93A,13
2320 DATA E88B048A15F6C2E0,AD
2330 DATA 7503E98E008ADA80,A0
2340 DATA E30180E2E0D0E273,F3
2350 DATA 06B220FF0EAE3AF6,66
2360 DATA C2807404FF06AE3A,DF
2370 DATA 0AD38A06A83A8815,6A
2380 DATA B500E8DA03E96300,0F
2390 DATA E960008A26A73A8A,5F
2400 DATA 06A83A0206A93AE8,F6
2410 DATA 4404F605E075E98A,0F
2420 DATA 15D0EA8ACAB620E8,F1
2430 DATA 51043ACA75DAB100,6B
2440 DATA 50BF372B5132EDD0,DB
2450 DATA E103F95902257820,66
2460 DATA 3A26A33A741A0245,6D
2470 DATA 0178153A06A43A74,44
2480 DATA 0FC606F022C351E8,20
2490 DATA 61FE59C606F02290,AC
2500 DATA 58FEC180F90875C8,17
2510 DATA E99DFFB8021C8B0E,EF
2520 DATA AE3AB22081F90080,13
2530 DATA 7204F7D9B22DE8CE,13
2540 DATA 01FEC4E88E01E84E,7D
2550 DATA 04803EAD3A00750E,37
2560 DATA 813EB03A00007503,40
2570 DATA E99700E972FDBF53,B4
2580 DATA 2B8A06A33AF626A4,ED
2590 DATA 3A8BC88A15F6C220,4B
2600 DATA 740AF6C2017511B2,3C
2610 DATA 1AE90C00F6C22075,F2
2620 DATA 07F6C2017402B201,73
2630 DATA 881547E2DEB704B5,73
2640 DATA FF8A16A93AE8E202,C9
2650 DATA E8FC03F6D5FECF75,2F
2660 DATA F0BEE92ABF9B06BD,3E
2670 DATA FB32B306B909008A,B3
2680 DATA 053E8846008A0488,C9
2690 DATA 05474645E2F183C7,56
2700 DATA 17FECB75E7E8CF03,FC
2710 DATA B00433C9E2FEFEC8,05
2720 DATA 75F8BEFB32BF9B06,6C
2730 DATA B306B909008A0488,A6
2740 DATA 054746E2F883C717,00
2750 DATA FECB75EEE8A803E9,80
2760 DATA 7E00BF532B8A06A3,5C
2770 DATA 3AF626A43A8BC88A,54
2780 DATA 15F6C280740880E2,4B
2790 DATA 7F80CA20881547E2,84
2800 DATA EE8A16A93AB500E8,88
2810 DATA 6002B8021D33C9E8,16
2820 DATA B200BEB32ABF9B06,71
2830 DATA BDFB32B306B90900,C8
2840 DATA 8A053E8846008A04,B2
2850 DATA 8805474645E2F183,D3
2860 DATA C717FECB75E7E84E,96
2870 DATA 03B00433C9E2FEFE,56
2880 DATA C875F8BEFB32BF9B,B6
2890 DATA 06B306B909008A04,75
2900 DATA 88054746E2F883C7,86
2910 DATA 17FECB75EEE82703,87
2920 DATA 8A16A93AE80302E8,81
2930 DATA 1D03C606E227C88A,A9
2940 DATA 16A93AE85101C0EE,01
2950 DATA 03730780FA007402,1C
2960 DATA FECAD0EE730D8A3E,FD
2970 DATA A43A80EF063AFA74,44
2980 DATA 02FEC23A16A93A74,C6
2990 DATA 0C8816A93AB500E8,A2
3000 DATA C801E8E202B88000,E4
3010 DATA BB0002E80B01750E,41
3020 DATA B80004BB1000E800,58
3030 DATA 017506E9B1FFE9A2,7F
3040 DATA FBE9D8F96081F900,EE
3050 DATA 807202F7D9BB6400,A1
3060 DATA E81B00E82900FEC4,9D
3070 DATA BB0A00E81000E81E,07
3080 DATA 00FEC4BB0100E805,B9
3090 DATA 00E8130061C332D2,6E
3100 DATA 2BCB7205FEC2E9F7,C4
3110 DATA FF03CB80C230C360,A5
3120 DATA 068BD8D0E7C0E402,33
3130 DATA 02E7B008E800038A,ED
3140 DATA C8BE30068AC432E4,B4
3150 DATA C1E00503F032FFC1,79
3160 DATA E30303F380EA20BB,72
3170 DATA B23A8B3F8B47028E,A2
3180 DATA C032F6C1E20303FA,6B
3190 DATA B408268A35C0E602,41
3200 DATA 4732D2BB00FCD3EB,12
3210 DATA D3EAF7D3203C205C,A0
3220 DATA 20083408542046FE,2A
3230 DATA CC75DF0761C3608A,D6
3240 DATA 154780FA007408E8,3B
3250 DATA 95FFFEC4E9F0FF61,CB
3260 DATA C3538ADCC0E3030A,EE
3270 DATA D98AF8891C46465B,EB
3280 DATA C3534E4E8B1C8ACB,08
3290 DATA 80E1078AE3C0EC03,FA
3300 DATA 8AC75BC3E8CF0180,9E
3310 DATA E21F3A16A33A73F4,76
3320 DATA 8AE2E8C1013A16A4,25
3330 DATA 3A73F78AC2E85E01,01
3340 DATA 803D8075DFC60581,78
3350 DATA C352BA0002EF5058,29
3360 DATA B202ED23C35AC350,C9
3370 DATA 53B801008BD8E8E8,25
3380 DATA FF7404B47FCD4132,63
3390 DATA F6BF1F2BB90200D0,A6
3400 DATA E68B058B5D0283C7,E1
3410 DATA 04E8CDFF740380CE,7D
3420 DATA 01E2ECB104D0E68B,E3
3430 DATA 058B5D0283C704E8,CF
3440 DATA B7FF740880FE0075,4D
3450 DATA 0380CE01E2E78A06,3B
3460 DATA AA3AA870740A8836,BE
3470 DATA AA3A80E60FE93700,78
3480 DATA 240F742F84F07407,F2
3490 DATA FE06AB3AE90800C6,E0
3500 DATA 06AB3A00E91C0080,3F
3510 DATA 3EAB3A007415803E,74
3520 DATA AB3A03730A8836AA,20
3530 DATA 3A80E630E90800FE,59
3540 DATA 0EAB3A8836AA3A5B,AA
3550 DATA 58C333C08EC0BF30,76
3560 DATA 06B90004F3AAE81E,8B
3570 DATA 01C333C002C2E89D,F6
3580 DATA 0032C933C0B4008A,D3
3590 DATA 1547E81200FEC43A,C3
3600 DATA 26A33A75F2FEC0FE,CC
3610 DATA C180F90675E7C360,CC
3620 DATA 8BD8C0E40202E7B0,F2
3630 DATA 08E873018AC8BE30,49
3640 DATA 068AC432E4C1E005,70
3650 DATA 03F032FF03F3C1E3,95
3660 DATA 0203F346F6C2E074,13
3670 DATA 10C0EA0580FA0475,82
3680 DATA 02FECA80C208E90C,15
3690 DATA 00F6C2017505D0EA,9D
3700 DATA E90200B20C8AF2C0,CB
3710 DATA E20202D6BF6D2A32,43
3720 DATA F603FAB4058A3580,82
3730 DATA FD007405F6D680E6,EF
3740 DATA F84732D2BB00F8D3,6B
3750 DATA EBD3EAF7D3203C20,AE
3760 DATA 5C20083408542046,B4
3770 DATA FECC75D961C35053,98
3780 DATA 8A1EA33A32FFBF53,5C
3790 DATA 2B2C01720503FBE9,9E
3800 DATA F7FFFEC086C403F8,FA
3810 DATA 5B58C35751B1008A,BB
3820 DATA D150BF372B5132ED,0D
3830 DATA D0E103F959022578,0B
3840 DATA 1A3A26A33A741402,02
3850 DATA 4501780F3A06A43A,7D
3860 DATA 7409E8B9FF843574,48
3870 DATA 02FEC258FEC180F9,68
3880 DATA 0875CE595FC35053,F5
3890 DATA 51B9DB128AFD8AD9,CA
3900 DATA D1E303CB8AD102D5,1A
3910 DATA 8AEA83C138890E0A,EB
3920 DATA 298AD5595B58C306,7C
3930 DATA 60BE3006B800A08E,EC
3940 DATA C033FFB023AAB035,06
3950 DATA AAB021AAB004AAB0,C3
3960 DATA 22AAB000AAB020AA,28
3970 DATA B92000ACC0E804AA,45
3980 DATA 47E2F8B20547B021,56
3990 DATA AA8AC2AAB022AAB0,0E
4000 DATA 00AAB020AAB92000,6C
4010 DATA 8A64E0ACC1E804AA,43
4020 DATA 47E2F5FEC280FA11,0A
4030 DATA 75DB81EE2000B204,04
4040 DATA 47B021AA8AC2AAB0,16
4050 DATA 22AAB020AAB020AA,A8
4060 DATA B920008A64E0ACC1,11
4070 DATA E804AA47E2F5FEC2,34
4080 DATA 80FA1175DB47B023,54
4090 DATA AAB075AA6107C353,0D
4100 DATA 5133DB8ADCB90800,4A
4110 DATA D1E38AE72AE07204,21
4120 DATA FEC38AFCE2F28AE3,06
4130 DATA 8AC7595BC34D494E,9B
4140 DATA 4520535745455045,29
4150 DATA 5220465800424F4D,E1
4160 DATA 42204C4546543A00,66
4170 DATA 3139393720284329,D7
4180 DATA 204142435020736F,61
4190 DATA 667477617265004C,2F
4200 DATA 4556454C20202020,30
4210 DATA 4541535920204E4F,1E
4220 DATA 524D414C00484152,E6
4230 DATA 442020435553544F,4F
4240 DATA 4D00435553544F4D,92
4250 DATA 204D4F4445004649,42
4260 DATA 454C442058205349,2E
4270 DATA 5A452020205B2020,66
4280 DATA 205D004649454C44,31
4290 DATA 20592053495A4520,EA
4300 DATA 20205B2020205D00,DC
4310 DATA 4E554D424552204F,84
4320 DATA 4620424F4D42205B,4D
4330 DATA 2020205D00000020,34
4340 DATA 0000206020207070,D0
4350 DATA 1070407070107010,90
4360 DATA 7050507010107040,80
4370 DATA 7010707040705070,30
4380 DATA 7050101010705070,20
4390 DATA 5070F8A8F8A8F870,C8
4400 DATA 88300020F8888888,68
4410 DATA F81060F0F0608850,20
4420 DATA 205088FF80878887,EE
4430 DATA 808F80FFFF00A222,93
4440 DATA 22A21C00FFFF0071,37
4450 DATA 8A828A7100FFFF00,E3
4460 DATA CF280F28CF00FFFF,E8
4470 DATA 009E209C02BC00FF,76
4480 DATA FF0179817109F101,7A
4490 DATA FFFF808784878484,13
4500 DATA 80FFFF00C40A911F,7A
4510 DATA 1100FFFF00742424,DE
4520 DATA 247700FFFF002222,07
4530 DATA 22229C00FFFF00F3,C7
4540 DATA 8AF3928B00FFFF01,4D
4550 DATA E101E101E101FF02,FE
4560 DATA 0010000400080000,60
4570 DATA 0140000001100000,E6
4580 DATA 0240008000200000,42
4590 DATA FF01FF0100010100,0F
4600 DATA 01FF01FF00FFFF14,91
4610 DATA 061400140C280014,4A
4620 DATA 146400##########,DC
