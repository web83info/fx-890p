# MTOOL Ver1.00
 
あれはいつのことだったでしょうか。その時私はある自作マシン語ゲ－ムを「BASIC自動書込式」にコンバ－トしていました。毎回インスト－ラ－を書くのですが、その度ごとに考えながら書いていました。だんだん面倒になったので、自動コンバ－タ－を作成したのです。

つまり、これはゲ－ムではなくユ－ティリティ－です。マシン語ゲ－ムを投稿したいのにFDDはないし、パソコンとはバイナリ通信ができないと嘆いている貴方や、マシン語モニタのない貴方もOKです。

 「今さらそんなもの．．．」と思っている貴方！このプログラムは今までより正確に誤りを指摘します。（後述）
 
## 入力方法

プログラムはFX-890P対応となっております。互換機でも動くはずです。プログラム自体はどのように動かしても暴走することはありませんが、マシン語を扱うという性質上どうしてもバックアップは必要です。
 
## 使い方

このプログラムはマシン語投稿者用（プログラマ－用）のものです。貴方が一生懸命作ったプログラムがあらかじめ確保されたマシン語エリアに生成されたとしましょう。そうしたらその状態でアセンブラの[L]コマンドなどで、プログラムの先頭番地と終了番地を記録して下さい。この例では[2000H]から[26FFH]にプログラムがあるとします。それからFエリアを最低一つNEWして下さい。そこにプログラムを生成します。
 実際に使ってみましょう。まずBASICプログラムをRUNします。すると、

```
WHICH FILE AREA [F?]
``` 
 
 と聞かれるので、出力したいFエリアを選んで下さい。すると、

```
START? / END?
``` 
 
と聞かれるので開始／終了番地をそれぞれ入力して下さい。そうするとポケコンから確認されます。

```
START 2000 / END 26FF
``` 
 
先頭番地は[???0]か[???8]にして下さい。終了番地が[???7]または[???F]のどちらでもない時は最高7バイトのダミ－デ－タが付加されます。気になる方は実行前にダミ－デ－タを0クリアしておきましょう。

 すると、

```
 WORKING 2???／26FF
``` 
 
と表示されてデ－タを生成していきます。プログラムが落ちたら完成です。もしエラ－が出たら、次の点を確認して下さい。
 
*  Fエリアは、NEWされているか？
* メモリは充分にあるか？
 
必要とされるデ－タはマシン語プログラムのサイズの2，3倍になりますので、覚悟しておいて下さい。

さて、エラ－がなく終了したとしましょう。そうしたら、アスキ－セ－ブするなり、Pエリアにコピ－するなりして下さい。

マシン語を書き込む時は、BASICプログラムを素直に打ち込んでRUNさせて下さい。
 
## 技術情報－必ずお読み下さい

このプログラムで出力されるプログラムは普通のチェックサムの計算方法と若干違います。次の例を見て下さい。
 
```
 1） 2000 ： 8B B8 EF FE 01 23 45 67
```
 
 このようなデ－タがあるとします。この時、普通の方法で計算されたチェックサムは```00H```になります。しかし、8とB、EとFは見間違えやすいので、次のように打ち込んでしまいました。

```
 2） 2000 ： 8B 8B FE EF 01 23 45 67
``` 
 
 普通にチェックサムの計算をすると```00H```になってしまうのです。つまり、順番違いは全くチェックできないのです。困りますね。

 ところが新開発された（少し嘘）FX－BCSやBCSで採用された方法を使うと、1）はB2H、2）は49Hと区別されます。 このように計算しています。

```
8BH *1 + B8H *2 + EFH *3 ＋．．．．＋67H *8
``` 
 
 しかし注意したいのは、一般的なチェックサムの計算方法と異なることです。普通のモニタでは打ち込めません。結果も異なります。（当然） もし一般的な方法でチェックサムを出力したかったら、次のように変更を加えて下さい。

260，340行の```P*(J+1)```を```P```にする。
 
 ## ご不満ありますか

もしマシン語書き込みプログラムに不満がある方は220行からの```WRITE#```文を変更して下さい。ただし、以下のように文字列を扱って下さい。
 
 1） ”（ダブルクオ－テ－ション）以外は普通に文字変数と同じように扱う。

 2） 制御文字（アスキ－コ－ド0から31）は使用しない。
  
## 参考文献

工学社：Z－1／FX－890P活用研究

## 掲載誌

工学社：「ポケコンジャーナル」1996年5月号 P4, 5
 
## 変数表
 
### 掲載リスト
 
| 変数 | 用途 |
| --- | --- |
| I$，C$ | 汎用 |
| S | スタ－トアドレス |
| E | エンドアドレス |
| A | 行番号 |
| B$ | チェックサム生成用 |
| C | チェックサム計算用 |
| I,J | ル－プ |
| P | メモリのデ－タ |
 
### 生成されるリスト
 
| 変数 | 用途 |
| --- | --- |
| L | 行番号 |
| I | アドレス |
| A$ | デ－タリ－ド用 |
| C | チェックサム検査 |
| J,I | ル－プ |
| J | アドレス補助 |
| P | 書き込むデ－タ |