# frozen_string_literal: true

require './spec/spec_helper'
require './spec/support/cache_helper'
require './getchuya_scraping/games'
require './getchuya_scraping/cache'
require './getchuya_scraping/release_list_scraping'
require './getchuya_scraping/introduction_page_scraping'

describe Games do
  include CacheHelper
  TARGET_YEAR_MONTH = '201902'

  context 'when initialize process' do
    describe '#initialize' do
      context 'when a cache file exists' do
        before do
          create_cache_mock(true, TARGET_YEAR_MONTH)
        end

        let(:execute_clear_cache) { described_class.new(true, TARGET_YEAR_MONTH).cache }
        let(:not_execute_clear_cache) { described_class.new(false, TARGET_YEAR_MONTH).cache }

        it { expect(execute_clear_cache).to have_received(:clear_cache).once }
        it { expect(execute_clear_cache).not_to have_received(:create_cache) }
        it { expect(not_execute_clear_cache).not_to have_received(:clear_cache) }
        it { expect(not_execute_clear_cache).not_to have_received(:create_cache) }
      end

      context 'when cache file does not exist' do
        before do
          create_cache_mock(false, TARGET_YEAR_MONTH)
          # create_gamesが実行されると時間がかかってしまうので空文字を返すようにする
          allow_any_instance_of(described_class).to receive(:create_games).and_return('')
        end

        let(:cache) { described_class.new(true, TARGET_YEAR_MONTH).cache }

        it { expect(cache).to have_received(:clear_cache) }
        it { expect(cache).to have_received(:create_cache).once }
      end
    end
  end

  context 'when not initialize process' do
    let!(:games) do
      create_cache_mock(false, TARGET_YEAR_MONTH)
      VCR.use_cassette 'game_list' do
        @games = described_class.new(true, TARGET_YEAR_MONTH)
      end
      @games
    end

    describe '#set_search_condition' do
      let!(:title) do
        games.set_search_condition('title', 'タイトル')
        games.where[:title]
      end
      let!(:brand_name) do
        games.set_search_condition('brand_name', 'ブランド名')
        games.where[:brand_name]
      end
      let!(:voice_actor) do
        games.set_search_condition('voice_actor', %w[１人目 ２人目])
        games.where[:voice_actor]
      end

      it { expect(title).to eq 'タイトル' }
      it { expect(brand_name).to eq 'ブランド名' }
      it { expect(voice_actor).to eq %w[１人目 ２人目] }
    end

    describe '#game_list' do
      let(:filtering_title) do
        games.set_search_condition('title', '金色')
        games.game_list
      end
      let(:filtering_brand) do
        games.set_search_condition('brand_name', 'SAGA PLANETS')
        games.game_list
      end
      let(:filtering_voice_actor) do
        games.set_search_condition('voice_actor', %w[遥そら 風音])
        games.game_list
      end
      let(:filtering_all) do
        games.set_search_condition('title', '金色')
        games.set_search_condition('brand_name', 'SAGA PLANETS')
        games.set_search_condition('voice_actor', %w[遥そら 風音])
        games.game_list
      end
      let(:filtering_nothing) { games.game_list }

      it { expect(filtering_title.count).to eq(5) }
      it { expect(filtering_brand.count).to eq(1) }
      it { expect(filtering_voice_actor.count).to eq(4) }
      it { expect(filtering_all.count).to eq(1) }
      it { expect(filtering_nothing.count).to eq(69) }
    end

    describe '#to_json' do
      let!(:json) do
        games.set_search_condition('voice_actor', %w[遥そら 風音])
        JSON.parse(games.to_json)
      end
      let(:brand_name_includes) { json[3]['brand_name'] == 'SAGA PLANETS' }
      let(:title_includes) { json[3]['title'].include?('金色ラブリッチェ-Golden Time-') }
      let(:voice_actor_includes) { json[3]['voice_actor'].include?('遥そら') }

      it { expect(brand_name_includes).to be_truthy }
      it { expect(title_includes).to be_truthy }
      it { expect(voice_actor_includes).to be_truthy }
    end

    describe '#json_file_path' do
      subject { "#{Games::CREATED_PATH}#{games.year}#{games.month}.json" }

      it { is_expected.to eq games.json_file_path }
    end

    describe '#create_json' do
      let(:to_json) do
        games.set_search_condition('voice_actor', %w[遥そら 風音])
        StringIO.new(games.to_json)
      end
      let(:json) { JSON.parse(to_json.string) }

      before do
        allow(File).to receive(:open).and_yield(to_json)
        games.create_json
      end

      it { expect(json[3]['brand_name']).to eq 'SAGA PLANETS' }
    end

    describe '#csv_file_path' do
      subject { "#{Games::CREATED_PATH}#{games.year}#{games.month}.csv" }

      it { is_expected.to eq games.csv_file_path }
    end

    describe '#create_csv' do
      let(:string_io) { StringIO.new }
      let(:csv_content) { string_io.read.scan(/\[.*?\]/) }
      let(:header) { csv_content[0] }
      let(:exists_brand_name) { csv_content[4].include?('SAGA PLANETS') }
      let(:exists_voice_actor) { csv_content[4].include?('遥そら') }

      before do
        allow(CSV).to receive(:open).and_yield(string_io)
        games.set_search_condition('voice_actor', %w[遥そら 風音])
        games.create_csv
        string_io.rewind
      end

      it { expect(header).to eq Games::HEADER_COLUMNS.to_s }
      it { expect(exists_brand_name).to be_truthy }
      it { expect(exists_voice_actor).to be_truthy }
    end
  end
end
