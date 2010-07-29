require 'stringio'

module YUICompressor
  JAR_FILE = File.expand_path('../yuicompressor-2.4.2.jar', __FILE__)

  autoload :JRuby, 'yuicompressor/jruby'
  autoload :Shell, 'yuicompressor/shell'

  def jruby?
    !! (RUBY_PLATFORM =~ /java/)
  end
  module_function :jruby?

  def compress_css(stream_or_string, options={})
    compress(stream_or_string, options.merge(:type => 'css'))
  end
  module_function :compress_css

  def compress_js(stream_or_string, options={})
    compress(stream_or_string, options.merge(:type => 'js'))
  end
  module_function :compress_js

  def default_css_options
    { :charset => 'utf-8', :line_break => nil }
  end
  module_function :default_css_options

  def default_js_options
    default_css_options.merge(
      :munge => false,
      :preserve_semicolons => false,
      :optimize => true
    )
  end
  module_function :default_js_options

  def streamify(stream_or_string) #:nodoc:
    if IO === stream_or_string || StringIO === stream_or_string
      stream_or_string
    elsif String === stream_or_string
      StringIO.new(stream_or_string.to_s)
    else
      raise ArgumentError, 'Stream or string required'
    end
  end
  module_function :streamify

  if jruby?
    # If we're on JRuby we can make native calls into the YUI Compressor code.
    # This gives us a big speed boost.
    include JRuby
  else
    # Otherwise, we need to make a system call to the Java interpreter.
    include Shell
  end

  module_function :command_arguments
  module_function :compress
end
