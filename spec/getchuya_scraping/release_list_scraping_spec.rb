# frozen_string_literal: true

require './spec/spec_helper'
require './getchuya_scraping/release_list_scraping.rb'

describe ReleaseListScraping do
  let!(:release_list_scraping) { described_class.new('201903') }

  describe '.scraping' do
    let(:release_list) do
      VCR.use_cassette 'release_list_scraping_release_list' do
        release_list_scraping.scraping
      end
    end

    # release_listが配列で１つ目の要素がHashで６つのKeyを持つかテスト
    it { expect(release_list[0]).to include(:release_date, :title, :introduction_page, :id, :brand_name, :price) }

    # スクレイピングした結果、値が取得できていることをテスト
    it { expect(release_list[0][:release_date]).not_to eq '' }
    it { expect(release_list[0][:title]).not_to eq '' }
    it { expect(release_list[0][:introduction_page]).not_to eq '' }
    it { expect(release_list[0][:id]).not_to eq '' }
    it { expect(release_list[0][:brand_name]).not_to eq '' }
    it { expect(release_list[0][:price]).not_to eq '' }
  end
end
