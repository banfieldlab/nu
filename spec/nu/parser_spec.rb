require 'spec_helper'

describe Nu::Parser do
  class DummyClass
    include Nu::Loggable
    include Nu::Parser
  end

  before(:each) do
    @dummy_class = DummyClass.new
    @dummy_class.extend(Nu::Parser)
  end

  it 'can be included' do
    expect(@dummy_class).to respond_to(:parse_until)
    expect(@dummy_class).to respond_to(:strip_quotes)
  end

  it 'can strip quotes' do
    expect(@dummy_class.strip_quotes("\"ABC\"")).to eq("ABC")
  end
end
