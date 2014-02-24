$LOAD_PATH.unshift File.expand_path('../../lib', __FILE__)
require 'togglate'
require "stringio"
require "fakeweb"

class String
  def ~
    margin = scan(/^ +/).map(&:size).min
    gsub(/^ {#{margin}}/, '')
  end
end

module Helpers
  def source_root
    File.join(File.dirname(__FILE__), 'fixtures')
  end
end

RSpec.configure do |c|
  c.include Helpers
  c.before do
    FakeWeb.clean_registry
    body = File.read(File.join(source_root, 'translated_text.json'))
    FakeWeb.register_uri(:get, %r(http://mymemory\.translated\.net), body:body)
  end
end
