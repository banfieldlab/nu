require 'spec_helper'

describe MgNu::Parser::Fasta do
  before do
    @ff = MgNu::Parser::Fasta.new('data/test.fasta')
  end

  it 'should be know about attributes' do
    expect(@ff).to be_a(MgNu::Parser::Fasta)
    expect(@ff).to respond_to(:filename)
    expect(@ff).to respond_to(:each)
  end

  it 'should yield MgNu::Sequence::Fasta objects' do
    count = 0
    @ff.each do |f|
      expect(f).to be_a(MgNu::Sequence::Fasta)
      expect(f.sequence).not_to be_nil
      expect(f.header).not_to be_nil
      count += 1
    end
    expect(count).to eq(2)
  end

  it 'should concatenate multiline seqeunces' do
    @ff.each do |f|
      expect(f.sequence).not_to match(/\n/)
    end
  end
end

describe 'MgNu::Parser::Fasta with a fasta quality file' do
  before do
    @ff = MgNu::Parser::Fasta.new('data/testqual.fasta.qual', true)
  end

  it 'should correctly format quality strings' do
    @ff.each do |f|
      expect(f).to be_a(MgNu::Sequence::Fasta)
      expect(f).to respond_to(:header)
      expect(f).to respond_to(:sequence)
      expect(f.sequence).not_to be_nil
      expect(f.header).not_to be_nil
      str = f.to_s
      temp = str.split(/\n/)
      temp.shift # drop header line

      temp.each do |qline|
        expect(qline.split(/\s+/).length).to eq(17)
      end
    end
  end
end
