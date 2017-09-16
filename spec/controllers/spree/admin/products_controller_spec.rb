require 'rails_helper'

RSpec.describe Spree::Admin::ProductsController, type: :controller do
  routes { Spree::Core::Engine.routes }
  #extend Spree::TestingSupport::AuthorizationHelpers::Request
  stub_authorization!

  # regression test for https://github.com/spree/spree/issues/1370
  context "adding properties to a product" do
    let!(:product) { create(:product) }
    specify do
      put :update, params: { id: product.to_param, product: { subscribable: true } }
      expect(response).to be_redirect
      expect(product.master.reload).to be_subscribable
    end
  end
end