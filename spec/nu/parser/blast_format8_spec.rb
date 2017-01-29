require 'spec_helper'

describe 'Nu::Parser::Blast format8' do
  before do
    @report = Nu::Parser::Blast.new('./data/test.blast.m8', 8)
    @queries = @report.parse
    expect(@report).to be_a(Nu::Parser::Blast)
  end

  it 'should correctly parse' do
    expect(@queries.length).to eq(2)
  end

  it 'should report the correct information for queries' do
    expect(@queries[0].sbjcts.length).to eq(3)
    expect(@queries[1].sbjcts.length).to eq(3)

    expect(@queries[0].sbjcts[0].hsps.length).to eq(3)
    expect(@queries[0].sbjcts[1].hsps.length).to eq(3)
    expect(@queries[0].sbjcts[2].hsps.length).to eq(3)

    expect(@queries[1].sbjcts[0].hsps.length).to eq(8)
    expect(@queries[1].sbjcts[1].hsps.length).to eq(1)
    expect(@queries[1].sbjcts[2].hsps.length).to eq(1)
  end
end
