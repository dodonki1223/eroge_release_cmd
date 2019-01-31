# frozen_string_literal: true

# Arrayクラス
#   Arrayクラスに独自メソッドを定義する
class Array
  # Arrayクラスのinclude?メソッドの複数値対応版のall?バージョン
  #   *listsでは「[1,2,3,4]」や「1,2,3,4」などのように配列か複数の引数を
  #   受け取り、その値が対象の配列内にすべて含まれている時はTrue、そうでな
  #   い時はFalseを返す
  def multiple_include_all?(*lists)
    lists.__send__(:all?) do |list|
      if list.is_a?(Array)
        # 配列の時は値を一つずつ取り出しArrayクラスのinclude?を呼ぶ
        list.__send__(:all?) { |j| include?(j) }
      else
        # 配列でなかった場合はArrayクラスのinclude?を呼ぶ
        include?(list)
      end
    end
  end

  # Arrayクラスのinclude?メソッドの複数値対応版のany?バージョン
  #   *listsでは「[1,2,3,4]」や「1,2,3,4」などのように配列か複数の引数を
  #   受け取り、その値が対象の配列内に１つでも含まれている時はTrue、１つも
  #   含まない時はFalseを返す
  def multiple_include_any?(*lists)
    lists.__send__(:any?) do |list|
      if list.is_a?(Array)
        # 配列の時は値を一つずつ取り出しArrayクラスのinclude?を呼ぶ
        list.__send__(:any?) { |j| include?(j) }
      else
        # 配列でなかった場合はArrayクラスのinclude?を呼ぶ
        include?(list)
      end
    end
  end
end
