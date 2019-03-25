# frozen_string_literal: true

require './spec/spec_helper'
require './eroge_release/getchuya_scraping/introduction_page_scraping'

module ErogeRelease
  describe IntroductionPageScraping do
    let(:game_id) { '1004515' }
    let!(:introduction_page_scraping) { described_class.new(game_id) }

    describe '#scraping' do
      let(:game_info) do
        VCR.use_cassette 'game_info' do
          introduction_page_scraping.scraping
        end
      end

      # game_infoがHashで３つのKeyを持つかテスト
      it { expect(game_info).to include(:package_image, :brand_page, :voice_actor) }

      # スクレイピングした結果、値が取得できていることをテスト
      it { expect(game_info[:package_image]).not_to eq '' }
      it { expect(game_info[:brand_page]).not_to eq '' }
      it { expect(game_info[:voice_actor]).not_to eq '' }
    end
  end
end
