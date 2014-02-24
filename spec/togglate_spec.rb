require 'spec_helper'

describe Togglate do
  it 'should have a version number' do
    Togglate::VERSION.should_not be_nil
  end
end

describe Togglate::BlockWrapper do
  before do
    @text = "#title\n\n\ntext\n"
  end

  describe "#chunk_by_space" do
    it "returns chunked array" do
      wrapper = Togglate::BlockWrapper.new(@text)
      exp = [[false, ["#title\n"]],
             [true, ["\n", "\n"]],
             [false, ["text\n"]]]
      expect(wrapper.send(:chunk_by_space).to_a).to eq exp
    end
  end

  describe "#wrap_with" do
    it "returns wrapped text" do
      wrapper = Togglate::BlockWrapper.new(@text)
      chunks = wrapper.send(:chunk_by_space)
      exp = "[translation here]\n\n<!--original\n#title\n-->\n\n\n[translation here]\n\n<!--original\ntext\n-->\n"
      expect(wrapper.send(:wrap_with, chunks)).to eq exp
    end

    context "optional pre-text" do
      it "returns wrapped text with a custom text" do
        wrapper = Togglate::BlockWrapper.new(@text, pretext:"-- translation --")
        chunks = wrapper.send(:chunk_by_space)
        exp = "-- translation --\n\n<!--original\n"
        expect(wrapper.send(:wrap_with, chunks)).to match(exp)
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

    describe "#wrap_with" do
      it "sets translated sentences to pretext" do
        text = "#Title\n\nProgramming is fun.\n"
        opt = {from: :en, to: :ja}
        wrapper = Togglate::BlockWrapper.new(text, translate:opt)
        chunks = wrapper.send(:chunk_by_space)
        exp = /プログラミングは楽しいです.*<!--original/m
        expect(wrapper.send(:wrap_with, chunks)).to match(exp)
      end
    end
  end
end
