require 'nokogiri'
require 'open-uri'

# --------------------------------------
# * 定数
# --------------------------------------
# げっちゅ屋の「ゲームの紹介」ページURL
GETCHYA_GAME_URI = "http://www.getchu.com/soft.phtml"
# 「あなたは18歳以上ですか？」のページが表示されないようにするためのCookie設定
COOKIE_OPTION = "getchu_adalt_flag=getchu.com"
# ゲームID ゲーム固定のID
GAME_ID = "1026277"

# --------------------------------------
# * スクレイピング対象のURLを作成
# --------------------------------------
# 変化するURLパラメーターを設定
# ※今後はここを動的に設定できるようにする
url_parameter_id = [["id", GAME_ID]]

# 固定のURLパラメーターと変化するURLパラメーターから対象年月のURLパラメータを作成
url_parameter = URI.encode_www_form(url_parameter_id)

# URLパラーメータを付加した形のものを作成
target_uri = GETCHYA_GAME_URI + "?" + url_parameter

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
# * ゲーム紹介ページよりスクレイピングする
# --------------------------------------
# パッケージ画像名を作成
image_file_name = "rc" + GAME_ID + "package." 

# パッケージ画像名を取得する
parsed_html.css('.highslide').each do |elem| 

  # パッケージ画像でなかったら次の要素へ
  next unless elem.to_s.include?(image_file_name)

  # パッケージ画像の相対パスを取得し「./」の部分を削除しフルURLを作成
  package_image_url = elem[:href].to_s
  package_image_url.slice!(0, 2)
  package_image_url = "http://www.getchu.com/" + package_image_url

  puts package_image_url

end

# 対象のゲームのブランドの公式サイトのURLを取得する
parsed_html.css('table > tr > td > a').each do |target_a| 

  # パッケージ画像でなかったら次の要素へ
  next unless target_a[:title].to_s.include?("このブランドの公式サイトを開く")
  puts target_a[:href]

end

# 出演声優の一覧を取得する
parsed_html.css('h2.chara-name').each do |target_h2| 

  voice_actor_name = /CV：.+/.match(target_h2).to_s
  voice_actor_name.slice!(0, 3)
  puts voice_actor_name

end
