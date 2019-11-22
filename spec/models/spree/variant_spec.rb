require 'spec_helper'

RSpec.describe Spree::Variant, type: :model do
  let(:variant) { build_stubbed :variant }

  describe "#pretty_name" do
    subject { variant.pretty_name }

    it 'includes the product and options', :aggregate_failures do
      expect(subject).to match variant.name
      expect(subject).to match variant.options_text
    end
  end
end
