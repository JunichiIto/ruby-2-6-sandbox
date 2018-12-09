require 'minitest/autorun'

module Functions
  class << self
    def split_lines(str)
      str.split("\n")
    end

    def sort(elements)
      elements.sort
    end

    def join_lines(elements)
      elements.join("\n")
    end
  end
end

module Procs
  class << self
    def split_lines
      -> (str) { str.split("\n") }
    end

    def sort
      -> (elements) { elements.sort }
    end

    def join_lines
      -> (elements) { elements.join("\n") }
    end
  end
end

class ProcCompositionTest < Minitest::Test
  INPUT = <<~TEXT
    carol
    dave
    bob
    ellen
    alice
  TEXT

  EXPECTED = <<~TEXT.chomp
    alice
    bob
    carol
    dave
    ellen
  TEXT

  def test_method_composition
    f = Functions.method(:split_lines) >> Functions.method(:sort) >> Functions.method(:join_lines)
    assert_equal EXPECTED, f.call(INPUT)
  end

  def test_procd_composition
    f = Procs.join_lines << Procs.sort << Procs.split_lines
    assert_equal EXPECTED, f.call(INPUT)
  end

  def test_symbol_proc_composition
    names = %w(alice bob carol)
    f = %i(upcase reverse to_sym).map(&:to_proc).inject(:>>)
    assert_equal %i(ECILA BOB LORAC), names.map(&f)
  end
end
