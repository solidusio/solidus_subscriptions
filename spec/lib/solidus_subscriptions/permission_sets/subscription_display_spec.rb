# frozen_string_literal: true

require 'rails_helper'
require "cancan/matchers"

RSpec.describe SolidusSubscriptions::PermissionSets::SubscriptionDisplay do
  let(:ability) { DummyAbility.new }

  subject { ability }

  context 'when activated' do
    before do
      described_class.new(ability).activate!
    end

    it { is_expected.to be_able_to(:display, SolidusSubscriptions::Subscription) }
  end

  context 'when not activated' do
    it { is_expected.not_to be_able_to(:display, SolidusSubscriptions::Subscription) }
  end
end
