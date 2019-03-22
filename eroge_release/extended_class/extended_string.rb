# frozen_string_literal: true

# Stringクラス
#   Stringクラスに独自メソッドを定義する
class String
  # Stringクラスのinclude?メソッドの複数値の対応版
  #   *listsでは「[1,2,3,4]」や「1,2,3,4」などのように配列か複数の引数を
  #   受け取り、その値が対象の文字列内に１つでも含まれている時はTrue、含ま
  #   れていな い時はFalseを返す
  def multiple_include?(*lists)
    result = lists.select do |list|
      if list.is_a?(Array)
        # 配列の時は値を一つずつ取り出しStringクラスのinclude?を呼ぶ
        result = list.select { |i| include?(i) }
        result.size >= 1
      else
        # 配列でなかった場合はStringクラスのinclude?を呼ぶ
        include?(list)
      end
    end
    result.size >= 1
  end
end
