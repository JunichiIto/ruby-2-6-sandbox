require 'minitest/autorun'

class RefinementsTest < Minitest::Test
  using Module.new {
    refine String do
      def to_proc
        proc { |it| it.send self }
      end

      def refine_method
        "X#refine_method"
      end
    end
  }

  def func &block
    block.call("homu")
  end

  def test_to_proc
    assert_equal "X#refine_method", "upcase".refine_method

    assert_equal "HOMU", "upcase".to_proc.call("homu")

    assert_equal "HOMU", func(&"upcase")
  end

  def test_public_send
    assert_equal "X#refine_method", "upcase".public_send(:refine_method)
  end

  def test_respond_to?
    assert "upcase".respond_to?(:refine_method)
  end
end