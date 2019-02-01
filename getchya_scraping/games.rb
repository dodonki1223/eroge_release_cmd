# frozen_string_literal: true

require './getchya_scraping/release_list_scraping.rb'
require './getchya_scraping/introduction_page_scraping.rb'
require './getchya_scraping/getchya_scraping.rb'
require './getchya_scraping/extended_string'
require 'json'
require 'csv'

# げっちゅ屋のゲーム情報を管理するクラス
# 発売リストページ、ゲーム紹介ページからスクレイピングした結果を保持
# する。その情報を加工・検索してデータを取得することができる
class Games
  attr_accessor :games, :year_month, :year, :month, :cache_file, :release_list, :where

  # 作成ファイルが格納されるディレクトリ
  CREATED_PATH = "#{__dir__}/created/"
  # キャッシュファイルが格納されるディレクトリ
  CACHE_PATH = "#{__dir__}/cache/"
  # CSV用のヘッダーカラム情報
  HEADER_COLUMNS = %w[id release_date title package_image price introduction_page brand_name brand_page voice_actor].freeze

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
    @cache_file = get_file_path(CACHE_PATH, "#{@year}#{@month}")
    clear_cache(@cache_file) if cleared_cache

    # ゲーム情報をセットする（げっちゅ屋よりスクレイピングして取得する）
    @games = get_games(cache_file)

    # キャッシャファイルが存在しない時、キャッシュフォルダへキャッシュ
    # ファイル（ゲーム情報をシリアライズしたもの）を作成する
    # ※ファイル名は「YYYYMM」の形式とする
    create_cache(@cache_file, @games) unless cached?(cache_file)

    # 年月情報をセットする
    @year_month = "#{@year}年#{@month}月"
  end

  # ゲーム情報を取得する
  #   ゲーム情報を絞り込んだ状態で取得する
  def game_list
    filtering
  end

  # ゲーム情報をjson形式に変換して返す
  #   ゲーム情報をげっちゅ屋からスクレイピングしその結果をjson形式に変換して返す
  def to_json
    JSON.pretty_generate(filtering)
  end

  # jsonファイルを作成する
  #   対象のパスにjsonファイルを作成する（デフォルト値はcreatedフォルダ内に作成する）
  def create_json(path = get_file_path(CREATED_PATH, "#{@year}#{@month}.json"))
    create_file(path, to_json)
  end

  # CSVファイルを作成する
  #   スクレイピングした結果をCSVファイルとして作成する
  def create_csv
    # CSVファイルのフルパスを取得する
    csv_file = get_file_path(CREATED_PATH, "#{@year}#{@month}.csv")
    # スクレイピングした結果からCSVファイルを新規作成する
    CSV.open(csv_file, 'wb', force_quotes: true) do |csv|
      csv << HEADER_COLUMNS
      filtering.each do |game|
        csv << [
          game[:id],
          game[:release_date],
          game[:title],
          game[:package_image],
          game[:price],
          game[:introduction_page],
          game[:brand_name],
          game[:brand_page],
          game[:voice_actor].join('、')
        ]
      end
    end
  end

  private

  # ゲーム情報を取得する
  #   キャッシュファイルが存在する時はキャッシュファイルから読み込んで取得する
  #   キャッシュファイルが存在しない時はゲーム情報をげっちゅ屋からスクレイピン
  #   グして取得する。インスタンス変数のgames、year、monthに値をセットする
  def get_games(cache_file)
    # キャッシュファイルが存在する時はスクレイピングを行わずキャッシュファイルから読み込む
    return load_cache(cache_file) if cached?(cache_file)

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

  # ゲーム情報を絞り込む
  #   @where変数に指定されている条件を元にゲーム情報を絞り込む
  def filtering
    # 絞り込み条件が指定されていなかった場合はそのままゲーム情報を返す
    return @games if @where.nil?

    # 絞り込み条件を元にゲーム情報を絞り込む
    filtering_games = @games
    @where.each_pair do |key, value|
      # ゲーム情報からデータを絞り込む
      filtering_games = filtering_games.select do |game|
        if game[key].is_a?(Array)
          # 配列の時は対象の値が含まれている値があるものを取得し、
          # それが１件以上の時はtrueを返し、そうでない時はfalseを返す
          result = game[key].select { |a| a.multiple_include?(value) }
          result.size >= 1
        else
          # 配列でない時は対象の値が含まれている時はtrueを返し、そうでない時はfalseを返す
          game[key.to_sym].to_s.multiple_include?(value)
        end
      end
    end
    filtering_games
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
    #   LFはそのままLFとして書き込まれる
    File.open(path, 'wb') { |file| file.puts content }
  end

  # キャッシュファイルを作成する
  #   シリアライズしたものをキャッシュファイルとして保存する
  def create_cache(path, content)
    File.open(path, 'wb') do |file|
      serialize_file = Marshal.dump(content)
      file.puts(serialize_file)
    end
  end

  # キャッシュファイルを読み込む
  #   シリアライズされたキャッシュファイルをデシリアライズして読み込む
  def load_cache(cache_file)
    deserialize_file = ''
    File.open(cache_file, 'r') { |file| deserialize_file = file.read }
    Marshal.load(deserialize_file)
  end

  # キャッシュファイルが存在するか？
  def cached?(cache_file)
    File.exist?(cache_file)
  end

  # キャッシュファイルをクリアする
  #   キャッシュファイルを削除する。削除対象のキャッシュファイルが
  #   存在しない場合は何も行わない
  def clear_cache(cache_file)
    File.delete(cache_file) if cached?(cache_file)
  rescue StandardError => e
    raise e.class, 'キャッシュファイルの削除に失敗しました'
  end
end
