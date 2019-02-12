# frozen_string_literal: true

require 'bundler/setup'
require 'google_drive'

# Googleスプレッドシートクラス
#   GoogleスプレッドシートのIDを指定してそのIDに一致するGoogleスプレッドシートを
#   を取得する
#   Googleスプレッドシートを操作する機能を提供する
class Spreadsheet
  attr_reader :session, :spreadsheet, :worksheet

  # コンストラクタ
  #   IDを引数で受け取り、もしIDが存在しなかった場合はGoogleスプレッドシートが見つかりません例外が
  #   発生する
  #   ※必ず存在するGoogleスプレッドシートがあること前提です
  def initialize(spreadsheet_id)
    # jsonファイルのconfigファイルからGoogleDrive::Sessionを作成する
    # https://github.com/gimite/google-drive-ruby/blob/master/doc/authorization.mdに
    # google_drive_config.jsonファイル作成方法が書かれています
    @session = GoogleDrive::Session.from_config('spreadsheet/google_drive_config.json')
    begin
      @spreadsheet = @session.spreadsheet_by_key(spreadsheet_id)
    rescue Google::Apis::ClientError => e
      # 例外メッセージとバックトレースを表示して処理を終了する
      puts "指定されたIDのスプレッドシートが見つかりませんでした\n#{e.message}(#{e.class})"
      puts e.backtrace
      exit
    end
  end

  # Googleスプレッドシートのワークシートをタイトルから取得する
  #   ワークシートが存在しない時は作成したワークシートを@worksheetにセットする存在する時はそのワー
  #   クシートを@worksheetにセットする
  def get_worksheet_by_title_not_exist_create(title)
    @worksheet = @spreadsheet.worksheet_by_title(title).nil? ? @spreadsheet.add_worksheet(title) : @spreadsheet.worksheet_by_title(title)
    @worksheet
  end
end
