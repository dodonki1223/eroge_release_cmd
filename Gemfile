# frozen_string_literal: true

source 'https://rubygems.org'

git_source(:github) { |repo_name| "https://github.com/#{repo_name}" }

# スクレイピングをするためのライブラリ
# ※1.9.0以上2.0.0未満の最新のものを使用
gem 'nokogiri', '~> 1.9'

# GoogleDriveを使用するためのライブラリ
gem 'google_drive'

# confファイルの読み込んで使用できるようになるライブラリ
gem 'inifile'

# 開発用グループ
group :development do
  # RubyのLintツール
  # ※0.62.0以上1.0.0未満の最新のものを使用
  #   「require: false」の記述は個別ごとrequireする必要がある
  gem 'rubocop', '~> 0.62', require: false
  # Rspec用のrubocop
  gem 'rubocop-rspec'
  # Rubyのテストフレームワーク
  # ※Ruby における BDD (behavior driven development、ビヘイビア駆動開発) の ためのテストフレームワーク
  gem 'rspec', '>= 3.8.0'
  # httpリクエストをスタブ化するライブラリ
  gem 'webmock'
  # テストで使う「HTTP通信」を１回目に記録しておいて、２回目以降のテストでの実行時間を短縮し、効率的な
  # テストを支援してくれるGem（「酒と涙とRubyとRailsと」より）
  gem 'vcr'
  # テストカバレッジを取得
  gem 'simplecov'
end
