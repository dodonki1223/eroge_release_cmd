# frozen_string_literal: true

require './eroge_release/cache/cache'

# Cacheクラスのヘルパーモジュール
# CacheのMockの機能を提供します
module CacheHelper
  # CacheクラスのMockを作成する
  #   キャッシュファイルの作成しない、読み込まない、クリアしないものを作成する
  def create_cache_mock(cached, year_month)
    cache = ErogeRelease::Cache.new(year_month, ErogeRelease::Games::CACHE_PATH)
    allow(cache).to receive_messages(cached?: cached, clear_cache: '', load_cache: '', create_cache: '')
    allow(ErogeRelease::Cache).to receive(:new).with(year_month, ErogeRelease::Games::CACHE_PATH).and_return(cache)
    cache
  end
end
