# frozen_string_literal: true

require './release_list_scraping.rb'
require './introduction_page_scraping.rb'
require './getchya_scraping.rb'
require 'json'

# げっちゅ屋のゲーム情報を管理するクラス
# 発売リストページ、ゲーム紹介ページからスクレイピングした結果を保持
# する。その情報を加工・検索してデータを取得することができる
class Games
  attr_accessor :games, :year_month, :year, :month

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
  #   ゲーム情報をげっちゅ屋からスクレイピングしその結果をjson形式に
  #   変換して返す
  def to_json
    @games.to_json
  end

  private

  # ゲーム情報を取得する
  #   ゲーム情報をげっちゅ屋からスクレイピングして取得する
  #   インスタンス変数のgames、year、monthに値をセットする
  def get_games(year_month)
    # げっちゅ屋の「月発売タイトル一覧・ゲーム」の一覧を取得する
    release_list_scraping = ReleaseListScraping.new(year_month)
    release_list = release_list_scraping.scraping

    # 年、月情報をセットする
    @year = release_list_scraping.year
    @month = release_list_scraping.month

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
end
