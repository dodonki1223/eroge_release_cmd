# frozen_string_literal: true

# Googleスプレッドシート書き込みクラス
#   GoogleスプレッドシートのIDを指定してそのIDに一致するGoogleスプレッドシートを
#   を取得し、書き込み出来るクラスです
class SpreadsheetWriter < Spreadsheet
  attr_reader :has_header

  # コンストラクタ
  #   Spredsheetクラスのコンストラクタを呼ぶ
  #   インスタンス変数の初期値をセット
  def initialize(spreadsheet_id)
    # 親クラスのコンストラクタを実行
    super(spreadsheet_id)
    # ヘッダーなしをセット
    @has_header = false
  end
end
