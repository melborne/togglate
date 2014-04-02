require 'spec_helper'

describe Togglate do
  it 'should have a version number' do
    Togglate::VERSION.should_not be_nil
  end

  describe ".commentout" do
    before do
      @original, @translated = begin
        %w(README.md README.ja.md).map do |f|
          File.read File.join(source_root, f)
        end
      end
    end

    it "extract comments from a text" do
      comments, remains = Togglate.commentout(@translated)
      expect(@original == comments).to be_true
    end
  end
end
