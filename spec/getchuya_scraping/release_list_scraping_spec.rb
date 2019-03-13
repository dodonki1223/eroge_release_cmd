# frozen_string_literal: true

require './spec/spec_helper'
require './getchuya_scraping/release_list_scraping.rb'

describe ReleaseListScraping do
  let!(:release_list_scraping) { described_class.new('201903') }

  describe '#scraping' do
    let(:release_list) do
      VCR.use_cassette 'release_list' do
        release_list_scraping.scraping
      end
    end
    let(:first_elemet) { release_list[0] }

    # release_listが配列で１つ目の要素がHashで６つのKeyを持つかテスト
    it { expect(first_elemet).to include(:release_date, :title, :introduction_page, :id, :brand_name, :price) }

    # スクレイピングした結果、値が取得できていることをテスト
    it { expect(first_elemet[:release_date]).not_to eq '' }
    it { expect(first_elemet[:title]).not_to eq '' }
    it { expect(first_elemet[:introduction_page]).not_to eq '' }
    it { expect(first_elemet[:id]).not_to eq '' }
    it { expect(first_elemet[:brand_name]).not_to eq '' }
    it { expect(first_elemet[:price]).not_to eq '' }
  end
end
