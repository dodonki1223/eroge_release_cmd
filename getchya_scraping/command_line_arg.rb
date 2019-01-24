# frozen_string_literal: true

require 'optparse'

# コマンドライン引数クラス
#   コマンドから受け取ったコマンドライン引数をパースして
#   プログラムから扱えるようにする機能を提供する
class CommandLineArg
  # コンストラクタ
  #   コマンドライン引数を受け取れるキーワードの設定、ヘルプコマンドが実行
  #   された時のメッセージの設定
  #   コマンドライン引数の値を取得するようのHash変数の作成
  def initialize
    # コマンドライン引数の値をセットするHash変数
    @options = {}
    OptionParser.new do |opt|
      # ヘルプコマンドを設定
      opt.on('-h', '--help', 'Show this help') do
        puts opt
        exit
      end
      # ヘルプコマンド以外のコマンドライン引数を設定する
      opt.on('-y', '--year_month [YEAR_MONTH]', 'Set Target Year And Month') { |v| @options[:year_month] = v }
      opt.on('-v', '--voice_actor [VOICE_ACTOR]', 'Narrow down by voice actor name') { |v| @options[:voice_actor] = v }
      opt.on('-t', '--title [TITLE]', 'Filter by title') { |v| @options[:title] = v }
      opt.on('-b', '--brand [BRAND]', 'Narrow down by brand') { |v| @options[:brand] = v }
      opt.on('-o', '--open [OPEN]', 'Open game page in browser') { |v| @options[:open] = v }
      opt.on('-c', '--csv [CSV]', 'Create a csv file') { |v| @options[:csv] = v }
      opt.on('-j', '--json [JSON]', 'Create a json file') { |v| @options[:json] = v }
      opt.on('--simple [SIMPLE]', 'Display results in a simplified way') { |v| @options[:simple] = v }
      opt.on('--title_only [TITLE_ONLY]', 'Show game title only') { |v| @options[:title_only] = v }
      # コマンドラインをparseする
      opt.parse!(ARGV)
    end
  end

  # 対象のコマンドライン引数が存在するか？
  def has?(name)
    @options.include?(name)
  end

  # 対象のコマンドライン引数の値を取得する
  #   対象のコマンドライン引数の値が存在しない場合は空文字を返す
  def get(name)
    return '' unless has?

    @options[name]
  end
end
