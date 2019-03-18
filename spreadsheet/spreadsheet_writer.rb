# frozen_string_literal: true

# Googleスプレッドシート書き込みクラス
#   GoogleスプレッドシートのIDを指定してそのIDに一致するGoogleスプレッドシートを
#   を取得し、書き込み出来るクラスです
class SpreadsheetWriter < Spreadsheet
  # コンストラクタ
  #   Spreadsheetクラスのコンストラクタを呼ぶ
  #   インスタンス変数の初期値をセット
  def initialize(spreadsheet_id)
    # 親クラスのコンストラクタを実行
    super(spreadsheet_id)
  end

  # GoogleスプレッドシートへCSVファイルから書き込みを行なう
  def write_by_csv(file_path)
    begin
      # CSVファイルの読み込み
      csv_data = CSV.read(file_path)
    rescue StandardError => e
      # 例外メッセージとバックトレースを表示して処理を終了する
      puts "CSVファイルが見つかりませんでした\n#{e.message}(#{e.class})"
      raise
    end
    # CSVファイルからデータを取得し、スプレッドシートへ書き込む
    csv_data.each_with_index do |data, row|
      data.each_with_index do |value, cell|
        # google-drive-rubyの仕様で1行目は1から、1セル目は1からなので行とセルにそれぞれ+1する
        @worksheet[row + 1, cell + 1] = value
      end
    end
    @worksheet.save
  end
end
