require 'nokogiri'
require 'open-uri'

# Fetch and parse HTML document
# doc = Nokogiri::HTML(open('https://www.yahoo.co.jp/'))
# File.open("test.html","w") do |text|
#  text.puts(doc)
# end

# puts "### Yahooから取得するぞ"
# # doc.css('ul.emphasis li a').each do |link|
# doc.css('table > tr > td > a').each do |link| 
#   # aタグを取得し、hrefにpickupという文字列が存在したら画面に表示
#   # ※ニュースの部分を表示
#   puts link.content if link[:href].include?("pickup")
# end

cookie_option = "getchu_adalt_flag=getchu.com"
# uri = "http://www.getchu.com/all/price.html?genre=pc_soft&year=2018&month=12&gall=all"
uri = "http://www.getchu.com/all/price.html"
url_parameter = URI.encode_www_form([
    ["genre", "pc_soft"], 
    ["gall", "all"],
    ["year", "2018"], 
    ["month", "12"]
  ])
full_uri = uri + "?" + url_parameter

page = URI.parse(full_uri)

# p page.to_s
# p page.request_uri
# p page.scheme + "://" + page.host + page.path
# p page.scheme + "://" + page.host
# p page.scheme
# p page.userinfo
# p page.host
# p page.port
# p page.registry
# p page.path
# p page.opaque
# p page.query
# p page.fragment
# p page.to_s.length

page = page.read({ "Cookie" => cookie_option })

charset = page.charset
doc = Nokogiri::HTML(page, nil, charset)


# 取得したものをhtmlとして保存する
# File.open("test.html","w:UTF-8") do |text|
#  text.puts(doc)
# end

# 日付を取得する文字列
DAY_REGEXP = /id="[0-1][0-9]\/[0-3][0-9]"/

doc.css('table > tr').each do |link| 

  next unless link[:bgcolor].to_s.include?("#ffffff")

  link.css("td").each do |td|
    # 日付
    if td[:align].to_s.include?("center") && td[:rowspan].to_s.include?("2") && td[:class].to_s.include?("black")
      puts td.content
    end
    # ソフト名
    if td[:align].to_s.include?("left") && td[:rowspan].to_s.include?("2")
      unless td[:class].to_s.include?("black")
        puts td.content
      end
    end
    # ソフト紹介ページ
    if td[:align].to_s.include?("left") && td[:rowspan].to_s.include?("2")
      unless td[:class].to_s.include?("black")
        td.css("a").each do |a|
          puts "http://www.getchu.com/all/" + a[:href]
        end
      end
    end
    # メーカー名
    if td[:align].to_s.include?("left") && td[:rowspan].to_s.include?("2") && td[:class].to_s.include?("black")
      puts td.content
    end
    # 定価
    if td[:align].to_s.include?("right") && td[:rowspan].to_s.include?("2") && td[:class].to_s.include?("black")
      puts td.content
    end
  end

end
