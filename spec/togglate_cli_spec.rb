require 'spec_helper'

describe Togglate::CLI do
  before do
    $stdout, $stderr = StringIO.new, StringIO.new
    @original_dir = Dir.pwd
    Dir.chdir(source_root)
  end

  after do
    $stdout, $stderr = STDOUT, STDERR
    Dir.chdir(@original_dir)
  end

  describe "#create" do
    context "wrap_exceptions" do
      it "wraps sentences" do
        Togglate::CLI.start(['create', 'README.md'])
        expect($stdout.string).to match(/<!--original\n# Title\n-->/)
      end

      it "wraps code blocks" do
        Togglate::CLI.start(['create', 'README.md'])
        expect($stdout.string).to match(/<!--original\n\s{4}% ruby title\.rb\n-->/)
      end

      it "wraps gfm code blocks" do
        Togglate::CLI.start(['create', 'README.md'])
        expect($stdout.string).to match(/<!--original.*```ruby.*```\n-->/m)
      end

      it "wraps sentences except code blocks" do
        Togglate::CLI.start(['create', 'README.md', '--wrap_exceptions', [/^\s{4}/]])
        expect($stdout.string).to match(/^\n\s{4}% ruby title\.rb\n$/)
      end

      it "wraps sentences except gfm code blocks" do
        Togglate::CLI.start(['create', 'README.md', '--wrap_exceptions', [/^```/]])
        expect($stdout.string).to match(/^\n```ruby.*```\n$/m)
      end
    end
  end

  
end