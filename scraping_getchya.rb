require 'nokogiri'
require 'open-uri'

# --------------------------------------
# * 定数
# --------------------------------------
# げっちゅ屋の「月別発売タイトル一覧・ゲーム」ページURL
GETCHYA_URI = "http://www.getchu.com/all/price.html"
# げっちゅ屋の「月別発売タイトル一覧・ゲーム」ページの固定のURLパラメーター
# ※さらに「年」、「月」のパラメータがある
FIXED_URL_PARAMETER = [["genre", "pc_soft"], ["gall", "all"]]
# 「あなたは18歳以上ですか？」のページが表示されないようにするためのCookie設定
COOKIE_OPTION = "getchu_adalt_flag=getchu.com"

# --------------------------------------
# * スクレイピング対象のURLを作成
# --------------------------------------
# 変化するURLパラメーターを設定
# ※今後はここを動的に設定できるようにする
url_parameter_year = ["year", "2018"]
url_parameter_month = ["month", "12"]

# 固定のURLパラメーターと変化するURLパラメーターから対象年月のURLパラメータを作成
url_parameter = URI.encode_www_form(FIXED_URL_PARAMETER.push(url_parameter_year, url_parameter_month))

# URLパラーメータを付加した形のものを作成
target_uri = GETCHYA_URI + "?" + url_parameter

# --------------------------------------
# * URI情報を取得する
# --------------------------------------
# 対象のURIを解析する
# ※URI::Generic のサブクラスのインスタンスを生成して返す
#   scheme が指定されていない場合は、URI::Generic オブジェクトを返す
html = URI.parse(target_uri)

# 対象のURLを開き、Cookie情報を追加（追加のヘッダフィールドを指定する）
# ※self.open(options={}).readと同じ
#   htmlとして読み込ませる
html = html.read({ "Cookie" => COOKIE_OPTION })

# 対象のURLの文字コードを取得する
# ※文字コードは「Content-Type ヘッダの文字コード情報」から取得する
html_char = html.charset

# Nokogiriで対象の読み込ませたhtmlを解析する
parsed_html = Nokogiri::HTML.parse(html, nil, html_char)

# --------------------------------------
# * げっちゅ屋よりスクレイピングする
# --------------------------------------
parsed_html.css('table > tr').each do |target_tr| 

  # bgcolorが"#ffffff"でなかったら次の要素へ
  next unless target_tr[:bgcolor].to_s.include?("#ffffff")

  target_tr.css("td").each do |td|

    # 日付 <tr align="center" rowspan="2" class="balack">の部分を取得
    if td[:align].to_s.include?("center") && td[:rowspan].to_s.include?("2") && td[:class].to_s.include?("black")
      puts td.content
    end

    # ソフト名 <tr align="left" rowspan="2">の部分を取得
    if td[:align].to_s.include?("left") && td[:rowspan].to_s.include?("2")
      # class="black" を含まないタグであること
      unless td[:class].to_s.include?("black")
        puts td.content
      end
    end

    # ソフト紹介ページ <tr align="left" rowspan="2">の部分を取得
    if td[:align].to_s.include?("left") && td[:rowspan].to_s.include?("2")
      # class="black" を含まないタグであること
      unless td[:class].to_s.include?("black")
        td.css("a").each do |a|
          puts "http://www.getchu.com/all/" + a[:href]
        end
      end
    end

    # ID <tr align="left" rowspan="2">の部分を取得しそこから７桁の数値を取得する
    if td[:align].to_s.include?("left") && td[:rowspan].to_s.include?("2")
      # class="black" を含まないタグであること
      unless td[:class].to_s.include?("black")
        td.css("a").each do |a|
          puts /[0-9]{7}/.match(a[:href])
        end
      end
    end

    # メーカー名 <tr align="left" rowspan="2" class="balack">の部分を取得
    if td[:align].to_s.include?("left") && td[:rowspan].to_s.include?("2") && td[:class].to_s.include?("black")
      puts td.content
    end

    # 定価 <tr align="right" rowspan="2" class="balack">の部分を取得
    if td[:align].to_s.include?("right") && td[:rowspan].to_s.include?("2") && td[:class].to_s.include?("black")
      puts td.content
    end

  end

end
