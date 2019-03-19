# frozen_string_literal: true

require './spec/spec_helper.rb'
require './getchuya_scraping/getchuya_scraping.rb'

describe GetchuyaScraping do
  let(:uri_getchuya) { 'www.getchu.com' }
  let(:uri_game_list_201902) { '/all/price.html?genre=pc_soft&year=2019&month=2&gage=&gall=all' }
  let(:test_uri) { 'https://hogehoge' }

  describe '.create_uri' do
    let(:not_exists_url_param) { described_class.create_uri(test_uri) }
    let(:exist_url_param) { described_class.create_uri(test_uri, [%w[genre pc_soft], %w[gall all]]) }

    it { expect(not_exists_url_param).to match(test_uri) }
    it { expect(exist_url_param).to match("#{test_uri}?genre=pc_soft&gall=all") }
  end

  describe '.robots' do
    let(:robots) do
      VCR.use_cassette 'robots' do
        Net::HTTP.get_response(URI(GetchuyaScraping::ROBOTS_TXT_URL)).body
      end
    end
    let(:get_robots) do
      VCR.use_cassette 'get_robots' do
        described_class.robots
      end
    end

    it { expect(robots).to eq get_robots }
  end

  describe '.parsed_html_for_uri' do
    let(:release_list) do
      VCR.use_cassette 'release_list_201902' do
        http = Net::HTTP.new(uri_getchuya)
        http.get(uri_game_list_201902, Cookie: GetchuyaScraping::COOKIE_OPTION)
      end
    end

    it { expect(release_list.code).to eq '200' }
  end
end
