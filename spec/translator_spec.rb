require 'spec_helper'

describe Togglate::Translator do
  let(:translator) { Togglate::Translator }

  describe ".new with translate option" do
    it "sets en-ja option when passed true" do
      tr = translator.new(true)
      opt = {to: :ja}
      expect(tr.opts).to eq opt
    end

    it "sets passed options" do
      opt = {from: :en, to: :it, email:true}
      tr = translator.new(opt)
      wrapper = Togglate::BlockWrapper.new('I need you.', translate:opt)
      expect(tr.opts).to eq opt
    end
  end

  describe ".translate" do
    before do
      opt = {from: :en, to: :ja}
      @translator = translator.new(opt)
    end

    it "translates passed text" do
      text = "Programming is fun."
      ext = "プログラミングは楽しいです。"
      expect(@translator.translate(text)).to eq ext
    end
  end
end