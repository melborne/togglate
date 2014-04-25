module MymemoryAdapter
  def translate(text)
    ::Mymemory.translate(text, opts)
  end

  def opts
    opt_parse(@opts)
  end
  
  private
  def opt_parse(opts)
    case opts
    when Hash
      if email = opts.delete(:email)
        ::Mymemory.config.email = email
      end
      opts
    when FalseClass, NilClass
      opts
    when TrueClass
      {to: :ja}
    else
      raise ArgumentError, "Invalid options passed"
    end
  end
end

class Togglate::Translator
  include MymemoryAdapter
  
  def initialize(opts)
    @opts = opts
  end

  def translate(text)
    super
  end
end
