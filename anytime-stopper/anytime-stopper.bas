100 CLS:CLEAR:L=1000:FOR I=&H2000 TO &H20CF STEP 8
110 READ A$:C=0:LOCATE 0,0:PRINT "LINE:";STR$(L)
120 FOR J=0 TO 7
130 P$=MID$(A$,J*2+1,2):IF P$="##" THEN 150
140 P=VAL("&H"+P$):POKE I+J,P:C=C+P*(J+1)
150 NEXT:READ A$:IF VAL("&H"+A$)-(C AND 255) THEN PRINT "ERROR IN ";L:END
160 L=L+10:NEXT
170 PRINT "COMPLETED END!":END
1000 DATA FCFAE800005D81ED,C5
1010 DATA 052033DB33C98EC3,F9
1020 DATA 8EDBB330B8952003,2B
1030 DATA C539077505394F02,C8
1040 DATA 74208BF3BFAC2003,DC
1050 DATA FDB102F3A5B89520,CD
1060 DATA 03C58907894F02B4,79
1070 DATA 20BF582003FDCD41,C6
1080 DATA FBCFBEAC2003F58B,40
1090 DATA FBB102F3A5B420BF,78
1100 DATA 7E2003FDCD41FBCF,97
1110 DATA 0C5B416E7974696D,99
1120 DATA 652053746F707065,71
1130 DATA 725D0D5374617965,A0
1140 DATA 64206F6E204D656D,42
1150 DATA 6F72792E0D000C52,9B
1160 DATA 656D6F7665642066,C5
1170 DATA 726F6D204D656D6F,69
1180 DATA 72792E0D0060E817,72
1190 DATA 00740FE8120075FB,1A
1200 DATA E80D0074FBE80800,61
1210 DATA 75FB61EA00000000,36
1220 DATA BA0002B80001EF50,AF
1230 DATA 58B202ED24027501,71
1240 DATA C3B80008B200EF50,D6
1250 DATA 58B202ED80E408C3,9E
