require 'spec_helper'

RSpec.describe SolidusSubscriptions::Spree::User::HaveManySubscriptions, type: :model do
  subject { Spree::User.new }

  it { is_expected.to have_many :subscriptions }
  it { is_expected.to accept_nested_attributes_for :subscriptions }

  describe '#subscriptions_attributes=' do
    it 'throws a deprecation warning' do
      allow(::Spree::Deprecation).to receive(:warn)

      subject.subscriptions_attributes = [{ interval_length: 2 }]

      expect(::Spree::Deprecation)
        .to have_received(:warn)
        .with(/Creating or updating subscriptions through Spree::User nested attributes is deprecated/)
    end
  end
end
