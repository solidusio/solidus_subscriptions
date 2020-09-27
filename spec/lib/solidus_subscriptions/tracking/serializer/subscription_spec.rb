# frozen_string_literal: true

RSpec.describe SolidusSubscriptions::Tracking::Serializer::Subscription do
  describe '.serialize' do
    it 'serializes into a hash' do
      subscription = build_stubbed(:subscription)

      expect(described_class.serialize(subscription)).to be_instance_of(Hash)
    end
  end
end
