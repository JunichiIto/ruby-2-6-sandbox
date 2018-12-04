require 'minitest/autorun'

class RubyTest < Minitest::Test
  def test_else_without_rescue
    script = <<~RUBY
      begin
        # ...
      else
        # ...
      end
    RUBY
    assert_raises(SyntaxError) do
      RubyVM::InstructionSequence.compile(script)
    end
  end

  # Мはロシア語の大文字
  # https://ja.wikipedia.org/wiki/%D0%9C
  Мир = 123
  def test_non_ascii_constants
    assert_equal 123, Мир
  end

  def test_non_symbol_keys_in_keyword_args
    # ???
  end

  def test_shadowing_warning
    # How to test??
    # ruby -cw -e "user = users.find {|user| cond(user) }"
  end

  def test_endless_range
    assert_equal [1, 2, 3], (1..).take(3)
    array = [0, 1, 2]
    assert_equal [1, 2], array[1..]
  end

  def test_range_percent
    steps = (1..).step(2)
    assert_equal [1, 3, 5], steps.take(3)

    steps = (1..) % 2
    assert_equal [1, 3, 5], steps.take(3)
  end

  # Range#=== は Range#include? メソッドでチェックしていたのですが、rb_funcall() で実際にメソッド呼び出しはやめて
  # range_include_internal() で include? 相当のチェックをしてみて、include? で判定不能だった時には cover?
  # 相当の処理で判定するようにしています。
  # Range#include? は始点が整数に変換可能か、文字列かでないと処理できないのでこれ以外の要素による Range の時には
  # <=> メソッドの大小関係のみで判定できる cover? のほうがより汎用的に使えるということのようです。
  # https://svn.ruby-lang.org/cgi-bin/viewvc.cgi/trunk/spec/ruby/core/range/case_compare_spec.rb?view=markup&pathrev=63453
  class MyClass
    include Comparable
    attr_reader :i
    def initialize(i)
      @i = i
    end
    def <=>(o)
      i <=> o.i
    end
  end
  def test_range_triple_equals
    # it "returns the result of calling #include? on self"
    range = 0...10
    assert range.include?(2)
    assert range.cover?(2)
    assert range === 2

    # it "returns the result of calling #cover? on self"
    range = MyClass.new(0)..MyClass.new(10)
    assert_raises(TypeError) do
      range.include?(MyClass.new(2))
    end
    assert range.cover?(MyClass.new(2))
    assert range === MyClass.new(2)
  end

  def test_range_accepts_range
    assert (1..5).cover?(2..3)
  end

  def test_range_step_returns_Enumerator__ArithmeticSequence
    assert_instance_of Enumerator::ArithmeticSequence, (1..10).step(2)
    assert_same Enumerator, Enumerator::ArithmeticSequence.superclass
  end

  def test_full_messages_options
    1 / 0
  rescue => e
    assert_match "ZeroDivisionError", e.full_message(highlight: false, order: 'top').lines[0]
    assert_match "Traceback (most recent call last):", e.full_message(highlight: false, order: 'bottom').lines[0]
    assert_match "\e[1mTraceback\e[m ", e.full_message(highlight: true, order: 'bottom').lines[0]
    refute_match "\e", e.full_message(highlight: false, order: 'bottom').lines[0]
  end

  def test_name_error
    e = NameError.new(receiver: 'foo')
    assert_equal 'foo', e.receiver
  end

  def test_key_error
    e = KeyError.new(key: 'foo', receiver: 'bar')
    assert_equal 'foo', e.key
    assert_equal 'bar', e.receiver
  end

  def test_array_union
    a = [1, 2, 3]
    b = [3, 4, 5]
    c = a.union(b)
    assert_equal [1, 2, 3, 4, 5], c
    assert_equal [1, 2, 3], a

    assert_equal [1, 2, 3, 4, 5], (a | b)
  end

  def test_array_diference
    a = [1, 2, 3]
    b = [3, 4, 5]
    c = a.difference(b)
    assert_equal [1, 2], c
    assert_equal [1, 2, 3], a

    assert_equal [1, 2], (a - b)
  end

  def test_array_to_h
    hash = ['alice', 'bob', 'carol'].to_h { |name| [name.to_sym, []] }
    assert_equal({ alice: [], bob: [], carol: [] }, hash)
  end

  def test_array_filter
    a = [1, 2, 3, 4, 5, 6]

    b = a.filter { |el| el % 3 == 0 }
    assert_equal [3, 6], b
    assert_equal [1, 2, 3, 4, 5, 6], a

    c = a.select { |el| el % 3 == 0 }
    assert_equal [3, 6], c
    assert_equal [1, 2, 3, 4, 5, 6], a

    d = a.filter! { |el| el % 3 == 0 }
    assert_equal [3, 6], d
    assert_equal [3, 6], a
  end

  def test_numeric_step_returns_Enumerator__ArithmeticSequence
    assert_instance_of Enumerator::ArithmeticSequence, 2.step(5)
    assert_same Enumerator, Enumerator::ArithmeticSequence.superclass
  end

  def test_hash_merge
    a = { a: 1 }
    b = { b: 2 }
    c = { c: 3 }

    d = a.merge(b, c)
    assert_equal({ a: 1, b: 2, c: 3}, d)
    assert_equal({ a: 1 }, a)

    e = a.merge!(b, c)
    assert_equal({ a: 1, b: 2, c: 3}, e)
    assert_equal({ a: 1, b: 2, c: 3}, a)
  end

  def test_string_sprit_with_block
    s = "1,2,3,4,5"

    elements = []
    s.split(',') { |el| elements.push(el.to_i * 10) }
    assert_equal [10, 20, 30, 40, 50], elements

    ret = s.split(',') { nil }
    assert_equal "1,2,3,4,5", ret
  end

  def test_kernel_then
    ret = "Hello, world!".then(&:upcase).then(&:reverse)
    assert_equal "!DLROW ,OLLEH", ret
  end

  def test_kernel_Integer
    a = Integer('a', exception: false)
    assert_nil a

    assert_raises(ArgumentError) do
      Integer('a')
    end
  end

  def test_dir_each_child
    dir = Dir.new('./test/dir_a')
    filenames = []
    dir.each_child { |name| filenames << name }
    assert_equal ['code_a.rb', 'text_a.txt'], filenames.sort

    filenames = []
    dir.each { |name| filenames << name }
    assert_equal ['.', '..', 'code_a.rb', 'text_a.txt'], filenames.sort
  end

  def test_dir_children
    dir = Dir.new('./test/dir_a')
    assert_equal ['code_a.rb', 'text_a.txt'], dir.children.sort

    assert_equal ['.', '..', 'code_a.rb', 'text_a.txt'], dir.entries.sort
  end

  def test_file_open_with_x_option
    assert File.exist?('./test/dir_a/text_a.txt')
    open('./test/dir_a/text_a.txt', 'w') { |f| }
    assert_raises(Errno::EEXIST) do
      open('./test/dir_a/text_a.txt', 'wx') { |f| }
    end

    refute File.exist?('./test/dir_a/text_b.txt')
    open('./test/dir_a/text_b.txt', 'wx') { |f| }
  ensure
    File.delete('./test/dir_a/text_b.txt') if File.exist?('./test/dir_a/text_b.txt')
  end

  def test_fileutils_cp_lr
    assert_equal ['.keep'], Dir.children('./test/dir_b')

    FileUtils.cp_lr './test/dir_a/.', './test/dir_b/'
    assert File.exist?('./test/dir_b/code_a.rb')
    assert File.exist?('./test/dir_b/text_a.txt')
  ensure
    ['./test/dir_b/code_a.rb', './test/dir_b/text_a.txt'].each do |name|
      File.delete(name) if File.exist?(name)
    end
  end

  # http://blog.livedoor.jp/sonots/archives/33344291.html
  def capture_stderr
    out = StringIO.new
    $stderr = out
    yield
    return out.string
  ensure
    $stderr = STDERR
  end

  def test_dir_glob_with_null_char
    warning = capture_stderr do
      Dir.glob("\0")
    end
    assert_match 'warning: use glob patterns list instead of nul-separated patterns', warning

    warning = capture_stderr do
      Dir["\0"]
    end
    assert_match 'warning: use glob patterns list instead of nul-separated patterns', warning
  end

  def test_file_read_with_external_commands
    assert_raises(Errno::ENOENT) do
      File.read("|echo hello")
    end
  end

  def test_time_new_with_timezone
    begin
      require 'timezone'
    rescue LoadError
      puts 'Please `gem install timezone`'
      raise
    end

    tz = Timezone.fetch('Europe/Athens')
    t = Time.new(2002, 10, 31, 2, 2, 2, tz)
    assert_equal '2002-10-31 02:02:02 +0200', t.to_s
  end

  def test_biding_sourcelocation
    assert_equal [__FILE__ , __LINE__ ], binding.source_location
  end

  def test_random_bytes
    bytes = Random.bytes(3)
    assert_instance_of String, bytes
    assert_equal 3, bytes.bytes.size
  end

  # http://d.hatena.ne.jp/nagachika/20180815
  # https://twitter.com/yukihiro_matz/status/1022287578995646464
  def m(*a, **k)
    [a, k]
  end

  def test_keyword_args
    e = assert_raises(ArgumentError) do
      m("a" => 1, a: 1)
    end
    assert_equal 'non-symbol key in keyword arguments: "a"', e.message
  end
end