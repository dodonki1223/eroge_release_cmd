# frozen_string_literal: true

# 標準出力をConsoleに表示させないようにするcontextです
# rubocopでも似たような機能が実装されているのでそれを採用する
RSpec.shared_context 'when disable standard output' do
  before do
    # 標準出力先を変更し画面に出力内容が表示されないようにする
    $stdout = StringIO.new
  end

  after do
    # テスト終了後に出力先を元に戻す
    $stdout = STDOUT
  end
end
