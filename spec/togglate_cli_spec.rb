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
    context "wrap_exceptions option" do
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

    context "code and method option" do
      it "adds hover code to the output" do
        Togglate::CLI.start(['create', 'README.md'])
        expect($stdout.string).to match(/<script.*nodeType==8.*<\/script>/m)
      end

      it "adds toggle code to the output" do
        Togglate::CLI.start(['create', 'README.md', '--method=toggle'])
        expect($stdout.string).to match(/<script.*slideDown.*<\/script>/m)
      end

      it "not adds code to the output" do
        Togglate::CLI.start(['create', 'README.md', '--code-embed=false'])
        expect($stdout.string).not_to match(/<script.*nodeType==8.*<\/script>/m)
        expect($stdout.string).not_to match(/<script.*createToggle.*<\/script>/m)
      end
    end

    context "toggle_link_text option" do
      it "sets texts for toggle link" do
        Togglate::CLI.start(['create', 'README.md', '-m=toggle', '--toggle-link-text', 'showme', 'closeme'])
        expect($stdout.string).to match(/<script.*showme.*<\/script>/m)
      end
    end
  end
end
