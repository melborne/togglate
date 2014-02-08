require "thor"

module Togglate
  class CLI < Thor
    desc "create FILE", "Create a base file for translation from a original file"
    option :toggle_code, default:true
    option :target, default:%($("pre[lang='original']"))
    option :show_text, default:"*"
    option :hide_text, default:"hide"
    option :wrapper, default:%w(```original ```)
    def create(file)
      opts = options.inject({}) { |h, (k,v)| h[k.intern] = v; h } # symbolize keys
      puts Togglate.create(file, opts)
    end
  end
end
