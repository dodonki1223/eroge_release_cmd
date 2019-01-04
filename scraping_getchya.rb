require './getchya_scraping.rb'
require './release_list_scraping.rb'
require './introduction_page_scraping.rb'
require 'date'

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

# # 固定のURLパラメーターと変化するURLパラメーターから対象年月のURLパラメータを作成
# url_parameter = URI.encode_www_form(FIXED_URL_PARAMETER.push(url_parameter_year, url_parameter_month))

# 固定のURLパラメーターと変化するURLパラメーターから対象年月のURLパラメータを作成
target_uri = GetchyaScraping::create_uri(GETCHYA_URI, FIXED_URL_PARAMETER.push(url_parameter_year, url_parameter_month))
parsed_html = GetchyaScraping::parsed_html_for_uri(target_uri)

# XXXX年XX月のゲームの発売リストを保持する変数を作成
game_list = []

# --------------------------------------
# * げっちゅ屋よりスクレイピングする
# --------------------------------------
parsed_html.css('table > tr').each do |tr| 

  # bgcolorが"#ffffff"でなかったら次の要素へ
  next unless tr[:bgcolor].to_s.include?("#ffffff")
  # tdタグ内の要素が４以外の時は次の要素へ
  # ※4の時は特典別に定価が別れている時なのでその時は無視する
  next unless tr.css("td").to_a.length != 4

  # ゲーム情報を保持するHashをすべて空文字で初期化する
  game = { :id => "", :title => "",  :package_image => "", :release_date => "", :brand_name => "", :brand_page => "", :voice_actor => "", :price => "", :introduction_page => "" }
  tr.css("td").each do |td|

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

# # --------------------------------------
# # * 取得できたゲームの一覧を表示する
# # --------------------------------------
# game_list.each do |game| 
#   puts game[:id]
#   puts game[:title]
#   puts game[:release_date]
#   puts game[:brand_name]
#   puts game[:price]
#   puts game[:introduction_page]
#   puts " "
# end

test = ReleaseListScraping.new("201901")
test.scraping
# test.game_list
puts test.target_uri

puts test.game_list

# test2 = IntroductionPageScraping.new("1026277")
# puts test2.id
# puts test2.target_uri

# test2.scraping