# eroge_release_cmd

![サンプル](/image/sample.gif)

## なんのソフト？
  
[げっちゅ屋](http://www.getchu.com/top.html?gc=gc)の[発売日リスト](http://www.getchu.com/all/price.html?genre=pc_soft&year=2019&month=3&gage=&gall=all)ページをスクレイピングしてその内容をコマンドで確認することができます。  
「今月はどんなゲームが発売されるのか？」、「推しの声優が出演しているゲームが発売されるのか？」、「大好きなあのメーカーは今月ゲームを発売するのか？」などの要望に答えることができるコマンドラインツールです。  

## 特徴

スクレイピングは時間がかかるものです。  
このコマンドラインツールにはキャッシュ機能が盛り込まれています。
年月単位で以前実行されたコマンドの結果をキャッシュし２回目に実行する時はそのキャッシュから読み込むので高速にコマンドの結果を確認することができます。

## インストール方法

```shell
$ git clone https://github.com/dodonki1223/eroge_release_cmd.git
$ cd eroge_release_cmd
$ bundle install
```

## Googleスプレッドシートの設定

Googleスプレッドシートに書き込みをする機能を使用する場合は下記の手順が必要です。  
※[google-drive-ruby](https://github.com/gimite/google-drive-ruby)を使用しているため[google-drive-ruby](https://github.com/gimite/google-drive-ruby)の設定が必要です

1. [google-drive-ruby](https://github.com/gimite/google-drive-ruby)を使用できるようにする
2. 書き込みを行なうGoogleスプレッドシートのIDを設定する

### 1. [google-drive-ruby](https://github.com/gimite/google-drive-ruby)を使用できるようにする 

[google-drive-rubyの認証手順](https://github.com/gimite/google-drive-ruby/blob/master/doc/authorization.md#authorization)の通りに[On behalf of you (command line authorization)](On behalf of you (command line authorization))の8まで進めて下さい  
9の作成するconfig.jsonのファイル名をgoogle_drive_config.jsonに変更し、下記ディレクトリに設置して下さい  

```
eroge_release_cmd/eroge_release/spreadsheet/google_drive_config.json
```

これ以降の設定は不要です

### 2. 書き込みを行なうGoogleスプレッドシートのIDを設定する

GoogleDriveにスプレッドシートを作成しそのURLを確認して下さい

例：
```
https://docs.google.com/spreadsheets/u/1/d/xxxxxxxxxxxxxxxxxxxxxxx/edit?usp=drive_web&ouid=107294483781638928010
```

`xxxxxxxxxxxxxxxxxxxxxxx`の部分がGoogleスプレッドシートのIDになります


下記コードの`Your Sheet Id`の部分に`GoogleスプレッドシートのID`を入力して下さい


```ruby
# 対象のファイル：eroge_release_cmd/getchuya

# GoogleスプレッドシートID
SPREADSHEET_ID = 'Your Sheet Id'
```

## 使用方法

下記コマンドで今月の発売リストの情報を表示します

```shell
$ bundle exec getchuya
```

オプションは以下の通りです

```shell
Usage: getchuya [options]
    -h, --help                       Show this help
        --robots                     Display contents of robots.txt
    -y, --year_month [YEAR_MONTH]    Set Target Year And Month
    -v, --voice_actor [VOICE_ACTOR]  Narrow down by voice actor name
    -t, --title [TITLE]              Filter by title
    -b, --brand_name [BRAND_NAME]    Narrow down by brand_name
    -o, --open [OPEN]                Open game page in browser
    -c, --csv [CSV]                  Create a csv file
    -j, --json [JSON]                Create a json file
    -s, --spreadsheet [SPREADSHEET]  Write to spreadsheet from CSV
        --open_spreadsheet [OPEN_SPREADSHEET]
                                     Open spreadsheet page in browser
        --clear_cache [CLEAR_CACHE]  Clear the cache
        --simple [SIMPLE]            Display results in a simplified way
```

対象の年月の発売リストを確認する

```shell
# 2017年5月の発売リストを確認します
$ bundle exec getchuya -y 201705
```

推しの声優が出演しているか確認する

```shell
# 遥そらさんと風音さんが出演しているゲームの一覧を表示します
$ bundle exec getchuya -v 遥そら,風音
```

特定のブランドがゲームを発売するか確認する

```shell
# SAGA PLANETSのゲームが発売するか確認する
$ bundle exec getchuya -b SAGA PLANETS
```

検索結果に表示されたゲームの情報をブラウザで確認する
※げっちゅ屋のゲーム紹介ページを表示する

```shell
# 遥そらさんと風音さんが出演しているゲームの一覧をブラウザで確認する 
$ bundle exec getchuya -v 遥そら,風音 -o
```

検索結果の内容でjsonファイル、csvファイルを作成する

```shell
# jsonファイルを作成する
$ bundle exec getchuya -j

# CSVファイルを作成する
$ bundle exec getchuya -c
```

Googleスプレッドシートに検索結果の内容を書き込む
※GoogleスプレッドシートへはCSVファイルを元に書き込むのでCSVファイルが無いと書き込めません

```shell
# 検索結果の内容をGoogleスプレッドシートに書き込む
$ bundle exec getchuya -c -s
```

キャッシュをクリアする

```shell
# 2018年5月のキャッシュをクリアする

$ bundle exec getchuya -y 201805 --clear_cache
```

## サポート環境

Macでのみ動作確認をしています。Windowsだと動くかわかりません。
rubyのバージョンは`2.3.7`で確認しています。  
恐らく`2.3.7`以上なら動作すると思います……。
