require 'java'
require 'logger'

module YUICompressor
  module JRuby

    require JAR_FILE

    import java.io.InputStreamReader
    import java.io.OutputStreamWriter
    import com.yahoo.platform.yui.compressor.JavaScriptCompressor
    import com.yahoo.platform.yui.compressor.CssCompressor

    class ErrorReporter < Logger #:nodoc:
      def initialize
        super($stderr)
      end

      def warning(message, source_name, line, line_source, line_offset)
        warn(message)
      end

      def error(message, source_name, line, line_source, line_offset)
        super(message)
      end
    end

    # Returns the set of arguments that are needed to instantiate a compressor
    # using the given +options+.
    def command_arguments(options={})
      args = [ options[:line_break] ? options[:line_break].to_i : -1 ]

      if options[:type].to_s == 'js'
        args << !! options[:munge]
        args << false # verbose?
        args << !! options[:preserve_semicolons]
        args << ! options[:optimize] # disable optimizations?
      end

      args
    end

    # Compresses the given +stream_or_string+ of code using the given +options+.
    # When using this method directly, at least the +:type+ option must be
    # specified, and should be one of +'css'+ or +'js'+. See
    # YUICompressor#compress_css and YUICompressor#compress_js for more details
    # about which options are acceptable for each type of compressor.
    #
    # If a block is given, it will receive the IO output object. Otherwise the
    # output will be returned as a string.
    def compress(stream_or_string, options={})
      raise ArgumentError, 'Option :type required' unless options.key?(:type)

      stream = streamify(stream_or_string)
      output = StringIO.new

      reader = InputStreamReader.new(stream.to_inputstream)
      writer = OutputStreamWriter.new(output.to_outputstream)

      compressor = case options[:type].to_s
      when 'js'
        options = default_js_options.merge(options)
        JavaScriptCompressor.new(reader, ErrorReporter.new)
      when 'css'
        options = default_css_options.merge(options)
        CssCompressor.new(reader)
      else
        raise ArgumentError, 'Unknown resource type: %s' % options[:type]
      end

      compressor.compress(writer, *command_arguments(options))
      writer.flush
      output.rewind

      if block_given?
        yield output
      else
        output.read
      end
    end

  end
end
