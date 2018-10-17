require 'spec_helper'

describe MgNu::Parser do
  class DummyClass
    include MgNu::Loggable
    include MgNu::Parser
  end

  before(:each) do
    @dummy_class = DummyClass.new
    @dummy_class.extend(MgNu::Parser)
  end

  it 'can be included' do
    expect(@dummy_class).to respond_to(:parse_until)
    expect(@dummy_class).to respond_to(:strip_quotes)
  end

  it 'can strip quotes' do
    expect(@dummy_class.strip_quotes('"ABC"')).to eq('ABC')
  end
end
