# frozen_string_literal: true

# GoogleDriveのスプレッドシートのヘルパーモジュール
# google-drive-rubyのMockの作成を提供します
module SpreadsheetHelper
  # GoogleDrive::SpreadsheetのMockを作成する
  def create_spreadsheet_mock(worksheet_by_title: nil, add_worksheet: '')
    spreadsheet = instance_double(GoogleDrive::Spreadsheet)
    allow(spreadsheet).to receive_messages(worksheet_by_title: worksheet_by_title, add_worksheet: add_worksheet)
    spreadsheet
  end

  # GoogleDrive::SessionのMockを作成する
  def create_session_mock(spreadsheet_mock)
    session = instance_double(GoogleDrive::Session)
    allow(session).to receive(:spreadsheet_by_key).and_return(spreadsheet_mock)
    allow(GoogleDrive::Session).to receive(:new).and_return(session)
  end

  # GoogleDrive::WorksheetのMockを作成する
  #   worksheet[row][cell]のメソッドが書き込まれるようMock化する
  #   引数として[ [header1, header2], [content1, content2], .... ]のような形式の配列を
  #   必ず渡すこと
  def create_worksheet_mock(csv_content)
    # 配列でない時は例外を返す
    unless csv_content.is_a?(Array) && csv_content[0].is_a?(Array)
      raise ArgumentError, '[ [header1, header2], [content1, content2], .... ]形式の配列を指定して下さい'
    end

    # 要素数を取得
    # +1をしているのはGoogleDrive::Worksheetが0始まりでなく1始まりなため
    element_count = csv_content[0].count + 1

    mock_return_value = Array.new(element_count, Array.new(element_count))
    return_value = proc { |row, cell, value| mock_return_value[row][cell] = value }

    # worksheet[1][1]とworksheet[1][1] = hogeのメソッドをMockする
    # 引数で渡されたCSVの内容で書き込む、値を返すようにする
    worksheet_mock = instance_double(GoogleDrive::Worksheet)
    csv_content.each_with_index do |row_data, row|
      row_data.each_with_index do |cell_data, cell|
        row_index = row + 1
        cell_index = cell + 1
        allow(worksheet_mock).to receive(:[]=)
          .with(row_index, cell_index, cell_data)
          .and_return(return_value.call(row_index, cell_index, cell_data))
        allow(worksheet_mock).to receive(:[])
          .with(row_index, cell_index)
          .and_return(mock_return_value[row_index][cell_index])
      end
    end

    # saveメソッドを実行したらcsvの内容を返すようにする
    allow(worksheet_mock).to receive(:save).and_return(csv_content)

    worksheet_mock
  end
end
