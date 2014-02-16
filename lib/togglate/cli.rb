require "thor"

module Togglate
  class CLI < Thor
    desc "create FILE", "Create a base file for translation from a original file"
    option :method, aliases:'-m', default:'hover', desc:"Select a display method: 'hover' or 'toggle'"
    option :embed_code, aliases:'-e', default:true, type: :boolean, desc:"Enable code embeding to false"
    option :toggle_link_text, type: :array, default:["*", "hide"]
    option :code_block, aliases:'-c', default:false, type: :boolean, desc:"Enable code blocks not to be wrapped"
    def create(file)
      opts = options.inject({}) { |h, (k,v)| h[k.intern] = v; h } # symbolize keys
      opts.update(wrap_exceptions:[/^```/, /^ {4}/]) if opts[:code_block]
      puts Togglate.create(file, opts)
    end

    desc "version", "Show Togglate version"
    def version
      puts "Togglate #{Togglate::VERSION} (c) 2014 kyoendo"
    end
    map "-v" => :version

  end
end
