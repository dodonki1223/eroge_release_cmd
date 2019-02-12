# frozen_string_literal: true

require 'bundler/setup'
require 'nokogiri'
require 'open-uri'

# げっちゅ屋スクレイピングクラス
# げっちゅ屋のスクレイピングで使用するクラスです
# ※create_uri、parsed_html_for_uriだけなのでmoduleでもいいような気がするが、今後
#   のことも考えとりあえずclassとする
class GetchuyaScraping
  # げっちゅ屋のルートURL
  ROOT_URI = 'http://www.getchu.com'
  # robots.txtのURL（クローラーのWEBページへのアクセスを制限するためのファイル）
  ROBOTS_TXT_URL = ROOT_URI + '/robots.txt'
  # ユーザーエージェント（自分のMac端末のUser-Agentをとりあえず設定する）
  # ※今後何を指定するのがいいのか検討する必要がある
  USER_AGENT = 'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_14_2) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/71.0.3578.98 Safari/537.36'
  # 「あなたは18歳以上ですか？」のページが表示されないようにするためのCookie設定
  COOKIE_OPTION = 'getchu_adalt_flag=getchu.com'

  # robots.txtの内容を取得
  #   げっちゅ屋のrobots.txtの内容を取得する
  #   クローラーのWEBページヘのアクセスを制限するためのファイルなので、スクレイピング
  #   する際はこのファイルの内容に従って行うこと
  def self.robots
    URI.parse(ROBOTS_TXT_URL).read
  end

  # URI作成
  #   URIとURLパラメーターを使用してURIを作成する
  #   URLパラメーターが存在しない時はそのままURIを返し、URLパラメーターが存在する
  #   時はURIにURLパラメーターを付加した形で返す
  def self.create_uri(uri, url_param = nil)
    return uri if url_param.nil?

    converting_url_param = URI.encode_www_form(url_param)
    uri + '?' + converting_url_param
  end

  # URIからNokogiriで解析後のhtmlを取得
  #   URIからhtmlを取得し、Nokogiriで読み込ませたhtmlを解析したものを取得する
  def self.parsed_html_for_uri(uri)
    # 対象のURIを解析する
    # ※URI::Generic のサブクラスのインスタンスを生成して返す
    #   scheme が指定されていない場合は、URI::Generic オブジェクトを返す
    html = URI.parse(uri)

    # CookieとUser-Agentを指定（追加のヘッダフィールドを指定する）し対象のURLを開く
    # ※self.open(options={}).readと同じ
    #   htmlとして読み込ませる
    html = html.read('Cookie' => COOKIE_OPTION, 'User-Agent' => USER_AGENT)

    # 対象のURLの文字コードを取得する
    # ※文字コードは「Content-Type ヘッダの文字コード情報」から取得する
    char = html.charset

    # Nokogiriで対象の読み込ませたhtmlを解析する
    Nokogiri::HTML.parse(html, nil, char)
  end
end
