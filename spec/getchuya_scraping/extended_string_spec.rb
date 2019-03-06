# frozen_string_literal: true

require './spec/spec_helper'
require './getchuya_scraping/extended_string'

describe String do
  describe '#multiple_include?' do
    let(:true_result_not_array) { 'Hello World!!'.multiple_include?('llo') }
    let(:false_result_not_array) { 'Hello World!!'.multiple_include?('aaaa') }
    let(:true_result_array) { 'Hello World!!'.multiple_include?(%w[World Hello aaaaa]) }
    let(:false_result_array) { 'Hello World!!'.multiple_include?(%w[Worlb Hellaaa aaaaa]) }

    it { expect(true_result_not_array).to be_truthy }
    it { expect(false_result_not_array).to be_falsey }
    it { expect(true_result_array).to be_truthy }
    it { expect(false_result_array).to be_falsey }
  end
end
