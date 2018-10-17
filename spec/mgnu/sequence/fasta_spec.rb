require 'spec_helper'

describe MgNu::Sequence::Fasta do
  before do
    @fs = MgNu::Sequence::Fasta.new(:header => 'test', :sequence => 'atgcatgcatgcatgcaaaa')
  end

  it 'knows about attributes' do
    expect(@fs).to be_a(MgNu::Sequence::Fasta)
    expect(@fs).to respond_to(:value)
    expect(@fs).to respond_to(:sequence)
    expect(@fs).to respond_to(:type)
    expect(@fs).to respond_to(:reverse_complement)
    expect(@fs).to respond_to(:translate)
    expect(@fs).to respond_to(:levenshtein_distance)
    expect(@fs).to respond_to(:distance)
    expect(@fs).to respond_to(:percent_identity)
    expect(@fs).to respond_to(:identity)
  end

  it 'can represent itself as a string' do
    expect(@fs.to_s).to eq(">test\natgcatgcatgcatgcaaaa")

    # create a long sequence
    @fs.sequence << 'atgcatgcatgcatgcaaaaatgcatgcatgcatgcaaaaatgcatgcatgcatgcaaaaatgcatgatgcatgcatgcatgcaaaaatgcatgcatgcatgcaaaaatgcatgcatgcatgcaaaaatgcatgcatgcatgcaaaa'

    # fasta entry with 60 (the default) chars/row
    result = ">test\n"
    result << "atgcatgcatgcatgcaaaaatgcatgcatgcatgcaaaaatgcatgcatgcatgcaaaa\n"
    result << "atgcatgcatgcatgcaaaaatgcatgatgcatgcatgcatgcaaaaatgcatgcatgca\n"
    result << "tgcaaaaatgcatgcatgcatgcaaaaatgcatgcatgcatgcaaaa\n"
    expect(@fs.to_s).to eq(result)

    # create a fasta entry with 50 chars/row
    result = ">test\n"
    result << "atgcatgcatgcatgcaaaaatgcatgcatgcatgcaaaaatgcatgcat\n"
    result << "gcatgcaaaaatgcatgcatgcatgcaaaaatgcatgatgcatgcatgca\n"
    result << "tgcaaaaatgcatgcatgcatgcaaaaatgcatgcatgcatgcaaaaatg\n"
    result << "catgcatgcatgcaaaa\n"
    expect(@fs.to_s(50)).to eq(result)
  end

  it 'can revcomp' do
    expect(@fs.reverse_complement).to eq('ttttgcatgcatgcatgcat')
  end

  it 'cat split on N' do
    fs = MgNu::Sequence::Fasta.new(
      :header => 'test',
      :sequence   => 'atgcatgcatgcatgcaaaaNNNNNNNNNNNNNNNNNNNNNNatgcatgcatgcatgcaaaa'
    )
    expect(fs.split_on_n.split("\n>").length).to eq(2)

    fs = MgNu::Sequence::Fasta.new(
      :header => 'test',
      :sequence   => 'atgcatgcatgcatgcaaaannnnnnnnnnnnnnnnnnnnnnatgcatgcatgcatgcaaaa'
    )
    expect(fs.split_on_n.split("\n>").length).to eq(2)
  end
end
