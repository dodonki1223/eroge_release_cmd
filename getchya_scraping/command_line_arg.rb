# frozen_string_literal: true

require 'optparse'

# コマンドライン引数クラス
#   コマンドから受け取ったコマンドライン引数をパースして
#   プログラムから扱えるようにする機能を提供する
class CommandLineArg
  attr_accessor :options

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

      # 値を受け取る系のコマンドライン引数を設定する
      opt.on('-y', '--year_month [YEAR_MONTH]', 'Set Target Year And Month') { |v| @options[:year_month] = v }
      opt.on('-v', '--voice_actor [VOICE_ACTOR]', 'Narrow down by voice actor name') { |v| @options[:voice_actor] = v }
      opt.on('-t', '--title [TITLE]', 'Filter by title') { |v| @options[:title] = v }
      opt.on('-b', '--brand_name [BRAND_NAME]', 'Narrow down by brand_name') { |v| @options[:brand_name] = v }

      # true、falseを受け取るコマンドライン引数を設定する
      # デフォルト値はすべてfalseとし、受け取ったものにはtrueをセットする
      @options[:open]        = false
      @options[:csv]         = false
      @options[:json]        = false
      @options[:clear_cache] = false
      @options[:simple]      = false
      opt.on('-o', '--open [OPEN]', 'Open game page in browser') { @options[:open] = true }
      opt.on('-c', '--csv [CSV]', 'Create a csv file') { @options[:csv] = true }
      opt.on('-j', '--json [JSON]', 'Create a json file') { @options[:json] = true }
      opt.on('--clear_cache [CLEAR_CACHE]', 'Clear the cache') { @options[:clear_cache] = true }
      opt.on('--simple [SIMPLE]', 'Display results in a simplified way') { @options[:simple] = true }

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
    return '' unless has?(name)

    @options[name]
  end
end
