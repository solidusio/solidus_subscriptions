# frozen_string_literal: true

RSpec.describe SolidusSubscriptions::Tracking::Event::SkippedSubscription do
  describe '#name' do
    it 'returns the name of the event' do
      subscription = build_stubbed(:subscription)

      event = described_class.new(subscription: subscription)

      expect(event.name).to eq('Skipped Subscription')
    end
  end

  describe '#email' do
    it 'returns the email on the subscriber' do
      subscription = build_stubbed(:subscription)

      event = described_class.new(subscription: subscription)

      expect(event.email).to eq(subscription.user.email)
    end
  end

  describe '#customer_properties' do
    it 'returns the serialized customer information' do
      subscription = build_stubbed(:subscription)
      allow(SolidusTracking::Serializer::CustomerProperties).to receive(:serialize)
        .with(subscription.user)
        .and_return('$email' => subscription.user.email)

      event = described_class.new(subscription: subscription)

      expect(event.customer_properties).to match(a_hash_including('$email' => subscription.user.email))
    end
  end

  describe '#properties' do
    it 'includes properties from the waitlist serializer serializer' do
      subscription = build_stubbed(:subscription)
      allow(SolidusSubscriptions::Tracking::Serializer::Subscription).to receive(:serialize)
        .with(subscription)
        .and_return('Id' => 1)

      event = described_class.new(subscription: subscription)

      expect(event.properties).to include('Id' => 1)
    end

    it 'generates a unique ID' do
      subscription = build_stubbed(:subscription)

      event = described_class.new(subscription: subscription)

      expect(event.properties).to include('$event_id' => an_instance_of(String))
    end
  end

  describe '#time' do
    it "returns the serializer's last update time" do
      subscription = build_stubbed(:subscription)

      event = described_class.new(subscription: subscription)

      expect(event.time).to eq(subscription.updated_at)
    end
  end
end
