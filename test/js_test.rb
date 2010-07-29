require File.expand_path('../helper', __FILE__)

class JSTest < Test::Unit::TestCase
  FIXTURE_JS = <<'CODE'
// here's a comment
var Foo = { "a": 1 };
Foo["bar"] = (function(baz) {
  /* here's a
     multiline comment */
  if (false) {
    doSomething();
  } else {
    for (var index = 0; index < baz.length; index++) {
      doSomething(baz[index]);
    }
  }
})("hello");
CODE

  def test_default_arguments
    if jruby?
      args = command_arguments(default_js_options)
      assert_equal([-1], args)
    else
      args = command_arguments(default_js_options)
      assert_equal(%w< --charset utf-8 >, args)
    end
  end

  def test_arguments
    if jruby?
      args = command_arguments(:type => 'js')
      assert_equal([-1, false, false, false, true], args)

      args = command_arguments(:type => 'js', :optimize => true)
      assert_equal([-1, false, false, false, false], args)

      args = command_arguments(:type => 'js', :munge => true)
      assert_equal([-1, true, false, false, true], args)

      args = command_arguments(:type => 'js', :non_existent => true)
      assert_equal([-1, false, false, false, true], args)
    else
      args = command_arguments(:type => 'js')
      assert_equal(%w< --type js --nomunge --disable-optimizations >, args)

      args = command_arguments(:type => 'js', :optimize => true)
      assert_equal(%w< --type js --nomunge >, args)

      args = command_arguments(:type => 'js', :munge => true)
      assert_equal(%w< --type js --disable-optimizations >, args)

      args = command_arguments(:type => 'js', :non_existent => true)
      assert_equal(%w< --type js --nomunge --disable-optimizations >, args)
    end
  end

  def test_default_compress
    assert_equal (<<'CODE').chomp, compress_js(FIXTURE_JS)
var Foo={a:1};Foo.bar=(function(baz){if(false){doSomething()}else{for(var index=0;index<baz.length;index++){doSomething(baz[index])}}})("hello");
CODE
  end

  def test_line_break_option_should_insert_line_breaks
    options = { :line_break => 0 }
    assert_equal (<<'CODE').chomp, compress_js(FIXTURE_JS, options)
var Foo={a:1};
Foo.bar=(function(baz){if(false){doSomething()
}else{for(var index=0;
index<baz.length;
index++){doSomething(baz[index])
}}})("hello");
CODE
  end

  def test_munge_option_should_munge_local_variable_names
    options = { :munge => true }
    assert_equal (<<'CODE').chomp, compress_js(FIXTURE_JS, options)
var Foo={a:1};Foo.bar=(function(b){if(false){doSomething()}else{for(var a=0;a<b.length;a++){doSomething(b[a])}}})("hello");
CODE
  end

  def test_optimize_option_should_not_modify_property_accesses_or_object_literal_keys_when_false
    options = { :optimize => false }
    assert_equal (<<'CODE').chomp, compress_js(FIXTURE_JS, options)
var Foo={"a":1};Foo["bar"]=(function(baz){if(false){doSomething()}else{for(var index=0;index<baz.length;index++){doSomething(baz[index])}}})("hello");
CODE
  end

  def test_preserve_semicolons_option_should_preserve_semicolons
    options = { :preserve_semicolons => true }
    assert_equal (<<'CODE').chomp, compress_js(FIXTURE_JS, options)
var Foo={a:1};Foo.bar=(function(baz){if(false){doSomething();}else{for(var index=0;index<baz.length;index++){doSomething(baz[index]);}}})("hello");
CODE
  end
end
