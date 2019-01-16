# frozen_string_literal: true

require './release_list_scraping.rb'
require './introduction_page_scraping.rb'
require './getchya_scraping.rb'
require 'json'

# げっちゅ屋のゲーム情報を管理するクラス
# 発売リストページ、ゲーム紹介ページからスクレイピングした結果を保持
# する。その情報を加工・検索してデータを取得することができる
class Games
  attr_accessor :games, :year_month, :year, :month, :cache_file

  # コンストラクタ
  #   年月の文字列を引数で受け取り、対象の年月のゲーム情報を取得しセットする
  #   対象の年月情報を合わせてセットする
  def initialize(year_month = nil)
    # ゲーム情報をセットする（げっちゅ屋よりスクレイピングして取得する）
    @games = get_games(year_month)
    # 年月情報をセットする
    @year_month = format('%<year>d年%<month>s月', year: @year, month: @month)
  end

  # ゲーム情報をjson形式に変換して返す
  #   ゲーム情報をげっちゅ屋からスクレイピングしその結果をjson形式に変換して返す
  def to_json
    JSON.pretty_generate(@games)
  end

  private

  # ゲーム情報を取得する
  #   キャッシュファイルが存在する時はキャッシュファイルから読み込んで取得する
  #   キャッシュファイルが存在しない時はゲーム情報をげっちゅ屋からスクレイピン
  #   グして取得する。インスタンス変数のgames、year、monthに値をセットする
  def get_games(year_month)
    # 発売リストクラスから年、月情報を取得する
    release_list_scraping = ReleaseListScraping.new(year_month)
    @year = release_list_scraping.year
    @month = release_list_scraping.month

    # キャッシュファイルが存在する時はスクレイピングを行わずキャッシュファイルから読み込む
    @cache_file = format('./cache/%<year>d%<month>s.json', year: @year, month: @month)
    return read_cache(@cache_file) if cached?(@cache_file)

    # げっちゅ屋の「月発売タイトル一覧・ゲーム」の一覧をスクレイピングして取得する
    release_list = release_list_scraping.scraping

    # ゲーム情報を追加していく
    games = []
    release_list.each do |game|
      # ゲームの紹介ページからスクレイピングし「パッケージ画像」、「ブランドページ」、「声優情報」を取得する
      introduction_page = IntroductionPageScraping.new(game[:id])
      # 「月発売タイトル一覧・ゲーム」と「パッケージ画像」、「ブランドページ」、「声優情報」をマージする
      game_info = game.merge(introduction_page.scraping)
      games.push(game_info)
    end

    # キャッシュファイルを作成する
    create_cache(@year, @month, games)

    games
  end

  # キャッシュファイルを作成する
  #   cacheフォルダ内に年月のjsonファイルを作成する
  #   すでに同名のファイルが存在した場合は中身が破棄され、今回の書き込み内容に
  #   上書きされる
  def create_cache(games)
    # キャッシュフォルダへキャッシュファイル（jsonファイル）を書き込む
    # ファイル名は「YYYYMM.json」の形式とする
    # ※ブロックを指定して呼び出した場合はブロックの実行が終了すると、ファイルは自動的にクローズされる
    File.open(@cache_file, 'w') { |file| file.puts JSON.pretty_generate(games) }
  end

  # キャッシュファイルを読み込む
  #   キャッシュファイル（jsonファイル）を配列で読み込み返す
  def read_cache(cache_file)
    File.open(cache_file) do |cache|
      JSON.parse(cache.read)
    end
  end

  # キャッシュファイルが存在するか？
  def cached?(cache_file)
    File.exist?(cache_file)
  end
end
