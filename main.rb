require './release_list_scraping.rb'
require './introduction_page_scraping.rb'

test = ReleaseListScraping.new("201901")
test.scraping


game_list = []

gorira =  test.scraping
gorira.each do |game| 
  # ゲームの紹介ページからスクレイピングし「パッケージ画像」、「ブランドページ」、「声優情報」を取得する
  introductionPage = IntroductionPageScraping.new(game[:id])
  merged_game = game.merge(introductionPage.scraping)
  game_list.push(merged_game)
end

game_list.each do |game| 
  puts game[:id]
  puts game[:title]
  puts game[:release_date]
  puts game[:brand_name]
  puts game[:price]
  puts game[:introduction_page]
  puts game[:package_image]
  puts game[:brand_page]
  puts game[:voice_actor].join(",")
  puts " "
end