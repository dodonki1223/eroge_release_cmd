# frozen_string_literal: true

require './release_list_scraping.rb'
require './introduction_page_scraping.rb'
require './getchya_scraping.rb'
require 'json'
require 'csv'

# げっちゅ屋のゲーム情報を管理するクラス
# 発売リストページ、ゲーム紹介ページからスクレイピングした結果を保持
# する。その情報を加工・検索してデータを取得することができる
class Games
  attr_accessor :games, :year_month, :year, :month, :cache_file, :release_list

  # 作成ファイルが格納されるディレクトリ
  CREATED_PATH = "#{__dir__}/created/"
  # キャッシュファイルが格納されるディレクトリ
  CACHE_PATH = "#{__dir__}/cache/"

  # コンストラクタ
  #   クラス内で使用するインスタンス変数をセットする
  #   キャッシュファイルパスを作成し、キャッシュファイルを削除する時はすでに作
  #   成されているキャッシュファイルを削除する
  def initialize(cleared_cache = false, year_month = nil)
    # 発売リスト、年、月情報を取得する
    @release_list = ReleaseListScraping.new(year_month)
    @year         = release_list.year
    @month        = release_list.month

    # キャッシュファイルのパス名を作成
    # キャッシュクリアの時はキャッシュをクリアする
    @cache_file = get_file_path(CACHE_PATH, "#{@year}#{@month}.json")
    clear_cache(@cache_file) if cleared_cache

    # ゲーム情報をセットする（げっちゅ屋よりスクレイピングして取得する）
    @games = get_games(cache_file)

    # キャッシュフォルダへキャッシュファイル（jsonファイル）を作成する
    # ※ファイル名は「YYYYMM.json」の形式とする
    create_json(@cache_file)

    # 年月情報をセットする
    @year_month = "#{@year}年#{@month}月"
  end

  # ゲーム情報をjson形式に変換して返す
  #   ゲーム情報をげっちゅ屋からスクレイピングしその結果をjson形式に変換して返す
  def to_json
    JSON.pretty_generate(@games)
  end

  # jsonファイルを作成する
  #   対象のパスにjsonファイルを作成する
  def create_json(path)
    create_file(path, to_json)
  end

  def create_csv
    csv_file = get_file_path(CREATED_PATH, "#{@year}#{@month}.csv")
    CSV.open(csv_file, 'wb') do |csv|
      csv << ["row", "of", "CSV", "data"]
      csv << ["another", "row"]
    end
  end

  private

  # ゲーム情報を取得する
  #   キャッシュファイルが存在する時はキャッシュファイルから読み込んで取得する
  #   キャッシュファイルが存在しない時はゲーム情報をげっちゅ屋からスクレイピン
  #   グして取得する。インスタンス変数のgames、year、monthに値をセットする
  def get_games(cache_file)
    # キャッシュファイルが存在する時はスクレイピングを行わずキャッシュファイルから読み込む
    return read_cache(cache_file) if cached?(cache_file)

    # げっちゅ屋の「月発売タイトル一覧・ゲーム」の一覧をスクレイピングして取得する
    release_list = @release_list.scraping

    # ゲーム情報を追加していく
    games = []
    release_list.each do |game|
      # ゲームの紹介ページからスクレイピングし「パッケージ画像」、「ブランドページ」、「声優情報」を取得する
      introduction_page = IntroductionPageScraping.new(game[:id])
      # 「月発売タイトル一覧・ゲーム」と「パッケージ画像」、「ブランドページ」、「声優情報」をマージする
      game_info = game.merge(introduction_page.scraping)
      games.push(game_info)
    end
    games
  end

  # ファイルのパス（フルパス）を取得する
  #   ファイルのパスは「作成ファイルパス」、「キャッシュファイルパス」のみなの
  #   でそれ以外を指定した時は例外を投げる
  def get_file_path(directory, file_name)
    unless [CREATED_PATH, CACHE_PATH].include?(directory)
      raise ArgumentError, 'CREATED_PATH、CACHE_PATHのどちらかを必ず指定して下さい'
    end

    directory + file_name
  end

  # ファイルを作成する
  #   対象のパスへcontentの内容を書き込む(文字列)。対象のパスに同名のファイ
  #   ルが存在した場合は中身が破棄され、今回の書き込み内容に上書きされる。
  #   大量の文字列を指定するとメモリ不足で落ちる可能性があると思われるので注
  #   意すること
  def create_file(path, content)
    # 対象のパス（フルパスが来る想定）へcontent情報を書き込む
    # ※ブロックを指定して呼び出した場合はブロックの実行が終了すると、ファイルは自動的にクローズされる
    File.open(path, 'w') { |file| file.puts content }
  end

  # キャッシュファイルが存在するか？
  def cached?(cache_file)
    File.exist?(cache_file)
  end

  # キャッシュファイルを読み込む
  #   キャッシュファイル（jsonファイル）を配列で読み込み返す
  def read_cache(cache_file)
    File.open(cache_file) do |cache|
      JSON.parse(cache.read)
    end
  end

  # キャッシュファイルをクリアする
  #   キャッシュファイルを削除する。削除対象のキャッシュファイルが
  #   存在しない場合はエラーメッセージをコンソールに表示する
  def clear_cache(cache_file)
    File.delete(cache_file)
  rescue StandardError => e
    puts '<キャッシュファイルの削除に失敗しました>'
    puts e.message
    puts e.backtrace
  end
end
