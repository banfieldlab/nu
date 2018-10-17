require 'spec_helper'
describe MgNu::Sequence do
  before do
    @s = MgNu::Sequence.new(:type => 'dna', :sequence => 'atgcatgcatgcatgcaaaa')
  end

  it 'knows about attributes' do
    expect(@s).to be_a(MgNu::Sequence)
    expect(@s).to respond_to(:value)
    expect(@s).to respond_to(:value=)
    expect(@s).to respond_to(:sequence)
    expect(@s).to respond_to(:sequence=)
    expect(@s).to respond_to(:type)
    expect(@s).to respond_to(:reverse_complement)
    expect(@s).to respond_to(:translate)
    expect(@s).to respond_to(:levenshtein_distance)
    expect(@s).to respond_to(:distance)
    expect(@s).to respond_to(:percent_identity)
    expect(@s).to respond_to(:identity)
  end

  it 'can determine dna/rna/protein' do
    expect(@s.dna?).to be(true)
    expect(@s.rna?).to be(false)
    expect(@s.aa?).to be(false)
    expect(@s.aminoacid?).to be(false)
    expect(@s.protein?).to be(false)
  end

  it 'can reverse complement' do
    expect(@s.reverse_complement).to eq('ttttgcatgcatgcatgcat')
  end

  it 'sequence unchanged after reverse complement' do
    @s.reverse_complement
    expect(@s.sequence).to eq('atgcatgcatgcatgcaaaa')
  end

  it 'sequence changed after reverse complement!' do
    @s.reverse_complement!
    expect(@s.sequence).to eq('ttttgcatgcatgcatgcat')
  end

  it 'can be changed' do
    @s.value = 'atgc'
    expect(@s.value).to eq('atgc')
    @s.sequence = 'tacg'
    expect(@s.sequence).to eq('tacg')
  end

  it 'can be translated' do
    expect(@s.translate).to eq('MHACMQ')
    expect(@s.translate(1)).to eq('MHACMQ')
    expect(@s.translate(2)).to eq('CMHACK')
    expect(@s.translate(3)).to eq('ACMHAK')
    expect(@s.translate(-1)).to eq('FCMHAC')
  end

  it 'can compute a levenshtein distance' do
    @s.sequence = 'kitten'
    other = MgNu::Sequence.new(:value => 'knitting')
    expect(@s.distance('knitting')).to eq(3)
    expect(@s.distance(other)).to eq(3)
  end

  it 'can determine percent identity' do
    @s.sequence = 'acgt'
    other = MgNu::Sequence.new(:value => 'acgg')
    expect(@s.identity('acgt')).to eq(1.0)
    expect(@s.identity('acgg')).to eq(0.75)
    expect(@s.identity(other)).to eq(0.75)
  end

  it 'can find blocks of N characters' do
    sequence_with_nblocks = MgNu::Sequence.new(:type     => 'dna',
                                             :sequence => 'atgnnnncatgnnnnnnnncatgcnnnnnnnatgcnnnnaaaa')
    pieces = sequence_with_nblocks.nblocks(3)
    expect(pieces.length).to eq(5)
    expect(pieces).to eq([1..3, 8..11, 20..24, 32..35, 40..43])
  end
end
