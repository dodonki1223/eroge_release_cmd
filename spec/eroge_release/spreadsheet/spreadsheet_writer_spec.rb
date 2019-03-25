# frozen_string_literal: true

require './spec/spec_helper'
require './spec/support/spreadsheet_helper'
require './spec/support/cli_spec_behavior'
require './eroge_release/spreadsheet/spreadsheet'
require './eroge_release/spreadsheet/spreadsheet_writer'

module ErogeRelease
  describe SpreadsheetWriter do
    include SpreadsheetHelper

    describe '#write_by_csv' do
      include_context 'when disable standard output'

      context 'when csv file does not exists' do
        subject(:write_by_csv) { described_class.new('hoge').write_by_csv('hoge') }

        it '例外が発生すること' do
          spreadsheet_mock = create_spreadsheet_mock(worksheet_by_title: nil)
          create_session_mock(spreadsheet_mock)

          expect { write_by_csv }.to raise_error(StandardError)
        end
      end

      context 'when csv file exists' do
        before do
          allow(CSV).to receive(:read).with('hoge').and_return(csv_content)
        end

        let(:csv_content) { [%w[header1 header2 header3], %w[content1 content2 content3]] }
        let(:worksheet_mock) { create_worksheet_mock(csv_content) }
        let(:spreadsheet_writer) do
          # スプレッドシートのMockを作成
          spreadsheet_mock = create_spreadsheet_mock(worksheet_by_title: worksheet_mock)
          create_session_mock(spreadsheet_mock)

          # スプレッドシート書き込みのMockを作成する
          spreadsheet_writer = described_class.new('hoge')
          spreadsheet_writer.get_worksheet_by_title_not_exist_create('hoge')
          spreadsheet_writer.write_by_csv('hoge')
          spreadsheet_writer
        end

        it 'ワークシートにヘッダー行の値が書き込まれること' do
          expect(spreadsheet_writer.worksheet[1, 2]).to eq(csv_content[0][1])
        end

        it 'ワークシートにヘッダー行以外の値が書き込まれること' do
          expect(spreadsheet_writer.worksheet[2, 1]).to eq(csv_content[1][0])
        end
      end
    end
  end
end
