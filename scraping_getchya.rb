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
url_parameter_year = ["year", "2019"]
url_parameter_month = ["month", "01"]

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

# XXXX年XX月のゲームの発売リストを保持する変数を作成
game_list = []

# --------------------------------------
# * げっちゅ屋よりスクレイピングする
# --------------------------------------
parsed_html.css('table > tr').each do |target_tr| 

  # bgcolorが"#ffffff"でなかったら次の要素へ
  next unless target_tr[:bgcolor].to_s.include?("#ffffff")
  # tdタグ内の要素が４以外の時は次の要素へ
  # ※4の時は特典別に定価が別れている時なのでその時は無視する
  next unless target_tr.css("td").to_a.length != 4

  # ゲーム情報を保持するHashをすべて空文字で初期化する
  game = { :id => "", :title => "",  :package_image => "", :release_date => "", :brand_name => "", :brand_page => "", :voice_actor => "", :price => "", :introduction_page => "" }
  target_tr.css("td").each do |td|

    # 日付 <tr align="center" class="balack">の部分を取得
    if td[:align].to_s.include?("center") && td[:class].to_s.include?("black")
      # 改行を削除して日付をセットする
      game[:release_date] = td.content.to_s.gsub(/[\r\n]/,"")
    end

    # ソフト名 <tr align="left">の部分を取得
    if td[:align].to_s.include?("left")
      # <a>タグが存在すること
      unless td.css("a").empty?
        game[:title] = td.content
      end
    end

    # ソフト紹介ページ <tr align="left">の部分を取得
    if td[:align].to_s.include?("left")
      # <a>タグが存在すること
      unless td.css("a").empty?
        game[:introduction_page] = "http://www.getchu.com/all/" + td.css("a").first[:href].to_s
      end
    end

    # ID <tr align="left">の部分を取得しそこから６桁以上の数値を取得する ６、７桁のIDのようだ
    if td[:align].to_s.include?("left")
      # class="black" を含まないタグであること、<a>タグが存在すること
      if td[:class].to_s.include?("black") == false && td.css("a").empty? == false
        game[:id] = /[0-9]{6,}/.match(td.css("a").first[:href]).to_s
      end
    end

    # ブランド名 <tr align="left" class="balack">の部分を取得
    if td[:align].to_s.include?("left") && td[:class].to_s.include?("black")
      game[:brand_name] = td.content
    end

    # 定価 <tr align="right" class="balack">の部分を取得
    if td[:align].to_s.include?("right") && td[:class].to_s.include?("black")
      game[:price] = td.content
    end

  end

  game_list.push(game)

end

# --------------------------------------
# * 取得できたゲームの一覧を表示する
# --------------------------------------
game_list.each do |game| 
  puts game[:id]
  puts game[:title]
  puts game[:release_date]
  puts game[:brand_name]
  puts game[:price]
  puts game[:introduction_page]
  puts " "
end
