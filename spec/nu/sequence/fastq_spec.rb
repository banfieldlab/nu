require 'spec_helper'
describe Nu::Sequence::Fastq do
  before do
    @fs = Nu::Sequence::Fastq.new(
      :header => 'HWI-EAS385_0092_FC:5:1:2510:1094#0/1',
      :sequence => 'CAAAGGTGATTCATTTAACTGGCAATCNNNNNNNCGACCGTCGTTTTTTGTGCCT',
      :quality  => 'eWddWa`cbeffff__afff_ggggWWBBBBBBBUXW\YZcffbef_fbcZZa^^'
    )
  end

  it 'knows about attributes' do
    expect(@fs).to be_a(Nu::Sequence::Fastq)
    expect(@fs).to respond_to(:value)
    expect(@fs).to respond_to(:value=)
    expect(@fs).to respond_to(:sequence)
    expect(@fs).to respond_to(:sequence=)
    expect(@fs).to respond_to(:qualhdr)
    expect(@fs).to respond_to(:quality)
    expect(@fs).to respond_to(:unpack_quality)
  end

  it 'can represent itself as a string' do
    result = <<EOT
@HWI-EAS385_0092_FC:5:1:2510:1094#0/1
CAAAGGTGATTCATTTAACTGGCAATCNNNNNNNCGACCGTCGTTTTTTGTGCCT
+
eWddWa`cbeffff__afff_ggggWWBBBBBBBUXW\\YZcffbef_fbcZZa^^
EOT
    expect(@fs.to_s).to eq(result)
  end
end
