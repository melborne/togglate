require 'spec_helper'

describe Togglate::SizedString do
  let(:sizedString) { Togglate::SizedString }
  before do
    @ss = sizedString.new('hello', 15)
  end

  describe "#<<" do
    context "under the max" do
      before do
        @ss << ', world'
      end
      
      it "returns a SizedString object" do
        expect(@ss).to be_instance_of(sizedString)
      end

      it "concats strings" do
        expect(@ss.to_s).to eq "hello, world"
      end
    end

    context "over the max" do
      it "raises SizeFullError" do
        expect { @ss << ', world of error' }.to raise_error sizedString::SizeFullError
      end
    end
  end

  describe "#joint=" do
    it "sets joint" do
      @ss.joint = '//'
      expect(@ss.joint).to eq '//'
      @ss << 'bye'
      expect(@ss.to_s).to eq 'hello//bye'
    end
  end

  describe "#split" do
    it "splits a string with joint" do
      @ss.joint = '//'
      @ss << 'world'
      expect(@ss.split).to eq ['hello', 'world']
    end
  end

  describe "#max" do
    context "set max exceed the current string length" do
      it "raises SizeFullError" do
        expect { @ss.max = 3 }.to raise_error sizedString::SizeFullError
      end
    end
  end
end
