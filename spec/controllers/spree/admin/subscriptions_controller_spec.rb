require 'rails_helper'

RSpec.describe Spree::Admin::SubscriptionsController, type: :controller do
  routes { Spree::Core::Engine.routes }
  stub_authorization!

  describe 'get /admin/subscriptions' do
    subject { get :index }

    it { is_expected.to be_successful }
    it { is_expected.to render_template :index }
  end
end
