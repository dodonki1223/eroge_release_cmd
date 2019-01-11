# frozen_string_literal: true

source 'https://rubygems.org'

git_source(:github) { |repo_name| "https://github.com/#{repo_name}" }

# gem "rails"

# スクレイピングをするためのライブラリ
# ※1.9.0以上2.0.0未満の最新のものを使用
gem 'nokogiri', '~> 1.9'

# 開発用グループ
group :development do
  # RubyのLintツール
  # ※0.62.0以上1.0.0未満の最新のものを使用
  #   「require: false」の記述は個別ごとrequireする必要がある
  gem 'rubocop', '~> 0.62', require: false
end
