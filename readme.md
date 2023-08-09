# FX-890P

カシオのポケコンFX-890P向けの各種プログラム。使用言語はBASIC、アセンブラ。ゲームやユーティリティープログラムが中心。

## 注意事項

* 各プログラムに付属するreadme.mdは、雑誌掲載時の原稿をベースにしています。そのため、ファイル名や図表の番号など、一部正しくないものもありますが、ご了承ください。
* 原則として、文字コードUTF-8、改行コードLFです。
  * 拡張子BAS（BASICプログラム）は、文字コードS-JIS、改行コードCR+LFです。
* 拡張子ASM（アセンブラソースリスト）は、内蔵アセンブラでアセンブルできるものと、MASMが必要なものがあります。詳しくは、各プログラムのreadme.mdを参照してください。
* 拡張子BIN（マシン語のバイナリファイル）は```BLOAD```命令で読み込むことができます。

## プログラム一覧

### ゲーム

| タイトル | 内容 | 言語 |
| --- | --- | --- |
| [3D-MAZE](3d-maze/readme.md) | 3D迷路 | マシン語 |
| [CYCLES 890P](cycles-890p/readme.md) | 落ちてくる矢印で輪を作り消す落ち物ゲーム | マシン語 |
| [GALAXY WALL FX-890P](galaxy-wall-fx-890p/readme.md) | 流れてくるブロックを消していく落ち物ゲーム | マシン語 |
| [GALAXY WALL TWIN β1](galaxy-wall-twin-beta1/readme.md) | 流れてくるブロックを消していく対戦型落ち物ゲーム | マシン語 |
| [Left or Right](left-or-right/readme.md) | あなたの右と左の感覚を狂わせてさしあげるゲーム | BASIC |
| [Mine Sweeper FX](mine-sweeper-fx/readme.md) | Windowsでおなじみの爆弾探しゲーム | マシン語 |
| [MIRRORIS-V](mirroris-v/readme.md) | フラッシュボールを鏡で反射させて消す落ち物ゲーム | マシン語 |
| [Number Breaker](number-breaker/readme.md) | 4つのヒントを手掛かりにして、隠された4つの数字とその順番を推理するゲーム | BASIC |
| [Overnight Sensation Remix](overnight-sensation-remix/readme.md) | 矢印を回転させて消すパズルゲーム | マシン語 |
| [Overnight Sensation Remi2](overnight-sensation-remi2/readme.md) | 矢印を回転させて消すパズルゲームの改良版 | マシン語 |
| [Panic Maker](panic-maker/readme.md) | 平面版ルービックキューブのようなゲーム | BASIC |
| [Poker Action for FX-890P](poker-action/readme.md) | 流れてくるトランプを並べてポーカーの役を作る落ち物ゲーム | マシン語 |
| [Reversible Panel](reversible-panel/readme.md) | パネルを裏返し、色を揃えるパズルゲーム | マシン語 |
| [算数マスター](math-master/readme.md) | 正しい数式となるよう数字を並べる算数パズルゲーム | BASIC |
| [ゼロヨン de GO!](zero-yon-de-go/readme.md) | ポケコンでできるゼロヨンゲーム | BASIC |
| [モンキー de ウッキー](monkey/readme.md) | 流れてくる数字を10にして消すアクションパズルゲーム | BASIC |

### 開発ツール

| タイトル | 内容 | 言語 |
| --- | --- | --- |
| [Anytime Register](anytime-register/readme.md) | プログラム実行中に任意のタイミングでレジスタの値を表示するマシン語プログラム | マシン語 |
| [Anytime Stopper](anytime-stopper/readme.md) | プログラム実行中に任意のタイミングでポーズさせるマシン語プログラム | マシン語 |
| [Data Convertor Ver.1.0](data-convertor/readme.md) | GPRINT形式のデータをDEFCHR$形式に変換 | BASIC |
| [DisAssembler FX](disassembler-fx/readme.md) | ポケコン上で動くディスアセンブラ | BASIC |
| [Real Inkey$](real-inkey/readme.md) | BASICで同時キー入力判定をするためのマシン語プログラム | マシン語 |
| [LINES-5](lines5/readme.md) | BASICから5行表示を可能にするマシン語プログラム | マシン語 |
| [MTOOL Ver1.00](mtool100/readme.md) | マシン語プログラムインストーラーを生成するBASICプログラム | BASIC |
| [MTOOL Ver1.50](mtool150/readme.md) | マシン語プログラムインストーラーを生成するBASICプログラムの改良版 | BASIC |

### ユーティリティー

| タイトル | 内容 | 言語 |
| --- | --- | --- |
| [BASIC Check Sum](basic-check-sum/readme.md) | BASICプログラムにチェックサムを | マシン語 |
| [BASIC Command Converter](basic-command-converter/readme.md) | 省略形で入力したBASICコマンドのコンバーター | マシン語 |
| [Let's Screen Capture](lets-screen-capture/readme.md) | スクリーンキャプチャを取得するプログラム | マシン語 |
| [Here Comes the Boss](here-comes-the-boss/readme.md) | ボスが来たときにダミー画面を表示するマシン語プログラム | マシン語 |
| [NAP（Number-place Auto-answering Program）](nap/readme.md) | ナンバープレース（数独）を自動的に解くプログラム | マシン語 |
