require "thor"

module Togglate
  class CLI < Thor
    desc "create FILE", "Create a base file for translation from a original file"
    option :code, aliases:'-c', default:true, type: :boolean
    option :method, aliases:'-m', default:'hover', desc:"any of 'hover' or 'toggle'"
    option :target, type: :string
    option :show_text, aliases:'-s', type: :string
    option :hide_text, aliases:'-h', type: :string
    option :wrapper, type: :array
    option :wrap_exceptions, type: :array
    def create(file)
      opts = options.inject({}) { |h, (k,v)| h[k.intern] = v; h } # symbolize keys
      if wrapper = options[:wrapper]
        wrapper.map! { |wr| wr.gsub(/\\n/, "\n") }
        opts.update(wrapper:wrapper)
      end
      puts Togglate.create(file, opts)
    end
  end
end
