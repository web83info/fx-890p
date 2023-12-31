# BASIC Check Sum

E500系のBCS（'94/12）は結構人気があって昨今のプログラムに利用されています。ところが、FX-BCS（'95/4）はあまりメジャーではありません。やはりその一因には速度の問題があると思います。高速化するためにはアセンブラしかない！ということでとりあえずアセンブラで組んでみました。連続計算能力は結構高いです。（1秒あたり0.8KB）ファイルエリア出力能力はありませんがチェック用にはすばらしい能力を発揮すると思います。

## 入力方法

アセンブラで組んだということはマシン語エリアを確保する必要があります。BASICかCALモ－ドで、

```
CLEAR 1024，611，6144
```

と入力します。そうしたら```basic-check-sum.bas```を転送・実行し、マシン語プログラムを書き込んでください。

プログラム本体の実行は、

```
CALL &H2000
```

です。

| 項目 | 内容 |
| --- |--- |
| 必要メモリー領域 | &H2000〜&H2262, 611（&H0263）バイト |
| 　プログラム領域 | &H2000〜&H2258, 601（&H0259）バイト |
| 　ワークエリア領域 | &H2259〜&H2262, 10（&H000A）バイト |
| メモリー領域確保コマンド | ```CLEAR 1024,611,6144``` |
| マシン語保存コマンド | ```BSAVE "FILENAME",&H2000,601,&H2000``` |
| マシン語読込コマンド | ```BLOAD "FILENAME",&H2000``` |
| マシン語実行コマンド | ```DEFSEG=0```<br>```CALL &H2000``` |

## 使い方

実行すると、

```
Which P-Area? [P0]
```

ときかれます。ここでチェックサムを表示させたいプログラムエリアをテンキ－で選択します。[RET]で決定します。指定したエリアにプログラムが存在しないときには、

```
Program Not Found!
```

と怒られてしまいます。正しく指定すると、次の様な画面になります。

```
New FX-BCS
Line  /  Check Sum
XXXXX      YYYY
Program Size=ZZZZZ
```

XXXXXとは、ただ今チェックサムを表示しているラインを示しています。YYYYはチェックサムですね。ZZZZZはプログラムサイズです。
[RET]または[↓]を押すと、次のラインの計算を始めます。[S]キ-を押すと、

SKIP MODE: [     ]

と表示されます。テンキーでこの行までSKIPさせたいと思う行を入力して下さい。間違えたときは[BS]、[←]で訂正が可能です。
最後の行まで表示するとCALモードに戻ります。

## アルゴリズム

行番号入力についてだけ説明します。入力した最高5桁のデ－タは以下の形式でワ－クエリアに保存されます。

```
コ－ド：ASCII-30H、1BYTEに1デ－タ
```

例えば、12345行は01H、02H、03H、04H、05Hとなっています。ここで問題が生じます。65536行以上の数を入力したときです。これは次の方法で解決します。

1. SIは最後の文字の次のアドレスを指しているので、5文字の場合、BYTE PTR [SI-5]が7以上なら戻ります。
2. SIをデクリメントしながら1の位、10の位・・・・とDXに加算します。もちろん、*1、*10・・・・とします。その結果結果が16BITでオーバーフローした（＝前の計算結果より小さくなった）ときは、65536〜69999までの間の行番号です。

あとは、DXに行番号が返ります。

## 参考文献
Z-1/FX-890P活用研究：工学社
