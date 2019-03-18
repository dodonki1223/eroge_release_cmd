# frozen_string_literal: true

require './spec/spec_helper'
require './spec/support/spreadsheet_helper'
require './spec/support/cli_spec_behavior'
require './spreadsheet/spreadsheet'

describe Spreadsheet do
  include SpreadsheetHelper

  describe '#initialize' do
    include_context 'when disable standard output'
    let(:spreadsheet) { described_class.new('hoge') }

    it { expect { spreadsheet }.to raise_error(Google::Apis::ClientError) }
  end

  describe '#delete_worksheet_by_title' do
    include_context 'when disable standard output'
    let(:spreadsheet) { described_class.new('hoge') }
    let(:worksheet) { spreadsheet.delete_worksheet_by_title('hoge') }

    it 'ワークシートが見つからず何も処理がされないこと' do
      spreadsheet_mock = create_spreadsheet_mock(worksheet_by_title: nil)
      create_session_mock(spreadsheet_mock)

      expect(worksheet).to be_nil
    end

    it 'ワークシートが削除されること' do
      worksheet_mock = instance_double(GoogleDrive::Worksheet)
      allow(worksheet_mock).to receive(:delete).and_return('run delete')
      spreadsheet_mock = create_spreadsheet_mock(worksheet_by_title: worksheet_mock)
      create_session_mock(spreadsheet_mock)

      expect(worksheet).to eq 'run delete'
    end
  end

  describe '#get_worksheet_by_title_not_exist_create' do
    let(:spreadsheet) { described_class.new('hoge') }
    let(:result) { spreadsheet.get_worksheet_by_title_not_exist_create('hoge') }

    context 'when a worksheet does not exist' do
      it 'ワークシートが新たに追加されること' do
        spreadsheet_mock = create_spreadsheet_mock(worksheet_by_title: nil, add_worksheet: 'run add_worksheet')
        create_session_mock(spreadsheet_mock)

        expect(result).to eq 'run add_worksheet'
      end
    end

    context 'when a worksheet exists' do
      it '対象のワークシートが取得されること' do
        worksheet_mock = instance_double(GoogleDrive::Worksheet)
        spreadsheet_mock = create_spreadsheet_mock(worksheet_by_title: worksheet_mock)
        create_session_mock(spreadsheet_mock)

        expect(result).to eq worksheet_mock
      end
    end
  end
end
