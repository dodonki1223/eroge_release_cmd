# frozen_string_literal: true

require './release_list_scraping.rb'
require './introduction_page_scraping.rb'
require './getchya_scraping.rb'

# ゲーム情報を格納する配列
game_list = []

# げっちゅ屋の「月発売タイトル一覧・ゲーム」の一覧を取得する
release_list_scraping = ReleaseListScraping.new
release_list = release_list_scraping.scraping

release_list.each do |game|
  # ゲームの紹介ページからスクレイピングし「パッケージ画像」、「ブランドページ」、「声優情報」を取得する
  introduction_page = IntroductionPageScraping.new(game[:id])
  # 「月発売タイトル一覧・ゲーム」と「パッケージ画像」、「ブランドページ」、「声優情報」をマージする
  merged_game = game.merge(introduction_page.scraping)
  game_list.push(merged_game)
end

# ゲームの情報を画面に出力
game_list.each do |game|
  puts game[:id]
  puts game[:title]
  puts game[:release_date]
  puts game[:brand_name]
  puts game[:price]
  puts game[:introduction_page]
  puts game[:package_image]
  puts game[:brand_page]
  puts game[:voice_actor].join(',')
  puts '-----------------------------------------------------------------'
end
