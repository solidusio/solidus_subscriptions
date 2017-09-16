require "rails_helper"

RSpec.describe Spree::Product, type: :model do
  let(:product) { build_stubbed :product }

  describe "#subscribable=" do
    it do
      product.subscribable = true
      expect(product.master).to be_subscribable
    end
  end
end
