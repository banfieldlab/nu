require 'spec_helper'

describe MgNu::Parser::FastaIndex do
  before do
    @ff = MgNu::Parser::FastaIndex.new('data/test.fasta')
  end

  it 'should know about attributes' do
    expect(@ff).to be_a(MgNu::Parser::FastaIndex)
    expect(File.exist?('data/test.fasta.tch')).to be(true)
    expect(@ff).to respond_to(:filename)
  end

  it 'should allow hash-like access using Fasta header names' do
    expect(@ff['name1'].sequence).to eq('ACCG')
  end

  after(:each) do
    @ff.close
  end

  after do
    File.delete('data/test.fasta.tch') if File.exist?('data/test.fasta.tch')
  end
end
