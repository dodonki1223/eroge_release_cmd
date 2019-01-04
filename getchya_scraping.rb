require 'nokogiri'
require 'open-uri'

# げっちゅ屋スクレイピングクラス
# げっちゅ屋のスクレイピングで使用するクラスです
class GetchyaScraping
  include Enumerable

  # げっちゅ屋のルートURL
  ROOT_URI = "http://www.getchu.com"
  # 「あなたは18歳以上ですか？」のページが表示されないようにするためのCookie設定
  COOKIE_OPTION = "getchu_adalt_flag=getchu.com"

  # URI作成
  #   URIとURLパラメーターを使用してURIを作成する
  #   URLパラメーターが存在しない時はそのままURIを返し、URLパラメーターが存在する
  #   時はURIにURLパラメーターを付加した形で返す
  def self.create_uri(uri, url_param = nil)
    return uri if url_param.nil?
    converting_url_param = URI.encode_www_form(url_param)
    uri + "?" + converting_url_param
  end

  # URIからNokogiriで解析後のhtmlを取得
  #   URIからhtmlを取得し、Nokogiriで読み込ませたhtmlを解析したものを取得する
  def self.parsed_html_for_uri(uri)
    # 対象のURIを解析する
    # ※URI::Generic のサブクラスのインスタンスを生成して返す
    #   scheme が指定されていない場合は、URI::Generic オブジェクトを返す
    html = URI.parse(uri)

    # 対象のURLを開き、Cookie情報を追加（追加のヘッダフィールドを指定する）
    # ※self.open(options={}).readと同じ
    #   htmlとして読み込ませる
    html = html.read({ "Cookie" => COOKIE_OPTION })

    # 対象のURLの文字コードを取得する
    # ※文字コードは「Content-Type ヘッダの文字コード情報」から取得する
    char = html.charset

    # Nokogiriで対象の読み込ませたhtmlを解析する
    parsed_html = Nokogiri::HTML.parse(html, nil, char)
  end

end