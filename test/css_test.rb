require File.expand_path('../helper', __FILE__)

class CSSTest < Test::Unit::TestCase
  FIXTURE_CSS = <<'CODE'
.a-class {
  background-color: red;
  background-position: 0;
}

div#an-id { color: #FFFFFF; }
CODE

  def test_default_arguments
    if jruby?
      args = command_arguments(default_css_options)
      assert_equal([-1], args)
    else
      args = command_arguments(default_css_options)
      assert_equal(%w< --charset utf-8 >, args)
    end
  end

  def test_arguments
    if jruby?
      args = command_arguments(:type => 'css')
      assert_equal([-1], args)

      args = command_arguments(:type => 'css', :line_break => 80)
      assert_equal([80], args)

      args = command_arguments(:type => 'css', :non_existent => true)
      assert_equal([-1], args)
    else
      args = command_arguments(:type => 'css')
      assert_equal(%w< --type css >, args)

      args = command_arguments(:type => 'css', :line_break => 80)
      assert_equal(%w< --type css --line-break 80 >, args)

      args = command_arguments(:type => 'css', :non_existent => true)
      assert_equal(%w< --type css >, args)
    end
  end

  def test_default_compress
    assert_equal (<<'CODE').chomp, compress_css(FIXTURE_CSS)
.a-class{background-color:red;background-position:0 0;}div#an-id{color:#FFF;}
CODE
  end

  def test_line_break_option_should_insert_line_breaks
    options = { :line_break => 0 }
    assert_equal (<<'CODE').chomp, compress_css(FIXTURE_CSS, options)
.a-class{background-color:red;background-position:0 0;}
div#an-id{color:#FFF;}
CODE
  end
end
