module Togglate
  class SizedString
    class SizeFullError < StandardError; end

    attr_reader :max
    attr_accessor :joint
    def initialize(str="", max=nil, joint:'')
      @max = max
      @joint = joint
      @strs = [str]
    end

    def <<(other)
      length = self.to_s.size + other.size
      validate_length(length) { @strs << other }
      self
    end

    def max=(n)
      validate_length(self.to_s.size, n) do
        @max = n
      end
    end

    def to_s
      @strs.join(@joint)
    end

    def split
      @strs
    end

    private
    def validate_length(length, max=@max)
      if max && length > max
        raise SizeFullError, "Exceed max size(#{@max_size})"
      end
      yield
    end
  end
end
