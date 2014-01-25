#encoding: utf-8

# Copyright (c) 2013-2014, Sylvain LAPERCHE
# All rights reserved.
# License: BSD 3-Clause (http://opensource.org/licenses/BSD-3-Clause)

require 'test/unit'
require 'INIConfig'

class TestINIConfig < Test::Unit::TestCase
  def test_sections_OK
    config = INIConfig.new()
    assert_equal(0, config.sections().length)
    config.add_section(:Input)
    config.add_section(:Output)
    config.add_section(:Default)
    assert_equal(3, config.sections().length)
  end

  def test_options_OK
    config = INIConfig.new()

    config.add_section(:Default)
    assert_equal(0, config.options(:Default).length)

    config.add_option(:Default, :foo, 42)
    assert_equal(1, config.options(:Default).length)
  end

  def test_options_wrong_section
    config = INIConfig.new()
    assert_raise INIError do
      config.options(:Default)
    end
  end

  def test_has_section_OK
    config = INIConfig.new()
    assert(!config.has_section?(:Default))

    config.add_section(:Default)
    assert(config.has_section?(:Default))
  end

  def test_has_option_OK
    config = INIConfig.new()
    config.add_section(:Default)
    assert(!config.has_option?(:Default, :foo))

    config.add_option(:Default, :foo, 42)
    assert(config.has_option?(:Default, :foo))
  end

  def test_has_option_wrong_section
    config = INIConfig.new()
    assert_raise INIError do
      config.has_option?(:Default, :foo)
    end
  end

  def test_get_OK
    config = INIConfig.new()
    config.add_section(:Default)
    config.add_option(:Default, :foo, 42)
    config.add_option(:Default, :bar, 'Hello World!')
    config.add_option(:Default, :baz, [20, 23, 30, 44, 70, 120])

    assert_equal(42, config[:Default, :foo])
    assert_equal('Hello World!', config[:Default, :bar])
    assert_equal([20, 23, 30, 44, 70, 120], config[:Default, :baz])
  end

  def test_get_wrong_section
    config = INIConfig.new()
    assert_raise INIError do
      config[:Default, :foo]
    end
  end

  def test_get_wrong_option
    config = INIConfig.new()
    config.add_section(:Default)
    assert_raise INIError do
      config[:Default, :foo]
    end
  end

  def test_add_section_OK
    config = INIConfig.new()
    assert_equal(0, config.sections().length)
    assert(!config.has_section?(:Default))

    config.add_section(:Default)
    assert_equal(1, config.sections().length)
    assert(config.has_section?(:Default))
  end

  def test_add_section_existing_section
    config = INIConfig.new()
    config.add_section(:Default)
    assert_raise INIError do
      config.add_section(:Default)
    end
  end

  def test_add_option_OK
    config = INIConfig.new()
    config.add_section(:Default)
    assert_equal(0, config.options(:Default).length)
    assert(!config.has_option?(:Default, :foo))

    config.add_option(:Default, :foo, 42)
    assert_equal(1, config.options(:Default).length)
    assert(config.has_option?(:Default, :foo))
    assert_equal(42, config[:Default, :foo])
  end

  def test_add_option_wrong_section
    config = INIConfig.new()
    assert_raise INIError do
      config.add_option(:Default, :foo, 42)
    end
  end

  def test_add_option_existing_option
    config = INIConfig.new()
    config.add_section(:Default)
    config.add_option(:Default, :foo, 42)
    assert_raise INIError do
      config.add_option(:Default, :foo, 42)
    end
  end

  def test_delete_section_OK
    config = INIConfig.new()
    config.add_section(:Default)
    assert_equal(1, config.sections().length)
    assert(config.has_section?(:Default))

    config.delete_section(:Default)
    assert_equal(0, config.sections().length)
    assert(!config.has_section?(:Default))
  end

  def test_delete_section_wrong_section
    config = INIConfig.new()
    assert_raise INIError do
      config.delete_section(:Default)
    end
  end

  def test_delete_option_OK
    config = INIConfig.new()
    config.add_section(:Default)
    config.add_option(:Default, :foo, 42)
    assert_equal(1, config.options(:Default).length)
    assert(config.has_option?(:Default, :foo))

    config.delete_option(:Default, :foo)
    assert_equal(0, config.options(:Default).length)
    assert(!config.has_option?(:Default, :foo))
  end

  def test_delete_option_wrong_section
    config = INIConfig.new()
    assert_raise INIError do
      config.delete_option(:Default, :foo)
    end
  end

  def test_delete_option_wrong_option
    config = INIConfig.new()
    config.add_section(:Default)
    assert_raise INIError do
      config.delete_option(:Default, :foo)
    end
  end

  def test_read_ok
    config = INIConfig.new()
    config.load('test/data/example.ini', 'UTF-8')
    assert(config.has_section?('Input'))
    assert(config.has_section?('2) Output'))
    assert_equal(2, config.sections().length)

    assert(config.has_option?('Input', 'data 1'))
    assert(config.has_option?('Input', 'data_2'))
    assert(config.has_option?('Input', 'data-3'))
    assert(config.has_option?('Input', 'data(4)'))
    assert(config.has_option?('Input', 'data[5}'))
    assert_equal(5, config.options('Input').length)

    assert_equal('true'          , config['Input', 'data 1'])
    assert_equal('42'            , config['Input', 'data_2'])
    assert_equal('bar==  baz'    , config['Input', 'data-3'])
    assert_equal('foo/bar&:baz§ê', config['Input', 'data(4)'])
    assert_equal('qwerty asdf'   , config['Input', 'data[5}'])

    assert(config.has_option?('2) Output', '名字'))
    assert_equal(1, config.options('2) Output').length)
    assert_equal('config', config['2) Output', '名字'])
  end

  def test_read_utf16
    config = INIConfig.new()
    config.load('test/data/utf16.ini', 'UTF-16LE', true)
    assert(config.has_section?(:汉语))
    assert_equal(1, config.sections().length)

    assert(config.has_option?(:汉语, :你好))
    assert_equal(1, config.options(:汉语).length)

    assert_equal('hello', config[:汉语, :你好])
  end

  def test_read_inline_comment
    config = INIConfig.new()
    config.load('test/data/inline.ini')
    assert(config.has_section?('Default'))
    assert_equal(1, config.sections().length)

    assert(config.has_option?('Default', 'var1'))
    assert(config.has_option?('Default', 'var2'))
    assert(config.has_option?('Default', 'var3'))
    assert(config.has_option?('Default', 'var4'))
    assert_equal(4, config.options('Default').length)

    assert_equal('foo', config['Default', 'var1'])
    assert_equal('bar', config['Default', 'var2'])
    assert_equal('not a #comment', config['Default', 'var3'])
    assert_equal('not a #comment', config['Default', 'var4'])
  end

  def test_read_as_symbol
    config = INIConfig.new()
    config.load('test/data/inline.ini', 'UTF-8', true)
    assert(config.has_section?(:Default))
    assert_equal(1, config.sections().length)

    assert(config.has_option?(:Default, :var1))
    assert(config.has_option?(:Default, :var2))
    assert(config.has_option?(:Default, :var3))
    assert(config.has_option?(:Default, :var4))
    assert_equal(4, config.options(:Default).length)

    assert_equal('foo', config[:Default, :var1])
    assert_equal('bar', config[:Default, :var2])
    assert_equal('not a #comment', config[:Default, :var3])
    assert_equal('not a #comment', config[:Default, :var4])
  end

  def test_read_double_quote
    config = INIConfig.new()
    config.load('test/data/double_quote.ini')
    assert_equal(1, config.sections().length)

    assert(config.has_option?('Default', 'var1'))
    assert(config.has_option?('Default', 'var2'))
    assert(config.has_option?('Default', 'var3'))
    assert(config.has_option?('Default', 'var4'))
    assert_equal(4, config.options('Default').length)

    assert_equal('foo', config['Default', 'var1'])
    assert_equal('a"b"c', config['Default', 'var2'])
    assert_equal("this is a \nmultiline value with a single ' quote ",
                 config['Default', 'var3'])
    assert_equal('with escaped double quote \\"',
                 config['Default', 'var4'])
  end

  def test_read_single_quote
    config = INIConfig.new()
    config.load('test/data/single_quote.ini')
    assert(config.has_section?('Default'))
    assert_equal(1, config.sections().length)

    assert(config.has_option?('Default', 'var1'))
    assert(config.has_option?('Default', 'var2'))
    assert(config.has_option?('Default', 'var3'))
    assert(config.has_option?('Default', 'var4'))
    assert_equal(4, config.options('Default').length)

    assert_equal('bar', config['Default', 'var1'])
    assert_equal("x'y'z", config['Default', 'var2'])
    assert_equal("another \nmultiline value with a \" double quote\n",
                 config['Default', 'var3'])
    assert_equal("with escaped single quote \\'",
                 config['Default', 'var4'])
  end

  def test_read_multiline
    config = INIConfig.new()
    config.load('test/data/multiline.ini')
    assert(config.has_section?('Default'))
    assert_equal(1, config.sections().length)

    assert(config.has_option?('Default', 'var1'))
    assert(config.has_option?('Default', 'var2'))
    assert(config.has_option?('Default', 'var3'))
    assert(config.has_option?('Default', 'var4'))
    assert_equal(4, config.options('Default').length)

    assert_equal('foo and bar', config['Default', 'var1'])
    assert_equal('this is a multiline value', config['Default', 'var2'])
    assert_equal('a multiline value on multiple lines',
                 config['Default', 'var3'])
    assert_equal('babar', config['Default', 'var4'])
  end

  def test_read_double_section
    config = INIConfig.new()
    assert_raise INIError do
      config.load('test/data/section_double.ini')
    end
  end

  def test_read_double_option
    config = INIConfig.new()
    assert_raise INIError do
      config.load('test/data/option_double.ini')
    end
  end

  def test_read_unmatched_quote
    config = INIConfig.new()
    assert_raise INIError do
      config.load('test/data/mismatch.ini')
    end
  end

  def test_read_non_endedd_multiline
    config = INIConfig.new()
    assert_raise INIError do
      config.load('test/data/no_end.ini')
    end
  end

  def test_read_default_section
    config = INIConfig.new()
    config.load('test/data/default_section.ini')
    assert(config.has_section?('Default'))
    assert_equal(1, config.sections().length)

    assert(config.has_option?('Default', 'foo'))
    assert(config.has_option?('Default', 'baz'))
    assert_equal(2, config.options('Default').length)

    assert_equal('bar', config['Default', 'foo'])
    assert_equal('qux', config['Default', 'baz'])
  end

  def test_read_custom_default_section
    config = INIConfig.new(default: 'Main')
    config.load('test/data/default_section.ini')
    assert(config.has_section?('Main'))
    assert_equal(1, config.sections().length)

    assert(config.has_option?('Main', 'foo'))
    assert(config.has_option?('Main', 'baz'))
    assert_equal(2, config.options('Main').length)

    assert_equal('bar', config['Main', 'foo'])
    assert_equal('qux', config['Main', 'baz'])
  end

  def test_to_s_OK
    config = INIConfig.new(delimiter:':')
    assert_equal('', config.to_s())

    config.add_section(:Default)
    assert_equal("[Default]\n", config.to_s())

    config.add_option(:Default, :foo, 42)
    assert_equal("[Default]\nfoo:42\n", config.to_s())
  end

  def test_whitespace_value
    config = INIConfig.new()
    config.add_section(:Default)
    config.add_option(:Default, :space, ' ')
    config.add_option(:Default, :tab  , "\t")
    config.add_option(:Default, :mix  , "   \t   ")
    config.save('test/data/tmp.ini')

    begin
      config = INIConfig.new()
      config.load('test/data/tmp.ini')
      assert(config.has_section?('Default'))
      assert_equal(1, config.sections().length)
      assert(config.has_option?('Default', 'space'))
      assert(config.has_option?('Default', 'tab'))
      assert(config.has_option?('Default', 'mix'))
      assert_equal(3, config.options('Default').length)
      assert_equal(' '       , config['Default', 'space'])
      assert_equal("\t"      , config['Default', 'tab'])
      assert_equal("   \t   ", config['Default', 'mix'])
    ensure
      File.delete('test/data/tmp.ini')
    end
  end

  def test_comment_like_value
    config = INIConfig.new()
    config.add_section(:Default)
    config.add_option(:Default, :semicolon, ';')
    config.add_option(:Default, :sharp    , '#')
    config.save('test/data/tmp.ini')

    begin
      config = INIConfig.new()
      config.load('test/data/tmp.ini')
      assert(config.has_section?('Default'))
      assert_equal(1, config.sections().length)
      assert(config.has_option?('Default', 'semicolon'))
      assert(config.has_option?('Default', 'sharp'))
      assert_equal(2, config.options('Default').length)
      assert_equal(';'       , config['Default', 'semicolon'])
      assert_equal('#'      , config['Default', 'sharp'])
    ensure
      File.delete('test/data/tmp.ini')
    end
  end
end
