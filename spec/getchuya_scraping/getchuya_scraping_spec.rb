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
end
