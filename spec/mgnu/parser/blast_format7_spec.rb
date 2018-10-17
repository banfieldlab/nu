require 'spec_helper'

describe 'MgNu::Parser::Blast format7' do
  before do
    @report = MgNu::Parser::Blast.new('data/test.blast.xml')
    @queries = @report.parse
  end

  it 'should correctly parse' do
    expect(@queries.length).to eq(8)
  end

  it 'should report the correct information for queries' do
    query_10 = @queries.select{|x| x.number == 10}[0]
    expect(query_10).to be_a(MgNu::Parser::Blast::Query)
    expect(query_10.number).to eq(10)
    expect(query_10.sbjcts.length).to eq(7)

    sbjct_6 = query_10.sbjcts.select{|x| x.number == 6}[0]
    expect(sbjct_6.sbjct_id).to eq('gi|31376410|gb|AC096051.7|')
    expect(sbjct_6.hsps.length).to eq(1)
    expect(sbjct_6.hsps[0].evalue).to eq(2.97608)
  end
end
