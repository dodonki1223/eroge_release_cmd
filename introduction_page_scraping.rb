# frozen_string_literal: true

require './getchya_scraping.rb'

# げっちゅ屋の「ゲーム紹介」ページをスクレイピングし
# ゲーム情報を取得するスクレイピングクラス
class IntroductionPageScraping < GetchyaScraping
  attr_accessor :id, :uri

  # げっちゅ屋の「ゲーム紹介」ページURL
  INTRODUCTION_PAGE_URI = ROOT_URI + '/soft.phtml'

  # コンストラクタ
  #   IDを引数で受け取り、もしIDが存在しなかった場合は引数エラーの例外を発生させる
  #   ※必ずIDを指定してすることを強制させるためである
  def initialize(id)
    # IDがnilの場合は引数エラーの例外を発生させる
    raise ArgumentError, 'IDは必ず指定して下さい' if id.nil?

    @id = id                                                            # スクレイピングするゲームのID（げっちゅ屋が管理しているID）
    @url_parameter_id = ['id', id]                                      # URLパラメータのID
    @game_info = { package_image: '', brand_page: '', voice_actor: '' } # スクレイピングしたゲーム情報を格納するHash
    @uri = target_uri                                                   # スクレイピング対象のURL
  end

  # スクレイピング
  #   げっちゅ屋の「ゲーム紹介ページ」からゲーム情報を取得する
  def scraping
    # スクレイピング対象のURLを作成し、そのURLをNokogiriで解析した結果を取得
    uri = target_uri
    parsed_html = GetchyaScraping.parsed_html_for_uri(uri)

    # 紹介ページからゲーム情報をスクレイピングする
    @game_info[:package_image] = scraping_package_image(parsed_html)
    @game_info[:brand_page] = scraping_brand_page(parsed_html)
    @game_info[:voice_actor] = scraping_voice_actors(parsed_html)
    @game_info
  end

  private

  # スクレイピング対象のURLを取得する
  #   URLパラメーターも付加した形で取得する
  def target_uri
    GetchyaScraping.create_uri(INTRODUCTION_PAGE_URI, url_param)
  end

  # URLパラメーター
  #   IDのURLパラメーターを返す
  def url_param
    [@url_parameter_id]
  end

  # パッケージ画像をスクレイピングする
  #   パッケージ画像のURLを取得し返す
  def scraping_package_image(html)
    # パッケージ画像名を作成
    # ※「rc + id + package」の形式になります
    image_file_name = 'rc' + @id + 'package.'
    # 「highslide」クラスを持つ要素ごと繰り返す
    html.css('.highslide').each do |elem|
      # パッケージ画像でなかったら次の要素へ
      next unless elem.to_s.include?(image_file_name)

      # パッケージ画像の相対パスを取得し「/」の部分を削除しフルURLを作成し返す
      package_image_url = elem[:href].to_s
      package_image_url.slice!(0, 1)
      return ROOT_URI + package_image_url
    end
  end

  # 対象のゲームのブランドの公式ページをスクレイピングする
  #   ブランドの公式ページのURLを取得し返す
  def scraping_brand_page(html)
    html.css('table > tr > td > a').each do |a|
      # パッケージ画像でなかったら次の要素へ
      next unless a[:title].to_s.include?('このブランドの公式サイトを開く')

      return a[:href]
    end
  end

  # ゲームに出演している声優情報をスクレイピングする
  #   声優情報を取得し返す
  def scraping_voice_actors(html)
    voice_actors = []
    html.css('h2.chara-name').each do |h2|
      # 「CV：xxxxxx」の形式から「CV：」を除いて取得する
      voice_actor_name = /CV：.+/.match(h2).to_s
      # 「CV：xxxxxx」の形式のものから声優名を取得できた時は追加する
      unless voice_actor_name.empty?
        voice_actor_name.slice!(0, 3)
        voice_actors.push(voice_actor_name)
      end
    end
    voice_actors
  end
end
