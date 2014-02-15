require "thor"

module Togglate
  class CLI < Thor
    desc "create FILE", "Create a base file for translation from a original file"
    option :method, aliases:'-m', default:'hover', desc:"any of 'hover' or 'toggle'"
    option :code_embed, aliases:'-c', default:true, type: :boolean
    option :toggle_link_text, type: :array
    option :wrap_exceptions, type: :array
    def create(file)
      opts = options.inject({}) { |h, (k,v)| h[k.intern] = v; h } # symbolize keys
      puts Togglate.create(file, opts)
    end
  end
end
