require "thor"

module Togglate
  class CLI < Thor
    desc "create FILE", "Create a base file for translation from a original file"
    option :method, aliases:'-m', default:'hover', desc:"Select a display method: 'hover' or 'toggle'"
    option :embed_code, aliases:'-e', default:true, type: :boolean, desc:"Enable code embeding to false"
    option :toggle_link_text, type: :array, default:["*", "hide"]
    option :code_block, aliases:'-c', default:false, type: :boolean, desc:"Enable code blocks not to be wrapped"
    option :translate, aliases:'-t', type: :hash, default:{}, desc:"Embed machine translated text. ex.-t=to:ja"
    option :email, desc:"Passing a valid email extends a limit of Mymemory anonymous usage from 100 to 1000 requests/day"
    def create(file)
      text = File.read(file)
      opts = symbolize_keys(options)
      blocks = [/^```/, /^{%/]
      opts.update(wrap_exceptions:blocks) if opts[:code_block]
      opts.update(translate:nil) if opts[:translate].empty?
      puts Togglate.create(text, opts)
    rescue => e
      STDERR.puts "something go wrong. #{e}"
      exit
    end

    desc "append_code FILE", "Append a hover or toggle code to a FILE"
    option :method, aliases:'-m', default:'hover', desc:"Select a display method: 'hover' or 'toggle'"
    option :toggle_link_text, type: :array, default:["*", "hide"]
    def append_code(file)
      text = File.read(file)
      opts = symbolize_keys(options)
      method = opts.delete(:method)
      code = Togglate.append_code(method, opts)
      puts "#{text}\n#{code}"
    rescue => e
      STDERR.puts "something go wrong. #{e}"
      exit
    end

    desc "commentout FILE", "Extract commented contents from a FILE"
    option :remains, aliases:'-r', default:false, type: :boolean, desc:"Output remaining text after extraction of comments"
    option :tag, aliases:'-t', default:'original', desc:"Specify comment tag name"
    def commentout(file)
      text = File.read(file)
      comments, remains = Togglate.commentout(text, tag:options['tag'])
      puts options['remains'] ? remains : comments
    rescue => e
      STDERR.puts "something go wrong. #{e}"
      exit
    end

    desc "version", "Show Togglate version"
    def version
      puts "Togglate #{Togglate::VERSION} (c) 2014 kyoendo"
    end
    map "-v" => :version

    no_tasks do
      def symbolize_keys(options)
        options.inject({}) do |h, (k,v)|
          h[k.intern] =
            case v
            when Hash then symbolize_keys(v)
            else v
            end
          h
        end
      end
    end
  end
end
