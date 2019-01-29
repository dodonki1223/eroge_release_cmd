# frozen_string_literal: true

# げっちゅ屋コマンド
#   げっちゅ屋の発売リストページから発売情報とゲーム情報をスクレイピング
#   してゲーム情報を確認できるコマンドラインツールです
# -------------------------------------------------------------------------
#   -h, --help                       Show this help
#       --robots                     Display contents of robots.txt
#   -y, --year_month [YEAR_MONTH]    Set Target Year And Month
#   -v, --voice_actor [VOICE_ACTOR]  Narrow down by voice actor name
#   -t, --title [TITLE]              Filter by title
#   -b, --brand_name [BRAND_NAME]    Narrow down by brand_name
#   -o, --open [OPEN]                Open game page in browser
#   -c, --csv [CSV]                  Create a csv file
#   -j, --json [JSON]                Create a json file
#       --clear_cache [CLEAR_CACHE]  Clear the cache
#       --simple [SIMPLE]            Display results in a simplified way
# -------------------------------------------------------------------------

require './getchya_scraping/command_line_arg.rb'
require './getchya_scraping/games.rb'

# Gamesクラスのインスタンスを取得する
#   Gamesクラスのインスタンスをキャッシュクリア区分、年月の引数に応じて取得する
def get_gams_instance(has_clear_cache, year_month)
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

  # シェルコマンドの「open」を使用してゲームの紹介ページを開く
  game_list.each do |game|
    system("open #{game[:introduction_page]}")
  end
end

# CSVファイルを作成する
def create_csv(game_list)
  game_list.create_csv
end

# JSONファイルを作成する
def create_json(game_list)
  game_list.create_json
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
command_line_args = CommandLineArg.new
year_month         = command_line_args.get(:year_month)  # 年月
title              = command_line_args.get(:title)       # 絞り込み用のタイトル
brand_name         = command_line_args.get(:brand_name)  # 絞り込み用のブランド名
voice_actor        = command_line_args.get(:voice_actor) # 絞り込み用の声優名
has_clear_cache    = command_line_args.get(:clear_cache) # キャッシュクリア区分(true:キャッシュをクリアする、false:キャッシュをクリアしない)
is_simple_display  = command_line_args.get(:simple)      # ゲーム情報を簡略表示する
is_open            = command_line_args.get(:open)        # ゲーム紹介ページを開くかどうかの区分
should_create_csv  = command_line_args.get(:csv)         # CSVをファイル作成する
should_create_json = command_line_args.get(:json)        # jsonファイルを作成する

# ---------------------------------
#  ゲーム情報の取得
# ---------------------------------
begin
  games = get_gams_instance(has_clear_cache, year_month)
rescue => e
  # 例外メッセージとバックトレースを表示して処理を終了する
  puts "#{e.message}(#{e.class})"
  puts e.backtrace
  exit
end
getchya_games = filtering_games(games, title, brand_name, voice_actor)

# ---------------------------------
#  ファイルの作成
# ---------------------------------
create_csv(getchya_games) if should_create_csv
create_json(getchya_games) if should_create_json

# ---------------------------------
#  画面表示
# ---------------------------------
if is_simple_display
  # 簡略表示処理
  simple_display_games(getchya_games.game_list)
else
  # 通常表示処理
  display_games(getchya_games.game_list)
end

# ---------------------------------
#  ゲーム情報をブラウザで表示
# ---------------------------------
open_urls(getchya_games.game_list) if is_open
