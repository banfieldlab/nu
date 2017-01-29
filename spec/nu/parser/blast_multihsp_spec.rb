require 'spec_helper'

describe 'Nu::Parser::Blast parsing a multihsp report' do
  before do
    @report = Nu::Parser::Blast.new('data/multihsp.blast', 0)
    @queries = @report.parse
    @query = @queries[0]
    @sbjct = @query.sbjcts[0]
  end
  
  it 'should have one query' do
    expect(@queries.length).to eq(1)
  end

  it 'should have 1 sbjcts for query 1' do
    expect(@queries[0].sbjcts.length).to eq(1)
  end

  it 'should have the correct sbjct_id for query 1' do
    expect(@sbjct.sbjct_id).to eq('Contig17100_1_5')
  end

  it 'should have the correct sbjct length' do
    expect(@sbjct.length).to eq(2190)
  end

  it 'should have a non-empty array of Hsps' do
    expect(@sbjct.hsps.length).to be > 0
  end

  describe 'Query 1, Sbjct 1, Hsp 1' do
    before do
      @hsp = @sbjct.hsps[0]
    end

    it 'should have a known query sequence' do
      str = 'gatcgacggcaagct'
      expect(@hsp.query_sequence).to eq(str)
    end

    it 'should have a known midline' do
      str = '|||||||||||||||'
      expect(@hsp.midline).to eq(str)
    end

    it 'should have a known sbjct sequence' do
      str = 'gatcgacggcaagct'
      expect(@hsp.sbjct_sequence).to eq(str)
    end

    it 'should have the correct bit score and raw score' do
      expect(@hsp.bit_score).to eq(30.2)
      expect(@hsp.score).to eq(15)
    end

    it 'should have a correct evalue' do
      expect(@hsp.evalue).to eq(0.12)
    end
  end # end - hsp 1 context

  describe 'Query 1, Sbjct 1, Hsp 4' do
    before do
      @hsp = @sbjct.hsps[3]
    end

    it 'should have a known query sequence' do
      str = 'gatcgataaagtg'
      expect(@hsp.query_sequence).to eq(str)
    end

    it 'should have a known midline' do
      str = '|||||||||||||'
      expect(@hsp.midline).to eq(str)
    end

    it 'should have a known sbjct sequence' do
      str = 'gatcgataaagtg'
      expect(@hsp.sbjct_sequence).to eq(str)
    end

    it 'should have the correct bit score and raw score' do
      expect(@hsp.bit_score).to eq(26.3)
      expect(@hsp.score).to eq(13)
    end

    it 'should have a correct evalue' do
      expect(@hsp.evalue).to eq(1.8)
    end

    it 'should have the correct query start/stop positions' do
      expect(@hsp.query_from).to eq(64175)
      expect(@hsp.query_to).to eq(64187)
    end

    it 'should have the correct sbjct start/stop positions' do
      expect(@hsp.sbjct_from).to eq(1566)
      expect(@hsp.sbjct_to).to eq(1578)
    end
  end
end
