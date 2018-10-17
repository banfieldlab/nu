require 'spec_helper'

describe 'MgNu::Parser::Blast format0' do
  before do
    @report = MgNu::Parser::Blast.new('data/test.blast', 0)
  end

  it 'knows about attributes' do
    expect(@report).to be_a(MgNu::Parser::Blast)
    expect(@report).to respond_to(:parse)
  end

  describe 'after calling parse' do
    before do
      @queries = @report.parse
    end
    
    it 'should have the correct number of queries' do
      expect(@queries.length).to eq(3)
    end

    it 'should contain the correct first query' do
      expect(@queries[0].query_id).to eq('test')
    end

    it 'should have the correct number of sbjcts for query 1' do
      expect(@queries[0].sbjcts.length).to eq(10)
    end

    it 'should have the correct number of sbjcts for query 2' do
      expect(@queries[1].sbjcts.length).to eq(10)
    end

    describe 'the third query' do
      before do
        @query = @queries[2]
      end

      it 'should have a correct database name' do
        expect(@query.database).to eq('NCBI Protein Reference Sequences')
      end

      it 'should respond to sbjcts' do
        expect(@query).to respond_to(:sbjcts)
        expect(@query.sbjcts).to be_a(Array)
        expect(@query.sbjcts.length).to eq(10)
      end
      
      describe 'the first sbjct of the third query' do
        before do
          @sbjct = @query.sbjcts[0]
        end

        it 'should have number 1' do
          expect(@sbjct.number).to eq(1)
        end

        it 'should have the correct sbjct name' do
          expect(@sbjct.sbjct_id).to eq('ref|ZP_02544218.1|')
        end

        it 'should have the correct length' do
          expect(@sbjct.length).to eq(121)
        end

        it 'should have a non-empty array of Hsps' do
          expect(@sbjct.hsps.length).to be > 0
        end

        it 'should respond to best_hsp and return an Hsp object' do
          expect(@query.sbjcts[0]).to respond_to(:best_hsp)
          expect(@sbjct.best_hsp).to be_a(MgNu::Parser::Blast::Hsp)
        end

        describe 'the first hsp of the first sbjct of the third query' do
          before do
            @hsp = @sbjct.hsps[0]
          end

          it 'should have a known query sequence' do
            str = 'MKKIL-ATIXSAALYGLP----AXVMAQGITDDLSNLGLNXFGNETNLGTNIALIGTIARIINILLGFLGVLAVILVLWGGFKWMTAAGDEAKIGEAKKLMGAGVIGLVIILAAFAIASFVVNQL'
            expect(@hsp.query_sequence).to eq(str)
          end

          it 'should have a known midline' do
            str = 'MKK L A + S  +   P    A V A   ++  S +     GN T+L +       I  I+NILL   G +AVI+++ GG +++ ++GD  ++  AK  +   VIGL++++ A+AI +FVV  +'
            expect(@hsp.midline).to eq(str)
          end

          it 'should have a known sbjct sequence' do
            str = 'MKKFLIAALVSLGIVVTPLAMDAPVFANAKSEVTSGVSSVNDGNSTDLPS------FITNIVNILLFLAGAVAVIVIIIGGIRYVMSSGDAGQVQSAKNTILYAVIGLIVVIMAYAIVNFVVTNV'
            expect(@hsp.sbjct_sequence).to eq(str)
          end

          it 'should have the correct bit score and raw score' do
            expect(@hsp.bit_score).to eq(62.0)
            expect(@hsp.score).to eq(149)
          end

          it 'should have a correct evalue' do
            expect(@hsp.evalue).to eq(1e-10)
          end

          it 'should have a non-nil query|sbjct_from and _to values' do
            expect(@hsp.query_from).not_to be_nil
            expect(@hsp.query_to).not_to be_nil
            expect(@hsp.sbjct_from).not_to be_nil
            expect(@hsp.sbjct_to).not_to be_nil
          end
        end
      end
    end
  end
end
