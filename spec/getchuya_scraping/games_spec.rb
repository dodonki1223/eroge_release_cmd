# frozen_string_literal: true

require './spec/spec_helper'
require './getchuya_scraping/games'
require './getchuya_scraping/cache'
require './getchuya_scraping/release_list_scraping'
require './getchuya_scraping/introduction_page_scraping'

describe Games do
  TARGET_YEAR_MONTH = '201902'

  let!(:release_list_instance) do
    ReleaseListScraping.new(TARGET_YEAR_MONTH)
  end
  let!(:release_list) do
    VCR.use_cassette 'release_list_scraping_release_list' do
      release_list_instance.scraping
    end
  end

  before do
    release_list.each do |game|
      VCR.use_cassette "introduction_page_scraping_game_info_#{game[:id]}" do
        IntroductionPageScraping.new(game[:id]).scraping
      end
    end

  end

  def filtering_games(title, brand_name, voice_actor)
    release_list_scraping = ReleaseListScraping.new(TARGET_YEAR_MONTH)
    allow(release_list_scraping).to receive_messages(scraping: release_list)
    allow(ReleaseListScraping).to receive(:new).with(TARGET_YEAR_MONTH).and_return(release_list_scraping)

    games = Games.new(false, TARGET_YEAR_MONTH)
    games.where.store(:title, title) unless title.empty?
    games.where.store(:brand_name, brand_name) unless brand_name.empty?
    games.where.store(:voice_actor, voice_actor) unless voice_actor.empty?
    games.game_list
  end

  describe '.initialize' do
    it 'キャッシュがクリアされること' do
      cache = Cache.new(TARGET_YEAR_MONTH)
      allow(cache).to receive_messages(cached?: true, clear_cache: '', load_cache: '', create_cache: '')
      allow(Cache).to receive(:new).with(TARGET_YEAR_MONTH).and_return(cache)

      expect(Games.new(true, TARGET_YEAR_MONTH).cache).to have_received(:clear_cache).once
    end
    it 'キャッシュがクリアされないこと' do
      cache = Cache.new(TARGET_YEAR_MONTH)
      allow(cache).to receive_messages(cached?: true, clear_cache: '', load_cache: '', create_cache: '')
      allow(Cache).to receive(:new).with(TARGET_YEAR_MONTH).and_return(cache)

      expect(Games.new(false, TARGET_YEAR_MONTH).cache).not_to have_received(:clear_cache)
    end
    it 'キャッシュファイルが作成されないこと' do
      cache = Cache.new(TARGET_YEAR_MONTH)
      allow(cache).to receive_messages(cached?: true, clear_cache: '', load_cache: '', create_cache: '')
      allow(Cache).to receive(:new).with(TARGET_YEAR_MONTH).and_return(cache)

      expect(Games.new(false, TARGET_YEAR_MONTH).cache).not_to have_received(:create_cache)
    end
    # TODO: create_gamesをなんとかする
    # it 'キャッシュファイルが作成されること' do
    #   cache = Cache.new(TARGET_YEAR_MONTH)
    #   allow(cache).to receive_messages(cached?: false, clear_cache: '', load_cache: '', create_cache: '')
    #   allow(Cache).to receive(:new).with(TARGET_YEAR_MONTH).and_return(cache)
    #
    #   expect(Games.new(true, TARGET_YEAR_MONTH).cache).to have_received(:create_cache).once
    # end
  end

  describe '.game_list' do
    let!(:filtering_title) { filtering_games('金色', '', '') }
    let!(:filtering_brand) { filtering_games('', 'SAGA PLANETS', '') }
    let!(:filtering_voice_actor) { filtering_games('', '', %w[遥そら 風音]) }
    let!(:filtering_all) { filtering_games('金色', 'SAGA PLANETS', %w[遥そら 風音]) }
    let!(:filtering_nothing) { filtering_games('', '', '') }

    it { expect(filtering_title.count).to eq(5) }
    it { expect(filtering_brand.count).to eq(1) }
    it { expect(filtering_voice_actor.count).to eq(4) }
    it { expect(filtering_all.count).to eq(1) }
    it { expect(filtering_nothing.count).to eq(69) }
  end
end
