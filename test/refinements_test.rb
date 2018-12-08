require 'minitest/autorun'

class RefinementsTest < Minitest::Test
  using Module.new {
    refine String do
      def to_proc
        # 渡された引数に対して、メソッド名=自分自身の文字列となるメソッドを呼び出す
        # （Symbol#to_procと考え方は同じ）
        -> (arg) { arg.send(self) }
      end

      def upcase_reverse
        self.upcase.reverse
      end
    end
  }

  def test_to_proc
    assert_equal "!OLLEH", "hello!".upcase_reverse

    assert_equal "BYE!", "upcase".to_proc.call("bye!")

    assert_equal ['A', 'B', 'C'], ['a', 'b', 'c'].map(&"upcase")
  end

  def test_public_send
    assert_equal "!OLLEH", "hello!".public_send(:upcase_reverse)
  end

  def test_respond_to?
    assert "hello!".respond_to?(:upcase_reverse)
  end
end