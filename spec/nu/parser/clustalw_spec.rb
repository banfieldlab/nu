require 'spec_helper'

describe Nu::Parser::ClustalW do
  before do
    @clw = Nu::Parser::ClustalW.new('data/clustalw_test.aln')
  end

  it 'should be a correct object' do
    expect(@clw).to be_a(Nu::Parser::ClustalW)
    expect(@clw).to respond_to(:file)
    expect(@clw).to respond_to(:buffer)
    expect(@clw).to respond_to(:alignment)
  end

  it 'should be parsed after creation' do
    expect(@clw.buffer.length).to be > 0
  end

  it 'return a Nu::Alignment' do
    expect(@clw.alignment).to be_a(Nu::Alignment)
  end

  describe 'Nu::Alignment' do
    before do
      @a = @clw.alignment
    end

    it 'should act like an array' do
      count = 0
      @a.each do |s|
        count += 1
        expect(s).to be_a(String)
      end
      expect(count).to eq(7)
    end

    it 'can iterate by column' do
      count = 0
      @a.each_position do |pos|
        count += 1
      end
      expect(count).to eq(@a.length)
      expect(@a.each_position).to be_a(Array)
    end

    it 'can iterate of a range of columns' do
      count = 0
      @a.each_position(10..20) do |pos|
        count += 1
      end
      r = []
      (10..20).each {|x| r << x }
      expect(count).to eq(r.length)
    end

    it 'can fetch a single position in in the alignment' do
      m = nil
      @a.each_position(3) do |pos|
        m = pos 
      end
      expect(m).to be_a(Array)
      expect(m[0]).to eq('K')
      expect(m[1]).to eq('N')
    end

    it 'should behave like an enumerable' do
      expect(@a[10..20]).to be_a(Array)
      m = @a[3]
      expect(m).to be_a(Array)
      expect(m[0][0]).to eq('K')
      expect(m[0][1]).to eq('N')
    end

    it 'reports the correct match length' do
      expect(@a.match.length).to eq(@a.length)
    end

    it 'reports correct match data using a range operator' do
      expect(@a.match(107..112)).to eq('. : .*')
    end

    it 'reports single position match values correctly' do
      expect(@a.match(3)).to eq(' ')
      expect(@a.match(107)).to eq('.')
      expect(@a.match(108)).to eq(' ')
      expect(@a.match(109)).to eq(':')
      expect(@a.match(112)).to eq('*')
    end
  end
end
