
# scan-shift-jis.rb
This script can be used to scan a file for strings encoded with Shift-JIS. 

## Usage

If you use the following command:

    $ ./scan_shift_jis.rb example.exe

A table with all the Shift-JIS encoded Japanese strings in the executable, together with the corresponding addresses of these strings will be printed:

```
address             |string
424BF8              |画像保存先ディレクトリが存在しません。
424C2C              |保存できるスクリーンショットは
424C4F              |までです。
424C5C              |バックバッファの取得に失敗しました
4252F0              |ゲームが既に起動しています。
425313              |から起動して下さい
425328              |本ソフトウェアの起動にはインストール作業が必要です。
42535D              |詳しくは製品に付属のドキュメントをお読みください。
4293F4              |ご使用の環境では正常に描画ができません
42B210              |ファイルオープンに失敗
42B22C              |ファイルの書出しに失敗
42B248              |バッファの確保に失敗
```

Note that the table is encoded using Shift-JIS. 
For more advanced usage, do

    $ ./scan_shift_jis.rb --help
