# frozen_string_literal: true

require './spec/spec_helper'
require './eroge_release/cache/cache'

module ErogeRelease
  describe Cache do
    let(:target_yaer_month) { '203001' }
    let(:cache) { described_class.new(target_yaer_month) }

    describe '#create_cache' do
      it '書き込まれる内容がシリアライズされたものになること' do
        # -------------------------------------------
        # メソッドをすべてMockする書き方
        # -------------------------------------------
        # # CacheクラスのMockを作成する
        # # create_cacheメソッドがStringIOの内容を返すよう設定する
        # # ※StringIOは文字列にIOと同じインタフェースを持たせるためのクラスで
        # #   実際にはファイルを作成しないのでIOオブジェクトのMockが作成できる
        # cache_mock = instance_double('Cache')
        # string_io = StringIO.new(Marshal.dump('Hello World!!'))
        # allow(cache_mock).to receive(:create_cache).and_return(string_io.read)
        #
        # # Cacheクラスのcreate_cacheメソッドがCacheクラスのMockのcreate_cacheメソッドを返すよう設定
        # cache = described_class.new(target_yaer_month)
        # allow(cache).to receive(:create_cache).and_return(cache_mock.create_cache('Hello World!!'))
        #
        # expect(cache.create_cache('Hello World!!')).to eq Marshal.dump('Hello World!!')

        # Fileクラスのopenを偽装する
        string_io = StringIO.new
        # 「allow(実装を置き換えたいオブジェクト).to receive(置き換えたいメソッド名).and_return(返却したい値やオブジェクト)」
        # の形式で記述が出来る
        allow(File).to receive(:open).and_yield(string_io)
        cache.create_cache('Hello World!!')

        expect(string_io.string).to eq Marshal.dump('Hello World!!').force_encoding('utf-8')
      end
    end

    describe '#load_cache' do
      it '読み取る内容がデシリアライズされたものであること' do
        # Fileクラスのopenを偽装する
        serialize_content = Marshal.dump('Hello World!!')
        string_io = StringIO.new(serialize_content)
        # and_yieldを使用することでFile.openのブロックに値を渡すことができる
        # ブロックの値は「File.open(@full_path, 'r') { |file| deserialize_file = file.read }」だと
        # |file|の「file」を指します
        allow(File).to receive(:open).and_yield(string_io)

        expect(cache.load_cache).to eq 'Hello World!!'
      end
    end

    describe '#clear_cache' do
      it 'ファイルの削除に失敗した時、例外が発生すること' do
        # Fileクラスのexist?がtrueを返すように偽装する
        allow(File).to receive(:exist?).and_return(true)
        # FileクラスのdeleteがStandardErrorを返すように偽装する
        allow(File).to receive(:delete).and_raise(StandardError)

        expect { cache.clear_cache }.to raise_error(StandardError, 'キャッシュファイルの削除に失敗しました')
      end
    end
  end
end
