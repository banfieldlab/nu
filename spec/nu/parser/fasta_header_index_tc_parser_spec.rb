require 'spec_helper'

describe Nu::Parser::FastaHeaderIndex do
  before do
    @ff = Nu::Parser::FastaHeaderIndex.new('data/test.fasta')
  end

  it 'should know about attributes' do
    expect(@ff).to be_a(Nu::Parser::FastaHeaderIndex)
    expect(File.exist?('data/test.fasta.hdr.tch')).to be(true)
    expect(@ff).to respond_to(:filename)
  end

  it 'should allow hash-like access using Fasta header names' do
    expect(@ff['name1']).to eq('description1')
  end

  after(:each) do
    @ff.close
  end

  after do
    File.delete('data/test.fasta.hdr.tch') if File.exist?('data/test.fasta.hdr.tch')
  end
end
