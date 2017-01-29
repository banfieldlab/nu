require 'spec_helper'

describe 'Nu::Parser::Blast parsing a oof report' do
  before do
    @report = Nu::Parser::Blast.new('data/test_blastx_oof.blast', 0)
    @queries = @report.parse
    @query = @queries[0]
  end

  it 'should have 1 query' do
    expect(@queries.length).to eq(1)
  end

  it 'should have 1 sbjcts for query 1' do
    expect(@query.sbjcts.length).to eq(1)
  end

  describe 'Query 1, Sbjct 1' do
    before do
      @sbjct = @query.sbjcts[0]
    end

    it 'should have the correct sbjct_id' do
      expect(@sbjct.sbjct_id).to eq('spe:Spro_0261')
    end

    it 'should have the correct length' do
      expect(@sbjct.length).to eq(729)
    end

    it 'should have a non-empty array of Hsps'do
      expect(@sbjct.hsps.length).to be > 0
    end

    describe 'Query 1, Sbjct 1, Hsp 1' do
      before do
        @hsp = @sbjct.hsps[0]
      end

      it 'should contain one frame-shift characters in the query sequence' do
        expect(@hsp.query_sequence.split(/\//).length).to be(2)
      end

      it 'should respond to query_frameshifts and return a hash with the correct key/value pair' do
        expect(@hsp).to respond_to(:query_frameshifts)
        expect(@hsp.query_frameshifts).to be_a(Hash)
        expect(@hsp.query_frameshifts.keys.length).to eq(1)
        expect(@hsp.query_frameshifts.keys[0]).to eq(576)
        expect(@hsp.query_frameshifts.values[0]).to eq(1)
      end
    end
  end
end
