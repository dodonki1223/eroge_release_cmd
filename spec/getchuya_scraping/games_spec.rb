# frozen_string_literal: true

require './spec/spec_helper'
require './getchuya_scraping/games'
require './getchuya_scraping/cache'
require './getchuya_scraping/release_list_scraping'
require './getchuya_scraping/introduction_page_scraping'

describe Games do
  def filtering_games(title, brand_name, voice_actor)
    games = Games.new(false, '201902')
    games.where.store(:title, title) unless title.empty?
    games.where.store(:brand_name, brand_name) unless brand_name.empty?
    games.where.store(:voice_actor, voice_actor) unless voice_actor.empty?
    games.game_list
  end

  let!(:release_list_instance) do
    ReleaseListScraping.new('201902')
  end
  let!(:release_list) do
    VCR.use_cassette 'release_list_scraping_release_list' do
      # ReleaseListScraping.new('201902').scraping.last(10)
      release_list_instance.scraping
    end
  end

  before do
    # release_list_instance = ReleaseListScraping.new('201902')
    # allow(release_list_instance).to receive(:scraping).and_return(release_list)

    allow(ReleaseListScraping).to receive(:new).and_return(release_list_instance)
    allow(release_list_instance).to receive(:scraping).and_return(release_list)
    # allow(ReleaseListScraping.new('201902')).to receive(:scraping).and_return(release_list)


    # allow(ReleaseListScraping).to receive_message_chain(:new, :scraping).with('201902').with(no_args).and_return(release_list)
    # allow(ReleaseListScraping).to receive_message_chain(:new, :year).with('201902').with(no_args).and_return('2019')
    # allow(ReleaseListScraping).to receive_message_chain(:new, :month).with('201902').with(no_args).and_return('02')
    release_list.each do |game|
      VCR.use_cassette "introduction_page_scraping_game_info_#{game[:id]}" do
        IntroductionPageScraping.new(game[:id]).scraping
      end
    end
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

  describe '.to_json' do

  end

  describe '.create_json' do

  end



  describe '.new' do
    context 'キャッシュファイルが存在する時' do

      # let!(:test) { Games.new(true, '201902') }

      it 'キャッシュクリア区分がtrueの時はキャッシュが削除されること' do
        # # instance = instance_double('Cache', release_list: 'return message!')
        # # puts instance.release_list
        #
        # allow(File).to receive(:exist?).and_return(false)
        #
        # # cache = Cache.new('201902')
        # # allow(cache).to receive_messages(cached?: false, clear_cache: '', load_cache: '')
        # # allow(Games.new(true, '201902')).to receive(:cache).and_return(cache)
        # # allow(Games).to receive(cache).and_return(cache)
        # #
        # #
        # # test = Games.new(true, '201902')
        # # allow(test).to receive(:cache).and_return(cache)
        # # allow(Games).to receive_message_chain(:new, :cache).with(true, '201902').with(no_args).and_return(cache)
        # # test = Games.new(true, '201902').cache
        #
        #
        # # puts test.clear_cache
        #
        # # p test.public_methods
        # # allow(test.cache).to receive(:clear_cache)
        # # puts test.cache.clear_cache
        #
        # # allow(test).to receive(:cache).and_return(cache)
        # # puts test.cache.clear_cache
        # # allow(Cache).to receive_message_chain(:new, :cached?).with('201902').with(no_args).and_return(true)
        # # allow(test).to receive(:clear_cache)
        #
        # # puts test.clear_cache
        #
        # test = Games.new(true, '201902')
        # allow(File).to receive(:exist?).and_return(true)
        # # FileクラスのdeleteがStandardErrorを返すように偽装する
        # allow(File).to receive(:delete).and_return(true)
        #
        # expect(File).to have_received(:delete).with(test.cache.full_path)
        # # expect(test.cache).to receive(:clear_cache)
      end

      context 'キャッシュファイルが存在しない時' do

      end
    end

    # it 'キャッシュクリア区分がfalseの時はキャッシュが削除されないこと' do
    #
    # end
  end
end
