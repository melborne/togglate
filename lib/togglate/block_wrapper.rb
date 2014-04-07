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
    @indent_re = /^\s{4,}\S/
  end

  def run
    wrap_chunks build_chunks
  end

  private
  def build_chunks
    in_block = false
    in_indent = false
    @text.each_line.chunk do |line|
      in_block = in_block?(line, in_block)
      prev_indent = in_indent
      in_indent = in_indented_block?(line, in_indent, in_block)

      ( blank_line?(line) ||
        true_to_false?(prev_indent, in_indent) ) &&
        !in_block && !in_indent
    end
  end

  def blank_line?(line, blank_line_re:/^\s*$/)
    !line.match(blank_line_re).nil?
  end

  def true_to_false?(prev, curr)
    # this captures the in-out state transition on 4 space block.
    # then handle it as blank line.
    [prev, curr] == [true, false]
  end

  def in_block?(line, in_block, block_tags:[/^```/, /^{%/])
    return !in_block if block_tags.any? { |ex| line.match ex }
    in_block
  end

  def in_indented_block?(line, status, in_block)
    return false if in_block
    if !status && line.match(@indent_re) ||
        status && line.match(/^\s{,3}\S/)
      !status
    else
      status
    end
  end

  def wrap_chunks(chunks)
    wrap_lines = chunks.inject([]) do |m, (is_blank_line, lines)|
      if is_blank_line || exception_block?(lines.first)
        m.push *lines
      else
        m.push pretext(lines)
        m.push "\n\n", @wrapper[0], "\n", *lines, @wrapper[1], "\n"
      end
    end
    @translate ? hash_to_translation(wrap_lines).join : wrap_lines.join
  end

  def exception_block?(line)
    if @wrap_exceptions.empty?
      false
    else
      (@wrap_exceptions + [@indent_re]).any? { |ex| line.match ex }
    end
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
