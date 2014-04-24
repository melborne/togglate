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
               [:_alone,  ["  line\n"]]]
        expect(wrapper.send(:build_chunks).to_a).to eq exp
      end
    end

    context "with html tag blocks" do
      it "wraps them as target blocks" do
        text =<<-EOS
#title

<table>
  <tr><th>Header</th></tr>

  <tr><td>Data</td></tr>
</table>
EOS

        wrapper = Togglate::BlockWrapper.new(text)
        exp = [[false, ["#title\n"]],
               [true,  ["\n"]],
               [false, ["<table>\n",
                        "  <tr><th>Header</th></tr>\n",
                        "\n",
                        "  <tr><td>Data</td></tr>\n",
                        "</table>\n"]]]
        expect(wrapper.send(:build_chunks).to_a).to eq exp
      end

      it "wraps irregularly indented tags" do
        text =<<-EOS
#title

<table>
<tr><th>Header</th></tr>

<tr><td>Data</td></tr>
</table>

sentence
EOS

        wrapper = Togglate::BlockWrapper.new(text)
        exp = [[false, ["#title\n"]],
               [true,  ["\n"]],
               [false, ["<table>\n",
                        "<tr><th>Header</th></tr>\n",
                        "\n",
                        "<tr><td>Data</td></tr>\n",
                        "</table>\n"]],
               [true, ["\n"]],
               [false, ["sentence\n"]]]
        expect(wrapper.send(:build_chunks).to_a).to eq exp
      end

      it "wraps html block which includes 4 or more indented parts" do
        text =<<-EOS
<table>
  <tr>
    <th>
      Header
    </th>
  </tr>
</table>
EOS

        wrapper = Togglate::BlockWrapper.new(text)
        exp = [[false, ["<table>\n",
                        "  <tr>\n",
                        "    <th>\n",
                        "      Header\n",
                        "    </th>\n",
                        "  </tr>\n",
                        "</table>\n"]]]
        expect(wrapper.send(:build_chunks).to_a).to eq exp
      end

      it "wraps self-closing tags as target blocks" do
        text =<<-EOS
#title

<!-- comment -->

<br />

<img src="img.png" />

<hr />
EOS

        wrapper = Togglate::BlockWrapper.new(text)
        exp = [[false, ["#title\n"]],
               [true,  ["\n"]],
               [false, ["<!-- comment -->\n"]],
               [true,  ["\n"]],
               [false, ["<br />\n"]],
               [true,  ["\n"]],
               [false, ["<img src=\"img.png\" />\n"]],
               [true,  ["\n"]],
               [false, ["<hr />\n"]]]
        expect(wrapper.send(:build_chunks).to_a).to eq exp
      end
    end
  end

  describe "#wrap_chunks" do
    before do
      @text =<<-EOS
#title

text
EOS
    end

    it "returns wrapped text" do
      wrapper = Togglate::BlockWrapper.new(@text)
      chunks = wrapper.send(:build_chunks)
      exp =<<-EOS
[translation here]

<!--original
#title
-->

[translation here]

<!--original
text
-->
EOS
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

    context "text has 4 indented code blocks" do
      it "wraps sentences after the code blocks correctly" do
        text =<<-EOS
#title

    % echo hello

line
line2
EOS
        wrapper = Togglate::BlockWrapper.new(text)
        chunks = wrapper.send(:build_chunks)
        exp =<<-EOS
[translation here]

<!--original
#title
-->

[translation here]

<!--original
    % echo hello

-->

[translation here]

<!--original
line
line2
-->
EOS
        expect(wrapper.send(:wrap_chunks, chunks)).to eq exp
      end

      it "wraps sentences after the code blocks correctly 2" do
        text =<<-EOS
#title

    % echo hello

line

line2
EOS
        wrapper = Togglate::BlockWrapper.new(text)
        chunks = wrapper.send(:build_chunks)
        exp =<<-EOS
[translation here]

<!--original
#title
-->

[translation here]

<!--original
    % echo hello

-->

[translation here]

<!--original
line
-->

[translation here]

<!--original
line2
-->
EOS
        expect(wrapper.send(:wrap_chunks, chunks)).to eq exp
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
