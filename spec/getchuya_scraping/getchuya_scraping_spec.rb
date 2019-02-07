# frozen_string_literal: true

require './spec/spec_helper'
require './getchuya_scraping/getchuya_scraping'

describe GetchuyaScraping do
  describe '.create_uri' do
    let(:not_exists_url_param) { described_class.create_uri('https://hogehoge') }
    let(:exist_url_param) { described_class.create_uri('https://hogehoge', [%w[genre pc_soft], %w[gall all]]) }

    it { expect(not_exists_url_param).to match('https://hogehoge') }
    it { expect(exist_url_param).to match('https://hogehoge?genre=pc_soft&gall=all') }
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
    let(:list_201902) do
      VCR.use_cassette 'list_201902' do
        http = Net::HTTP.new('www.getchu.com')
        http.get('/all/price.html?genre=pc_soft&year=2019&month=2&gage=&gall=all', Cookie: GetchuyaScraping::COOKIE_OPTION)
      end
    end

    it { expect(list_201902.code).to eq '200' }
  end
end
