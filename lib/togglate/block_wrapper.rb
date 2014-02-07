class Togglate::BlockWrapper
  def initialize(text,
                 space_re:/^\s*$/,
                 chunk_exceptions:[/^```/],
                 wrapper:%w(```original ```),
                 wrap_exceptions:[/^```/, /^\s{4}/])
    @text = text
    @space_re = space_re
    @chunk_exceptions = chunk_exceptions
    @wrapper = wrapper
    @wrap_exceptions = wrap_exceptions
  end

  def run
    wrap_with chunk_by_space
  end

  private
  def chunk_by_space
    in_block = false
    @text.each_line.chunk do |line|
      in_block = !in_block if @chunk_exceptions.any? { |ex| line.match ex }
      !line.match(@space_re).nil? && !in_block
    end
  end

  def wrap_with(chunks)
    chunks.inject([]) do |m, (is_space, lines)|
      if is_space || @wrap_exceptions.any? { |ex| lines[0].match ex }
        m.push *lines
      else
        m.push @wrapper[0], "\n", *lines, @wrapper[1], "\n"
      end
    end.join
  end
end
