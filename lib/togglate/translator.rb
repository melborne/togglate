module MymemoryAdapter
  def translate(text)
    ::Mymemory.translate(text, opts)
  end

  def email=(email)
    ::Mymemory.config.email = email
  end

  def opts
    opt_parse(@opts)
  end
  
  private
  def opt_parse(opts)
    case opts
    when Hash, FalseClass, NilClass
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
