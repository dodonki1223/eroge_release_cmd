# frozen_string_literal: true

# げっちゅ屋コマンド
#   げっちゅ屋の発売リストページから発売情報とゲーム情報をスクレイピング
#   してゲーム情報を確認できるコマンドラインツールです
# -------------------------------------------------------------------------
# -h, --help                       Show this help
#     --robots                     Display contents of robots.txt
# -y, --year_month [YEAR_MONTH]    Set Target Year And Month
# -v, --voice_actor [VOICE_ACTOR]  Narrow down by voice actor name
# -t, --title [TITLE]              Filter by title
# -b, --brand_name [BRAND_NAME]    Narrow down by brand_name
# -o, --open [OPEN]                Open game page in browser
# -c, --csv [CSV]                  Create a csv file
# -j, --json [JSON]                Create a json file
# -s, --spreadsheet [SPREADSHEET]  Write to spreadsheet from CSV
#     --clear_cache [CLEAR_CACHE]  Clear the cache
#     --simple [SIMPLE]            Display results in a simplified way
# -------------------------------------------------------------------------

require './getchuya_scraping/command_line_arg.rb'
require './getchuya_scraping/games.rb'
require './spreadsheet/spreadsheet.rb'
require './spreadsheet/spreadsheet_writer.rb'

# GoogleスプレッドシートID
SPREADSHEET_ID = 'Your Sheet Id'

# Gamesクラスのインスタンスを取得する
#   Gamesクラスのインスタンスをキャッシュクリア区分、年月の引数に応じて取得する
def get_games_instance(has_clear_cache, year_month)
  return Games.new(has_clear_cache) if year_month.empty?

  Games.new(has_clear_cache, year_month)
end

# ゲーム情報を絞り込む
#   タイトル、ブランド名、声優名で絞り込む
def filtering_games(games, title, brand_name, voice_actor)
  games.where = {}
  games.where.store(:title, title) unless title.empty?
  games.where.store(:brand_name, brand_name) unless brand_name.empty?
  games.where.store(:voice_actor, voice_actor) unless voice_actor.empty?
  games
end

# スプレッドシートへCSVファイルから書き込む
#   更新対象のワークシート（年月のタイトル）を削除し、新しくワークシートへ
#   CSVファイルから書き込む
def write_spreadsheet_by_csv(year_month, csv_file)
  spreadsheet = SpreadsheetWriter.new(SPREADSHEET_ID)

  # 更新対象のワークシートを削除しCSVファイルから書き込みを行なう
  spreadsheet.delete_worksheet_by_title(year_month)
  spreadsheet.get_worksheet_by_title_not_exist_create(year_month)
  spreadsheet.write_by_csv(csv_file)

  # 書き込みを行ったスプレッドシートを返す
  spreadsheet
end

# シェルコマンドの「open」を使用して対象のものを開く
#   URLを指定された時は規定のブラウザでそのURLを開く
def system_open(target)
  system("open #{target}")
end

# URLを開く
#   絞り込んだゲームを規定のブラウザで表示する
def open_urls(game_list)
  # 画面にゲーム数を表示し、ユーザーにそのまま処理を続行するか対話する
  puts
  puts "「#{game_list.count}」件のゲーム情報をブラウザで表示します"
  puts '処理を終了する時は「Ctrl + C」で終了して下さい'

  # Ctrl+Cを押下後用の処理
  # ※例外を補足し画面に何も表示させないようにする
  begin
    system('read -p "続行する場合はEnterを押して下さい: "')
  rescue Interrupt
    puts
    exit
  end

  # ゲームの紹介ページを開く
  game_list.each do |game|
    system_open(game[:introduction_page])
  end
end

# ゲーム情報を表示する
#   タイトル、発売日、ブランド名、価格、声優情報を画面に表示する
def display_games(game_list)
  # データが存在しなかったら処理を終了
  if game_list.count.zero?
    puts '表示データがありませんでした'
    exit
  end
  puts '-----------------------------------------------------------------------------'
  game_list.each do |game|
    puts game[:title]
    puts game[:release_date]
    puts game[:brand_name]
    puts game[:price]
    puts game[:voice_actor].empty? ? '声優情報なし' : game[:voice_actor].join('､')
    puts '-----------------------------------------------------------------------------'
  end
end

# ゲーム情報を簡略表示する
#   発売日、タイトルを画面に表示する
def simple_display_games(game_list)
  # データが存在しなかったら処理を終了
  if game_list.count.zero?
    puts '表示データがありませんでした'
    exit
  end
  game_list.each do |game|
    puts "#{game[:release_date]} #{game[:title]}"
  end
end

# ---------------------------------
#  コマンドライン引数を取得する
# ---------------------------------
command_line_args          = CommandLineArg.new
year_month                 = command_line_args.get(:year_month)       # 年月
title                      = command_line_args.get(:title)            # 絞り込み用のタイトル
brand_name                 = command_line_args.get(:brand_name)       # 絞り込み用のブランド名
voice_actor                = command_line_args.get(:voice_actor)      # 絞り込み用の声優名
has_clear_cache            = command_line_args.get(:clear_cache)      # キャッシュクリア区分(true:キャッシュをクリアする、false:キャッシュをクリアしない)
is_simple_display          = command_line_args.get(:simple)           # ゲーム情報を簡略表示する
is_open                    = command_line_args.get(:open)             # ゲーム紹介ページを開くかどうかの区分
should_create_csv          = command_line_args.get(:csv)              # CSVをファイル作成する
should_create_json         = command_line_args.get(:json)             # jsonファイルを作成する
should_writing_spreadsheet = command_line_args.get(:spreadsheet)      # スプレッドシートへ書き込みをする
is_open_spreadsheet        = command_line_args.get(:open_spreadsheet) # スプレッドシートページを開くかどうかの区分

# ---------------------------------
#  ゲーム情報の取得
# ---------------------------------
begin
  games = get_games_instance(has_clear_cache, year_month)
rescue StandardError => e
  # 例外メッセージとバックトレースを表示して処理を終了する
  puts "#{e.message}(#{e.class})"
  puts e.backtrace
  exit
end
getchuya_games = filtering_games(games, title, brand_name, voice_actor)

# ---------------------------------
#  ファイルの作成
# ---------------------------------
getchuya_games.create_csv if should_create_csv
getchuya_games.create_json if should_create_json

# ---------------------------------
#  スプレッドシートへの書き込み
# ---------------------------------
if should_writing_spreadsheet
  # スプレッドシートへの書き込み処理
  target_year_month = "#{getchuya_games.year}#{getchuya_games.month}"
  spreadsheet = write_spreadsheet_by_csv(target_year_month, getchuya_games.csv_file_path)

  # 書き込みを行ったワークシートをブラウザで開く
  system_open(spreadsheet.worksheet.human_url) if is_open_spreadsheet
end

# ---------------------------------
#  画面表示
# ---------------------------------
if is_simple_display
  # 簡略表示処理
  simple_display_games(getchuya_games.game_list)
else
  # 通常表示処理
  display_games(getchuya_games.game_list)
end

# ---------------------------------
#  ゲーム情報をブラウザで表示
# ---------------------------------
open_urls(getchuya_games.game_list) if is_open
