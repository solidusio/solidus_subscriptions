# frozen_string_literal: true

RSpec.describe SolidusSubscriptions::Tracking::Serializer::SubscriptionLineItem do
  describe '.serialize' do
    it 'serializes into a hash' do
      create(:store)
      subscription_line_item = build_stubbed(:subscription_line_item)

      expect(described_class.serialize(subscription_line_item)).to be_instance_of(Hash)
    end
  end
end
