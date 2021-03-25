# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Spree::Variant, type: :model do
  let(:variant) { build_stubbed :variant }

  describe "#pretty_name" do
    subject(:pretty_name) { variant.pretty_name }

    it 'includes the product and options', :aggregate_failures do
      expect(pretty_name).to match variant.name
      expect(pretty_name).to match variant.options_text
    end
  end
end
