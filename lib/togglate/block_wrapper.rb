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
    wrap_lines = chunks.inject([]) do |m, (is_space, lines)|
      if is_space || @wrap_exceptions.any? { |ex| lines[0].match ex }
        m.push *lines
      else
        if @translate
          hash_value = lines.join.hash
          sentences_to_translate[hash_value] = lines.join
          m.push hash_value
        else
          m.push @pretext
        end
        m.push "\n\n", @wrapper[0], "\n", *lines, @wrapper[1], "\n"
      end
    end
    @translate ? hash_to_translation(wrap_lines).join : wrap_lines.join
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
    lines.map do |line|
      if res = translates[line]
        res
      else
        line
      end
    end
  end

  using CoreExt

  def request_translation
    res = {}
    sentences_to_translate.thread_with do |k, text|
      res[k] = ::Mymemory.translate(text, @translate)
    end
    res
  end
end
