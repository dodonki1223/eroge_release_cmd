# frozen_string_literal: true

module ErogeRelease
  # キャッシュファイルを管理するクラス
  #   キャッシュファイルに関する機能を提供する
  class Cache
    attr_reader :file_name, :path, :full_path

    # キャッシュファイルが格納されるデフォルトのディレクトリ
    DEFAULT_CACHE_PATH = "#{__dir__}/cache/"

    # コンストラクタ
    #   クラス内で使用するインスタンス変数をセットする
    def initialize(file_name, path = DEFAULT_CACHE_PATH)
      @file_name = file_name
      @path      = path
      @full_path = "#{path}#{file_name}"
    end

    # キャッシュファイルを作成する
    #   キャッシュフォルダが存在しない時は作成する
    #   シリアライズしたものをキャッシュファイルとして保存する
    def create_cache(content)
      Dir.mkdir(@path) unless Dir.exist?(@path)
      File.open(@full_path, 'wb') do |file|
        serialize_file = Marshal.dump(content)
        # 改行なしで書き込む
        # ※putsを使用した場合、末尾に改行がつく
        file.print(serialize_file)
      end
    end

    # キャッシュファイルを読み込む
    #   シリアライズされたキャッシュファイルをデシリアライズして読み込む
    def load_cache
      deserialize_file = ''
      File.open(@full_path, 'r') { |file| deserialize_file = file.read }
      Marshal.load(deserialize_file)
    end

    # キャッシュファイルが存在するか？
    def cached?
      File.exist?(@full_path)
    end

    # キャッシュファイルをクリアする
    #   キャッシュファイルを削除する。削除対象のキャッシュファイルが
    #   存在しない場合は何も行わない
    def clear_cache
      File.delete(@full_path) if cached?
    rescue StandardError => e
      raise e.class, 'キャッシュファイルの削除に失敗しました'
    end
  end
end
