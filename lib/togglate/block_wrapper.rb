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
  end

  def run
    wrap_with chunk_by_space
  end

  private
  def chunk_by_space(block_tags:[/^```/], space_re:/^\s*$/)
    in_block = false
    @text.each_line.chunk do |line|
      in_block = !in_block if block_tags.any? { |ex| line.match ex }
      !line.match(space_re).nil? && !in_block
    end
  end

  def wrap_with(chunks)
    chunks.inject([]) do |m, (is_space, lines)|
      if is_space || @wrap_exceptions.any? { |ex| lines[0].match ex }
        m.push *lines
      else
        unless @pretext.nil? || @pretext.empty?
          set_translated_text_to_pretext(lines) if @translate
          m.push @pretext, "\n\n"
        end
        m.push @wrapper[0], "\n", *lines, @wrapper[1], "\n"
      end
    end.join
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

  def set_translated_text_to_pretext(lines)
    @original_pretext ||= @pretext.dup
    @pretext = request_translated_text(lines.join, @translate)
  end

  def request_translated_text(text, option)
    ::Mymemory.translate(text, option)
  end
end
