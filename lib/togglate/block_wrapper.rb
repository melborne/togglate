class Togglate::BlockWrapper
  def initialize(text,
                 wrapper:%W([translation\ here]\n\n<!--original -->),
                 wrap_exceptions:[],
                 **opts)
    @text = text
    @wrapper = wrapper
    @wrap_exceptions = wrap_exceptions
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
        m.push @wrapper[0], "\n", *lines, @wrapper[1], "\n"
      end
    end.join
  end
end
