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
end
