require 'spec_helper'

describe Togglate::BlockWrapper do
  before do
    @text = "#title\n\n\ntext\n"
  end

  describe "#build_chunks" do
    it "returns chunked array" do
      wrapper = Togglate::BlockWrapper.new(@text)
      exp = [[false, ["#title\n"]],
             [true, ["\n", "\n"]],
             [false, ["text\n"]]]
      expect(wrapper.send(:build_chunks).to_a).to eq exp
    end

    context "with liquid tags" do
      it "wraps liquid tag blocks as target blocks" do
        text =<<-EOS
#title

text

{% highlight bash %}
bash code

here
{% endhighlight %}
EOS

        wrapper = Togglate::BlockWrapper.new(text)
        exp = [[false, ["#title\n"]],
               [true,  ["\n"]],
               [false, ["text\n"]],
               [true,  ["\n"]],
               [false, ["{% highlight bash %}\n",
                        "bash code\n",
                        "\n",
                        "here\n",
                        "{% endhighlight %}\n"]]]
        expect(wrapper.send(:build_chunks).to_a).to eq exp
      end
    end

    context "with fenced code blocks" do
      it "wraps fenced code blocks as target blocks" do
        text = <<-EOS
# title

text

``` ruby
puts 'Hello'

p :World
```
EOS
        wrapper = Togglate::BlockWrapper.new(text)
        exp = [
          [false, ["# title\n"]],
          [true,  ["\n"]],
          [false, ["text\n"]],
          [true,  ["\n"]],
          [false, ["``` ruby\n", "puts 'Hello'\n", "\n", "p :World\n", "```\n"]]
        ]
        expect(wrapper.send(:build_chunks).to_a).to eq exp
      end
    end

    context "with 4 indented code blocks" do
      it "wraps them as target blocks" do
        text =<<-EOS
#title

    tell application 'Foo'

      beep

    end tell

  line
EOS

        wrapper = Togglate::BlockWrapper.new(text)
        exp = [[false, ["#title\n"]],
               [true,  ["\n"]],
               [false, ["    tell application 'Foo'\n",
                        "\n",
                        "      beep\n",
                        "\n",
                        "    end tell\n",
                        "\n"]],
                [true,  ["  line\n"]]]
        expect(wrapper.send(:build_chunks).to_a).to eq exp
      end
    end
  end

  describe "#wrap_chunks" do
    it "returns wrapped text" do
      wrapper = Togglate::BlockWrapper.new(@text)
      chunks = wrapper.send(:build_chunks)
      exp = "[translation here]\n\n<!--original\n#title\n-->\n\n\n[translation here]\n\n<!--original\ntext\n-->\n"
      expect(wrapper.send(:wrap_chunks, chunks)).to eq exp
    end

    context "optional pre-text" do
      it "returns wrapped text with a custom text" do
        wrapper = Togglate::BlockWrapper.new(@text, pretext:"-- translation --")
        chunks = wrapper.send(:build_chunks)
        exp = "-- translation --\n\n<!--original\n"
        expect(wrapper.send(:wrap_chunks, chunks)).to match(exp)
      end
    end
  end

  describe "Embed results of MyMemory translation service" do
    describe ".new with translate option" do
      it "sets en-ja option when passed true" do
        wrapper = Togglate::BlockWrapper.new('I need you.', translate:true)
        opt = {to: :ja}
        expect(wrapper.instance_variable_get('@translate')).to eq opt
      end

      it "sets passed options" do
        opt = {from: :en, to: :it, email:true}
        wrapper = Togglate::BlockWrapper.new('I need you.', translate:opt)
        expect(wrapper.instance_variable_get('@translate')).to eq opt
      end
    end

    describe "#wrap_chunks" do
      it "sets translated sentences to pretext" do
        text = "#Title\n\nProgramming is fun.\n"
        opt = {from: :en, to: :ja}
        wrapper = Togglate::BlockWrapper.new(text, translate:opt)
        chunks = wrapper.send(:build_chunks)
        exp = /プログラミングは楽しいです.*<!--original/m
        expect(wrapper.send(:wrap_chunks, chunks)).to match(exp)
      end
    end
  end
end
