# frozen_string_literal: true

RSpec.describe SolidusSubscriptions::PermissionSets::SubscriptionManagement do
  it 'is allowed to manage all subscriptions' do
    user = create(:user)
    subscription = create(:subscription)

    ability = Spree::Ability.new(user)
    permission_set = described_class.new(ability)
    permission_set.activate!

    expect(ability).to be_able_to(:manage, subscription)
  end

  it "is allowed to manage all line items" do
    user = create(:user)
    subscription = create(:subscription)
    line_item = create(:subscription_line_item, subscription: subscription)

    ability = Spree::Ability.new(user)
    permission_set = described_class.new(ability)
    permission_set.activate!

    expect(ability).to be_able_to(:manage, line_item)
  end
end
