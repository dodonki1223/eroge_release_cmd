# frozen_string_literal: true

require './eroge_release/getchuya_scraping/getchuya_scraping'
require 'date'

module ErogeRelease
  # げっちゅ屋の「月発売タイトル一覧・ゲーム」ページをスクレイピングし
  # 発売リスト情報を取得するスクレイピングクラス
  class ReleaseListScraping < GetchuyaScraping
    attr_accessor :year_month, :year, :month, :uri

    # げっちゅ屋の「月別発売タイトル一覧・ゲーム」ページURL
    RELEASE_LIST_URI = ROOT_URI + '/all/price.html'
    # ゲームの紹介ページの共通URL
    INTRODUCTION_PAGE_URI = ROOT_URI + '/soft.phtml?id='

    # コンストラクタ
    #   年月の文字列を引数で受け取り、不正だった場合は例外を発生させる
    #   引数がなかった時は年、月には現在日付のものをセットする
    #   インスタンス変数の初期化（年、月、年URLパラメーター、月URLパラメーター、発売リスト）
    def initialize(year_month = nil)
      # 引数がなかった場合は現在日付の年月の文字列を取得する
      year_month  = Date.today.strftime('%Y%m').to_s if year_month.nil?
      @year_month = year_month

      # 6桁でなかった場合は例外を発生させる
      # ※yyyymmの形式で引数来ることを想定しているため
      raise ArgumentError, '「%Y%m」で年月を指定して下さい' if year_month.length != 6

      # 年月の文字列から「年」、「月」を作成
      @year  = year_month.to_s[0, 4]
      @month = year_month.to_s[4, 2]

      # 年、月の値が不正だった場合は例外を発生させる
      raise ArgumentError, '年が不正です（2012年より指定して下さい）' unless @year.to_i.between?(2012, 2999)
      raise ArgumentError, '月が不正です（01〜12で指定して下さい）'  unless @month.to_i.between?(1, 12)

      @url_param_year      = ['year', @year]                                   # 年月の文字列から「年」のURLパラメーターを作成
      @url_param_month     = ['month', @month]                                 # 年月の文字列から「月」のURLパラメーターを作成
      @release_list        = []                                                # XXXX年XX月のゲームの発売リストを保持する変数に初期値をセット
      @fixed_url_parameter = [%w[genre pc_soft], %w[gall all], %w[gage adult]] # げっちゅ屋の「月別発売タイトル一覧・ゲーム」ページの固定のURLパラメーター(アダルトの作品のみを対象とする)
      @uri                 = target_uri                                        # スクレイピングする対象のURLをセット
    end

    # スクレイピング
    #   げっちゅ屋の「月別発売タイトル一覧・ゲーム」ページURLからゲーム情報を取得する
    def scraping
      # スクレイピング対象のURLを作成し、そのURLをNokogiriで解析した結果を取得
      uri = target_uri
      parsed_html = GetchuyaScraping.parsed_html_for_uri(uri)

      # 解析した結果からtrタグごと繰り返す
      parsed_html.css('table > tr').each do |tr|
        # bgcolorが"#ffffff"でなかったら次の要素へ
        next unless tr[:bgcolor].to_s.include?('#ffffff')
        # tdタグ内の要素が４以外の時は次の要素へ
        # ※4の時は特典別に定価が別れている時なのでその時は無視する
        next unless tr.css('td').to_a.length != 4

        # ゲーム情報を格納するHashを初期化する
        game = {}

        # trタグ内のtdタグごと繰り返す
        tr.css('td').each do |td|
          game[:release_date]      = "#{@year}/#{scraping_date(td)}" unless scraping_date(td).nil?
          game[:title]             = scraping_title(td) unless scraping_title(td).nil?
          game[:id]                = scraping_id(td) unless scraping_id(td).nil?
          game[:introduction_page] = INTRODUCTION_PAGE_URI + game[:id] unless game[:id].nil?
          game[:brand_name]        = scraping_brand_name(td) unless scraping_brand_name(td).nil?
          game[:price]             = scraping_price(td) unless scraping_price(td).nil?
        end

        # 取得したゲームの情報をゲームの発売リストに追加
        @release_list.push(game)
      end
      @release_list
    end

    private

    # スクレイピング対象のURLを取得する
    #   URLパラメーターも付加した形で取得する
    def target_uri
      GetchuyaScraping.create_uri(RELEASE_LIST_URI, url_param)
    end

    # URLパラメーター
    #   固定のURLパラメーターと変化するURLパラメーターを結合してスクレイピング対象の
    #   発売リストページのURLパラメーターを作成する
    def url_param
      @fixed_url_parameter.push(@url_param_year, @url_param_month)
    end

    # 発売日をスクレイピングする
    #   「日付」項目 <tr align="center" class="balack">の部分を取得し返す
    #   日付の部分には改行文字・タブ文字があるので削除して日付を取得する
    def scraping_date(td)
      if td[:align].to_s.include?('center') && td[:class].to_s.include?('black')
        td.content.to_s.gsub(/[\r\n]/, '').to_s.gsub(/[\t]/, '')
      end
    end

    # ソフト名をスクレイピングする
    #   ソフト名 <tr align="left">の部分を取得し返す
    def scraping_title(td)
      if td[:align].to_s.include?('left')
        # <a>タグが存在すること
        return td.content unless td.css('a').empty?
      end
    end

    # IDをスクレイピングする
    #   ID <tr align="left">の部分を取得しそこから６桁以上の数値を取得し返す
    #   IDは6、7桁のようだ
    def scraping_id(td)
      return nil unless td[:align].to_s.include?('left')

      # class="black" を含まないタグであり、<a>タグが存在した時
      if td[:class].to_s.include?('black') == false && td.css('a').empty? == false
        # 6〜7桁の数値を抜き出して返す
        return /[0-9]{6,}/.match(td.css('a').first[:href]).to_s
      end
    end

    # ブランド名をスクレイピングする
    #   ブランド名 <tr align="left" class="balack">の部分を取得し返す
    def scraping_brand_name(td)
      return td.content if td[:align].to_s.include?('left') && td[:class].to_s.include?('black')
    end

    # 定価をスクレイピングする
    #   定価 <tr align="right" class="balack">の部分を取得し返す
    def scraping_price(td)
      return td.content if td[:align].to_s.include?('right') && td[:class].to_s.include?('black')
    end
  end
end
