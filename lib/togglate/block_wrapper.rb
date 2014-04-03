require "timeout"

class Togglate::BlockWrapper
  def initialize(text,
                 wrapper:%w(<!--original -->),
                 pretext:"[translation here]",
                 wrap_exceptions:[],
                 **opts)
    @text = text
    @wrapper = wrapper
    @pretext = pretext
    @wrap_exceptions = wrap_exceptions
    @translate = set_translate_opt(opts[:translate])
    @timeout = opts.fetch(:timeout, 5)
    @email = opts[:email]
  end

  def run
    wrap_chunks build_chunks
  end

  private
  def build_chunks(block_tags:[/^```/, /^{%/])
    in_block = false
    @text.each_line.chunk do |line|
      in_block = !in_block if block_tags.any? { |ex| line.match ex }
      blank_line?(line) && !in_block
    end
  end

  def blank_line?(line, blank_line_re:/^\s*$/)
    !line.match(blank_line_re).nil?
  end

  def wrap_chunks(chunks)
    wrap_lines = chunks.inject([]) do |m, (is_blank_line, lines)|
      if is_blank_line || @wrap_exceptions.any? { |ex| lines[0].match ex }
        m.push *lines
      else
        m.push pretext(lines)
        m.push "\n\n", @wrapper[0], "\n", *lines, @wrapper[1], "\n"
      end
    end
    @translate ? hash_to_translation(wrap_lines).join : wrap_lines.join
  end

  def pretext(lines)
    if @translate
      hash_value = lines.join.hash
      sentences_to_translate[hash_value] = lines.join
      hash_value
    else
      @pretext
    end
  end

  def set_translate_opt(opt)
    case opt
    when Hash, FalseClass, NilClass
      opt
    when TrueClass
      {to: :ja}
    else
      raise ArgumentError
    end
  end

  def sentences_to_translate
    @sentences_to_translate ||= {}
  end

  def hash_to_translation(lines)
    translates = request_translation
    lines.map { |line| translates[line] || line }
  end

  def request_translation
    Mymemory.config.email = @email if @email
    res = {}
    thread_with(sentences_to_translate) do |k, text|
      begin
        timeout(@timeout) { res[k] = ::Mymemory.translate(text, @translate) }
      rescue Timeout::Error
        res[k] = @pretext
      end
    end
    res
  end

  def thread_with(hash)
    mem = []
    hash.map do |*item|
      Thread.new(*item) do |*_item|
        mem << yield(*_item)
      end
    end.each(&:join)
    mem
  end
end
